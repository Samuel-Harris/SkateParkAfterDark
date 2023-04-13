class CollisionDetector {
  Optional<Contact> detectCollision(Collidable collidableA, Collidable collidableB) {
    if (collidableA instanceof Circle && collidableB instanceof Circle) {
      if (detectCircleCircleCollision((Circle) collidableA, (Circle) collidableB)) {
        return Optional.of(new Contact(collidableA, collidableB, 0.9, PVector.sub(collidableB.getPos(), collidableA.getPos())));
      }
    }
    
    return Optional.empty();
  }
  
  
  private boolean detectCircleCircleCollision(Circle circleA, Circle circleB) {
    return PVector.dist(circleA.getPos(), circleB.getPos()) <= circleA.getRadius() + circleB.getRadius();
  }
}
