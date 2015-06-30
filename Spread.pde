/*
 *  Composition
 *
 *  DESCRIPTION: A pretty generic composition class 
 * 
 *  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php 
 */

class Spread {
  int spreadNum;
  PGraphics pg;
  private int spreadWidthPx;
  private int spreadHeightPx;
  PFont myPGFont;
  XML xml;
  String heading;
  String subheading;
  String body;
  
  Spread(int _spreadNum, int _spreadWidthPx, int _spreadHeightPx) {
    spreadNum = _spreadNum;
    spreadWidthPx = _spreadWidthPx;
    spreadHeightPx = _spreadHeightPx;
    
    // load content
    xml = loadXML("zine.xml");
    XML[] children = xml.getChildren("spread");
    //XML spread = children[spreadNum-1];
    XML[] pages = children[spreadNum-1].getChildren("page");
    int numPages = pages.length;
    int pageWidthPx = spreadWidthPx;
    if (numPages > 0){
      pageWidthPx /= numPages;
    }
    //String page = children[spreadNum-1].getChildren("page")[0].getContent();
    //heading = children[pageNum-1].getChild("heading").getContent();
    //body = children[pageNum-1].getChild("body").getContent();
    //println("Created Page: "+pageNum);
    
    myPGFont = createFont("DINPro-Black", 48);
    pg = createGraphics(_spreadWidthPx, _spreadHeightPx);  
    

    //pg.textAlign(CENTER, CENTER);
    pg.beginDraw();
    pg.background(255);
    pg.textFont(myPGFont);
    pg.fill(0);
    
    //draw page-specific content
    XML heading, body;
    for(int i = 0; i < pages.length; i++){
      heading = pages[i].getChild("heading");
      body = pages[i].getChild("body");
      if (heading != null){
        pg.textSize(50);
        pg.text(heading.getContent(), pageWidthPx * i + 100, 100);
      }
      if (body != null){
        pg.textSize(12);
        pg.text(body.getContent(), pageWidthPx * i + 100, 300, 400, 700);
      }
      pg.text(pages[i].getString("id"), pageWidthPx*(i+1)-100, spreadHeightPx-100);
    }
    
    //draw spread-general content
    pg.textSize(500);
    pg.line(random(0, _spreadWidthPx),random(0,_spreadHeightPx),
            random(0, _spreadWidthPx),random(0,_spreadHeightPx));
    pg.rect(0,0,100,100);
    pg.text(String.format("%02d", spreadNum), _spreadWidthPx/3, _spreadHeightPx/2);
    
    pg.endDraw();
  }
  
  public PGraphics getPage() {
   println("passing back page"+pg);
   return pg;
  }
  
  public int getWidth() {
    return spreadWidthPx;
  }
  
  public int getHeight() {
    return spreadHeightPx;
  }
}