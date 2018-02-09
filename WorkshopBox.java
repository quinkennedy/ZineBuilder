import processing.core.PGraphics;
import processing.data.XML;

abstract class WorkshopBox{
  // all the work, none of the drawing
  public Rectangle layout(XML xml, Rectangle area, PGraphics pg, VarService vars){
    
    //translate "off screen"
    pg.pushMatrix();
    pg.translate(pg.width, pg.height);
    
    //just use the renderer's output to convey actual space used
    Rectangle output = render(xml, area, pg, vars, false);
    pg.popMatrix();
    return output;
  }
  // all the work, and draw it too!
  public abstract Rectangle render(XML xml, Rectangle area, PGraphics pg, VarService vars, boolean debug);
  public Rectangle render(XML xml, Rectangle area, PGraphics pg, VarService vars){
    return render(xml, area, pg, vars, false);
  }
  public abstract boolean isResizable();
}