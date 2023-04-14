import java.util.List;
import java.util.Optional;

boolean startScreen = true,
        pauseScreen = false,
        gameOverScreen = false,
        mouseOverStartButton = false,
        mouseOverContinueButton = false,
        mouseOverExitButton = false;

PImage bgImage;

int round = 1;

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

void setup() {
  fullScreen(); //<>// //<>//

  bgImage = loadImage("bg.jpg");

  mapWidth = 3 * displayWidth; //<>// //<>//
  mapHeight = 3 * displayHeight;

  player = new Player(new PVector(mapWidth/2, mapHeight/2));

  cameraX = player.pos.x - displayWidth/2;
  cameraY = player.pos.y - displayHeight/2;
  
  enemies = new ArrayList();
  for (int i = 0; i < 3; i++) {
    enemies.add(new Enemy(new PVector(mapWidth/2, mapHeight/2), player, int(random(2000,3000)), int(random(6,13))));
  }
  
  visibleObjectList = new ArrayList();
  visibleObjectList.add(player);
  visibleObjectList.addAll(enemies);
  
  collidableObjectList = new ArrayList();
  collidableObjectList.add(player);
  collidableObjectList.addAll(enemies);
  
  collisionDetector = new CollisionDetector();
}

void drawOcatgon() {
  float x = mapWidth/2;
  float y = mapHeight/2;
  float angle = TWO_PI / 8;
  fill(0,150,60);
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * octagonRadius;
    float sy = y + sin(a) * octagonRadius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

void drawStartScreen() {
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(159,20,0);
  text("Skate Park\nAfter Dark", cameraX + width/2, cameraY + height/2);

  rectMode(CORNER);

  float x = cameraX + width/2 - 50;
  float y = cameraY + width/2 ;
  float w = 100;
  float h = 50;
  if (overRect(x,y,w,h)) {
    fill(12,160,20);
    mouseOverStartButton = true;
  }
  else {
    fill(230,230,230);
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
  fill(159,20,0);
  text("Skate Park\nAfter Dark", cameraX + width/2, cameraY + height/4);
  text("Game Paused", cameraX + width/2, cameraY + height/2);

  rectMode(CORNER);
  float x = cameraX + width/2 - 65;
  float y = cameraY + width/2 ;
  float w = 130;
  float h = 50;
  if (overRect(x,y,w,h)) {
    fill(12,160,20);
    mouseOverContinueButton = true;
  }
  else {
    fill(230,230,230);
    mouseOverContinueButton = false;
  }
  rect(x, y, w, h);

  fill(255);
  String str = "Continue";
  text(str, cameraX + width/2, cameraY + width/2 + 20);

  y = cameraY + width/2 + 70;
  if (overRect(x,y,w,h)) {
    fill(12,160,20);
    mouseOverExitButton = true;
  }
  else {
    fill(230,230,230);
    mouseOverExitButton = false;
  }
  rect(x, y, w, h);
  fill(255);
  str = "Exit";
  text(str, cameraX + width/2, cameraY + width/2 + 90);
}

void draw() {
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
  
  for (Contact contact: contactList) {
    contact.resolve();
  }
  
  cameraX = player.pos.x - displayWidth/2;
  cameraY = player.pos.y- displayHeight/2;

  translate(-cameraX, -cameraY);

  //image(bgImage, 0, 0, mapWidth, mapHeight);
  fill(230);
  rect(0,0, mapWidth, mapHeight);
  drawOcatgon();

  if (startScreen) {
    drawStartScreen();
    return;
  }

  if (pauseScreen) {
    drawPauseScreen();
    return;
  }

  for (VisibleObject visibleObject: visibleObjectList) {
    visibleObject.draw();
  }
  
  
  translate(cameraX, cameraY);
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
  }
  if (mouseOverContinueButton) {
    pauseScreen = mouseOverContinueButton = false;
  }
  if (mouseOverExitButton) {
    exit();
  }
}

boolean overRect(float x, float y, float w, float h) {
  return cameraX+mouseX>=x && cameraX+mouseX<=x+w && cameraY+mouseY>=y && cameraY+mouseY <=y+h;
}
