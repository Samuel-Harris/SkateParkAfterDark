class Bullet extends Particle {
  static final int BULLET_SPEED = 50;
  static final float BULLET_MASS = 5;
  
  int life;
  int damage;
  PVector velocity;
  
  Bullet(PVector pos, PVector dir, int life, int damage, PVector playerVelocity) {
    super(pos, BULLET_MASS, 10);
    
    this.velocity = PVector.sub(dir.setMag(BULLET_SPEED), playerVelocity);
    if (velocity.mag() < BULLET_SPEED) {
      dir.setMag(BULLET_SPEED);
    }
    this.life = life;
    this.damage = damage;
  }
  
  public void draw() {
    stroke(0);
    fill(200,0,0);
    circle(pos.x, pos.y, 2*radius);
    pos.add(velocity);
    life--;
  }
  
  void collideWith(Collidable other) {
    if (other instanceof Bullet || other instanceof Player || other instanceof LineSegment) return;
    if (other instanceof Enemy) {
      Enemy enemy = (Enemy)other;
      enemy.health -= damage;
    }
    life = 0;
  }
}
