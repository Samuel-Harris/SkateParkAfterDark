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
Particle player;

void setup() {
  fullScreen();

  bgImage = loadImage("bg.jpg");

  mapWidth = 3 * displayWidth;
  mapHeight = 3 * displayHeight;

   playerX = mapWidth/2;
   playerY = mapHeight/2;

  cameraX = playerX - displayWidth/2;
  cameraY = playerY - displayHeight/2;

}

void draw() {
  cameraX = playerX - displayWidth/2;
  cameraY = playerY - displayHeight/2;

  translate(-cameraX, -cameraY);

  image(bgImage, 0, 0, mapWidth, mapHeight);

  if (startScreen) {
    textAlign(CENTER, CENTER);
    textSize(32);
    fill(159,20,0);
    text("Skate Park\nAfter Dark", cameraX + width/2, cameraY + height/2);
    return;
  }

  player.draw(!pauseScreen);



  translate(cameraX, cameraY);
}
