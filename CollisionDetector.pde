class CollisionDetector {
  Optional<Contact> detectCollision(Collidable collidableA, Collidable collidableB) {
    if (collidableA instanceof Circle && collidableB instanceof Circle) {
      float radiusSum = ((Circle) collidableA).getRadius() + ((Circle) collidableB).getRadius();
      if (detectCircleCircleCollision((Circle) collidableA, (Circle) collidableB, radiusSum)) {
        PVector contactNormal = PVector.sub(collidableB.getPos(), collidableA.getPos());
        float penetrationDistance = radiusSum - contactNormal.mag();
        return Optional.of(new Contact(collidableA, collidableB, 0.7, contactNormal.normalize(), penetrationDistance));
      }
    }
    
    return Optional.empty();
  }
  
  private boolean detectCircleCircleCollision(Circle circleA, Circle circleB, float radiusSum) {
    return PVector.dist(circleA.getPos(), circleB.getPos()) <= radiusSum;
  }
}
