interface Collidable {
  void collideWith(Collidable other);
  
  PVector getPos();
  
  PVector getVelocity();
  
  float getMass();
  
  float getInvMass();
  
  void addForce(PVector force);
}
