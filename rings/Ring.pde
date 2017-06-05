
class Ring{
  public float innerR;
  public float outerR;
  public float x;
  public float y;
  int noPies = 100;//at least 10 pies;
  float anglePie = 2*PI/noPies; //angle of each pie
  public Point[] innerPoints;
  public Point[] outerPoints;
  float innerRMod = 1;
  float outerRMod = 1;
  float noiseX = 0;
  float noiseY = 0;
  float noiseZ = 0;
  public float noiseIncrement = 0.025;
  float textureAngleOffset = 0;
  float textureAngularSpeed = 0;
  float alpha = 1;
  boolean presence = true;

public Ring(float innerR, float outerR, float x, float y){
  this.innerR = innerR;
  this.outerR = outerR;
  this.x = x;
  this.y = y;
  this.noiseZ = innerR;
  innerPoints = new Point[noPies];
  outerPoints = new Point[noPies];
  for(int i = 0; i<noPies; i++){
    innerPoints[i] = new Point();
    outerPoints[i] = new Point();
  }
  calculateControlPoints();
  
  remapTexture();
}
public void update(){
  fade();
  textureAngleOffset += textureAngularSpeed;
  remapTexture();
  updateControlPoints();
}

public void updateControlPoints(){
  wiggle();
  calculateControlPoints();
}

void remapTexture(){
  float angle = textureAngleOffset;
  for(int i = 0; i<noPies; i++){
    innerPoints[i].setOriginRTheta(innerR-1, angle);
    outerPoints[i].setOriginRTheta(outerR-1, angle);
    angle+=anglePie;
  }
}

void calculateControlPoints(){
  float angle = 0;
  for(int i = 0; i<noPies; i++){
    innerPoints[i].setRTheta(innerR*innerRMod*(1-noise(angle, noiseY,noiseZ)/20), angle);
    outerPoints[i].setRTheta(outerR*outerRMod, angle);
    angle+=anglePie;
  }
}



public void modifyInnerR(float mod){

  innerRMod = interpolate(innerRMod,1+(outerR-innerR)*mod/innerR,0.1);
}

public void modifyOuterR(float mod){
  outerRMod = interpolate(outerRMod,1+(outerR-innerR)*mod/outerR,0.1);
}

public float interpolate(float original, float target, float originalToTargetRatio){
  return original*(1-originalToTargetRatio)+target*originalToTargetRatio;
}

public void wiggle(){
  noiseY+=noiseIncrement;
}

public void modifyTextureAngleOffset(float mod){
  textureAngleOffset+=mod;
}

public void fade(){
  if(presence){
    alpha += alpha>=1?0:0.005;
  }else{
    alpha -= alpha<=0?0:0.005;
  }
}

}
