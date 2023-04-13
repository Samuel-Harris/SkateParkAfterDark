class Player extends Particle {
  int lives;
  
  float moveForce;
  boolean isMovingLeft;
  boolean isMovingRight;
  boolean isMovingUp;
  boolean isMovingDown;
  
  public Player(PVector startPos) {
    super(startPos, 1000.0, 50);
    canMove = true;
    
    moveForce = 3000;
  }
  
  void draw() {
    PVector moveDirection = new PVector(0, 0);
    if (isMovingLeft) {
      moveDirection.add(new PVector(-1, 0));
    }
    
    if (isMovingRight) {
      moveDirection.add(new PVector(1, 0));
    }
    
    if (isMovingUp) {
      moveDirection.add(new PVector(0, -1));
    }
    
    if (isMovingDown) {
      moveDirection.add(new PVector(0, 1));
    }
    
    moveDirection.normalize();
    addForce(moveDirection.mult(moveForce));
    
    if (canMove) {
      integrate();
    }
    
    fill(0);
    stroke(0);
    circle(pos.x, pos.y, 2*radius);
  }
  
  void collideWith(Collidable other) {
  }
  
  int getLives() {
    return lives;
  }
  
  void stopMoving() {
    canMove = false;
  }
  
  void startMoving() {
    canMove = true;
  }
  
  void startMovingLeft() {
    isMovingLeft = true;
  }
  
  void startMovingRight() {
    isMovingRight = true;
  }
  
  void startMovingUp() {
    isMovingUp = true;
  }
  
  void startMovingDown() {
    isMovingDown = true;
  }
  
  void stopMovingLeft() {
    isMovingLeft = false;
  }
  
  void stopMovingRight() {
    isMovingRight = false;
  }
  
  void stopMovingUp() {
    isMovingUp = false;
  }
  
  void stopMovingDown() {
    isMovingDown = false;
  }
}
