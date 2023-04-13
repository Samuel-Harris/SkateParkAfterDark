import java.util.List;

boolean startScreen = true,
        pauseScreen = false,
        gameOverScreen = false;

PImage bgImage;

int round = 1;

float mapWidth,
      mapHeight,
      cameraX,
      cameraY;

float playerX, playerY;
Player player;

List<VisibleObject> visibleObjectList;

void setup() {
  fullScreen();

  bgImage = loadImage("bg.jpg");

  mapWidth = 3 * displayWidth; //<>//
  mapHeight = 3 * displayHeight;

   playerX = mapWidth/2;
   playerY = mapHeight/2;

  player = new Player(new PVector(displayWidth/2, displayHeight/2)); 

  cameraX = player.pos.x - displayWidth/2;
  cameraY = player.pos.y- displayHeight/2;
  
  visibleObjectList = new ArrayList();
  visibleObjectList.add(player);
}

void draw() {
  cameraX = player.pos.x - displayWidth/2;
  cameraY = player.pos.y- displayHeight/2;

  translate(-cameraX, -cameraY);

  image(bgImage, 0, 0, mapWidth, mapHeight);

  if (startScreen) {
    textAlign(CENTER, CENTER);
    textSize(32);
    fill(159,20,0);
    text("Skate Park\nAfter Dark", cameraX + width/2, cameraY + height/2);
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
