class Particle {
  float x;
  float y;
  float vx;
  float vy;
  float halfWidth = width / 2;
  float halfHeight = height / 2;
  public float mod = 1;
  color c;
  float ang;
  public float v = 0.3;
  
  Particle(){
    float a = random(2*PI);
    float r = random(particleRadius);
    x = width / 2 + r*cos(a);
    y = width / 2 + r*sin(a);
    ang = random(2*PI);
    vx = v*sin(ang);
    vy = v*cos(ang);
    colorMode(HSB, 1);
    c = color(0.5+(random(0.1)), 0.3+ random(0.7), 0.4+random(0.4));
  }
  
  public void setSpeed(float s){
    v = s;
    vx = v*cos(ang);
    vy = v*sin(ang);
  }
  
  public void relocate(){
    
    float a = random(2*PI);
    float r = random(particleRadius);
    x = width / 2 + r*cos(a);
    y = width / 2 + r*sin(a);
  }
  
  void run(){
    x += vx;
    y += vy;
    float dx = halfWidth - x;
    float dy = halfHeight - y;
    if (sqrt((dx * dx) + (dy * dy)) > particleRadius){
       ang = atan2(dy, dx) / PI * 180;
       vx = v*cos(ang);
       vy = v*sin(ang);
    }
    int xx = int((x-halfWidth)*mod+halfWidth);
    int yy = int((y-halfHeight)*mod+halfHeight);
    if(xx >= 0 && xx < width && yy >= 0 && yy < height){
      pixels[xx + width * yy] = c;
    }
  }
}