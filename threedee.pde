public class ThreeDee extends WorkshopBox{
  public Rectangle layout(XML xml, Rectangle rect, PGraphics pg, VarService vars){
    return rect;
  }
  public Rectangle render(XML xml, Rectangle rect, PGraphics pg, VarService vars, boolean debug){
    float angleStep = .2f;
    float radiusStep = -10;
    float radius = rect.w/2;
    
    pg.lights();
    pg.pushMatrix();
    pg.translate(rect.x+rect.w/2, rect.y+rect.h/2, 0);
    while(radius > 0){
      pg.rotateZ(angleStep);
      pg.pushMatrix();
      pg.translate(0, radius);
      pg.fill(color(0, random(255), random(255)));
      pg.box(random(100,200), random(100,200), random(100, 200));
      pg.popMatrix();
      radius += radiusStep;
    }
    pg.popMatrix();
    return rect;
  }
  
  public boolean isResizable(){
    return true;
  }
}