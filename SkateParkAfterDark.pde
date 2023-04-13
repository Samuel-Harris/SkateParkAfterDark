import java.util.List;

boolean startScreen = true,
        pauseScreen = false,
        gameOverScreen = false,
        mouseOverStartButton = false;

PImage bgImage;

int round = 1;

float mapWidth,
      mapHeight,
      cameraX,
      cameraY,
      octagonRadius = 1500;

Player player;

List<VisibleObject> visibleObjectList;

void setup() {
  fullScreen();

  bgImage = loadImage("bg.jpg");
  
  //frameRate(60);

  mapWidth = 3.5 * displayWidth; //<>//
  mapHeight = 5 * displayHeight;
  


  player = new Player(new PVector(mapWidth/2, mapHeight/2)); 

  cameraX = player.pos.x - displayWidth/2;
  cameraY = player.pos.y - displayHeight/2;
  
  visibleObjectList = new ArrayList();
  visibleObjectList.add(player);
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

void draw() {
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

  for (VisibleObject visibleObject: visibleObjectList) {
    visibleObject.draw();
  }
  
  translate(cameraX, cameraY);
}

void keyPressed() {
  switch (key) {
    case 'w':
      player.startMovingUp();
      break;
    case 'a':
      player.startMovingLeft();
      break;
    case 's':
      player.startMovingDown();
      break;
    case 'd':
      player.startMovingRight();
      break;
  }
}

void keyReleased() {
  switch (key) {
    case 'w':
      player.stopMovingUp();
      break;
    case 'a':
      player.stopMovingLeft();
      break;
    case 's':
      player.stopMovingDown();
      break;
    case 'd':
      player.stopMovingRight();
      break;
  }
}

void mouseReleased() {
  if (mouseOverStartButton) {
    startScreen = mouseOverStartButton = false;
  }
}

boolean overRect(float x, float y, float w, float h) {
  return cameraX+mouseX>=x && cameraX+mouseX<=x+w && cameraY+mouseY>=y && cameraY+mouseY <=y+h;
} 
