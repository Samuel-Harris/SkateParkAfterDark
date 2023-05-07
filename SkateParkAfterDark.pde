import java.util.List;
import java.util.Optional;
import processing.sound.SoundFile;
import java.util.stream.IntStream;

boolean startScreen = true,
  pauseScreen = false,
  mouseOverStartButton = false,
  mouseOverContinueButton = false,
  mouseOverRetryButton = false,
  mouseOverExitButton = false,
  controlOpen = true;


int round, incre, fade, bulletRefillCount, coolOffRail;

String roundString;

float mapWidth,
  mapHeight,
  cameraX,
  cameraY,
  transitionCounter,
  octagonRadius = 1500,   
  octagonMinX = 100000,
  octagonMaxX = -100000,
  octagonMinY = 100000,
  octagonMaxY = -100000, 
  tileXCount, tileYCount,
  tileWidth, tileHeight;
 //<>//
int characterSpriteWidth = 200;
Player player;

List<VisibleObject> visibleObjectList;
List<Collidable> collidableObjectList;

CollisionDetector collisionDetector;

List<Enemy> enemies;
int enemyCount;
PShape octagon;
int[][] tiles;
int currentCol = 0;

HUD hud;

SoundFile backgroundMusic;
SoundFile skatingSound;
SoundFile shotgunSound;
SoundFile shotgunReloadSound;
SoundFile shotgunOutOfAmmoSound;
SoundFile stabSound;
SoundFile grindingSound;
final int numLevelChangeSounds = 4;
SoundFile[] levelChangeSounds = new SoundFile[numLevelChangeSounds];

int reloadFrames = 30; 

void setup() {
  imageMode(CENTER);

  fullScreen();

  mapWidth = 5 * displayWidth;
  mapHeight = 5 * displayHeight;

  backgroundMusic = new SoundFile(this, "music/background_music.wav");
  backgroundMusic.amp(0.8);
  backgroundMusic.jump(int(random(backgroundMusic.duration())));

  skatingSound = new SoundFile(this, "player_sounds/skating_sound.wav");

  shotgunSound = new SoundFile(this, "player_sounds/shotgun_fire.wav");
  shotgunSound.amp(0.2);
  
  shotgunReloadSound = new SoundFile(this, "player_sounds/shotgun_reload.wav");
  shotgunReloadSound.amp(0.2);

  grindingSound = new SoundFile(this, "player_sounds/grind.wav");

  for (int i=0; i<4; i++) {
    levelChangeSounds[i] = new SoundFile(this, "roadman_sounds/level_change_" + i + ".wav");
  }
  
  shotgunOutOfAmmoSound = new SoundFile(this, "player_sounds/out_of_ammo.wav");
  
  stabSound = new SoundFile(this, "player_sounds/stab.wav");

  reset();
}

void reset() {
  round = 0;
  roundString = "";
  bulletRefillCount = 0;
  coolOffRail = 60;
  tileXCount = 2*10;
  tileYCount = 3*6;
  

  startScreen = true;
  pauseScreen = false;
  mouseOverStartButton = false;
  mouseOverContinueButton = false;
  mouseOverRetryButton = false;
  mouseOverExitButton = false;

  player = new Player(new PVector(mapWidth/2, mapHeight/2), skatingSound, stabSound, characterSpriteWidth);

  roundGenerator();
}

void roundGenerator() {
  if (!IntStream.range(0, numLevelChangeSounds).anyMatch(i -> levelChangeSounds[i].isPlaying())) {
    levelChangeSounds[int(random(numLevelChangeSounds))].play();
  }

  incre = -10;
  fade = 200;
  round++;
  roundString += "I ";
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


  visibleObjectList = new ArrayList();
  visibleObjectList.add(player);
  visibleObjectList.addAll(enemies);

  hud = new HUD(player, 300);
  player.resetLives();

  collidableObjectList = new ArrayList();
  collidableObjectList.add(player);
  collidableObjectList.addAll(enemies);

  collisionDetector = new CollisionDetector();

  PVector octagonCentre = new PVector(mapWidth/2, mapHeight/2);
  float EIGHTH_PI = PI / 8;
  octagon = createShape();
  octagon.beginShape();
  //octagon.fill(0, 150, 60);
  octagon.strokeWeight(4);
  octagon.noFill();
  float prevSx = octagonCentre.x + cos(-EIGHTH_PI) * octagonRadius;
  float prevSy = octagonCentre.y + sin(-EIGHTH_PI) * octagonRadius;
  for (int i=0; i<8; i++) {
    float sx = octagonCentre.x + cos(i*QUARTER_PI+EIGHTH_PI) * octagonRadius;
    float sy = octagonCentre.y + sin(i*QUARTER_PI+EIGHTH_PI) * octagonRadius;
    octagon.vertex(sx, sy);

    collidableObjectList.add(new LineSegment(new PVector(prevSx, prevSy), new PVector(sx, sy)));
    prevSx = sx;
    prevSy = sy;

    octagonMinX = min(octagonMinX, sx);
    octagonMaxX = max(octagonMaxX, sx);
    octagonMinY = min(octagonMinY, sy);
    octagonMaxY = max(octagonMaxY, sy);
  }
  octagon.endShape(CLOSE);
  
  tileWidth = (octagonMaxX-octagonMinX)/tileXCount;
  tileHeight = (octagonMaxY-octagonMinY)/tileYCount;
  
  tiles = new int[(int)tileXCount][(int)tileYCount];

  Rail[] rails = new Rail[3];
  float hexRad = (octagonMaxX - octagonMinX) /2;
  int minLengthOfRail = 600;
  int maxLengthOfRail = 700;
  for (int i = 2; i >= 0; i--) {
    PVector st;
    PVector en;
    boolean doesIntersect = false;
    do {
      do {
        st = new PVector(random( octagonMinX, octagonMaxX), random( octagonMinY, octagonMaxY));
      } while (PVector.dist(st, octagonCentre) > hexRad);

      do {
        float rad = random(minLengthOfRail, maxLengthOfRail);
        float Xmin = st.x - rad;
        float Xmax = st.x + rad;
        float Ymin = st.y - rad;
        float Ymax = st.y + rad;
        en = new PVector(random( Xmin, Xmax),random( Ymin, Ymax));
      }  while (PVector.dist(en, octagonCentre) > hexRad);
      
      rails[i] = new Rail(st,en);
      for (int j = i+1; j < 3; j++) {
        doesIntersect = doesLineIntersect(rails[i], rails[j]);
        if (doesIntersect) break;
      }
    } while (doesIntersect);
    collidableObjectList.add(rails[i]);
    visibleObjectList.add(rails[i]);
  }
}

void updateTiles(boolean isOdd) {
  tiles = new int[(int)tileXCount][(int)tileYCount];
  int col;
  do {
    col =  (int) random(1,8);
  } while (currentCol == col);
  currentCol = col;
  
  for (int i = 0; i < tileXCount; i++){
    for (int j = 0; j < tileYCount; j++){
      tiles[i][j] = isOdd ? col:0;
      isOdd = !isOdd;
    }
    isOdd = !isOdd;
  }
}
void drawTiles() {
  fill(230);
  rect(0, 0, mapWidth, mapHeight);
  for (int i = 0; i < tileXCount; i++){
    for (int j = 0; j < tileYCount; j++){
      switch (tiles[i][j]) {
        case 1:
          fill(#C0C0C0);
        break;
        case 2:          
          fill(#FFD700);
        break;
        case 3:          
          fill(#FF69B4);
        break;
        case 4:
          fill(#9400D3);
        break;
        case 5:          
          fill(#00BFFF);
        break;
        case 6:          
          fill(#00FF00);
        break;
        case 7:          
          fill(#ffa500);
        break;
        default:
        fill(230);
        break;
      }
      stroke(0);
      strokeWeight(1);
      rect((i*tileWidth) + octagonMinX ,(j*tileHeight) + octagonMinY,tileWidth,tileHeight);
    }
  }
  
  for (int i = 0; i < octagon.getVertexCount()-1; i++) {
    PVector v1 = octagon.getVertex(i);
    PVector v2 = octagon.getVertex(i+1);
    if (i%2==0) {
      fill(230);
      stroke(230);
      strokeWeight(4);
      if (i%4==0) triangle(v1.x, v2.y, v1.x, v1.y, v2.x, v2.y);
      else triangle(v2.x, v1.y, v1.x, v1.y, v2.x, v2.y);
    }

  }

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
  transitionCounter++;
  textAlign(LEFT, LEFT);
  textSize(52);
  if (fade >= 200) incre = -10;
  else if (fade <= 50) incre = 10;
  fade += incre;
  fill(159, 20, 0, fade);
  if (transitionCounter == 0) {
  } else if (transitionCounter < 150) {
    
    text(roundString, 30, 50);
  } else if (transitionCounter < 300) {
    text(roundString +"I", 30, 50);
  } else {
    roundGenerator();
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
  if (!backgroundMusic.isPlaying()) {
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
  
  if (frameCount % 60 == 0) {
    updateTiles(frameCount%120 == 0);
  }

  cameraX = player.pos.x - displayWidth/2;
  cameraY = player.pos.y - displayHeight/2;

  translate(-cameraX, -cameraY);

  drawTiles();
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
    //drawGameOverScreen();
    //getOffRail(List.of(player));
    //return;
  }

  for (VisibleObject visibleObject : visibleObjectList) {
    visibleObject.draw();
  }

  translate(cameraX, cameraY);

  if (enemies.isEmpty()) {
    transitionScreen();
  }

  if (!controlOpen) {
    if (bulletRefillCount%reloadFrames == 0) {
      shotgunReloadSound.play();
      player.gainBullet();
    }
    bulletRefillCount++;
  }

  hud.draw();
}

void getOnTheRail(Particle p, Rail rai) {
  if (p instanceof Player) {
    grindingSound.loop();
    stopPlayerFromMoving();
  }
  p.forceAccumulator = new PVector(0, 0);
  PVector dir = p.getVelocity();
  float d = PVector.dot(dir, rai.getNormalisedVector());
  p.state = d>0 ? ParticleMovementState.RAILLEFT: ParticleMovementState.RAILRIGHT;
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
      controlOpen = true;
      float angle = atan2(cameraY+mouseY - p.pos.y, cameraX+mouseX - p.pos.x );
      PVector force = PVector.fromAngle(angle).setMag(1000);
      p.addForce(force);
      coolOffRail = 59;
    }
    p.state = ParticleMovementState.DEFAULT;
    p.trickForce = null;
}

void stopPlayerFromMoving() {
  controlOpen = false;
}

void keyPressed() {
  if (controlOpen) {
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
    }
  }
  else {
    if (key == ' '){
      print("hello");
      
      getOffRail(player);
    }
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
    levelChangeSounds[int(random(numLevelChangeSounds))].play();
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
    Bullet b = new Bullet(pos, dir, 10, 100);
    visibleObjectList.add(b);
    collidableObjectList.add(b);
  }
}

boolean overRect(float x, float y, float w, float h) {
  return cameraX+mouseX>=x && cameraX+mouseX<=x+w && cameraY+mouseY>=y && cameraY+mouseY <=y+h;
}
