public class JoshuaExampleFullBleed extends WorkshopBox{
  public Rectangle render(XML xml, Rectangle rect, PGraphics pg, VarService vars, boolean debug){
    
    pg.pushMatrix();

    // draw background rectangle over the full spread of two pages
    pg.fill(122);
    pg.rect(0, 0, pg.width/2, pg.height);
    
    // Draw some bezier curves
    pg.stroke(0);
    pg.strokeWeight(18);
    pg.noFill();
    for (int i = 0; i < 200; i += 20) {
      pg.bezier(random(0.0, rect.w), 40+i, 410, 20, 440, 300, 240-(i/16.0), 300+(i/8.0));
    }
  
    pg.popMatrix();

    // return a rectangle for the layout engine to use
    return new Rectangle(rect.x, rect.y, rect.w, rect.h);
  }
  
  public boolean isResizable(){
    return false;
  }
}