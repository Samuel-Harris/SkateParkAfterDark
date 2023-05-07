import java.util.List;
import java.util.Optional;
import processing.sound.SoundFile;
import java.util.stream.IntStream;

boolean startScreen = true,
  pauseScreen = false,
  mouseOverStartButton = false,
  mouseOverContinueButton = false,
  mouseOverRetryButton = false,
  mouseOverExitButton = false;


int round, incre, fade, bulletRefillCount, coolOffRail;

float mapWidth,
  mapHeight,
  cameraX,
  cameraY,
  transitionCounter,
  octagonRadius = 1500;

int characterSpriteWidth = 200;
Player player;

List<VisibleObject> visibleObjectList;
List<Collidable> collidableObjectList;

CollisionDetector collisionDetector;

List<Enemy> enemies;
int enemyCount;
PShape octagon;

HUD hud;

SoundFile backgroundMusic;
SoundFile skatingSound;
SoundFile shotgunSound;
SoundFile shotgunReloadSound;
SoundFile shotgunOutOfAmmoSound;
SoundFile stabSound;
SoundFile grindingSound;
SoundFile deathSound;
final int numLevelChangeSounds = 4;
int lastLevelChangeSound = -1;
SoundFile[] levelChangeSounds = new SoundFile[numLevelChangeSounds];

int reloadFrames = 30;

DeathSoundState deathSoundState;
boolean deathSoundHasBeenPlayed;
final int deathSoundPauseFrames = 30;
int currDeathSoundPauseFrames;

void setup() {
  imageMode(CENTER);

  fullScreen();

  mapWidth = 5 * displayWidth;
  mapHeight = 5 * displayHeight;
  
  cursor(loadImage("cross_hair/cross_hair.png"));

  backgroundMusic = new SoundFile(this, "music/background_music.wav");
  backgroundMusic.amp(0.8);
  backgroundMusic.jump(int(random(backgroundMusic.duration())));

  skatingSound = new SoundFile(this, "player_sounds/skating_sound.wav");

  shotgunSound = new SoundFile(this, "player_sounds/shotgun_fire.wav");
  shotgunSound.amp(0.2);
  
  shotgunReloadSound = new SoundFile(this, "player_sounds/shotgun_reload.wav");
  shotgunReloadSound.amp(0.4);
  shotgunReloadSound.rate(1.2);

  grindingSound = new SoundFile(this, "player_sounds/grind.wav");

  for (int i=0; i<4; i++) {
    levelChangeSounds[i] = new SoundFile(this, "roadman_sounds/level_change_" + i + ".wav");
  }
  
  shotgunOutOfAmmoSound = new SoundFile(this, "player_sounds/out_of_ammo.wav");
  
  stabSound = new SoundFile(this, "player_sounds/stab.wav");
  
  deathSound = new SoundFile(this, "player_sounds/death.wav");
  
  deathSoundState = DeathSoundState.NOT_PLAYING;

  reset();
}

void reset() {
  round = 0;
  bulletRefillCount = 0;
  coolOffRail = 60;

  startScreen = true;
  pauseScreen = false;
  mouseOverStartButton = false;
  mouseOverContinueButton = false;
  mouseOverRetryButton = false;
  mouseOverExitButton = false;

  player = new Player(new PVector(mapWidth/2, mapHeight/2), skatingSound, stabSound, characterSpriteWidth);

  roundGenerator();
  
  deathSoundHasBeenPlayed = false;
  deathSoundState = DeathSoundState.NOT_PLAYING;
  if (deathSound.isPlaying()) {
    deathSound.stop();
  }
}

void playLevelChangeSound() {
  if (!IntStream.range(0, numLevelChangeSounds).anyMatch(i -> levelChangeSounds[i].isPlaying())) {
    int levelChangeSoundNum;
    
    do {
      levelChangeSoundNum = int(random(numLevelChangeSounds));
    } while (lastLevelChangeSound == levelChangeSoundNum);
    
    levelChangeSounds[levelChangeSoundNum].play();
    lastLevelChangeSound = levelChangeSoundNum;
  }
}

void roundGenerator() {
  playLevelChangeSound();

  incre = -10;
  fade = 200;
  round++;
  transitionCounter = 0;
  enemyCount = ceil(1.5 * round);

  cameraX = player.pos.x - displayWidth/2;
  cameraY = player.pos.y - displayHeight/2;

  enemies = new ArrayList();
  for (int i = 0; i < enemyCount; i++) {
    float enX = random(mapWidth);
    float enY = random(mapHeight);
    while (dist(enX, enY, player.pos.x, player.pos.y)<2*displayWidth) {
      enX = random(mapWidth);
      enY = random(mapHeight);
    }
    enemies.add(new Enemy(new PVector(enX, enY), player, int(random(2000, 3000)), int(random(6, 13)), 500, characterSpriteWidth));
  }
  
  visibleObjectList = new ArrayList(); //<>//
  visibleObjectList.add(player);
  visibleObjectList.addAll(enemies);
  
  hud = new HUD(player, 300);
  player.resetLives();

  collidableObjectList = new ArrayList();
  collidableObjectList.add(player);
  collidableObjectList.addAll(enemies);

  collisionDetector = new CollisionDetector();

  float minX = 100000;
  float maxX = -100000;
  float minY = 100000;
  float maxY = -100000;

  PVector octagonCentre = new PVector(mapWidth/2, mapHeight/2);
  float EIGHTH_PI = PI / 8;
  octagon = createShape();
  octagon.beginShape();
  octagon.fill(0, 150, 60);
  float prevSx = octagonCentre.x + cos(-EIGHTH_PI) * octagonRadius;
  float prevSy = octagonCentre.y + sin(-EIGHTH_PI) * octagonRadius;
  for (int i=0; i<8; i++) {
    float sx = octagonCentre.x + cos(i*QUARTER_PI+EIGHTH_PI) * octagonRadius;
    float sy = octagonCentre.y + sin(i*QUARTER_PI+EIGHTH_PI) * octagonRadius;
    octagon.vertex(sx, sy);

    collidableObjectList.add(new LineSegment(new PVector(prevSx, prevSy), new PVector(sx, sy)));
    prevSx = sx;
    prevSy = sy;

    minX = min(minX, sx);
    maxX = max(maxX, sx);
    minY = min(minY, sy);
    maxY = max(maxY, sy);
  }
  octagon.endShape(CLOSE);
  
  int distanceFromSide = 100;
  minX += distanceFromSide;
  maxX -= distanceFromSide;
  minY += distanceFromSide;
  maxY -= distanceFromSide;

  int numRails = 4;
  Rail[] rails = new Rail[numRails];
  float hexRad = (maxX - minX) /2;
  int minLengthOfRail = 600;
  int maxLengthOfRail = 900;
  float minDistanceBetweenRails = 500;
  
  for (int i = numRails-1; i >= 0; i--) {
    PVector start;
    PVector end;
    boolean isValid = true;
    float railLength;
    do {
      do {
        do {
          start = new PVector(random(minX, maxX), random(minY, maxY));
        } while (PVector.dist(start, octagonCentre) > hexRad);
        
        end = new PVector(random(minX, maxX),random(minY, maxY));
        railLength = start.dist(end);
      }  while (PVector.dist(end, octagonCentre) > hexRad || railLength < minLengthOfRail || railLength > maxLengthOfRail);
      
      rails[i] = new Rail(start, end);
      for (int j = i+1; j < numRails; j++) {
        isValid = !doesLineIntersect(rails[i], rails[j]) && getShortestDistanceBetweenRails(rails[i], rails[j]) > minDistanceBetweenRails;
        if (!isValid) break;
      }
    } while (!isValid);
    collidableObjectList.add(rails[i]);
    visibleObjectList.add(rails[i]);
  }
}

float getShortestDistanceBetweenRails(Rail r1, Rail r2) {
  PVector r1Start = new PVector(r1.Xmin, r1.Ymin);
  PVector r1End = new PVector(r1.Xmax, r1.Ymax);
  
  PVector r2Start = new PVector(r2.Xmin, r2.Ymin);
  PVector r2End = new PVector(r2.Xmax, r2.Ymax);
  
  return min(min(min(r1Start.dist(r2Start), r1Start.dist(r2End)), r1End.dist(r2Start)), r1End.dist(r2Start));
}

boolean doesLineIntersect (Rail r1, Rail r2) {
  if (r1.m == r2.m) return false;
  float x = (r2.c - r1.c) / (r1.m - r2.m);
  if (x < r1.Xmin || x > r1.Xmax || x < r2.Xmin || x > r2.Xmax) {
    return false;
  }

  float y = r1.m * x + r1.c;
  if (y < r1.Ymin || y > r1.Ymax || y < r2.Ymin || y > r2.Ymax) {
    return false;
  }

  return true;
}

void transitionScreen() {
  int transitionCounterMax = 300;
  
  transitionCounter++;
  textAlign(CENTER, CENTER);
  textSize(52);
  if (fade >= 200) incre = -10;
  else if (fade <= 50) incre = 10;
  fade += incre;
  fill(159, 20, 0, fade);
  if (transitionCounter == 0) {
  } else if (transitionCounter < transitionCounterMax / 2) {
    text("I", 30, 50);
  } else if (transitionCounter < transitionCounterMax) {
    text("I I", 30, 50);
  } else {
    roundGenerator();
  }
  
  if (transitionCounter >= player.getBulletCount() * transitionCounterMax / player.getMaxBullets()) {
    player.gainBullet();
  }
}

void drawStartScreen() {
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(159, 20, 0);
  text("Skate Park\nAfter Dark", cameraX + width/2, cameraY + height/2);

  rectMode(CORNER);

  float x = cameraX + width/2 - 50;
  float y = cameraY + width/2 ;
  float w = 100;
  float h = 50;
  if (overRect(x, y, w, h)) {
    fill(12, 160, 20);
    mouseOverStartButton = true;
  } else {
    fill(230, 230, 230);
    mouseOverStartButton = false;
  }
  rect(x, y, w, h);
  fill(255);
  String str = "Start!";
  text(str, cameraX + width/2, cameraY + width/2 + 20);
}

void drawPauseScreen() {
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(159, 20, 0);
  text("Skate Park\nAfter Dark", cameraX + width/2, cameraY + height/4);
  text("Game Paused", cameraX + width/2, cameraY + height/2);

  rectMode(CORNER);
  float x = cameraX + width/2 - 65;
  float y = cameraY + width/2 ;
  float w = 130;
  float h = 50;
  if (overRect(x, y, w, h)) {
    fill(12, 160, 20);
    mouseOverContinueButton = true;
  } else {
    fill(230, 230, 230);
    mouseOverContinueButton = false;
  }
  rect(x, y, w, h);

  fill(255);
  String str = "Continue";
  text(str, cameraX + width/2, cameraY + width/2 + 20);

  y = cameraY + width/2 + 70;
  if (overRect(x, y, w, h)) {
    fill(12, 160, 20);
    mouseOverExitButton = true;
  } else {
    fill(230, 230, 230);
    mouseOverExitButton = false;
  }
  rect(x, y, w, h);
  fill(255);
  str = "Exit";
  text(str, cameraX + width/2, cameraY + width/2 + 90);
}

void drawGameOverScreen() {
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(159, 20, 0);
  text("Skate Park\nAfter Dark", cameraX + width/2, cameraY + height/4);
  text("Game Over", cameraX + width/2, cameraY + height/2);

  rectMode(CORNER);
  float x = cameraX + width/2 - 65;
  float y = cameraY + width/2 ;
  float w = 130;
  float h = 50;
  if (overRect(x, y, w, h)) {
    fill(12, 160, 20);
    mouseOverRetryButton = true;
  } else {
    fill(230, 230, 230);
    mouseOverRetryButton = false;
  }
  rect(x, y, w, h);

  fill(255);
  String str = "Retry";
  text(str, cameraX + width/2, cameraY + width/2 + 20);

  y = cameraY + width/2 + 70;
  if (overRect(x, y, w, h)) {
    fill(12, 160, 20);
    mouseOverExitButton = true;
  } else {
    fill(230, 230, 230);
    mouseOverExitButton = false;
  }
  rect(x, y, w, h);
  fill(255);
  str = "Exit";
  text(str, cameraX + width/2, cameraY + width/2 + 90);
}

void draw() {
  if (!backgroundMusic.isPlaying() && deathSoundState == DeathSoundState.NOT_PLAYING) {
    backgroundMusic.loop();
  }

  // this can be optimised by just removing the bullet and enemy from the collidableObjectList & visibleObjectList direclty from the collideWith class, however not the best coding practice
  List toRemove = collidableObjectList.stream().filter(e -> e instanceof Bullet).map(e -> (Bullet)e).filter(e -> e.life <= 0).collect(Collectors.toList());
  collidableObjectList.removeAll(toRemove);
  visibleObjectList.removeAll(toRemove);

  toRemove = enemies.stream().filter(e -> e.health <= 0).collect(Collectors.toList());
  enemies.removeAll(toRemove);
  collidableObjectList.removeAll(toRemove);
  visibleObjectList.removeAll(toRemove);

  List<Contact> contactList = new ArrayList();
  for (int i=0; i<collidableObjectList.size(); i++) {
    for (int j=i+1; j<collidableObjectList.size(); j++) {
      Collidable collidableA = collidableObjectList.get(i);
      Collidable collidableB = collidableObjectList.get(j);

      Optional<Contact> contactOptional = collisionDetector.detectCollision(collidableA, collidableB);
      if (contactOptional.isPresent()) {
        contactList.add(contactOptional.get());
      }
    }
  }
  
  List<Particle> contactListWithParticleCollidingWithRails1 = contactList.stream()
    .filter(e -> e.collidableA instanceof Rail && e.collidableB instanceof Particle)
    .map(e -> (Particle)e.collidableB)
    .collect(Collectors.toList());
  List<Particle> contactListWithParticleCollidingWithRails2 = contactList.stream()
    .filter(e -> e.collidableB instanceof Rail && e.collidableA instanceof Particle)
    .map(e -> (Particle)e.collidableA)
    .collect(Collectors.toList());
  contactListWithParticleCollidingWithRails1.addAll(contactListWithParticleCollidingWithRails2);
  List<Particle> esfce = collidableObjectList.stream()
    .filter(e -> e instanceof Particle)
    .map(e -> (Particle)e)
    .filter(e -> e.state != ParticleMovementState.DEFAULT)
    .filter(e -> !contactListWithParticleCollidingWithRails1.contains(e))
    .collect(Collectors.toList());
  getOffRail(esfce);
  
  if (coolOffRail < 60){
    if (--coolOffRail == 0) coolOffRail = 60;
  }
  
  for (Contact contact : contactList) {
    if (contact.collidableA instanceof Bullet && contact.collidableB instanceof Bullet) continue;
    if (contact.collidableA instanceof Bullet && contact.collidableB instanceof Player) continue;
    if (contact.collidableA instanceof Player && contact.collidableB instanceof Bullet) continue;

    if (contact.collidableA instanceof Rail && contact.collidableB instanceof Particle) {
      Rail rai = (Rail) contact.collidableA;
      Particle p = (Particle) contact.collidableB;
      if (p.state == ParticleMovementState.DEFAULT) {
        if (p instanceof Player && coolOffRail < 60) continue;
        getOnTheRail(p, rai);
      }
      contact.collidableB.addForce(p.trickForce);
      continue;
    } else if (contact.collidableB instanceof Rail && contact.collidableA instanceof Particle) {
      Rail rai = (Rail) contact.collidableB;
      Particle p = (Particle) contact.collidableA;
      if (p.state == ParticleMovementState.DEFAULT) {
        if (p instanceof Player && coolOffRail < 60) continue;
        getOnTheRail(p, rai);
      }
      contact.collidableA.addForce(p.trickForce);
      continue;
    }
    contact.resolve();
  }

  cameraX = player.pos.x - displayWidth/2;
  cameraY = player.pos.y - displayHeight/2;

  translate(-cameraX, -cameraY);

  fill(230);
  rect(0, 0, mapWidth, mapHeight);
  shape(octagon, 0, 0);

  if (startScreen) {
    drawStartScreen();
    return;
  }

  if (pauseScreen) {
    drawPauseScreen();
    return;
  }

  if (player.getLives()<=0) {
    drawGameOverScreen();
    if (!deathSoundHasBeenPlayed) {
      playDeathSound();
    }
    getOffRail(List.of(player));
    return;
  }

  for (VisibleObject visibleObject : visibleObjectList) {
    visibleObject.draw();
  }

  translate(cameraX, cameraY);

  if (enemies.isEmpty()) {
    transitionScreen();
  }

  if (player.getMovementState() != ParticleMovementState.DEFAULT) {
    if (bulletRefillCount%reloadFrames == 0) {
      player.gainBullet();
    }
    bulletRefillCount++;
  }

  hud.draw();
}

void playDeathSound() {
  if (backgroundMusic.isPlaying()) {  // player just died, start death sound sequence
    backgroundMusic.pause();
    deathSoundState = DeathSoundState.BEGINNING_PAUSE;
    currDeathSoundPauseFrames = deathSoundPauseFrames;
  } else {
    switch (deathSoundState) {
      case BEGINNING_PAUSE:
        if (currDeathSoundPauseFrames > 0) {
          currDeathSoundPauseFrames -= 1;
        } else {
          currDeathSoundPauseFrames = deathSoundPauseFrames;
          deathSoundState = DeathSoundState.DEATH_SOUND;
          deathSound.play();
        }
        break;
      case DEATH_SOUND:
        if (!deathSound.isPlaying()) {
          deathSoundState = DeathSoundState.END_PAUSE;
        }
        break;
      case END_PAUSE:
        if (currDeathSoundPauseFrames > 0) {
          currDeathSoundPauseFrames -= 1;
        } else {
          currDeathSoundPauseFrames = deathSoundPauseFrames;
          deathSoundState = DeathSoundState.NOT_PLAYING;
          backgroundMusic.loop();
          deathSoundHasBeenPlayed = true;
        }
    }
  }
}

void getOnTheRail(Particle p, Rail rai) {
  if (p instanceof Player) {
    grindingSound.loop();
    stopPlayerFromMoving();
  }
  p.forceAccumulator = new PVector(0, 0);
  PVector dir = p.getVelocity();
  float d = PVector.dot(dir, rai.getNormalisedVector());
  p.state = ParticleMovementState.RAIL;
  d *= -500;
  float maxSpeed = 3000;
  float minSpeed = 1500;
  if (abs(d) < minSpeed) {
    if (d<0) d = -minSpeed;
    else d = minSpeed;
  } else if (abs(d) > maxSpeed) {
    if (d<0) d = -maxSpeed;
    else d = maxSpeed;
  }
  p.trickForce = rai.getNormalisedVector().copy().setMag(d);
  GetClosestPoint(rai, p);
  p.prevPos = p.pos.copy();
}

void GetClosestPoint(Rail r, Particle p) {
  PVector a_to_p = new PVector(p.pos.x - r.startPoint.x, p.pos.y - r.startPoint.y);
  PVector a_to_b = new PVector(r.endPoint.x - r.startPoint.x, r.endPoint.y - r.startPoint.y);
  float atb2 = a_to_b.x*a_to_b.x + a_to_b.y*a_to_b.y;
  float atp_dot_atb = a_to_p.x*a_to_b.x + a_to_p.y*a_to_b.y;
  float t = atp_dot_atb / atb2;
  p.pos = new PVector(r.startPoint.x + a_to_b.x*t, r.startPoint.y + a_to_b.y*t );
}

void getOffRail(List<Particle> ps) {
  for (Particle p : ps) {
    getOffRail(p);
  }
}

void getOffRail(Particle p) {
    if (p instanceof Player) {
      grindingSound.pause();
      player.setMovementState(ParticleMovementState.DEFAULT);
      float angle = atan2(cameraY+mouseY - p.pos.y, cameraX+mouseX - p.pos.x );
      PVector force = PVector.fromAngle(angle).setMag(1000);
      p.addForce(force);
      coolOffRail = 59;
    }
    p.state = ParticleMovementState.DEFAULT;
    p.trickForce = null;
}

void stopPlayerFromMoving() {
    player.setMovementState(ParticleMovementState.RAIL);
}

void keyPressed() {
  switch (key) {
    case 'w':
    case 'W':
      player.startMovingUp();
      break;
    case 'a':
    case 'A':
      player.startMovingLeft();
      break;
    case 's':
    case 'S':
      player.startMovingDown();
      break;
    case 'd':
    case 'D':
      player.startMovingRight();
      break;
    case ' ':
      getOffRail(player);
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == TAB) pauseScreen = true;
  }
  switch (key) {
  case 'w':
  case 'W':
    player.stopMovingUp();
    break;
  case 'a':
  case 'A':
    player.stopMovingLeft();
    break;
  case 's':
  case 'S':
    player.stopMovingDown();
    break;
  case 'd':
  case 'D':
    player.stopMovingRight();
    break;
  case TAB:
    pauseScreen = true;
    break;
  }
}

void mouseReleased() {
  if (mouseOverStartButton) {
    startScreen = mouseOverStartButton = false;
    playLevelChangeSound();
  } else if (mouseOverContinueButton) {
    pauseScreen = mouseOverContinueButton = false;
  } else if (mouseOverRetryButton) {
    reset();
  } else if (mouseOverExitButton) {
    exit();
  } else {
    fireBullets();
  }
}

void fireBullets() {
  if (player.bulletCount < 1) {
    shotgunOutOfAmmoSound.play();
    return;
  }
  shotgunSound.play();
  player.bulletCount -= 1;
  for (int i = 0; i < 5; i++) {
    float angle = random(player.minAngle, player.maxAngle);
    PVector dir = PVector.fromAngle(angle).setMag(50);
    PVector pos = PVector.add(player.pos, dir);
    Bullet b = new Bullet(pos, dir, 10, 100, player.getVelocity());
    visibleObjectList.add(b);
    collidableObjectList.add(b);
  }
}

boolean overRect(float x, float y, float w, float h) {
  return cameraX+mouseX>=x && cameraX+mouseX<=x+w && cameraY+mouseY>=y && cameraY+mouseY <=y+h;
}
