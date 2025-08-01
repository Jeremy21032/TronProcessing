class TronGameControlado {
  ArrayList<PVector> trail;
  PVector pos;
  float angle;
  float speed;
  float maxSpeed = 7;
  float minSpeed = 2;
  boolean gameOver = false;
  boolean gameStarted = false;

  int currentDir = 0;

  color myColor;

  float cameraY = 0;
  float cameraAngle = 0;
  float terrainHeight = 0;
  float glowIntensity = 0;

  float cameraDistance = 50;
  float cameraHeight = 30;
  float cameraAngleOffset = 0.3;

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
    float vx = 0;
    float vy = 0;
    if (currentDir == 0) {
      vx = 0;
      vy = -speed;
      angle = -HALF_PI;
    } else if (currentDir == 1) {
      vx = speed;
      vy = 0;
      angle = 0;
    } else if (currentDir == 2) {
      vx = 0;
      vy = speed;
      angle = HALF_PI;
    } else if (currentDir == 3) {
      vx = -speed;
      vy = 0;
      angle = PI;
    }
    pos.add(vx, vy);

    time += 0.1;
    cameraY = sin(time * 0.5) * 20;
    cameraAngle = sin(time * 0.3) * 0.1;
    glowIntensity = sin(time * 2) * 0.3 + 0.7;

    if (trail.size() == 0 || dist(pos.x, pos.y, trail.get(trail.size()-1).x, trail.get(trail.size()-1).y) > 2) {
      trail.add(pos.copy());
    }

    for (int i = 0; i < trail.size()-20; i++) {
      PVector trailPos = trail.get(i);
      if (dist(pos.x, pos.y, trailPos.x, trailPos.y) < 8) {
        gameOver = true;
        return;
      }
    }
  }

  void drawGame() {
    setupFirstPersonView();
    draw3DTerrain();
    draw3DTrail();
    draw3DBike();
    updateParticles();
    drawParticles();
    
    if (gameOver) {
      drawGameOver();
    }
    
    drawUI();
  }
  
  void setupFirstPersonView() {
    perspective(PI/3.0, float(width)/float(height), 10, 2000);
    
    translate(width/2, height/2, 0);
    
    rotateX(-cameraAngleOffset + cameraAngle);
    rotateY(0.1);
    
    float camX = pos.x - width/2;
    float camY = pos.y - height/2;
    float camZ = -cameraDistance;
    float camYOffset = -cameraHeight;
    
    translate(-camX, -camY + camYOffset, camZ);
  }
  
  void draw3DTerrain() {
    pushMatrix();
    translate(0, 200, 0);
    rotateX(PI/2);
    stroke(255, 255, 255, 80);
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
    
    strokeWeight(12);
    stroke(myColor, 150 * glowIntensity);
    noFill();
    
    beginShape();
    for (int i = 0; i < trail.size(); i++) {
      PVector p = trail.get(i);
      float z = i * 0.5;
      vertex(p.x, p.y, z);
    }
    endShape();
    
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
    
    pushMatrix();
    rotateZ(angle);
    
    fill(myColor, 200 * glowIntensity);
    noStroke();
    box(20, 8, 6);
    
    fill(50, 50, 50);
    translate(-8, 0, 0);
    sphere(4);
    translate(16, 0, 0);
    sphere(4);
    
    fill(255, 255, 255, 100 * glowIntensity);
    translate(-8, -2, 3);
    sphere(2);
    
    popMatrix();
    
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
    
    if (gameStarted && random(1) < 0.3) {
      particles.add(new PVector(
        pos.x + random(-20, 20),
        pos.y + random(-20, 20),
        random(-50, 50)
      ));
    }
    
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

    if (currentDir == 0 || currentDir == 2) {
      if (keyCode == LEFT) {
        currentDir = 3;
      } else if (keyCode == RIGHT) {
        currentDir = 1;
      } else if (keyCode == UP) {
        speed = min(speed + 0.5, maxSpeed);
      } else if (keyCode == DOWN) {
        speed = max(speed - 0.5, minSpeed);
      }
    } else if (currentDir == 1 || currentDir == 3) {
      if (keyCode == UP) {
        currentDir = 0;
      } else if (keyCode == DOWN) {
        currentDir = 2;
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