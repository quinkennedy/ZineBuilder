public class JoshuaExample extends WorkshopBox{
  public Rectangle render(XML xml, Rectangle rect, PGraphics pg, VarService vars, boolean debug){
    
    // rect is a single page
      // half spread - margins - header - footer
    // pg is a spread 
    // top left or top middle (called twice per contentbox tag) 
    
    // tag for helloworld
    
    // WorkshopBoxes.java
    //private WorkshopBoxes(ZineBuilder zineBuilder){
    //boxes.put("helloworld", zineBuilder.new HelloWorld());
    //boxes.put("threedee", zineBuilder.new ThreeDee());
    //boxes.put("JoshuaExample", zineBuilder.new JoshuaExample());
  
    //don't use background method, draw a background rect
    pg.pushMatrix();
    
    pg.fill(122);
    pg.rect(rect.x, rect.y, rect.w, rect.h);
    
    // You are passed a rectangle of printable area
    pg.translate(rect.x, rect.y);
    
    // You can ignore to do full bleed 
    //pg.translate(rect.x, rect.y);
    
    // this is the rect you are allowed to fill
    println("[JoshuaExample] you are meant to fill: " + rect.x + ", " + rect.y + ", " + rect.w + ", " + rect.h);
    
    // Dont do pg.beginDraw();
    // Don't do this... pg.pushStyle();
    //pg.background(0);
    pg.stroke(0);
    pg.noFill();
    for (int i = 0; i < 200; i += 20) {
      pg.bezier(random(0.0, rect.w), 40+i, 410, 20, 440, 300, 240-(i/16.0), 300+(i/8.0));
    }
    // Don't do this ... pg.popStyle();
    // Don't do this... pg.endDraw();
    pg.popMatrix();
    
    //pg.pushMatrix();
    //pg.translate(rect.x, rect.y);
    //String text = "hello world!";
    //pg.text(text, 0, 0);
    //pg.popMatrix();
    return new Rectangle(rect.x, rect.y, rect.w, rect.h);
  }
  
  public boolean isResizable(){
    return false;
  }
}