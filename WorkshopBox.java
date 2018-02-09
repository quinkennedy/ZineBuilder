import processing.core.PGraphics;
import processing.data.XML;

abstract class WorkshopBox{
  // all the work, none of the drawing
  public Rectangle layout(XML xml, Rectangle area, PGraphics pg){
    pg.pushMatrix();
    pg.translate(pg.width, pg.height);
    Rectangle output = render(xml, area, pg, false);
    pg.popMatrix();
    return output;
  }
  // all the work, and draw it too!
  public abstract Rectangle render(XML xml, Rectangle area, PGraphics pg, boolean debug);
  public Rectangle render(XML xml, Rectangle area, PGraphics pg){
    return render(xml, area, pg, false);
  }
  public abstract boolean isResizable();
}