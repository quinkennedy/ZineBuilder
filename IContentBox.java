import processing.core.PGraphics;

abstract class ContentBox{
  // all the work, none of the drawing
  public Rectangle layout(Rectangle area, PGraphics pg){
    pg.pushMatrix();
    pg.translate(pg.width, pg.height);
    Rectangle output = render(area, pg, false);
    pg.popMatrix();
    return output;
  }
  // all the work, and draw it too!
  public abstract Rectangle render(Rectangle area, PGraphics pg, boolean debug);
  public Rectangle render(Rectangle area, PGraphics pg){
    return render(area, pg, false);
  }
}