import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

//audio
Minim minim;
FFT fft;
AudioPlayer song;
BeatDetect beat;

//background image
PImage img;
//ball image
PImage ballImage;
int ballImageR;
float ballImageRatio;


float imageWidth;
float imageHeight;
float lastTimeStamp;
float ringSizeModifier = 0.05;
float particleSpeed = 0.3;
// graphics
Ring[] rings;
int noRings = 1; // howmany rings will be used?
int bandsPerRing;
float ringColorOffset = 0;
boolean moveRingColor = false;
boolean drawParticles = false;
boolean useBeat = true;

// set to true to turn on gradient color
boolean useFillColor = false;
boolean tintColor = false;
// gradient colors; from the inside out
color c2 = #d06020;
color c1 = #80c050;

int particleNum = 5000;
int particleRadius = 160;
Particle[] particles = new Particle[particleNum];

void setup(){
  size(500, 500, P2D);
  
  for (int i = 0; i<particleNum; i++){
    particles[i] = new Particle();
  }
  
  img = loadImage("single_cover_website2.jpg");
  ballImage = loadImage("star.jpg");
  
  ballImageR = ballImage.width / 2;
  
  imageWidth = img.width;
  imageHeight = img.height;
  
  
  minim = new Minim(this);
  song = minim.loadFile("song.mp3");
  beat = new BeatDetect();
  beat.detectMode(BeatDetect.FREQ_ENERGY);
  
  song.play();
  fft = new FFT(song.bufferSize(), song.sampleRate());
  println(fft.specSize());
  initRings();
  lastTimeStamp=millis();
}



void draw(){
  fill(0, 0.07);
  tint(1, 0.07);
  image(img, 0,0);
  noTint();
  rect(0,0,width, height);
  fft.forward(song.mix);
  beat.detect(song.mix);
  float mod;
  if(moveRingColor){
    ringColorOffset += 0.15;
    setColor(c1, c2, rings);
  }
  for(int i = 0; i<noRings; i++){
   float level = 0;
    for(int j = 0; j<bandsPerRing; j++){
      level+=fft.getBand(i*bandsPerRing+j);
    }
    
    if(useBeat){
      mod = beat.isRange(18, 26, 3)?5:1;
    }else{
      mod = 10*(log(level)-2);
    }
    mod=mod<0?0:mod*ringSizeModifier;
    rings[i].modifyOuterR(mod);
    rings[i].modifyInnerR(mod);
    rings[i].update();
    drawARing(rings[i]);
  }
  if(drawParticles){
    
    loadPixels();
    for (int i = 0; i<particleNum; i++){
      particles[i].run();
    }
    updatePixels(); 
  }
}


void drawARing(Ring ring){
  if (ring.drawSeparate) {
    noStroke();
    for (int i = 0; i < ring.noPies; i++) {
      beginShape();
      if (ring.useFillColor) {
        if (tintColor) {
          tint(ring.fillColors[i], ring.alpha);
          texture(ballImage);
        } else {
          fill(ring.fillColors[i],ring.alpha);
        }
      } else {
        texture(ballImage);
      }
      int j = i+1;
      if (j >= ring.noPies) {
        j = 0;
      }
      vertex(ring.x+ring.outerPoints[i].x, ring.y+ring.outerPoints[i].y, ballImage.width/2+ring.outerPoints[i].originX, ballImage.height/2+ring.outerPoints[i].originY);
      vertex(ring.x+ring.outerPoints[j].x, ring.y+ring.outerPoints[j].y, ballImage.width/2+ring.outerPoints[j].originX, ballImage.height/2+ring.outerPoints[j].originY);
      vertex(ring.x+ring.innerPoints[j].x, ring.y+ring.innerPoints[j].y, ballImage.width/2+ring.innerPoints[j].originX, ballImage.height/2+ring.innerPoints[j].originY);
      vertex(ring.x+ring.innerPoints[i].x, ring.y+ring.innerPoints[i].y, ballImage.width/2+ring.innerPoints[i].originX, ballImage.height/2+ring.innerPoints[i].originY);
      endShape();
    }
  } else {
    noStroke();
    beginShape();
    
    if (ring.useFillColor) {
      if (tintColor) {
        tint(ring.fillColor, ring.alpha);
        texture(ballImage);
      } else {
        fill(ring.fillColor,ring.alpha);
      }
    } else {
      texture(ballImage);
    }
    
    
    for(int i = 0; i<ring.outerPoints.length; i++){
      vertex(ring.x+ring.outerPoints[i].x, ring.y+ring.outerPoints[i].y, ballImageR+ballImageRatio*ring.outerPoints[i].originX, ballImageR+ballImageRatio*ring.outerPoints[i].originY);
    }
  
    beginContour();
    for(int i = ring.innerPoints.length-1; i>=0; i--){
      vertex(ring.x+ring.innerPoints[i].x, ring.y+ring.innerPoints[i].y, ballImageR+ballImageRatio*ring.innerPoints[i].originX, ballImageR+ballImageRatio*ring.innerPoints[i].originY);
    }
  
    endContour();
    endShape();
  }
}

void initRings(){
  bandsPerRing = fft.specSize()/noRings;
  colorMode(HSB, 1);
  
  rings = new Ring[noRings];
  float ringThickness = width*0.3/noRings;
  ballImageRatio = ballImageR / width*0.3;
  for(int i = 0; i<noRings; i++){
    rings[i] = new Ring(ringThickness*(i)+1, ringThickness*(i+1)-4, width/2, height/2);
    rings[i].useFillColor = useFillColor;
  }
  setColor(c1, c2, rings);
}

void setColor(color c1, color c2, Ring[] rings){
  for(int i=0; i<rings.length; i++){
    rings[noRings-i-1].fillColor = lerpColor(c1, c2, 1.*((i+ringColorOffset)%noRings)/(rings.length-1));
    rings[noRings-i-1].randomizeColor();
  }
}

void drawFPS(){
  float time = millis();
  float fps = 1000/(time-lastTimeStamp);
  stroke(1);
  fill(1);
  textSize(32);
  text("fps: "+fps, 10,30);
  lastTimeStamp = time;
}

void keyPressed(){
  if(key=='1'){
    useBeat = true;
    noRings = 1;
    initRings();
  }else if(key=='2'){
    drawParticles = false;
    useBeat = false;
    noRings = 10;
    initRings();
    tintColor = true;
    for(int ringNumber = 0; ringNumber<noRings; ringNumber++){
      rings[ringNumber].useOuterNoise = false;
      rings[ringNumber].useFillColor = true;
      rings[ringNumber].alpha = 0.1;
    }
    for(int ringNumber = 0; ringNumber<noRings; ringNumber+=2){
      rings[ringNumber].targetAlpha = 0;
    }
  }else if(key=='3'){
    drawParticles = false;
    moveRingColor = true;
    for(int i = 0; i<rings.length; i++){
      rings[i].textureAngularSpeed =random(0.020)-0.01;
      rings[i].alpha = 1;
    }
    
  }else if(key=='4'){
    drawParticles = true;
    moveRingColor = false;
    ringColorOffset = 0;
    setColor(#5060b0, #6070e0, rings);
    for(int ringNumber = 0; ringNumber<noRings; ringNumber++){
      rings[ringNumber].targetAlpha = 0.2;
    }
    
  }else if(key=='5'){
    for(int ringNumber = 0; ringNumber<noRings; ringNumber++){
      rings[ringNumber].targetAlpha = 0;
    }
    particleRadius = int(sqrt(width*width/4+height*height/4));
    for(int i = 0; i<particleNum; i++){
      particles[i].setSpeed(3);
    }
  }else if(key=='a'){
    ringSizeModifier += 0.1;
    particleSpeed +=0.2;
    particleRadius += 10;
    for(int i = 0; i<particleNum; i++){
      particles[i].setSpeed(particleSpeed);
    }
  }else if(key=='s'){
    ringSizeModifier -= 0.1;
    particleSpeed -=0.2;
    particleRadius -= 10;
    for(int i = 0; i<particleNum; i++){
      particles[i].setSpeed(particleSpeed);
    }
  }else if(key=='z'){
    
    particleRadius = 160;
    for(int i = 0; i<particleNum; i++){
      particles[i].setSpeed(0.3);
      particles[i].relocate();
    }
  }
  /*else if(key>='1'&&key<='9'){
    int ringNumber = key-'1';
    if(ringNumber<rings.length)rings[ringNumber].presence = !rings[ringNumber].presence;
  }*/
}