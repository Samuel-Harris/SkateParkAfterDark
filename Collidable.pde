interface Collidable {
  void collideWith(Collidable other);
  
  PVector getPos();
  
  PVector getVelocity();
  
  float getInvMass();
}
