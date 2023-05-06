class Rail extends LineSegment implements VisibleObject {
  float m;
  float c;
  float Xmin;
  float Xmax;
  float Ymin;
  float Ymax;
  public Rail (PVector startPoint, PVector endPoint) {
    super(startPoint,endPoint);
    this.m = (endPoint.y - startPoint.y) / (endPoint.x - startPoint.x);
    this.c = startPoint.y - m * startPoint.x;
    Xmin = min(startPoint.x, endPoint.x);
    Xmax = max(startPoint.x, endPoint.x);
    Ymin = min(startPoint.y, endPoint.y);
    Ymax = max(startPoint.y, endPoint.y);
  }
  
  public void draw() {
    strokeWeight(35);
    strokeCap(ROUND);
    if (transitionCounter == 0) {
      stroke(200, 200, 200);
    }
    else if ((transitionCounter / 4) % 2 == 0) {
      stroke(0, 0, 100);
    } else {
      stroke(200, 10, 20);
    }
    line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
    strokeWeight(4);
  }
}
