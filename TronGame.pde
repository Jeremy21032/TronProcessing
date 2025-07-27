class TronGame {
  ArrayList<PVector> trail1;
  ArrayList<PVector> trail2;
  PVector pos1, pos2;
  float angle1, angle2;
  int dir1, dir2;
  Moto moto1, moto2;
  color color1, color2;
  boolean gameOver = false;
  boolean gameStarted = false;
  String loser = "";

  // Variables 3D
  float speed = 4;
  float cameraY = 0;
  float cameraAngle = 0;
  float glowIntensity = 0;
  float cameraDistance = 50;
  float cameraHeight = 30;
  float cameraAngleOffset = 0.3;
  ArrayList<PVector> particles;
  float time = 0;
  int framesToNextTurn1 = 0;
  int framesToNextTurn2 = 0;

  TronGame(color c) {
    color1 = c;
    color2 = color(255, 120, 0); // naranja clásico para la segunda moto
    reset();
    moto1 = new Moto(pos1, angle1, color1);
    moto2 = new Moto(pos2, angle2, color2);
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
    draw3DTrail(trail1, color1);
    draw3DTrail(trail2, color2);
    draw3DBike(moto1, trail1.size());
    draw3DBike(moto2, trail2.size());
    updateParticles();
    drawParticles();
    drawWaitingUI();
  }

  void updateGame() {
    // Movimiento automático moto1
    float vx1 = 0, vy1 = 0;
    if (dir1 == 0) { vx1 = 0; vy1 = -speed; angle1 = -HALF_PI; }
    else if (dir1 == 1) { vx1 = speed; vy1 = 0; angle1 = 0; }
    else if (dir1 == 2) { vx1 = 0; vy1 = speed; angle1 = HALF_PI; }
    else if (dir1 == 3) { vx1 = -speed; vy1 = 0; angle1 = PI; }
    pos1.add(vx1, vy1);
    if (framesToNextTurn1 <= 0) {
      int giro = int(random(2));
      if (dir1 == 0 || dir1 == 2) dir1 = (giro == 0) ? 1 : 3;
      else dir1 = (giro == 0) ? 0 : 2;
      framesToNextTurn1 = int(random(40, 120));
    } else framesToNextTurn1--;
    moto1.pos = pos1;
    moto1.angle = angle1;
    if (trail1.size() == 0 || dist(pos1.x, pos1.y, trail1.get(trail1.size()-1).x, trail1.get(trail1.size()-1).y) > 2) {
      trail1.add(pos1.copy());
    }

    // Movimiento automático moto2
    float vx2 = 0, vy2 = 0;
    if (dir2 == 0) { vx2 = 0; vy2 = -speed; angle2 = -HALF_PI; }
    else if (dir2 == 1) { vx2 = speed; vy2 = 0; angle2 = 0; }
    else if (dir2 == 2) { vx2 = 0; vy2 = speed; angle2 = HALF_PI; }
    else if (dir2 == 3) { vx2 = -speed; vy2 = 0; angle2 = PI; }
    pos2.add(vx2, vy2);
    if (framesToNextTurn2 <= 0) {
      int giro = int(random(2));
      if (dir2 == 0 || dir2 == 2) dir2 = (giro == 0) ? 1 : 3;
      else dir2 = (giro == 0) ? 0 : 2;
      framesToNextTurn2 = int(random(40, 120));
    } else framesToNextTurn2--;
    moto2.pos = pos2;
    moto2.angle = angle2;
    if (trail2.size() == 0 || dist(pos2.x, pos2.y, trail2.get(trail2.size()-1).x, trail2.get(trail2.size()-1).y) > 2) {
      trail2.add(pos2.copy());
    }

    // Colisión moto1 con su propio rastro
    for (int i = 0; i < trail1.size()-20; i++) {
      PVector t = trail1.get(i);
      if (dist(pos1.x, pos1.y, t.x, t.y) < 8) { gameOver = true; loser = "Moto 1"; return; }
    }
    // Colisión moto2 con su propio rastro
    for (int i = 0; i < trail2.size()-20; i++) {
      PVector t = trail2.get(i);
      if (dist(pos2.x, pos2.y, t.x, t.y) < 8) { gameOver = true; loser = "Moto 2"; return; }
    }
    // Colisión cruzada
    for (int i = 0; i < trail2.size(); i++) {
      PVector t = trail2.get(i);
      if (dist(pos1.x, pos1.y, t.x, t.y) < 8) { gameOver = true; loser = "Moto 1"; return; }
    }
    for (int i = 0; i < trail1.size(); i++) {
      PVector t = trail1.get(i);
      if (dist(pos2.x, pos2.y, t.x, t.y) < 8) { gameOver = true; loser = "Moto 2"; return; }
    }

    // Efectos visuales
    time += 0.1;
    cameraY = sin(time * 0.5) * 20;
    cameraAngle = sin(time * 0.3) * 0.1;
    glowIntensity = sin(time * 2) * 0.3 + 0.7;
  }

  void drawGame() {
    setupFirstPersonView();
    draw3DTerrain();
    draw3DTrail(trail1, color1);
    draw3DTrail(trail2, color2);
    draw3DBike(moto1, trail1.size());
    draw3DBike(moto2, trail2.size());
    if (gameOver) drawGameOver();
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
    float camX = pos1.x - width/2;
    float camY = pos1.y - height/2;
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
  
  void draw3DTrail(ArrayList<PVector> trail, color c) {
    if (trail.size() < 2) return;
    
    pushMatrix();
    translate(-width/2, -height/2, 0);
    
    // Rastro principal 3D
    strokeWeight(12);
    stroke(c, 150 * glowIntensity);
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
    stroke(c, 50 * glowIntensity);
    beginShape();
    for (int i = 0; i < trail.size(); i++) {
      PVector p = trail.get(i);
      float z = i * 0.5;
      vertex(p.x, p.y, z);
    }
    endShape();
    
    popMatrix();
  }
  
  void draw3DBike(Moto m, int trailSize) {
    pushMatrix();
    translate(-width/2, -height/2, 0);
    m.draw3D(trailSize * 0.5);
    // Efecto de partículas de escape (si quieres mantenerlo)
    if (gameStarted) {
      for (int i = 0; i < 3; i++) {
        float px = pos1.x + random(-5, 5);
        float py = pos1.y + random(-5, 5);
        float pz = trailSize * 0.5 + random(-2, 2);
        fill(color1, 100);
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
        pos1.x + random(-20, 20),
        pos1.y + random(-20, 20),
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
    fill(color1);
    text("Presiona ESPACIO para comenzar", width/2, height/2);
    textSize(16);
    fill(color1);
    text("Modo espectador: duelo de motos automáticas", width/2, height/2 + 40);
    
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
    fill(color1);
    text("¡GAME OVER!", width/2, height/2 - 50);
    textSize(20);
    fill(color1);
    text("Perdió: " + loser, width/2, height/2 + 20);
    
    hint(ENABLE_DEPTH_TEST);
  }
  
  void drawUI() {
    // Resetear vista 2D para UI
    hint(DISABLE_DEPTH_TEST);
    camera();
    
    fill(color1);
    textSize(16);
    textAlign(LEFT);
    text("Modo espectador: duelo de motos automáticas", 10, 20);
    
    hint(ENABLE_DEPTH_TEST);
  }

  // Eliminar keyPressed: el usuario no puede controlar nada
  void keyPressed(char key, int keyCode) {
    // No hacer nada
  }
  
  void startGame() {
    gameStarted = true;
  }

  void reset() {
    // Moto 1: izquierda abajo, va hacia arriba
    pos1 = new PVector(width/3, height-100);
    angle1 = -HALF_PI;
    dir1 = 0;
    // Moto 2: derecha abajo, va hacia arriba
    pos2 = new PVector(2*width/3, height-100);
    angle2 = -HALF_PI;
    dir2 = 0;
    trail1 = new ArrayList<PVector>();
    trail2 = new ArrayList<PVector>();
    trail1.add(pos1.copy());
    trail2.add(pos2.copy());
    gameOver = false;
    gameStarted = false;
    particles = new ArrayList<PVector>();
    time = 0;
    framesToNextTurn1 = int(random(40, 120));
    framesToNextTurn2 = int(random(40, 120));
    loser = "";
}
} 