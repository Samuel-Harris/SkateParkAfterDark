class LineSegment implements Collidable {
  PVector startPoint;
  PVector endPoint;
  PVector centre;
  PVector normalisedVector;
  PVector normalVector;
  float halfLength;
  
  public LineSegment(PVector startPoint, PVector endPoint) {
    this.startPoint = startPoint;
    this.endPoint = endPoint;
    normalisedVector = PVector.sub(endPoint, startPoint).normalize();
    normalVector = new PVector(normalisedVector.y, -normalisedVector.x);
    
    centre = PVector.add(startPoint, endPoint).div(2);
    halfLength = PVector.dist(startPoint, centre);
  }
  
  void collideWith(Collidable other) {
  }
  
  PVector getStartPoint() {
    return startPoint;
  }
  
  PVector getEndPoint() {
    return endPoint;
  }
  
  float getHalfLength() {
    return halfLength;
  }
  
  PVector getNormalisedVector() {
    return normalisedVector;
  }
  
  PVector getNormalVector() {
    return normalVector;
  }
  
  PVector getPos() {
    return centre;
  }
  
  PVector getVelocity() {
    return new PVector(0, 0);
  }
  
  float getInvMass() {
    return 0;
  }
  
  float getMass() {
    return Float.POSITIVE_INFINITY;
  }
  
  void addForce(PVector force) {
  }
}
