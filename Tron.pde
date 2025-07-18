TronLogo logo;
StartButton startButton;
TronGame game;

// Estados: 0 = logo animado, 1 = esperando inicio, 2 = juego
int estado = 0;

color motoColor;
color[] colores = {color(0,255,255), color(255,120,0), color(0,255,100), color(255,0,200)};
int lastColorIndex = -1;

void setup() {
  size(800, 600, P3D);
  logo = new TronLogo(width/2, height/2 - 60, 400);
  startButton = new StartButton(width/2, height/2 + 100, 180, 50, "INICIAR");
  setRandomColor();
  game = new TronGame(motoColor);
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
  } else if (estado == 1) {
    game.drawWaitingScreen();
  } else if (estado == 2) {
    game.updateAndDraw();
  }
}

void mousePressed() {
  if (estado == 0 && logo.isFinished() && startButton.isMouseOver()) {
    estado = 1;
    setRandomColor();
    game = new TronGame(motoColor);
  }
}

void keyPressed() {
  if (estado == 1 && key == ' ') {
    estado = 2;
    game.startGame();
  } else if (estado == 2) {
    game.keyPressed(key, keyCode);
    if (game.gameOver && (key == 'r' || key == 'R')) {
      motoColor = color(255,120,0); // naranja clásico
      game = new TronGame(motoColor);
      estado = 1;
    }
  }
}
