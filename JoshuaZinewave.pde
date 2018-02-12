public class JoshuaZinewave extends WorkshopBox{
    int xspacing = 15; // How far apart should each horizontal location be spaced
    int c_w; // Width of entire wave
    int maxwaves = 6; 
    float theta = 0.0f;
    float[] amplitude = new float[maxwaves]; // Height of wave
    float[] dx = new float[maxwaves]; // Value for incrementing X, to be calculated as a function of period and xspacing
    float[] yvalues; // Using an array to store height values for the wave (not entirely necessary)
    
  public Rectangle render(XML xml, Rectangle rect, PGraphics pg, VarService vars, boolean debug){

    pg.fill(60);
    pg.rect(0, 0, pg.width/2, pg.height);
    
    pg.smooth();
    setupWave();
    
    pg.pushMatrix();

    calcWave();

    for (int j=3; j<13; j++) {
      //renderWave(j*70, j*30, j*20,j*20,j*20);
      //int wH, int wOff, int rV,int gV,int bV//
      pg.beginShape();
      pg.noStroke();
      pg.fill(j*20,j*20,j*20);
      pg.noFill();
      pg.stroke(0);
      pg.vertex(-600, rect.h+30);
      pg.vertex(-600, j*30);
     for (int x = 0; x < yvalues.length; x++) {
        pg.vertex(x*xspacing+j*30,j*70/2+(yvalues[x]));
     }

     pg.vertex(rect.w+200, j*70);
     pg.vertex(rect.w+200, rect.h+10);
     pg.endShape();
    }

  pg.textSize(30);
  pg.text("zinewave originated in the year "+ (int) random(1600,2200), 50, 200, 300, 600);
  
    pg.popMatrix();

    // return a rectangle for the layout engine to use
    return new Rectangle(rect.x, rect.y, rect.w, rect.h);
  }
  
  void setupWave() {
    //c_w = rect.w + 16;
    for (int i = 0; i < maxwaves; i++) {
      amplitude[i] = random(5,7);
      float period = random(100,800); // How many pixels before the wave repeats
      dx[i] = (TWO_PI / period) * xspacing;
    }
    yvalues = new float[c_w/xspacing];
  }
  
  void calcWave() {
    // Increment theta (try different values for 'angular velocity' here
    theta += 0.02; // Set all height values to zero
    for (int i = 0; i < yvalues.length; i++) {
      yvalues[i] = 0.0f;
    } // Accumulate wave height values

    for (int j = 0; j < maxwaves; j++) {
      float x = theta;
        for (int i = 0; i < yvalues.length; i++) {
          if (j % 2 == 0) yvalues[i] += sin(x)*amplitude[j];
             else yvalues[i] += cos(x)*amplitude[j];
             x+=dx[j];
         }
    }
  }

  public boolean isResizable(){
    return false;
  }
}