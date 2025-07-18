class TronLogo {
  float x, y, s;
  ArrayList<PVector[]> segments; // Cada segmento es un par de puntos (inicio, fin)
  int currentSegment = 0;
  float progress = 0; // 0 a 1 en el segmento actual
  float speed = 4; // pixeles por frame
  boolean finished = false;
  
  // Variables 3D
  float time = 0;
  float glowIntensity = 0;

  TronLogo(float x, float y, float s) {
    this.x = x;
    this.y = y;
    this.s = s;
    segments = new ArrayList<PVector[]>();
    buildSegments();
  }

  void buildSegments() {
    // T
    segments.add(new PVector[] {new PVector(-270, 0), new PVector(-170, 0)}); // horizontal izquierda a derecha
    segments.add(new PVector[] {new PVector(-220, 0), new PVector(-220, -80)}); // vertical hacia arriba
    // R
    segments.add(new PVector[] {new PVector(-150, 40), new PVector(-150, -80)});
    segments.add(new PVector[] {new PVector(-150, -80), new PVector(-80, -80)});
    segments.add(new PVector[] {new PVector(-80, -80), new PVector(-80, -20)});
    segments.add(new PVector[] {new PVector(-80, -20), new PVector(-150, -20)});
    segments.add(new PVector[] {new PVector(-80, -20), new PVector(-60, 0)});
    // O (rectángulo)
    segments.add(new PVector[] {new PVector(-30, -80), new PVector(60, -80)});
    segments.add(new PVector[] {new PVector(60, -80), new PVector(60, 0)});
    segments.add(new PVector[] {new PVector(60, 0), new PVector(-30, 0)});
    segments.add(new PVector[] {new PVector(-30, 0), new PVector(-30, -80)});
    // N
    segments.add(new PVector[] {new PVector(90, 0), new PVector(90, -80)});
    segments.add(new PVector[] {new PVector(90, -80), new PVector(170, 0)});
    segments.add(new PVector[] {new PVector(170, 0), new PVector(170, -80)});
    // Apóstrofe
    segments.add(new PVector[] {new PVector(-290, -40), new PVector(-270, -40)});
    segments.add(new PVector[] {new PVector(-290, -40), new PVector(-290, -20)});
  }

  void display() {
    // Actualizar efectos 3D
    time += 0.05;
    glowIntensity = sin(time * 2) * 0.3 + 0.7;
    
    // Configurar vista 3D para el logo
    pushMatrix();
    translate(x, y, 0);
    float scaleF = s/600.0;
    scale(scaleF);
    
    // Efecto de rotación 3D sutil
    rotateY(sin(time * 0.5) * 0.1);
    rotateX(sin(time * 0.3) * 0.05);
    
    // 1. Dibuja todos los segmentos completados con efecto 3D
    for (int i = 0; i < currentSegment; i++) {
      PVector[] seg = segments.get(i);
      draw3DSegment(seg[0], seg[1]);
    }
    
    // 2. Dibuja el segmento actual (parcial) con efectos 3D
    if (!finished && currentSegment < segments.size()) {
      PVector[] seg = segments.get(currentSegment);
      PVector start = seg[0];
      PVector end = seg[1];
      float nx = lerp(start.x, end.x, progress);
      float ny = lerp(start.y, end.y, progress);
      PVector moto = new PVector(nx, ny);
      
      // Glow 3D para el segmento actual
      draw3DSegment(start, moto);
      
      // Moto 3D con rastro corto
      float trailLen = 24; // longitud del rastro
      float segLen = dist(start.x, start.y, moto.x, moto.y);
      float t0 = max(0, segLen - trailLen) / segLen;
      float tx = lerp(start.x, moto.x, t0);
      float ty = lerp(start.y, moto.y, t0);
      draw3DSegment(new PVector(tx, ty), moto);
      
      // Moto 3D
      draw3DBike(moto);
    }
    
    popMatrix();
    
    if (!finished) animate();
  }

  void draw3DSegment(PVector a, PVector b) {
    // Efecto de glow 3D
    strokeWeight(18);
    stroke(0, 255, 255, 90 * glowIntensity);
    line(a.x, a.y, b.x, b.y);
    
    // Línea principal 3D
    strokeWeight(8);
    stroke(180, 255, 255, 200 * glowIntensity);
    line(a.x, a.y, b.x, b.y);
    
    // Efecto de profundidad
    strokeWeight(4);
    stroke(0, 255, 255, 50 * glowIntensity);
    line(a.x + 2, a.y + 2, b.x + 2, b.y + 2);
  }
  
  void draw3DBike(PVector moto) {
    pushMatrix();
    translate(moto.x, moto.y, 0);
    
    // Cuerpo de la moto 3D
    noStroke();
    
    // Motor principal con glow
    for (int i = 18; i >= 8; i -= 2) {
      fill(0, 255, 255, map(i, 8, 18, 120, 10) * glowIntensity);
      ellipse(0, 0, i, i);
    }
    
    // Núcleo brillante
    fill(255, 255, 255, 200 * glowIntensity);
    ellipse(0, 0, 7, 7);
    
    // Efecto de partículas
    for (int i = 0; i < 3; i++) {
      float px = random(-10, 10);
      float py = random(-10, 10);
      fill(0, 255, 255, 100 * glowIntensity);
      ellipse(px, py, 2, 2);
    }
    
    popMatrix();
  }

  void animate() {
    if (finished) return;
    PVector[] seg = segments.get(currentSegment);
    PVector start = seg[0];
    PVector end = seg[1];
    float segLen = dist(start.x, start.y, end.x, end.y);
    float step = speed / (s/600.0); // ajusta velocidad al tamaño
    progress += step / segLen;
    if (progress >= 1) {
      currentSegment++;
      progress = 0;
      if (currentSegment >= segments.size()) {
        finished = true;
        return;
      }
    }
  }

  boolean isFinished() {
    return finished;
  }
} 