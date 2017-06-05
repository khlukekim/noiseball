class Point{
  public float x;
  public float y; 
  public float r;
  public float theta;
  public float originX;
  public float originY;


public Point(){
  
}

public void setXY(float x, float y){
  this.x = x;
  this.y = y;
  this.r = dist(0,0,x,y);
  this.theta = atan2(y,x);
}

public void setRTheta(float r, float theta){
  this.r = r;
  this.theta = theta;
  this.x = cos(theta)*r;
  this.y = sin(theta)*r;
}

public void setOriginXY(float x, float y){
  this.originX = x;
  this.originY = y;
}

public void copyOriginXYFromXY(){
  this.originX = this.x;
  this.originY = this.y;
}

public void setOriginRTheta(float r, float theta){
  this.originX = cos(theta)*r;
  this.originY = sin(theta)*r;
}
}
