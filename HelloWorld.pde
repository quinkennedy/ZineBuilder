public class HelloWorld extends WorkshopBox{
  public Rectangle render(XML xml, Rectangle rect, PGraphics pg, boolean debug){
    pg.pushMatrix();
    pg.translate(rect.x, rect.y);
    String text = "hello world!";
    pg.text(text, 0, 0);
    pg.popMatrix();
    return new Rectangle(rect.x, rect.y, pg.textAscent(), pg.textWidth(text));
  }
  
  public boolean isResizable(){
    return false;
  }
}