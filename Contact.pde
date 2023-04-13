class Contact {
  Collidable collidableA;
  Collidable collidableB;
  float coefficientOfRestitution;
  PVector contactNormal;
  
  public Contact(Collidable collidableA, Collidable collidableB, float coefficientOfRestitution, PVector contactNormal) {
    this.collidableA = collidableA;
    this.collidableB = collidableB;
    this.coefficientOfRestitution = coefficientOfRestitution;
    this.contactNormal = contactNormal;
  }
  
  void resolve() {
    PVector relativeVelocity = PVector.sub(collidableA.getVelocity(), collidableB.getVelocity());
    
    //Find the velocity in the direction of the contact
    float separatingVelocity = relativeVelocity.dot(contactNormal);
        
    // Calculate new separating velocity
    float newSepVelocity = -separatingVelocity * coefficientOfRestitution;
    
    // Now calculate the change required to achieve it
    float deltaVelocity = newSepVelocity - separatingVelocity;
    
    // Apply change in velocity to each object in proportion inverse mass.
    // i.e. lower inverse mass (higher actual mass) means less change to vel.
    float totalInverseMass = collidableA.getInvMass();
    totalInverseMass += collidableB.getInvMass();
    
    // Calculate impulse to apply
    float impulse = deltaVelocity / totalInverseMass ;
        
    // Find the amount of impulse per unit of inverse mass
    PVector impulsePerIMass = contactNormal.get() ;
    impulsePerIMass.mult(impulse) ;
    
    // Calculate the p1 impulse
    PVector p1Impulse = impulsePerIMass.get() ;
    p1Impulse.mult(collidableA.getInvMass()) ;
    
    // Calculate the p2 impulse
    // NB Negate this one because it is in the opposite direction 
    PVector p2Impulse = impulsePerIMass.get() ;
    p2Impulse.mult(-collidableB.getInvMass()) ;
    
    // Apply impulses. They are applied in the direction of contact, proportional
    //  to inverse mass
    collidableA.getVelocity().add(p1Impulse) ;
    collidableB.getVelocity().add(p2Impulse) ;
    
    
    collidableA.collideWith(collidableB);
    collidableB.collideWith(collidableA);
  }
}
