import java.util.LinkedList;
import java.util.stream.Collectors;


class Player extends Particle {
  int lives;
  int maxLives;
  int bulletCount;
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
  
  public Player(PVector startPos, SoundFile skatingSound) {
    super(startPos, 1000.0, 50);
    canMove = true;
    maxLives = 3;
    lives = maxLives;
    minAngle = 0;
    maxAngle = 0;
    moveForce = 3000;
    bulletCount = 500;
    hitInvulnerabilityFrames = 30;
    hitInvulnerabilityFramesLeft = 0;
    this.skatingSound = skatingSound;
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
    
    stroke(0);
    circle(pos.x, pos.y, 2*radius);
    float angle = atan2(cameraY+mouseY - pos.y, cameraX+mouseX - pos.x );
    minAngle = angle-QUARTER_PI/3;
    maxAngle = angle+QUARTER_PI/3;
    fill(244);
    stroke(244);
    arc(pos.x, pos.y, 200, 200, minAngle, maxAngle);
    ellipseMode(CENTER); 
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
          skatingSound.amp(0.1);
        }
      } else if (speedEnum != PlayerSpeedEnum.FAST) {
          speedEnum = PlayerSpeedEnum.FAST;
          skatingSound.rate(1.5);
          skatingSound.amp(0.2);
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
      lives--;
      hitInvulnerabilityFramesLeft = hitInvulnerabilityFrames;
    }
  }
  
  int getLives() {
    return lives;
  }
  
  int getMaxLives() {
    return maxLives;
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
