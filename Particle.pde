abstract class Particle {
  PVector pos;
  PVector prevPos;
  PVector forceAccumulator
  float mass;
  float invMass;
  
  public Particle(PVector pos, float mass) {
    this.pos = pos.copy();
    this.prevPos = pos.copy();
    this.mass = mass;
    invMass = 1.0/mass;
  }
  
  void draw(boolean move) {
    if (move) {
      integrate();
    }
  }
  
  void integrate() {
    float acceleration = forceAccumulator.mult(invMass);
    PVector tmp = pos.copy();
    pos = pos.mult(2).sub(prevPos).add(acceleration);
    prevPos = tmp;
    
    forceAccumulator = new PVector(0, 0);
  }
  
  void addForce(PVector force) {
    forceAccumulator.add(force);
  }
}
