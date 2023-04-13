class CollisionDetector {
  void detectCollision(Collidable collidableA, Collidable collidableB) {
    boolean collisionDetected = false;
    if (collidableA instanceof Circle && collidableB instanceof Circle) {
      collisionDetected = detectCircleCircleCollision((Circle) collidableA, (Circle) collidableB);
    }
    
    if (collisionDetected) {
      collidableA.collideWith(collidableB);
      collidableB.collideWith(collidableA);
    }
  }
  
  
  private boolean detectCircleCircleCollision(Circle circleA, Circle circleB) {
    return PVector.dist(circleA.getPos(), circleB.getPos()) <= circleA.getRadius() + circleB.getRadius();
  }
}
