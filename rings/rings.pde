import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

//audio
Minim minim;
AudioInput in;
FFT fft;

//background image
PImage img;

float imageWidth;
float imageHeight;
float lastTimeStamp;

// graphics
Ring[] rings;
int noRings = 10; // howmany rings will be used?
int bandsPerRing;


// set to true to turn on gradient color
boolean useFillColor = true;
boolean tintColor = false;
// gradient colors; from the inside out
color c1 = #d06020;
color c2 = #80c050;

void setup(){
  size(800, 800, P2D);
  img = loadImage("single_cover_website2.jpg");
  imageWidth = img.width;
  imageHeight = img.height;
  minim = new Minim(this);
  in = minim.getLineIn();
  fft = new FFT(in.bufferSize(), in.sampleRate());
  bandsPerRing = fft.specSize()/noRings;
  colorMode(HSB, 1);
  
  rings = new Ring[noRings];
  float ringThickness = width*0.3/noRings;
  for(int i = 0; i<noRings; i++){
    rings[i] = new Ring(ringThickness*(i)+1, ringThickness*(i+1)-4, width/2, height/2);
    rings[i].useFillColor = useFillColor;
  }
  setColor(c1, c2, rings);
  for(int i = 0; i<noRings; i++){
    rings[i].randomizeColor();
  }
  lastTimeStamp=millis();
}



void draw(){
  fill(0, 0.07);
  noTint();
  image(img, 0,0);
  rect(0,0,width, height);
  fft.forward(in.mix);
  float mod;
  for(int i = 0; i<noRings; i++){
   float level = 0;
    for(int j = 0; j<bandsPerRing; j++){
      level+=fft.getBand(i*bandsPerRing+j);
    }
    mod = log(level)-2;
    mod=mod<0?0:mod/5;
    rings[i].modifyOuterR(mod);
    rings[i].update();
    drawARing(rings[i]);
  }
  
  fill(0);
  rect(0,0,300,30);
  
  
  
}


void drawARing(Ring ring){
  if (ring.drawSeparate) {
    noStroke();
    for (int i = 0; i < ring.noPies - 1; i++) {
      beginShape();
      if (ring.useFillColor) {
        if (tintColor) {
          tint(ring.fillColors[i]);
          texture(img);
        } else {
          fill(ring.fillColors[i],ring.alpha);
        }
      } else {
        texture(img);
      }
      int j = i+1;
      if (j >= ring.noPies) {
        j = 0;
      }
      vertex(ring.x+ring.outerPoints[i].x, ring.y+ring.outerPoints[i].y, img.width/2+ring.outerPoints[i].originX, img.height/2+ring.outerPoints[i].originY);
      vertex(ring.x+ring.outerPoints[j].x, ring.y+ring.outerPoints[j].y, img.width/2+ring.outerPoints[j].originX, img.height/2+ring.outerPoints[j].originY);
      vertex(ring.x+ring.innerPoints[j].x, ring.y+ring.innerPoints[j].y, img.width/2+ring.innerPoints[j].originX, img.height/2+ring.innerPoints[j].originY);
      vertex(ring.x+ring.innerPoints[i].x, ring.y+ring.innerPoints[i].y, img.width/2+ring.innerPoints[i].originX, img.height/2+ring.innerPoints[i].originY);
      endShape();
    }
  } else {
    noStroke();
    beginShape();
    
    if (ring.useFillColor) {
      if (tintColor) {
        tint(ring.fillColor);
        texture(img);
      } else {
        fill(ring.fillColor,ring.alpha);
      }
    } else {
      texture(img);
    }
    
    
    for(int i = 0; i<ring.outerPoints.length; i++){
      vertex(ring.x+ring.outerPoints[i].x, ring.y+ring.outerPoints[i].y, img.width/2+ring.outerPoints[i].originX, img.height/2+ring.outerPoints[i].originY);
    }
  
    beginContour();
    for(int i = ring.innerPoints.length-1; i>=0; i--){
      vertex(ring.x+ring.innerPoints[i].x, ring.y+ring.innerPoints[i].y, img.width/2+ring.innerPoints[i].originX, img.height/2+ring.innerPoints[i].originY);
    }
  
    endContour();
    endShape();
  }
}

void setColor(color c1, color c2, Ring[] rings){
  for(int i=0; i<rings.length; i++){
    rings[i].fillColor = lerpColor(c1, c2, 1.*i/(rings.length-1));
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
  if(key=='a'){
    for(int i = 0; i<rings.length; i++){
      rings[i].textureAngularSpeed =random(0.014)-0.007;
    }
  }else if(key=='s'){
    for(int i = 0; i<rings.length; i++){
      rings[i].textureAngularSpeed =0;
    }
  }else if(key>='1'&&key<='9'){
    int ringNumber = key-'1';
    if(ringNumber<rings.length)rings[ringNumber].presence = !rings[ringNumber].presence;
  }
}