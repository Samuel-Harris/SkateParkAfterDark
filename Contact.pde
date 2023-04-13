class Contact {
  Collidable collidableA;
  Collidable collidableB;
  float coefficientOfRestitution;
  PVector contactNormal;
  float penetrationDistance;
  
  public Contact(Collidable collidableA, Collidable collidableB, float coefficientOfRestitution, PVector contactNormal, float penetrationDistance) {
    this.collidableA = collidableA;
    this.collidableB = collidableB;
    this.coefficientOfRestitution = coefficientOfRestitution;
    this.contactNormal = contactNormal;
    this.penetrationDistance = penetrationDistance;
  }
  
  void resolve() {
    PVector relativeVelocity = PVector.sub(collidableA.getVelocity(), collidableB.getVelocity());
    
    //Find the velocity in the direction of the contact
    float separatingVelocity = relativeVelocity.dot(contactNormal);
    
    // Now calculate the change required to achieve new separating velocity
    float deltaVelocity = -separatingVelocity * coefficientOfRestitution - separatingVelocity;
    
    // Apply change in velocity to each object in proportion inverse mass.
    // i.e. lower inverse mass (higher actual mass) means less change to vel.
    float totalInverseMass = collidableA.getInvMass() + collidableB.getInvMass();
    
    // Calculate impulse to apply
    float impulse = deltaVelocity / totalInverseMass;
    
    collidableA.addForce(PVector.mult(contactNormal, -impulse - penetrationDistance * collidableA.getMass()));
    collidableB.addForce(PVector.mult(contactNormal, impulse + penetrationDistance * collidableB.getMass()));
    
    collidableA.collideWith(collidableB);
    collidableB.collideWith(collidableA);
  }
}
