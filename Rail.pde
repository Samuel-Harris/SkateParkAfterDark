//class Rail implements VisibleObject {
//  PVector startPoint;
//  PVector endPoint;
//  PartRail top, bottom;
//  public Rail (PVector startPoint, PVector endPoint) {
//    this.startPoint = startPoint;
//    this.endPoint = endPoint;
//    top = new PartRail(startPoint,endPoint);
//    bottom = new PartRail(startPoint,endPoint);
//  }
//  public void draw() {
//    strokeWeight(35);
//    strokeCap(ROUND);
//    stroke(200, 200, 200);
//    line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
//    strokeWeight(4);
//  }
//}

class Rail extends LineSegment implements VisibleObject {
  public Rail (PVector startPoint, PVector endPoint) {
    super(startPoint,endPoint);
  }
  
  public void draw() {
    strokeWeight(35);
    strokeCap(ROUND);
    stroke(200, 200, 200);
    line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
    strokeWeight(4);
  }
}
