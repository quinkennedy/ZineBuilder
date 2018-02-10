public class HelloWorld extends WorkshopBox{
  public Rectangle render(XML xml, Rectangle rect, PGraphics pg, VarService vars, boolean debug){
    String text = "hello world!";
    pg.text(text, rect.x, rect.y);
    return new Rectangle(rect.x, rect.y, pg.textAscent(), pg.textWidth(text));
  }
  
  public boolean isResizable(){
    return false;
  }
}