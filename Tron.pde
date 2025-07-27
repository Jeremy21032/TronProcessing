TronLogo logo;
StartButton startButton;
TronGameEspectador gameEspectador;
TronGameControlado gameControlado;
MenuButton espectadorButton;
MenuButton controladoButton;

// Estados: 0 = logo animado, 1 = esperando inicio, 2 = menú de selección, 3 = modo espectador, 4 = modo controlado
int estado = 0;

color motoColor;
color[] colores = {color(0,255,255), color(255,120,0), color(0,255,100), color(255,0,200)};
int lastColorIndex = -1;

void setup() {
  size(800, 600, P3D);
  logo = new TronLogo(width/2, height/2 - 60, 400);
  startButton = new StartButton(width/2, height/2 + 100, 180, 50, "INICIAR");
  espectadorButton = new MenuButton(width/2, height/2 - 50, 200, 60, "MODO ESPECTADOR");
  controladoButton = new MenuButton(width/2, height/2 + 50, 200, 60, "MODO CONTROLADO");
  setRandomColor();
  gameEspectador = new TronGameEspectador(motoColor);
  gameControlado = new TronGameControlado(motoColor);
}

void setRandomColor() {
  int idx;
  do {
    idx = int(random(colores.length));
  } while (idx == lastColorIndex);
  lastColorIndex = idx;
  motoColor = colores[idx];
}

void draw() {
  background(0);
  if (estado == 0) {
    logo.display();
    if (logo.isFinished()) {
      startButton.display();
    }
  } else if (estado == 2) {
    drawMenu();
  } else if (estado == 3) {
    gameEspectador.updateAndDraw();
  } else if (estado == 4) {
    gameControlado.updateAndDraw();
  }
}

void drawMenu() {
  // Fondo con efecto 3D
  pushMatrix();
  translate(width/2, height/2, 0);
  
  // Efecto de rotación sutil
  float time = frameCount * 0.02;
  rotateY(sin(time * 0.5) * 0.05);
  rotateX(sin(time * 0.3) * 0.02);
  
  // Título del menú
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(0, 255, 255, 255);
  text("SELECCIONA EL MODO", 0, -150);
  
  popMatrix();
  
  // Mostrar botones en 2D para que funcionen los clics
  espectadorButton.display();
  controladoButton.display();
}

void mousePressed() {
  if (estado == 0 && logo.isFinished() && startButton.isMouseOver()) {
    estado = 2; // Ir al menú de selección
  } else if (estado == 2) {
    if (espectadorButton.isMouseOver()) {
      estado = 3; // Modo espectador
      setRandomColor();
      gameEspectador = new TronGameEspectador(motoColor);
    } else if (controladoButton.isMouseOver()) {
      estado = 4; // Modo controlado
      setRandomColor();
      gameControlado = new TronGameControlado(motoColor);
    }
  }
}

void keyPressed() {
  if (estado == 3 && key == ' ') {
    gameEspectador.startGame();
  } else if (estado == 4 && key == ' ') {
    gameControlado.startGame();
  } else if (estado == 3) {
    gameEspectador.keyPressed(key, keyCode);
    if (gameEspectador.gameOver && (key == 'r' || key == 'R')) {
      motoColor = color(255,120,0); // naranja clásico
      gameEspectador = new TronGameEspectador(motoColor);
      estado = 2; // Volver al menú
    }
  } else if (estado == 4) {
    gameControlado.keyPressed(key, keyCode);
    if (gameControlado.gameOver && (key == 'r' || key == 'R')) {
      motoColor = color(255,120,0); // naranja clásico
      gameControlado = new TronGameControlado(motoColor);
      estado = 2; // Volver al menú
    }
  }
}
