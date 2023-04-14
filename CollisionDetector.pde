class CollisionDetector {
  Optional<Contact> detectCollision(Collidable collidableA, Collidable collidableB) {
    if (collidableA instanceof Circle && collidableB instanceof Circle) {
      return generateCircleCircleContact((Circle) collidableA, (Circle) collidableB);
    } else if (collidableA instanceof Circle && collidableB instanceof LineSegment) {
      return generateCircleLineSegmentContact((Circle) collidableA, (LineSegment) collidableB);
    } else if (collidableA instanceof LineSegment && collidableB instanceof Circle) {
      return generateCircleLineSegmentContact((Circle) collidableB, (LineSegment) collidableA);
    }
    
    return Optional.empty();
  }
  
  private Optional<Contact> generateCircleCircleContact(Circle circleA, Circle circleB) {
      float radiusSum = circleA.getRadius() + circleB.getRadius();
      PVector contactNormal = PVector.sub(circleB.getPos(), circleA.getPos());
      float penetrationDistance = radiusSum - contactNormal.mag();
      
      return penetrationDistance >= 0
        ? Optional.of(new Contact(circleA, circleB, 0.7, contactNormal.normalize(), penetrationDistance))
        : Optional.empty();
  }
  
  private Optional<Contact> generateCircleLineSegmentContact(Circle circle, LineSegment lineSegment) {
    if (PVector.sub(circle.getPos(), lineSegment.getPos()).mag() <= circle.getRadius() + lineSegment.getHalfLength()) {  // check whether circle within radius of line segment
      PVector parallelogramBase = lineSegment.getNormalisedVector();
      PVector parallelogramSide = PVector.sub(circle.getPos(), lineSegment.getStartPoint());
      float distance = abs(parallelogramBase.x*parallelogramSide.y - parallelogramBase.y*parallelogramSide.x);  // norm of 2d cross-product
      float penetrationDistance = circle.getRadius() - distance;
      
      if (penetrationDistance >= 0) {
        return Optional.of(new Contact(circle, lineSegment, 0.7, lineSegment.getNormalVector(), penetrationDistance));
      }
    }
    
    return Optional.empty();
  }
}
