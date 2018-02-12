
public class DbsWord1 extends WorkshopBox{
  public Rectangle render(XML xml, Rectangle rect, PGraphics pg, VarService vars, boolean debug){
    
    pg.pushMatrix();

    // draw background rectangle over the full spread of two pages
    pg.fill(250);
    pg.rect(0, 0, pg.width/2, pg.height);
    
    DrawWord(rect, pg, xml.getInt("wordType"), 0, 110, 250);
    
    
    pg.popMatrix();

    // return a rectangle for the layout engine to use
    return new Rectangle(rect.x, rect.y, rect.w, rect.h);
  }
  
  public boolean isResizable(){
    return false;
  }
}