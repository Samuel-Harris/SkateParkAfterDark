class Enemy extends Particle {
  float MAX_HEALTH, health;
  Player player;
  float moveForce;
  PVector dir;
  int frameReaction;
  PImage sprite;
  
  public Enemy(PVector startPos, Player player, float moveForce, int frameReaction, float health, int characterSpriteWidth) {
    super(startPos, 1500, 50);
    this.player = player;
    this.moveForce = moveForce;
    this.frameReaction = frameReaction;
    dir = new PVector(0,0);
    this.health = this.MAX_HEALTH = health;
    sprite = loadImage("character_sprites/enemy.png");
    sprite.resize(characterSpriteWidth, characterSpriteWidth);
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

    drawHealthBar();
    
    float angle = atan2(pos.y-prevPos.y, pos.x-prevPos.x);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    image(sprite, 0, 0);
    popMatrix();
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
  }
}
