class HUD implements VisibleObject {
  private final Player player;
  private final PImage[] heartSprites;
  private final int heartWidth;
  private final int[] heartXPositions;
  
  public HUD(Player player) {
    this.player = player;
    
    heartSprites = new PImage[9];
    
    heartWidth = (int) (0.1*height);
    
    for (int i=0; i<9; i++) {
      heartSprites[i] = loadImage("heart/heart_" + str(i) + ".png");
      heartSprites[i].resize(heartWidth, heartWidth);
    }
    
    heartXPositions = new int[player.getMaxLives()];
    for (int i=0; i<player.getMaxLives(); i++) {
      heartXPositions[i] = i*heartWidth + heartWidth;
    }
  }
  
  public void draw() {
    int livesLeft = player.getLives();
    for (int i=0; i<livesLeft; i++) {
      image(heartSprites[0], heartXPositions[i], height - heartWidth);
    }
    
    for (int i=livesLeft; i<player.getMaxLives(); i++) {
      image(heartSprites[8], heartXPositions[i], height - heartWidth);
    }
  }
}
