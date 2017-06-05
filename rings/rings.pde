import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

PImage img ;

Minim minim;
AudioInput in;
FFT fft;
float imageWidth;
float imageHeight;
float lastTimeStamp;

Ring[] rings;
int noRings = 8;
int bandsPerRing;

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
  }
  lastTimeStamp=millis();
}



void draw(){
  fill(0, 0.07);
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
  noStroke();
  //stroke(0,0,0);
  beginShape();
  texture(img);
  for(int i = 0; i<ring.outerPoints.length; i++){
  vertex(ring.x+ring.outerPoints[i].x, ring.y+ring.outerPoints[i].y, img.width/2+ring.outerPoints[i].originX, img.height/2+ring.outerPoints[i].originY);
  }

  beginContour();
  for(int i = 0; i<ring.innerPoints.length; i++){
    vertex(ring.x+ring.innerPoints[i].x, ring.y+ring.innerPoints[i].y, img.width/2+ring.innerPoints[i].originX, img.height/2+ring.innerPoints[i].originY);
  }

  endContour();
  endShape();
  
  
  fill(0,1-ring.alpha);
  beginShape();
  for(int i = 0; i<ring.outerPoints.length; i++){
  vertex(ring.x+ring.outerPoints[i].x, ring.y+ring.outerPoints[i].y, img.width/2+ring.outerPoints[i].originX, img.height/2+ring.outerPoints[i].originY);
  }

  beginContour();
  for(int i = 0; i<ring.innerPoints.length; i++){
    vertex(ring.x+ring.innerPoints[i].x, ring.y+ring.innerPoints[i].y, img.width/2+ring.innerPoints[i].originX, img.height/2+ring.innerPoints[i].originY);
  }

  endContour();
  endShape();
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
