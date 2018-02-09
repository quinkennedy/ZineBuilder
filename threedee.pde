public class ThreeDee extends WorkshopBox{
  public Rectangle render(XML xml, Rectangle rect, PGraphics pg, VarService vars, boolean debug){
    pg.pushMatrix();
    pg.translate(rect.x, rect.y);
    pg.lights();
    pg.fill(color(0, 255, 0));
    pg.box(200, 500, 300);
    pg.popMatrix();
    return rect;
  }
  
  public boolean isResizable(){
    return true;
  }
}