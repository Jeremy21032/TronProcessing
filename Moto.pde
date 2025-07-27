class Moto {
  PVector pos;
  float angle;
  color myColor;

  Moto(PVector pos, float angle, color myColor) {
    this.pos = pos;
    this.angle = angle;
    this.myColor = myColor;
  }

  void draw3D(float z) {
    pushMatrix();
    translate(pos.x, pos.y, z);
    pushMatrix();
    rotateZ(angle);
    fill(myColor, 200);
    noStroke();
    box(20, 8, 6);
    fill(50, 50, 50);
    translate(-8, 0, 0);
    sphere(4);
    translate(16, 0, 0);
    sphere(4);
    fill(255, 255, 255, 100);
    translate(-8, -2, 3);
    sphere(2);
    popMatrix();
    popMatrix();
  }
} 