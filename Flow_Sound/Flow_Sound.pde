import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import com.thomasdiewald.pixelflow.java.*;
import com.thomasdiewald.pixelflow.java.accelerationstructures.*;
import com.thomasdiewald.pixelflow.java.antialiasing.FXAA.*;
import com.thomasdiewald.pixelflow.java.antialiasing.GBAA.*;
import com.thomasdiewald.pixelflow.java.antialiasing.SMAA.*;
import com.thomasdiewald.pixelflow.java.dwgl.*;
import com.thomasdiewald.pixelflow.java.flowfieldparticles.*;
import com.thomasdiewald.pixelflow.java.fluid.*;
import com.thomasdiewald.pixelflow.java.geometry.*;
import com.thomasdiewald.pixelflow.java.imageprocessing.*;
import com.thomasdiewald.pixelflow.java.imageprocessing.filter.*;
import com.thomasdiewald.pixelflow.java.render.skylight.*;
import com.thomasdiewald.pixelflow.java.rigid_origami.*;
import com.thomasdiewald.pixelflow.java.sampling.*;
import com.thomasdiewald.pixelflow.java.softbodydynamics.*;
import com.thomasdiewald.pixelflow.java.softbodydynamics.constraint.*;
import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.*;
import com.thomasdiewald.pixelflow.java.softbodydynamics.softbody.*;
import com.thomasdiewald.pixelflow.java.utils.*;



Minim minim;
AudioInput in;
FFT fft;
String note;// name of the note
int n;//int value midi note
color c;//color
float hertz;//frequency in hertz
float midi;//float midi note
int noteNumber;//variable for the midi note
float linetoshow;
int linex =0;
float volumn;
int sampleRate= 44100;//sapleRate of 44100
float [] max= new float [sampleRate/2];//array that contains the half of the sampleRate size, because FFT only reads the half of the sampleRate frequency. This array will be filled with amplitude values.
float maximum;//the maximum amplitude of the max array
float frequency;//the frequency in hertz

int channel = 1;
int pitch = 40;
int soundVelocity = 127;


int innerSize=30;
int XPos = mouseX;
float eRadius;
boolean toggle = false;
// fluid simulation
DwFluid2D fluid;
// render target
PGraphics2D pg_fluid;



public void setup() {

  minim = new Minim(this);
  minim.debugOn();
  in = minim.getLineIn(Minim.MONO, 4096, sampleRate);
  fft = new FFT(in.left.size(), sampleRate);

  size(400, 512, P2D);
  // library context
  DwPixelFlow context = new DwPixelFlow(this);
  // fluid simulation
  fluid = new DwFluid2D(context, width, height, 1);
  // some fluid parameters
  fluid.param.dissipation_velocity = 0.80f;
  fluid.param.dissipation_density = 1f;
  pg_fluid = (PGraphics2D) createGraphics(width, height, P2D);
  eRadius=20;
}

public void draw() {

  background(0);
  findNote(); //find note function
  textSize(50); //size of the text
  volumn = in.mix.level()*1000;
  text("volumn = "+ volumn, 50, 300);
  if (volumn>40) {
    text (frequency-6+" hz", 50, 80);//display the frequency in hertz
    pushStyle();
    fill(c);
    text ("note "+note, 50, 150);//display the note name
    text (midi, 50, 200);//display the midi
    popStyle();

    push();
    rotate(PI / 2.0);
    float px1 = 0;
    float py1 = 100;
    float vx1 = random(-300, 300);
    float vy1 = eRadius + random(-50, 50);
    if ( eRadius < 20 ) eRadius = 20;
    fluid.addVelocity(px1, py1, 100, vx1, vy1);
    fluid.addDensity (px1, py1, 30, 255, 0, 0, 1.0f, 3); //outer smoke
    fluid.addDensity (px1, py1, 120, 0, 0, 255, 1.0f, 1); //inner smoke
    pop();
  }

  innerSize=100;
  eRadius*=.90;
  innerSize*=.3;
  if (eRadius<80) eRadius=30;
  if (innerSize<30) innerSize=30;
  fluid.addCallback_FluiData(new DwFluid2D.FluidData() {
    public void update(DwFluid2D fluid) {
    }
  }
  );

  fluid.update();

  pg_fluid.beginDraw();
  pg_fluid.background(0);
  pg_fluid.endDraw();

  fluid.renderFluidTextures(pg_fluid, 0);

  image(pg_fluid, 0, 0);
}


void findNote() {
  if (volumn>10) {
    fft.forward(in.left);
    for (int f=0; f<sampleRate/2; f++) { //analyses the amplitude of each frequency analysed, between 0 and 22050 hertz
      max[f]=fft.getFreq(float(f)); //each index is correspondent to a frequency and contains the amplitude value
    }
    maximum=max(max);//get the maximum value of the max array in order to find the peak of volume

    for (int i=0; i<max.length; i++) {// read each frequency in order to compare with the peak of volume
      if (max[i] == maximum) {//if the value is equal to the amplitude of the peak, get the index of the array, which corresponds to the frequency
        frequency= i;
      }
    }


    midi= 69+12*(log((frequency-6)/440));// formula that transform frequency to midi numbers
    n= int (midi);//cast to int


    //the octave have 12 tones and semitones. So, if we get a modulo of 12, we get the note names independently of the frequency  
    if (n%12==9)
    {
      note = ("a");
      c = color (255, 0, 0);
    }

    if (n%12==10)
    {
      note = ("a#");
      c = color (255, 0, 80);
    }

    if (n%12==11)
    {
      note = ("b");
      c = color (255, 0, 150);
    }

    if (n%12==0)
    {
      note = ("c");
      c = color (200, 0, 255);
    }

    if (n%12==1)
    {
      note = ("c#");
      c = color (100, 0, 255);
    }

    if (n%12==2)
    {
      note = ("d");
      c = color (0, 0, 255);
    }

    if (n%12==3)
    {
      note = ("d#");
      c = color (0, 50, 255);
    }

    if (n%12==4)
    {
      note = ("e");
      c = color (0, 150, 255);
    }

    if (n%12==5)
    {
      note = ("f");
      c = color (0, 255, 255);
    }

    if (n%12==6)
    {
      note = ("f#");
      c = color (0, 255, 0);
    }

    if (n%12==7)
    {
      note = ("g");
      c = color (255, 255, 0);
    }

    if (n%12==8)
    {
      note = ("g#");
      c = color (255, 150, 0);
    }
  }
}

void stop() {
  // always close Minim audio classes when you are done with them
  in.close();
  minim.stop();

  super.stop();
}
