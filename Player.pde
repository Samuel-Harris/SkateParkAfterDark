class Player extends Particle {
  int lives;
  
  float moveForce;
  boolean isMovingLeft;
  boolean isMovingRight;
  boolean isMovingUp;
  boolean isMovingDown;
  
  public Player(PVector startPos) {
    super(startPos, 1000.0);
    canMove = true;
    
    moveForce = 3000;
  }
  
  void draw() {
    if (isMovingLeft) {
      addForce(new PVector(-moveForce, 0));
    }
    
    if (isMovingRight) {
      addForce(new PVector(moveForce, 0));
    }
    
    if (isMovingUp) {
      addForce(new PVector(0, -moveForce));
    }
    
    if (isMovingDown) {
      addForce(new PVector(0, moveForce));
    }
    
    if (canMove) {
      integrate();
    }
    
    
    fill(0);
    stroke(0);
    circle(pos.x, pos.y, 100);
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
