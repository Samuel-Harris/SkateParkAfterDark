class Bullet extends Particle {
  int life;
  PVector velocity;
  Bullet(PVector pos, PVector dir, int life) {
    super(pos, 50.0, 10);
    this.velocity = dir.setMag(10);
    this.life = life;
  }
  
  public void draw() {
    stroke(0);
    fill(200,0,0);
    circle(pos.x, pos.y, 2*radius);
    pos.add(velocity);
    life--;
  }
  
  void collideWith(Collidable other) {
    if (other instanceof Bullet) return;
    life = 0;
  }
}
