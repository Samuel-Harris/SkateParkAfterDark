class Bullet extends Particle {
  int life;
  int damage;
  PVector velocity;
  Bullet(PVector pos, PVector dir, int life, int damage) {
    super(pos, 50.0, 10);
    this.velocity = dir.setMag(30);
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
