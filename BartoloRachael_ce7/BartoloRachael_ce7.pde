// FFT_01.pde
// This example is based in part on an example included with
// the Beads download originally written by Beads creator
// Ollie Bown. It draws the frequency information for a
// sound on screen.
// Jodianne Bartolo
import beads.*;
import controlP5.*;

PowerSpectrum ps;
PowerSpectrum ps1;
ControlP5 p5;
Bead endListener;
Reverb r;
Gain g;
Gain g1;
SamplePlayer player;
color fore = color(255, 255, 255);
color back = color(0,0,0);
BiquadFilter bp;
Glide slidey;
Glide changing;
AudioContext ac1;
UGen mic;
void setup()
{

 size(600,600);


 ac = new AudioContext();
 mic = ac.getAudioInput();
 slidey = new Glide(ac, 5000.0, 500);
 changing = new Glide(ac, 1, 300);
 bp = new BiquadFilter(ac, BiquadFilter.AP, slidey, 0.5f);
 
 p5 = new ControlP5(this);
 // set up a master gain object
 Gain g = new Gain(ac, 2, 0.3);

 mic.pause(true);

 


 // load up a sample included in code download

 try
 {
 // Load up a new SamplePlayer using an included audio
 // file.
 
 player = getSamplePlayer("mine.wav",false);
 player.setKillOnEnd(false);
 r = new Reverb(ac, 1);
 r.setDamping(.6);
 bp.addInput(player);
 bp.addInput(mic);
 g.addInput(bp);
 r.addInput(g);

 // connect the SamplePlayer to the master Gain

 ac.out.addInput(r);
 ac.out.addInput(g);
 r.pause(true);
 }
 catch(Exception e)
 {
 // If there is an error, print the steps that got us to
 // that error.
 e.printStackTrace();
 }
 // In this block of code, we build an analysis chain
 // the ShortFrameSegmenter breaks the audio into short,
 // discrete chunks.
 ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);

 sfs.addInput(ac.out);


 // FFT stands for Fast Fourier Transform
 // all you really need to know about the FFT is that it
 // lets you see what frequencies are present in a sound
 // the waveform we usually look at when we see a sound
 // displayed graphically is time domain sound data
 // the FFT transforms that into frequency domain data
 FFT fft = new FFT();

 // connect the FFT object to the ShortFrameSegmenter
 sfs.addListener(fft);


 // the PowerSpectrum pulls the Amplitude information from
 // the FFT calculation (essentially)
 ps = new PowerSpectrum();
 ps1 = new PowerSpectrum();
 // connect the PowerSpectrum to the FFT
 fft.addListener(ps);
 
 // list the frame segmenter as a dependent, so that the
 // AudioContext knows when to update it.
 ac.out.addDependent(sfs); 

   
   Bead endListener = new Bead() {
    public void messageReceived(Bead message) {
      SamplePlayer sp = (SamplePlayer) message;
      sp.pause(true);
      sp.setToLoopStart();
      // maybe play a second sound when the first is done
      // mySound could have a different endListener
      player.start();

    }
   };
   
   player.setEndListener(endListener);
   player.start();
    
    p5.addButton("noFilter")
    .setPosition(width / 2 - 50, 80)
    .setSize(width /2 -50, 20)
    .setLabel("No Filter")
    .setColorBackground(color(160,120,20))
    .activateBy((ControlP5.RELEASE));
    
    p5.addButton("lpFilter")
    .setPosition(width / 2 - 50, 110)
    .setSize(width /2 -50, 20)
    .setLabel("Low Pass Filter")
    .setColorBackground(color(160,10,250))
    .activateBy((ControlP5.RELEASE));
    
    p5.addButton("hpFilter")
    .setPosition(width / 2 - 50, 140)
    .setSize(width /2 -50, 20)
    .setLabel("High Pass Filter")
    .setColorBackground(color(30,40,40))
    .activateBy((ControlP5.RELEASE));
    
    p5.addButton("bpFilter")
    .setPosition(width / 2 - 50, 170)
    .setSize(width /2 -50, 20)
    .setLabel("Band Pass Filter")
    .setColorBackground(color(70,40,40))
    .activateBy((ControlP5.RELEASE));
    
    p5.addButton("reverby")
    .setPosition(width / 2 - 50, 200)
    .setSize(width /2 -50, 30)
    .setLabel("Reverb")
    .setColorBackground(color(70,200,90))
    .activateBy((ControlP5.RELEASE));
   
    p5.addButton("micIn")
    .setPosition(width / 2 - 50, 250)
    .setSize(width /2 -50, 30)
    .setLabel("Mic Input")
    .setColorBackground(color(70,10,200))
    .activateBy((ControlP5.RELEASE));
    
     p5.addSlider("Slider")
     .setPosition(width/ 2 - 140, 40)
     .setSize(15, 150)
     .setRange(200, 10000)
     .setValue(5000)
     .setLabel("Cutoff frequency");
    
    p5.addSlider("verb")
     .setPosition(width/ 2 - 140, 280)
     .setSize(15, 150)
     .setRange(0, 1.0)
     .setValue(.5)
     .setLabel("Reverb Damping");
    
    

 // start processing audio
 ac.start();
}
// In the draw routine, we will interpret the FFT results and
// draw them on screen.

void draw()
{
 background(back);
 stroke(fore);

 // The getFeatures() function is a key part of the Beads
 // analysis library. It returns an array of floats
 // how this array of floats is defined (1 dimension, 2
 // dimensions ... etc) is based on the calling unit
 // generator. In this case, the PowerSpectrum returns an
 // array with the power of 256 spectral bands.
 
 if (ac.isRunning()) {
 float[] features = ps.getFeatures();

 // if any features are returned
 if(features != null)
 {
 // for each x coordinate in the Processing window
 for(int x = 0; x < width; x++)
 {
 // figure out which featureIndex corresponds to this x-
 // position
 int featureIndex = (x * features.length) / width;
 // calculate the bar height for this feature
 int barHeight = Math.min((int)(features[featureIndex] *
 height), height - 1);
 // draw a vertical line corresponding to the frequency
 // represented by this x-position
 line(x, height, x, height - barHeight);
 }
 }
 }
 }


public void noFilter() {

  bp.setType(BiquadFilter.AP);

}

public void lpFilter() {

  bp.setType(BiquadFilter.LP);


}
public void hpFilter() {

  bp.setType(BiquadFilter.HP);
}
public void bpFilter() {

  bp.setType(BiquadFilter.BP_SKIRT);
}
public void Slider(float value) {

  slidey.setValue(value);
}

public void reverby() {

  if (r.isPaused()) {
      r.start();
  } else {
    r.pause(true);
    
  }
  


}

public void verb(float value) {

  ac.start();
  changing.setValue(value);
  r.setDamping(changing.getValue());
}

public void micIn() {
     if ( mic.isPaused()) {
       player.pause(true);
       mic.start();
     } else {
       mic.pause(true);
       player.start();
     }

}
