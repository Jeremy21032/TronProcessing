class TronGameControlado {
  ArrayList<PVector> trail;
  PVector pos;
  float angle; // dirección de la moto (en radianes)
  float speed;
  float maxSpeed = 7;
  float minSpeed = 2;
  boolean gameOver = false;
  boolean gameStarted = false;

  // Dirección actual: 0=arriba, 1=derecha, 2=abajo, 3=izquierda
  int currentDir = 0;

  // Color de la moto y rastro
  color myColor;

  // Variables 3D
  float cameraY = 0;
  float cameraAngle = 0;
  float terrainHeight = 0;
  float glowIntensity = 0;

  // Cámara en primera persona
  float cameraDistance = 50;
  float cameraHeight = 30;
  float cameraAngleOffset = 0.3; // Diagonal hacia arriba

  // Efectos 3D
  ArrayList<PVector> particles;
  float time = 0;

  TronGameControlado(color c) {
    myColor = c;
    reset();
  }

  void updateAndDraw() {
    if (!gameOver && gameStarted) {
      updateGame();
    }
    drawGame();
  }

  void drawWaitingScreen() {
    setupFirstPersonView();
    draw3DTerrain();
    draw3DTrail();
    draw3DBike();
    updateParticles();
    drawParticles();
    drawWaitingUI();
  }

  void updateGame() {
    // Movimiento en la dirección actual (no suave)
    float vx = 0;
    float vy = 0;
    if (currentDir == 0) { // arriba
      vx = 0;
      vy = -speed;
      angle = -HALF_PI;
    } else if (currentDir == 1) { // derecha
      vx = speed;
      vy = 0;
      angle = 0;
    } else if (currentDir == 2) { // abajo
      vx = 0;
      vy = speed;
      angle = HALF_PI;
    } else if (currentDir == 3) { // izquierda
      vx = -speed;
      vy = 0;
      angle = PI;
    }
    pos.add(vx, vy);

    // Actualizar efectos 3D
    time += 0.1;
    cameraY = sin(time * 0.5) * 20;
    cameraAngle = sin(time * 0.3) * 0.1;
    glowIntensity = sin(time * 2) * 0.3 + 0.7;

    // Solo agrega al trail si avanzó suficiente
    if (trail.size() == 0 || dist(pos.x, pos.y, trail.get(trail.size()-1).x, trail.get(trail.size()-1).y) > 2) {
      trail.add(pos.copy());
    }

    // Sin límites de bordes

    // Colisión con el propio rastro
    for (int i = 0; i < trail.size()-20; i++) {
      PVector trailPos = trail.get(i);
      if (dist(pos.x, pos.y, trailPos.x, trailPos.y) < 8) {
        gameOver = true;
        return;
      }
    }
  }

  void drawGame() {
    // Configurar vista 3D en primera persona
    setupFirstPersonView();
    
    // Dibujar terreno 3D
    draw3DTerrain();
    
    // Dibuja el rastro 3D con glow
    draw3DTrail();
    
    // Dibuja la moto 3D
    draw3DBike();
    
    // Efectos de partículas
    updateParticles();
    drawParticles();
    
    // Game over overlay
    if (gameOver) {
      drawGameOver();
    }
    
    // UI overlay
    drawUI();
  }
  
  void setupFirstPersonView() {
    // Configurar perspectiva 3D
    perspective(PI/3.0, float(width)/float(height), 10, 2000);
    
    // Posicionar cámara en primera persona diagonal
    translate(width/2, height/2, 0);
    
    // Rotar para vista diagonal hacia arriba
    rotateX(-cameraAngleOffset + cameraAngle);
    rotateY(0.1);
    
    // Posicionar cámara detrás y arriba de la moto
    float camX = pos.x - width/2;
    float camY = pos.y - height/2;
    float camZ = -cameraDistance;
    float camYOffset = -cameraHeight;
    
    translate(-camX, -camY + camYOffset, camZ);
  }
  
  void draw3DTerrain() {
    // Terreno base
    pushMatrix();
    translate(0, 200, 0);
    rotateX(PI/2);
    // Grid 3D
    stroke(255, 255, 255, 80); // blanco
    strokeWeight(1);
    noFill();
    int gridSize = 50;
    int gridExtent = 20;
    for (int x = -gridExtent; x <= gridExtent; x++) {
      for (int z = -gridExtent; z <= gridExtent; z++) {
        float y = sin((x + time) * 0.1) * 5 + cos((z + time) * 0.1) * 5;
        if (x < gridExtent) {
          line(x * gridSize, y, z * gridSize, (x+1) * gridSize, y, z * gridSize);
        }
        if (z < gridExtent) {
          line(x * gridSize, y, z * gridSize, x * gridSize, y, (z+1) * gridSize);
        }
      }
    }
    popMatrix();
  }
  
  void draw3DTrail() {
    if (trail.size() < 2) return;
    
    pushMatrix();
    translate(-width/2, -height/2, 0);
    
    // Rastro principal 3D
    strokeWeight(12);
    stroke(myColor, 150 * glowIntensity);
    noFill();
    
    beginShape();
    for (int i = 0; i < trail.size(); i++) {
      PVector p = trail.get(i);
      float z = i * 0.5; // Profundidad basada en posición en el trail
      vertex(p.x, p.y, z);
    }
    endShape();
    
    // Efecto de glow 3D
    strokeWeight(20);
    stroke(myColor, 50 * glowIntensity);
    beginShape();
    for (int i = 0; i < trail.size(); i++) {
      PVector p = trail.get(i);
      float z = i * 0.5;
      vertex(p.x, p.y, z);
    }
    endShape();
    
    popMatrix();
  }
  
  void draw3DBike() {
    pushMatrix();
    translate(-width/2, -height/2, 0);
    translate(pos.x, pos.y, trail.size() * 0.5);
    
    // Cuerpo de la moto 3D
    pushMatrix();
    rotateZ(angle);
    
    // Motor principal
    fill(myColor, 200 * glowIntensity);
    noStroke();
    box(20, 8, 6);
    
    // Ruedas
    fill(50, 50, 50);
    translate(-8, 0, 0);
    sphere(4);
    translate(16, 0, 0);
    sphere(4);
    
    // Efecto de luz
    fill(255, 255, 255, 100 * glowIntensity);
    translate(-8, -2, 3);
    sphere(2);
    
    popMatrix();
    
    // Efecto de partículas de escape
    if (gameStarted) {
      for (int i = 0; i < 3; i++) {
        float px = pos.x + random(-5, 5);
        float py = pos.y + random(-5, 5);
        float pz = trail.size() * 0.5 + random(-2, 2);
        
        fill(myColor, 100);
        noStroke();
        pushMatrix();
        translate(px, py, pz);
        sphere(1);
        popMatrix();
      }
    }
    
    popMatrix();
  }
  
  void updateParticles() {
    if (particles == null) {
      particles = new ArrayList<PVector>();
    }
    
    // Agregar nuevas partículas solo si el juego está activo
    if (gameStarted && random(1) < 0.3) {
      particles.add(new PVector(
        pos.x + random(-20, 20),
        pos.y + random(-20, 20),
        random(-50, 50)
      ));
    }
    
    // Actualizar partículas existentes
    for (int i = particles.size() - 1; i >= 0; i--) {
      PVector p = particles.get(i);
      p.z += 2;
      if (p.z > 100) {
        particles.remove(i);
      }
    }
  }
  
  void drawParticles() {
    pushMatrix();
    translate(-width/2, -height/2, 0);
    
    for (PVector p : particles) {
      float alpha = map(p.z, -50, 100, 255, 0);
      fill(0, 255, 255, alpha);
      noStroke();
      pushMatrix();
      translate(p.x, p.y, p.z);
      sphere(2);
      popMatrix();
    }
    
    popMatrix();
  }
  
  void drawWaitingUI() {
    // Resetear vista 2D para overlay
    hint(DISABLE_DEPTH_TEST);
    camera();
    
    fill(0, 0, 0, 150);
    rect(0, 0, width, height);
    textAlign(CENTER, CENTER);
    textSize(24);
    fill(myColor);
    text("Presiona ESPACIO para comenzar", width/2, height/2);
    textSize(16);
    fill(myColor);
    text("Flechas: Izq/Der gira, Arriba acelera, Abajo frena", width/2, height/2 + 40);
    
    hint(ENABLE_DEPTH_TEST);
  }

  void drawGameOver() {
    // Resetear vista 2D para overlay
    hint(DISABLE_DEPTH_TEST);
    camera();
    
    fill(0, 0, 0, 200);
    rect(0, 0, width, height);
    textAlign(CENTER, CENTER);
    textSize(32);
    fill(myColor);
    text("¡GAME OVER!", width/2, height/2 - 50);
    textSize(16);
    fill(myColor);
    text("Presiona ESPACIO para reiniciar o R para cambiar color", width/2, height/2 + 20);
    
    hint(ENABLE_DEPTH_TEST);
  }
  
  void drawUI() {
    // Resetear vista 2D para UI
    hint(DISABLE_DEPTH_TEST);
    camera();
    
    fill(myColor);
    textSize(12);
    textAlign(LEFT);
    text("Flechas: Izq/Der gira, Arriba acelera, Abajo frena", 10, 20);
    text("Velocidad: " + nf(speed, 0, 1), 10, 40);
    
    hint(ENABLE_DEPTH_TEST);
  }

  void keyPressed(char key, int keyCode) {
    if (gameOver && key == ' ') {
      reset();
      return;
    }
    if (gameOver || !gameStarted) return;

    // Solo se puede girar en perpendicular a la dirección actual
    // 0=arriba, 1=derecha, 2=abajo, 3=izquierda
    if (currentDir == 0 || currentDir == 2) { // vertical
      if (keyCode == LEFT) {
        currentDir = 3; // izquierda
      } else if (keyCode == RIGHT) {
        currentDir = 1; // derecha
      } else if (keyCode == UP) {
        speed = min(speed + 0.5, maxSpeed);
      } else if (keyCode == DOWN) {
        speed = max(speed - 0.5, minSpeed);
      }
    } else if (currentDir == 1 || currentDir == 3) { // horizontal
      if (keyCode == UP) {
        currentDir = 0; // arriba
      } else if (keyCode == DOWN) {
        currentDir = 2; // abajo
      } else if (keyCode == LEFT) {
        speed = max(speed - 0.5, minSpeed);
      } else if (keyCode == RIGHT) {
        speed = min(speed + 0.5, maxSpeed);
      }
    }
  }
  
  void startGame() {
    gameStarted = true;
  }

  void reset() {
    pos = new PVector(width/2, height-100);
    currentDir = 0;
    angle = -HALF_PI;
    speed = 4;
    trail = new ArrayList<PVector>();
    trail.add(pos.copy());
    gameOver = false;
    gameStarted = false;
    particles = new ArrayList<PVector>();
    time = 0;
  }
} 