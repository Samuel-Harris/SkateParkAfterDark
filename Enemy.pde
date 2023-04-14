class Enemy extends Particle {
  boolean isColliding;
  
  public Enemy() {
    super(new PVector(3 * displayWidth/2 - 200, 3 * displayHeight/2 - 200), 1500, 50);
  Player player;
  float moveForce;
  PVector dir;
  int frameReaction;
  public Enemy(PVector startPos, Player player, float moveForce, int frameReaction) {
    super(startPos, 100, 50);
    this.player = player;
    this.moveForce = moveForce;
    this.frameReaction = frameReaction;
    dir = new PVector(0,0);
  }
  
  public void draw() {
    if (frameCount % frameReaction == 0) {
      dir = PVector.sub(player.pos,this.pos);
    }
    dir.normalize();
    addForce(dir.mult(moveForce));

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
