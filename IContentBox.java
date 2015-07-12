import processing.core.PGraphics;

interface IContentBox{
  public abstract Rectangle render(Rectangle area, PGraphics pg);
  
  public static class Rectangle{
    float x, y, w, h;
    
    public Rectangle(float x, float y, float width, float height){
      this.x = x;
      this.y = y;
      this.w = width;
      this.h = height;
    }
  }
}