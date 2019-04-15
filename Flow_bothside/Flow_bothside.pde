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

public void setup() {

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
  //if (toggle == false) {
  //float px = mouseX; //places smoke in Xposition
  //float py = -mouseY+700; //subtract because sim Y is flipped
  if (keyPressed) {
    if (key == 'a' || key == 'A') {
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
    
    if (key == 'b' || key == 'B') {
      push();
      rotate(PI / 2.0);
      float px1 = 0;
      float py1 = 100;
      float vx1 = random(-300, 300);
      float vy1 = eRadius + random(-50, 50);
      if ( eRadius < 20 ) eRadius = 20;
      fluid.addVelocity(px1, py1, 30, vx1, vy1);
      fluid.addDensity (px1, py1, 50, 0f, 0.3f, 1f, 1.0f, 3); //outer smoke
      fluid.addDensity (px1, py1, innerSize, 0f, 0f, 1f, 1.0f, 1); //inner smoke
      pop();
    }
  }

  if (keyPressed) {
    if (key == 'c' || key == 'C') {
      push();
      rotate(PI / 2.0);
      float px2 = width;
      float py2 = 100;
      float vx2 = random(-300, 300);
      float vy2 = eRadius + random(-50, 50);
      if ( eRadius < 20 ) eRadius = 20;
      fluid.addVelocity(px2, py2, 30, vx2, vy2);
      fluid.addDensity (px2, py2, 200, .5f, 0f, 1f, 1f, 1); //outer smoke
      fluid.addDensity (px2, py2, innerSize, 1f, 1f, 1f, 1.0f, 1); //inner smoke
      pop();
    }

    if (keyPressed) {
      if (key == 'd' || key == 'D') {
        push();
        rotate(PI / 2.0);
        float px2 = width;
        float py2 = 100;
        float vx2 = random(-300, 300);
        float vy2 = eRadius + random(-50, 50);
        if ( eRadius < 20 ) eRadius = 20;
        fluid.addVelocity(px2, py2, 30, vx2, vy2);
        fluid.addDensity (px2, py2, 20, .5f, 0f, 1f, 1f, 1); //outer smoke
        fluid.addDensity (px2, py2, innerSize, 0f, 1f, 1f, 1.0f, 1); //inner smoke
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
  }
}
