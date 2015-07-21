public class Rectangle{
  float x, y, w, h;
  
  public Rectangle(float x, float y, float width, float height){
    this.x = x;
    this.y = y;
    this.w = width;
    this.h = height;
  }
  
  public String toString(){
    return String.format("%1$f,%2$f,%3$f,%4$f",x,y,w,h);
  }
}