class StartButton {
  float x, y, w, h;
  String label;
  float time = 0;
  float glowIntensity = 0;
  
  StartButton(float x, float y, float w, float h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }
  
  void display() {
    time += 0.1;
    glowIntensity = sin(time * 2) * 0.3 + 0.7;
    pushMatrix();
    translate(x, y, 0);
    
    rotateY(sin(time * 0.5) * 0.05);
    rotateX(sin(time * 0.3) * 0.02);
    
    rectMode(CENTER);
    textAlign(CENTER, CENTER);
    textSize(28);
    
    stroke(0, 255, 255, 150 * glowIntensity);
    strokeWeight(3);
    
    if (isMouseOver()) {
      fill(0, 80, 120, 200 * glowIntensity);
      translate(0, 0, 10);
    } else {
      fill(0, 40, 60, 150 * glowIntensity);
    }
    
    rect(0, 0, w, h, 18);
    fill(0, 20, 30, 100);
    noStroke();
    rect(2, 2, w, h, 18);

    fill(0, 255, 255, 255 * glowIntensity);
    noStroke();
    text(label, 0, 0);
    
    if (isMouseOver()) {
      for (int i = 0; i < 5; i++) {
        float px = random(-w/2, w/2);
        float py = random(-h/2, h/2);
        float pz = random(5, 15);
        
        fill(0, 255, 255, 100 * glowIntensity);
        noStroke();
        pushMatrix();
        translate(px, py, pz);
        sphere(2);
        popMatrix();
      }
    }
    
    popMatrix();
  }
  
  boolean isMouseOver() {
    return mouseX > x-w/2 && mouseX < x+w/2 && mouseY > y-h/2 && mouseY < y+h/2;
  }
} 