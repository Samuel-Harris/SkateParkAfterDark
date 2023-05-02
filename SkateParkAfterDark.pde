import java.util.List;
import java.util.Optional;
import processing.sound.SoundFile;

boolean startScreen = true,
  pauseScreen = false,
  mouseOverStartButton = false,
  mouseOverContinueButton = false,
  mouseOverRetryButton = false,
  mouseOverExitButton = false;


int round = 0,
  transitionCounter = 0;

float mapWidth,
  mapHeight,
  cameraX,
  cameraY,
  octagonRadius = 1500;

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

void setup() {
  imageMode(CENTER);

  fullScreen();

  mapWidth = 5 * displayWidth;
  mapHeight = 5 * displayHeight;

  backgroundMusic = new SoundFile(this, "music/background_music.wav");
  backgroundMusic.amp(0.8);
  backgroundMusic.jump(int(random(backgroundMusic.duration())));
  
  skatingSound = new SoundFile(this, "sound_effects/skating_sound.wav");
  
  reset();
}

void reset() {
  startScreen = true;
  pauseScreen = false;
  mouseOverStartButton = false;
  mouseOverContinueButton = false;
  mouseOverRetryButton = false;
  mouseOverExitButton = false;
  
  player = new Player(new PVector(mapWidth/2, mapHeight/2), skatingSound);

  roundGenerator();
}

void roundGenerator() {
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
    enemies.add(new Enemy(new PVector(enX, enY), player, int(random(2000, 3000)), int(random(6, 13)), 500));
  }

  visibleObjectList = new ArrayList();
  visibleObjectList.add(player);
  visibleObjectList.addAll(enemies);

  hud = new HUD(player);

  collidableObjectList = new ArrayList();
  collidableObjectList.add(player);
  collidableObjectList.addAll(enemies);

  collisionDetector = new CollisionDetector();

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
  }
  octagon.endShape(CLOSE);
}

void transitionScreen() {
  transitionCounter++;
  textAlign(CENTER, CENTER);
  textSize(52);
  fill(159, 20, 0);
  if (transitionCounter == 0) {
    // add sound here
  } else if (transitionCounter < 150) {
    text("I", 30, 50);
  } else if (transitionCounter < 300) {
    text("I I", 30, 50);
  } else {
    // add sound here as well
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

  for (Contact contact : contactList) {
    if (contact.collidableA instanceof Bullet && contact.collidableB instanceof Bullet) continue;
    if (contact.collidableA instanceof Bullet && contact.collidableB instanceof Player) continue;
    if (contact.collidableA instanceof Player && contact.collidableB instanceof Bullet) continue;
    contact.resolve();
  }

  cameraX = player.pos.x - displayWidth/2;
  cameraY = player.pos.y - displayHeight/2;

  translate(-cameraX, -cameraY);

  //image(bgImage, 0, 0, mapWidth, mapHeight);
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
    return;
  }

  for (VisibleObject visibleObject : visibleObjectList) {
    visibleObject.draw();
  }

  translate(cameraX, cameraY);

  if (enemies.isEmpty()) {
    transitionScreen();
  }

  hud.draw();
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
  if (player.bulletCount < 5) {
    return;
  }
  player.bulletCount -= 5;
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
