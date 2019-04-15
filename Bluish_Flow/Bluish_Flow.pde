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

int innerSize=30;
int XPos = mouseX;
float eRadius;
boolean toggle = false;

// fluid simulation
DwFluid2D fluid;

// render target
PGraphics2D pg_fluid;

public void setup(){
  
  size(512, 700, P2D);

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

public void draw()
{

  background(0);
  if (toggle == false) {

    float px = mouseX; //places smoke in Xposition
    float py = -mouseY+700; //subtract because sim Y is flipped
    float vx = random(-300, 300);
    float vy = eRadius + random(-50, 500);
    if ( eRadius < 20 ) eRadius = 20;
    fluid.addVelocity(px, py, 30, vx, vy);
    
    //fluid.addDensity(px, py, radius, r, g, b, intensity, 3);
    fluid.addDensity (px, py, 50, 0f, 0.3f, 1f, 1.0f, 3); //outer smoke
    fluid.addDensity (px, py, innerSize, 0f, 0f, 1f, 1.0f, 1); //inner smoke

  }
  if (toggle == true) {

    float px = mouseX;
    float py = -mouseY+700;
    float vx = random(-300, 300);
    float vy = eRadius + random(-50, 50);
    if ( eRadius < 20 ) eRadius = 20;
    fluid.addVelocity(px, py, 24, vx, vy);
    fluid.addDensity (px, py, 90, .5f, 0f, 1f, 1f, 1); //outer smoke
    fluid.addDensity (px, py, innerSize, 1f, 1f, 1f, 1.0f, 1); //inner smoke
  }

  if (key == 'z') {
  }
  if (key == 'x') {
  }


  //if (beat.isOnset() ) eRadius = 400;
  innerSize=100;
  eRadius*=.90;
  innerSize*=.3;
  if (eRadius<80) eRadius=30;
  if (innerSize<30) innerSize=30;
  fluid.addCallback_FluiData(new DwFluid2D.FluidData() {
    public void update(DwFluid2D fluid) {

      //brightsmoke
    }
  }
  );

  fluid.update();

  // clear render target
  pg_fluid.beginDraw();
  pg_fluid.background(0);
  pg_fluid.endDraw();

  // render fluid stuff
  fluid.renderFluidTextures(pg_fluid, 0);

  // display
  image(pg_fluid, 0, 0);
}
void mousePressed() {
  toggle = true;
}
void mouseReleased() {
  toggle = false;
}
