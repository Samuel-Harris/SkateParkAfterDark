class Enemy extends Particle {
  boolean isColliding;
  
  public Enemy() {
    super(new PVector(3 * displayWidth/2 - 200, 3 * displayHeight/2 - 200), 1500, 50);
  }
  
  public void draw() {
    if (canMove) {
      integrate();
    }
    
    if (isColliding) {
      fill(0, 255, 0);
      isColliding = false;
    } else {
      fill(255, 0, 0);
    }
    stroke(0);
    circle(pos.x, pos.y, 2*radius);
  }
  
  public int getHealth() {
    return 0;
  }
  
  void collideWith(Collidable other) {
    isColliding = true;
  }
}
