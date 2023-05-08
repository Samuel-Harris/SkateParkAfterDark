import java.util.List;
import java.util.Optional;
import processing.sound.SoundFile;
import java.util.stream.IntStream;

boolean startScreen = true, storyScreen = false,
  pauseScreen = false,
  helpScreen = false,
  mouseOverStartButton = false,
  mouseOverHelpButton = false,
  mouseOverReturnButton = false,
  mouseOverContinueButton = false,
  mouseOverRetryButton = false,
  mouseOverExitButton = false;


int round, incre, fade, bulletRefillCount, coolOffRail, maxCoolOffRail;

String roundString;

float mapWidth,
  mapHeight,
  cameraX,
  cameraY,
  transitionCounter,
  storyScreenCounter,
  storyScreenMaxCounter,
  octagonRadius = 1500,   
  octagonMinX = 100000,
  octagonMaxX = -100000,
  octagonMinY = 100000,
  octagonMaxY = -100000, 
  tileXCount, tileYCount,
  tileWidth, tileHeight;

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
SoundFile deathSound;
final int numLevelChangeSounds = 4;
int lastLevelChangeSound = -1;
SoundFile[] levelChangeSounds = new SoundFile[numLevelChangeSounds];

int reloadFrames = 30;

DeathSoundState deathSoundState;
boolean deathSoundHasBeenPlayed;
final int deathSoundPauseFrames = 30;
int currDeathSoundPauseFrames;

PImage startScreenImage, introScreenImage, pauseScreenImage, helpScreenImage, gameOverScreenImage;

String[] story = {"Meet Tony \"The Skater\" Johnson, a legendary roller skater who \n loves nothing more than tearing up the skate park with his trusty gun at his side.\nTony's always been a bit of a troublemaker, but he's never had \n to deal with anything like this.",
                  "One fateful day, Tony was rolling down the street on his way to the \n skate park when he noticed a group of menacing-looking roadmen following him. \nThey were shouting all sorts of slangs at him, but Tony wasn't \n worried. He's faced down tougher foes than these guys.",
                  "As he arrived at the skate park, Tony heard the sound of steel knives \n being sharpened behind him. He turned around to see the roadmen, \nnow brandishing their weapons and moving in for the kill. \nTony knew he had to act fast.",
                  "With his skates on and his gun in hand, Tony began to dodge and weave \n his way through the skate park, performing tricks on rails and \n jumps to gain more bullets for his gun. The roadmen chased him, \n but Tony was too fast for them. He blasted them with his gun,\n taking them out one by one.",
                  "Tony's heart was pounding as he realized that he was up against \n something much more sinister than he had anticipated. \n These roadmen were dangerous, and they weren't going to stop \n until they had taken him out.",
                  "But Tony was determined to survive. He rolled through the skate park, \ndodging knives and firing his gun with deadly accuracy. \nThe roadmen fell one by one, until there were none left standing.",
                  "As Tony breathed a sigh of relief, he knew that he had made it to the \nnext level. He was one step closer to taking down the entire gang \nand claiming his place as the undisputed king of the skate park.",
                  "With a smirk on his face, Tony looked out over the empty skate park, \nknowing that he had just saved his own life. He may be a roller skater, \nbut he was also a gangster, and he knew how to handle himself when the going got tough. \nAnd with that, Tony rolled off into the sunset, ready to face whatever came his way.",
                  "Press the 'W' key to begin."
};

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
  
  introScreenImage = loadImage("background/intro.jpeg");
  startScreenImage = loadImage("background/start.jpeg");
  pauseScreenImage = loadImage("background/paused.jpeg");
  helpScreenImage = loadImage("background/control.jpeg");
  gameOverScreenImage = loadImage("background/end.jpeg");

  reset();
}

void reset() {
  round = 0;
  roundString = "";
  bulletRefillCount = 0;
  storyScreenMaxCounter = 255*story.length;
  storyScreenCounter = storyScreenMaxCounter;
  maxCoolOffRail = 30;
  coolOffRail = maxCoolOffRail;
  tileXCount = 2*10;
  tileYCount = 3*6;
  

  startScreen = true;
  pauseScreen = false;
  mouseOverStartButton = false;
  mouseOverContinueButton = false;
  mouseOverRetryButton = false;
  mouseOverExitButton = false;
  
  storyScreen = false;
  helpScreen = false;
  mouseOverHelpButton = false;
  mouseOverReturnButton = false;

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
  
  visibleObjectList = new ArrayList(); //<>//
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

  int distanceFromSide = 100;
  minX += distanceFromSide;
  maxX -= distanceFromSide;
  minY += distanceFromSide;
  maxY -= distanceFromSide;

  int numRails = 4;
  Rail[] rails = new Rail[numRails];
  float hexRad = (octagonMaxX - octagonMinX) /2;
  int minLengthOfRail = 600;
  int maxLengthOfRail = 900;
  
  float minDistanceBetweenRails = 500;
  float minAngleDifferenceBetweenRails = 0.3;
  
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
        isValid = !doesLineIntersect(rails[i], rails[j]) && getShortestDistanceBetweenRails(rails[i], rails[j]) > minDistanceBetweenRails && getAngleBetweenRails(rails[i], rails[j]) > minAngleDifferenceBetweenRails;
        if (!isValid) break;
      }
    } while (!isValid);
    collidableObjectList.add(rails[i]);
    visibleObjectList.add(rails[i]);
  }
}

float getAngleBetweenRails(Rail r1, Rail r2) {  
  return PVector.angleBetween(new PVector(1, r1.m), new PVector(1, r2.m));
}

float getShortestDistanceBetweenRails(Rail r1, Rail r2) {
  PVector r1Start = new PVector(r1.Xmin, r1.Ymin);
  PVector r1End = new PVector(r1.Xmax, r1.Ymax);
  
  PVector r2Start = new PVector(r2.Xmin, r2.Ymin);
  PVector r2End = new PVector(r2.Xmax, r2.Ymax);
  
  return min(min(min(r1Start.dist(r2Start), r1Start.dist(r2End)), r1End.dist(r2Start)), r1End.dist(r2Start));
}

float getAngleBetweenRails(Rail r1, Rail r2) {  
  return PVector.angleBetween(new PVector(1, r1.m), new PVector(1, r2.m));
}

float getShortestDistanceBetweenRails(Rail r1, Rail r2) {
  PVector r1Start = new PVector(r1.Xmin, r1.Ymin);
  PVector r1End = new PVector(r1.Xmax, r1.Ymax);
  
  PVector r2Start = new PVector(r2.Xmin, r2.Ymin);
  PVector r2End = new PVector(r2.Xmax, r2.Ymax);
  
  return min(min(min(r1Start.dist(r2Start), r1Start.dist(r2End)), r1End.dist(r2Start)), r1End.dist(r2Start));
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
  int transitionCounterMax = 300;
  
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
  
  if (transitionCounter >= player.getBulletCount() * transitionCounterMax / player.getMaxBullets()) {
    player.gainBullet();
  }
}

void drawStartScreen() {
  imageMode(CORNERS);
  image(startScreenImage, cameraX, cameraY, cameraX+width, cameraY + height);
  
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(159, 20, 0);
  text("Skate Park\nAfter Dark", cameraX + width/2, cameraY + height/4);

  rectMode(CORNER);

  float x = cameraX + width/2 - 65;
  float y = cameraY + height/2 + height/4 - 20;
  float w = 130;
  float h = 50;
  if (overRect(x, y, w, h)) {
    fill(12, 160, 20);
    mouseOverHelpButton = true;
  } else {
    noFill();
    mouseOverHelpButton = false;
  }
  rect(x, y, w, h);
  fill(255);
  String str = "Controls";
  text(str, cameraX + width/2, cameraY + height/2 + height/4 );
  
  y = cameraY + height/2 + height/4 + 70;
  if (overRect(x, y, w, h)) {
    fill(12, 160, 20);
    mouseOverStartButton = true;
  } else {
    noFill();
    mouseOverStartButton = false;
  }
  rect(x, y, w, h);
  fill(255);
  str = "Start!";
  text(str, cameraX + width/2, cameraY + height/2 + height/4 + 90);
}

void drawHelpScreen() {
  imageMode(CORNERS);
  image(helpScreenImage, cameraX, cameraY, cameraX+width, cameraY + height);
  
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(159, 20, 0);
  text("Controls", cameraX + width/2, cameraY + height/6);
  
  textAlign(CENTER, TOP);
  fill(255);
  text("Movement:", cameraX + width/4, cameraY + height/3);
  
  text("- Use the 'W' key to move forward.", cameraX + width/4 + 10, cameraY + height/3 + 50);
  text("- Use the 'A' key to move left.", cameraX + width/4 + 10, cameraY + height/3 + 100);
  text("- Use the 'S' key to move backward.", cameraX + width/4 + 10, cameraY + height/3 + 150);
  text("- Use the 'D' key to move right.", cameraX + width/4 + 10, cameraY + height/3 + 200);
  text("- Use the SPACE bar to get off the rail.", cameraX + width/4 + 10, cameraY + height/3 + 250);
  
  fill(255);
  text("Shooting:", cameraX + 3*width/4, cameraY + height/3);
  
  text("- Use the left mouse button to shoot your weapon.", cameraX + 3*width/4 + 10, cameraY + height/3 + 50);
  text("- Aim your weapon using the mouse cursor.", cameraX + 3*width/4 + 10, cameraY + height/3 + 100);
  text("- Take down all roadmen to progress\n through the levels.", cameraX + 3*width/4 + 10, cameraY + height/3 + 150);
  
  text("Press the 'Tab' key to pause the game.", cameraX + 2*width/4 + 10, cameraY + height/3 + 325);

  textAlign(CENTER, CENTER);
  rectMode(CORNER);
  float x = cameraX + width/2 - 50;
  float y = cameraY + width/2 ;
  float w = 100;
  float h = 50;
  if (overRect(x, y, w, h)) {
    fill(12, 160, 20);
    mouseOverReturnButton = true;
  } else {
    noFill();
    mouseOverReturnButton = false;
  }
  rect(x, y, w, h);
  fill(255);
  String str = "Return";
  text(str, cameraX + width/2, cameraY + width/2 + 20);
}

void drawStoryScreen() {
  imageMode(CORNERS);
  image(introScreenImage, cameraX, cameraY, cameraX+width, cameraY + height);
  storyScreenCounter--;
  if (storyScreenCounter<0) storyScreenCounter = storyScreenMaxCounter;
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(239, 230, 239, storyScreenCounter % 255);
  stroke(0);
  text(story[story.length -1 - (int)storyScreenCounter/255], cameraX + width/2, cameraY + height/4 + storyScreenCounter % 255);
  
  if (storyScreenCounter % 255 < 130) {
    fill(239, 230, 239, 255);
    text(story[story.length  - (int)storyScreenCounter/255], cameraX + width/2, cameraY + height/4 + 255 + storyScreenCounter % 255);
  }
  
  text(story[8], cameraX + width/2, cameraY + 9*height/10);

}

void drawPauseScreen() {
  imageMode(CORNERS);
  image(pauseScreenImage, cameraX, cameraY, cameraX+width, cameraY + height);
  
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(159, 20, 0);
  text("Skate Park\nAfter Dark", cameraX + width/2, cameraY + height/4);
  text("Game Paused", cameraX + width/2, cameraY + height/2);

  rectMode(CORNER);
  float x = cameraX + width/2 - 65;
  float y = cameraY + height/2 + height/4;
  float w = 130;
  float h = 50;
  if (overRect(x, y, w, h)) {
    fill(12, 160, 20);
    mouseOverContinueButton = true;
  } else {
    noFill();
    mouseOverContinueButton = false;
  }
  rect(x, y, w, h);

  fill(255);
  String str = "Continue";
  text(str, cameraX + width/2, cameraY + height/2 + height/4 + 20);

  y = cameraY + height/2 + height/4 + 70;
  if (overRect(x, y, w, h)) {
    fill(12, 160, 20);
    mouseOverHelpButton = true;
  } else {
    noFill();
    mouseOverHelpButton = false;
  }
  rect(x, y, w, h);
  fill(255);
  str = "Control";
  text(str, cameraX + width/2, cameraY + height/2 + height/4 + 90);
  
  y = cameraY + height/2 + height/4 + 140;
  if (overRect(x, y, w, h)) {
    fill(12, 160, 20);
    mouseOverExitButton = true;
  } else {
    noFill();
    mouseOverExitButton = false;
  }
  rect(x, y, w, h);
  fill(255);
  str = "Exit";
  text(str, cameraX + width/2, cameraY + height/2 + height/4 + 160);
}

void drawGameOverScreen() {
  imageMode(CORNERS);
  image(gameOverScreenImage, cameraX, cameraY, cameraX+width, cameraY + height);
  
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
  
  if (coolOffRail < maxCoolOffRail){
    if (--coolOffRail == 0) coolOffRail = maxCoolOffRail;
  }
  
  for (Contact contact : contactList) {
    if (contact.collidableA instanceof Bullet && contact.collidableB instanceof Bullet) continue;
    if (contact.collidableA instanceof Bullet && contact.collidableB instanceof Player) continue;
    if (contact.collidableA instanceof Player && contact.collidableB instanceof Bullet) continue;

    if (contact.collidableA instanceof Rail && contact.collidableB instanceof Particle) {
      Rail rai = (Rail) contact.collidableA;
      Particle p = (Particle) contact.collidableB;
      if (p.state == ParticleMovementState.DEFAULT) {
        if (p instanceof Player && coolOffRail < maxCoolOffRail) continue;
        getOnTheRail(p, rai);
      }
      contact.collidableB.addForce(p.trickForce);
      continue;
    } else if (contact.collidableB instanceof Rail && contact.collidableA instanceof Particle) {
      Rail rai = (Rail) contact.collidableB;
      Particle p = (Particle) contact.collidableA;
      if (p.state == ParticleMovementState.DEFAULT) {
        if (p instanceof Player && coolOffRail < maxCoolOffRail) continue;
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
  
  if (helpScreen) {
    drawHelpScreen();
    return;
  }
  
  if (startScreen) {
    drawStartScreen();
    return;
  }
  
  if (storyScreen) {
    drawStoryScreen();
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
      coolOffRail = maxCoolOffRail-1;
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
      if (storyScreen) storyScreen = false;
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
  if (mouseOverReturnButton) {
    print("hello");
    helpScreen = mouseOverReturnButton = false;
  } else if (mouseOverStartButton) {
    startScreen = mouseOverStartButton = false;
    storyScreen = true;
    playLevelChangeSound();
  } else if (mouseOverHelpButton) {
    helpScreen = true;
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
