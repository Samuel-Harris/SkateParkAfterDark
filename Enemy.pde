class Enemy extends Particle {
  boolean isColliding;
  float MAX_HEALTH, health;
  Player player;
  float moveForce;
  PVector dir;
  int frameReaction;
  
  public Enemy(PVector startPos, Player player, float moveForce, int frameReaction, float health) {
    super(startPos, 1500, 50);
    this.player = player;
    this.moveForce = moveForce;
    this.frameReaction = frameReaction;
    dir = new PVector(0,0);
    this.health = this.MAX_HEALTH = health;
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
    drawHealthBar();
  }
  
  public void drawHealthBar() {
    if (health<MAX_HEALTH/4) fill(255,0,0);
    else if( health < MAX_HEALTH/2) fill(100,120,0);
    else fill(0,255,0);
    noStroke();
    float drawWidth = (health / MAX_HEALTH) * 50;
    float x = pos.x+radius+10;
    float y = pos.y-radius;
    rect(x, y, drawWidth, 10);
    
    stroke(0);
    noFill();
    rect(x, y, 50, 10);
  }
  
  public int getHealth() {
    return 0;
  }
  
  void collideWith(Collidable other) {
    isColliding = true;
  }
}
