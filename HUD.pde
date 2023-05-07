class HUD implements VisibleObject {
  private final Player player;
  private final PImage[] heartSprites;
  private final int heartWidth;
  private final int[] heartXPositions;
  private final float hitInvulnerabilityFrames;
  private final int numHeartSprites;
  private final float transitionCounterFrames;
  private int numRevivedHearts;
  private float reviveCounter;

  
  public HUD(Player player, int transitionCounterMax) {
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
    
    this.transitionCounterFrames = transitionCounterMax/3;
    this.reviveCounter = transitionCounterFrames;
    this.numRevivedHearts = 0;
  }
  
  public void draw() {
    int livesLeft = player.getLives();
    for (int i=0; i<livesLeft; i++) {
      image(heartSprites[0], heartXPositions[i], height - heartWidth);
    }
    
    for (int i=livesLeft+1; i<player.getMaxLives(); i++) {
      image(heartSprites[numHeartSprites-1], heartXPositions[i], height - heartWidth);
    }
    
    if (livesLeft < player.getMaxLives()) {
      if (transitionCounter == 0) {
        image(heartSprites[(int) ((numHeartSprites - 1) * (1 - player.getHitInvulnerabilityFramesLeft() / hitInvulnerabilityFrames))], heartXPositions[livesLeft], height - heartWidth);
      }
      else {
        int decwea = (int) ((numHeartSprites - 1) * ( reviveCounter/ transitionCounterFrames));
        int heartIndex = livesLeft + numRevivedHearts;
        for (int i = livesLeft; i < player.getMaxLives(); i++) {
          image(heartSprites[i < heartIndex ? 0 : i == heartIndex ? decwea : (numHeartSprites - 1)], heartXPositions[i], height - heartWidth);
        }
        if (decwea == 0) { //<>//
          numRevivedHearts++;
          this.reviveCounter = transitionCounterFrames;
        }
        reviveCounter--;
      }
    }
    
    fill(255);
    textSize(104); 
    textAlign(CENTER,CENTER);
    text(player.bulletCount, width - 100, height - heartWidth); 
  }  
}
