abstract class Particle implements VisibleObject {
  PVector pos;
  PVector prevPos;
  PVector forceAccumulator;
  float mass;
  float invMass;
  boolean canMove;
  
  public Particle(PVector pos, float mass) {
    this.pos = pos.copy();
    this.prevPos = pos.copy();
    this.forceAccumulator = new PVector(0, 0);
    this.mass = mass;
    invMass = 1.0/mass;
  }
  
  abstract void draw();
  
  void integrate() {
    PVector acceleration = forceAccumulator.mult(invMass);
    PVector tmp = pos.copy();
    pos = pos.mult(1.92).sub(prevPos.mult(0.92)).add(acceleration);
    prevPos = tmp;
    
    forceAccumulator = new PVector(0, 0);
  }
  
  void addForce(PVector force) {
    forceAccumulator.add(force);
  }
}
