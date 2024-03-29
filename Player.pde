import java.util.LinkedList;
import java.util.stream.Collectors;


class Player extends Particle {
  int lives;
  int maxLives;
  int bulletCount;
  int maxBullets;
  float moveForce;
  boolean isMovingLeft;
  boolean isMovingRight;
  boolean isMovingUp;
  boolean isMovingDown;
  int hitInvulnerabilityFrames;
  int hitInvulnerabilityFramesLeft;
  float minAngle,maxAngle;
  PlayerSpeedEnum speedEnum;
  SoundFile skatingSound;
  SoundFile stabSound;
  PImage sprite;
  
  public Player(PVector startPos, SoundFile skatingSound, SoundFile stabSound, int characterSpriteWidth) {
    super(startPos, 1000.0, 50);
    canMove = true;
    maxLives = 3;
    lives = maxLives;
    minAngle = 0;
    maxAngle = 0;
    moveForce = width;
    bulletCount = 6;
    maxBullets = 8;
    hitInvulnerabilityFrames = 30;
    hitInvulnerabilityFramesLeft = 0;
    this.skatingSound = skatingSound;
    this.stabSound = stabSound;
    sprite = loadImage("character_sprites/player.png");
    sprite.resize(characterSpriteWidth, characterSpriteWidth);
  }
  
  void draw() {
    PVector moveDirection = new PVector(0, 0);
    if (state == ParticleMovementState.DEFAULT && isMovingLeft) {
      moveDirection.add(new PVector(-1, 0));
    }
    
    if (state == ParticleMovementState.DEFAULT && isMovingRight) {
      moveDirection.add(new PVector(1, 0));
    }
    
    if (state == ParticleMovementState.DEFAULT && isMovingUp) {
      moveDirection.add(new PVector(0, -1));
    }
    
    if (state == ParticleMovementState.DEFAULT && isMovingDown) {
      moveDirection.add(new PVector(0, 1));
    }
    
    moveDirection.normalize();
    addForce(moveDirection.mult(moveForce));
    
    if (canMove) {
      integrate();
    }
    
    if (hitInvulnerabilityFramesLeft > 0) {
      hitInvulnerabilityFramesLeft--;
      
      if ((hitInvulnerabilityFramesLeft / 4) % 2 == 0) {
        fill(0);
      } else {
        fill(255);
      }
    } else { 
      fill(0);
    }
    
    float angle = atan2(cameraY+mouseY - pos.y, cameraX+mouseX - pos.x );
    minAngle = angle-QUARTER_PI/3;
    maxAngle = angle+QUARTER_PI/3;
    
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    image(sprite, 0, 0);
    popMatrix();
  }
  
  void integrate() {
    float speed = getVelocity().mag();
    if (speed < 5) {
      if (speedEnum != PlayerSpeedEnum.STATIONARY) {
        speedEnum = PlayerSpeedEnum.STATIONARY;
        skatingSound.pause();
      }
    } else {
      if (speed < 30) {
        if (speedEnum != PlayerSpeedEnum.SLOW) {
          speedEnum = PlayerSpeedEnum.SLOW;
          skatingSound.rate(1.2);
          skatingSound.amp(0.3);
        }
      } else if (speedEnum != PlayerSpeedEnum.FAST) {
          speedEnum = PlayerSpeedEnum.FAST;
          skatingSound.rate(1.5);
          skatingSound.amp(0.4);
      }
      
      if (!skatingSound.isPlaying()) {
        skatingSound.loop();
      }
    }
    
    super.integrate();
  }
  
  float getHitInvulnerabilityFrames() {
    return (float) hitInvulnerabilityFrames;
  }
  
  float getHitInvulnerabilityFramesLeft() {
    return (float) hitInvulnerabilityFramesLeft;
  }
  
  void collideWith(Collidable other) {
    if (other instanceof Enemy && lives > 0 && hitInvulnerabilityFramesLeft == 0) {
      stabSound.play();
      lives--;
      hitInvulnerabilityFramesLeft = hitInvulnerabilityFrames;
    }
  }
  
  void gainBullet() {
    if (bulletCount < maxBullets) {
      bulletCount += 1;
      shotgunReloadSound.play();
    }
  }
  
  int getLives() {
    return lives;
  }
  
  int getMaxLives() {
    return maxLives;
  }
  
  void resetLives() {
    this.lives = maxLives;
  }
  
  int getBulletCount() {
    return bulletCount;
  }
  
  int getMaxBullets() {
    return maxBullets;
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
