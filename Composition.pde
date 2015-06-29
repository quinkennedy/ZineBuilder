/*
 *  Composition
 *
 *  DESCRIPTION: A pretty generic composition class 
 * 
 *  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php 
 */

class Composition {
  int pageNum;
  PGraphics pg;
  private int pageWidth;
  private int pageHeight;
  PFont myFont;
  
  Composition(int _pageNum, int _pageWidth, int _pageHeight) {
    pageNum = _pageNum;
    pageWidth = _pageWidth;
    pageHeight = _pageHeight;
    
    println("Created Page: "+pageNum);
    pg = createGraphics(_pageWidth, _pageHeight);  
    myFont = createFont("DINPro-Black", 48);
    textFont(myFont);
    pg.textAlign(CENTER, CENTER);

    pg.beginDraw();
    pg.textSize(300);
    pg.background(255);
    pg.fill(0);
    pg.line(random(0, _pageWidth),random(0,_pageHeight),random(0, _pageWidth),random(0,_pageHeight));
    pg.rect(0,0,100,100);
    pg.text(str(pageNum), _pageWidth/2, _pageHeight/2);
    pg.endDraw();
  }
  
  public PGraphics getPage() {
   println("passing back page"+pg);
   return pg;
  }
  
  public int getWidth() {
    return pageWidth;
  }
  
  public int getHeight() {
    return pageHeight;
  }
}