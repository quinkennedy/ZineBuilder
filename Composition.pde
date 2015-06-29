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
  PFont myPGFont;
  XML xml;
  String heading;
  String subheading;
  String body;
  
  Composition(int _pageNum, int _pageWidth, int _pageHeight) {
    pageNum = _pageNum;
    pageWidth = _pageWidth;
    pageHeight = _pageHeight;
    
    // load content
    xml = loadXML("zine.xml");
    XML[] children = xml.getChildren("page");
    String page = children[pageNum-1].getContent();
    heading = children[pageNum-1].getChild("heading").getContent();
    body = children[pageNum-1].getChild("body").getContent();
    println("Created Page: "+pageNum);
    
    myPGFont = createFont("DINPro-Black", 48);
    pg = createGraphics(_pageWidth, _pageHeight);  
    

    //pg.textAlign(CENTER, CENTER);

    pg.beginDraw();
    pg.textFont(myPGFont);
    pg.textSize(500);
    pg.background(255);
    pg.fill(0);
    pg.line(random(0, _pageWidth),random(0,_pageHeight),random(0, _pageWidth),random(0,_pageHeight));
    pg.rect(0,0,100,100);
    pg.text(String.format("%02d", pageNum), _pageWidth/3, _pageHeight/2);
    pg.textSize(50);
    pg.text(heading, 100, 100);
    pg.textSize(12);
    pg.text(body, 100, 300, 400, 700);
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