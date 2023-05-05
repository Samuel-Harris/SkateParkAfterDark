class HUD implements VisibleObject {
  private final Player player;
  private final PImage[] heartSprites;
  private final int heartWidth;
  private final int[] heartXPositions;
  private final float hitInvulnerabilityFrames;
  private final int numHeartSprites;
  
  public HUD(Player player) {
    this.player = player;
    
    numHeartSprites = 9;
    
    heartSprites = new PImage[numHeartSprites];
    
    heartWidth = (int) (0.1*height);
    
    for (int i=0; i<numHeartSprites; i++) {
      heartSprites[i] = loadImage("heart/heart_" + str(i) + ".png");
      heartSprites[i].resize(heartWidth, heartWidth);
    }
    
    heartXPositions = new int[player.getMaxLives()];
    for (int i=0; i<player.getMaxLives(); i++) {
      heartXPositions[i] = i*heartWidth + heartWidth;
    }
    
    hitInvulnerabilityFrames = player.getHitInvulnerabilityFrames();
  }
  
  public void draw() {
    int livesLeft = player.getLives();
    for (int i=0; i<livesLeft; i++) {
      image(heartSprites[0], heartXPositions[i], height - heartWidth);
    }
    
    if (livesLeft < player.getMaxLives()) {
      image(heartSprites[(int) ((numHeartSprites - 1) * (1 - player.getHitInvulnerabilityFramesLeft() / hitInvulnerabilityFrames))], heartXPositions[livesLeft], height - heartWidth);
    }
    
    for (int i=livesLeft+1; i<player.getMaxLives(); i++) {
      image(heartSprites[numHeartSprites-1], heartXPositions[i], height - heartWidth);
    }
    
    fill(255);
    textSize(104); 
    textAlign(CENTER,CENTER);
    text(player.bulletCount, width - 100, height - heartWidth); 
  }  
}
