abstract class Particle implements VisibleObject, Circle {
  PVector pos;
  PVector prevPos;
  PVector forceAccumulator;
  float mass;
  float invMass;
  boolean canMove;
  float radius;
  
  public Particle(PVector pos, float mass, float radius) {
    this.pos = pos.copy();
    this.prevPos = pos.copy();
    this.forceAccumulator = new PVector(0, 0);
    this.mass = mass;
    invMass = 1.0/mass;
    
    this.radius = radius;
    canMove = true;
  }
  
  abstract void draw();
  
  void integrate() {
    PVector acceleration = forceAccumulator.mult(invMass);
    PVector tmp = pos.copy();
    pos = pos.mult(1.92).sub(prevPos.mult(0.92)).add(acceleration);
    prevPos = tmp;
    
    forceAccumulator = new PVector(0, 0);
  }
  
  float getRadius() {
    return radius;
  }
  
  PVector getPos() {
    return pos;
  }
  
  PVector getVelocity() {
    return PVector.sub(prevPos, pos);
  }
  
  float getMass() {
    return mass;
  }
  
  float getInvMass() {
    return invMass;
  }
  
  void addForce(PVector force) {
    forceAccumulator.add(force);
  }
}
