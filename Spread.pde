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
  private int topMargin = 200;
  private int bottomMargin = 200;
  private int leftOutsideMargin = 200;
  private int rightOutsideMargin = 200;
  private int insideLeftMargin = 50;
  private int insideRightMargin = 50;
  private int headingSize = 120;
  private int subheadingSize = 80;
  private int bodySize = 30;
  private int quoteSize = 120;
  private int footerSize = 30;
  private int baseLine = 400;
  private color bgColor = color(255);
  private color primaryColor = color(0);
  private color spotColor = color(122);

  Spread() {
  }
  
  Spread(int _spreadNum, int _spreadWidthPx, int _spreadHeightPx, boolean isCover) {
    spreadNum = _spreadNum;
    spreadWidthPx = _spreadWidthPx;
    spreadHeightPx = _spreadHeightPx;

    // load content
    xml = loadXML("zine.xml");
    
    if (isCover == true) {
        createCover();
        println("laying out cover "+spreadNum);
    } else {
    // parse spreads
    XML[] spreads = xml.getChildren("spread");
    //XML spread = children[spreadNum-1];
    XML[] pages = spreads[spreadNum-1].getChildren("page");
    int numPages = pages.length;
    int pageWidthPx = spreadWidthPx;
    if (numPages > 0) {
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
    pg.background(bgColor);
    pg.textFont(myPGFont);
    pg.fill(primaryColor);

    //parse page-specific content
    String heading, subheading, body, footer;
    PImage [] contentimages;
    String quote, author; 
    for (int i = 0; i < pages.length; i++) {
      pg.pushMatrix();
      pg.translate(pageWidthPx * i, 0);
      heading = extractString(pages[i], "heading");
      //heading = pages[i].getChild("heading");
      subheading = extractString(pages[i], "subheading");
      //subheading = pages[i].getChild("subheading");
      body = extractString(pages[i], "body");
      //body = pages[i].getChild("body");
      footer = extractString(pages[i], "footer");
      //footer = pages[i].getChild("footer");
      contentimages = extractImages(pages[i]);

      String contentType = pages[i].getString("type");
      if (contentType == null) {
        base(heading, subheading, body, footer, contentimages);
       } else if (contentType.equals("quote")) {
        quote = extractString(pages[i], "quote");
        author = pages[i].getChild("quote").getString("author");
        quote(heading, subheading, body, footer, quote, author);
      } else if (contentType.equals("toc")) {
        Content[] content = extractContents(pages[i]);
        toc(heading, subheading, body, footer, content);
      } else if (contentType.equals("photo")) {
        photo(heading, subheading, body, footer, contentimages);
      }
      pg.popMatrix();
      //quote = pages[i].getChild("quote");
    }

    //draw spread-general content for debugging purposes
    //pg.textSize(500);
    //pg.line(random(0, _spreadWidthPx), random(0, _spreadHeightPx), random(0, _spreadWidthPx), random(0, _spreadHeightPx));
    pg.rect(0, 0, 100, 100);
    //pg.text(String.format("%02d", spreadNum), _spreadWidthPx/3, _spreadHeightPx/2);

    pg.endDraw();
    }
  }

  public String extractString(XML _page, String _tag) {
    XML tXML = _page.getChild(_tag);
    if (tXML == null) {
      return null;
    } else {
      return tXML.getContent();
    }
  }
  
  public PImage[] extractImages(XML _page) {
      XML [] tXML = _page.getChildren("image");
      PImage [] tImages = new PImage[tXML.length];
      for(int j=0; j<tXML.length; j++) {
        tImages[j] = loadImage(tXML[j].getString("src")); 
        println(tImages[j]);
      }
      return tImages;
  }
  
  public Content[] extractContents(XML _page){
    XML[] xContents = _page.getChild("table").getChildren("content");
    Content[] tContents = new Content[xContents.length];
    for(int i = 0; i < xContents.length; i++){
      tContents[i] = new Content(xContents[i].getString("page"), xContents[i].getContent());
    }
    return tContents;
  }

  public void setMargins(int _topMargin, int _bottomMargin, 
                         int _leftOutsideMargin, int _rightOutsideMargin, 
                         int _insideLeftMargin, int _insideRightMargin) {
    topMargin = _topMargin;
    bottomMargin = _bottomMargin;
    leftOutsideMargin = _leftOutsideMargin;
    rightOutsideMargin = _rightOutsideMargin;
    insideLeftMargin = _insideLeftMargin;
    insideRightMargin = _insideRightMargin;
  }
  
  public void createCover() {
    XML[] cover = xml.getChildren("cover");
    XML[] pages = cover[spreadNum-1].getChildren("page");
    //println(cover);
    
    int numPages = pages.length;
    int pageWidthPx = spreadWidthPx;
    if (numPages > 0) {
     pageWidthPx /= numPages;
    }
      
    myPGFont = createFont("DINPro-Black", 48);
    pg = createGraphics(spreadWidthPx, spreadHeightPx);  

     ////pg.textAlign(CENTER, CENTER);
     pg.beginDraw();
     pg.background(bgColor);
     pg.textFont(myPGFont);
     //pg.text(100,100,
     pg.fill(255,122,255);
     pg.rect(0,0,spreadWidthPx, spreadHeightPx);
     pg.fill(0);
     
         String heading, subheading, body, footer;
    PImage [] contentimages;
    String quote, author; 
    for (int i = 0; i < pages.length; i++) {
      heading = extractString(pages[i], "heading");
      //heading = pages[i].getChild("heading");
      subheading = extractString(pages[i], "subheading");
      //subheading = pages[i].getChild("subheading");
      body = extractString(pages[i], "body");
      //body = pages[i].getChild("body");
      footer = extractString(pages[i], "footer");
      //footer = pages[i].getChild("footer");
      contentimages = extractImages(pages[i]);
      
      String contentType = pages[i].getString("type");
      if (contentType == null) {
        base(heading, subheading, body, footer, contentimages);
      }
      
     pg.pushMatrix();
     pg.translate(pageWidthPx * i, 0);
      


     pg.popMatrix();
    }
    
    pg.endDraw();

    
    //XML[] coverpages = cover[].getChildren("page");

    //XML[] outsideCover = cover[0].getChildren("page");
    //XML[] outsideBackCover = cover[0].getChildren("page");
    //XML[] insideCover = cover[0].getChildren("page");
    //XML[] insideBackCover = cover[0].getChildren("page");
    
    
    //heading = extractString(pages[i], "heading");
    //heading = pages[i].getChild("heading");
    //subheading = extractString(pages[i], "subheading");
  }
  
  public void quote(String _heading, String _subheading, String _body, String _footer, String _quote, String _author) {
    // TODO: Check to see if the quote will fit and shrink to fit.
    pg.fill(primaryColor);
    pg.textSize(quoteSize);
    pg.text(_quote, topMargin, leftOutsideMargin, pageWidthPx-insideLeftMargin, pageHeightPx-bottomMargin);
    pg.textSize(headingSize);
    pg.text(_author, leftOutsideMargin, pageHeightPx-bottomMargin);
  }

  public void toc(String _heading, String _subheading, String _body, String _footer, Content[] contents) {
    //parse the data into FormattedTextBlock;
    String[] separators = {" ", "|", "   ", " | ", " /**/ ", "\n"};
    int interI = (int)random(1, separators.length);
    int intraI = (int)random(0, interI);
    PFont regular = loadFont("reg-print.vlw");
    PFont bold = loadFont("bold-print.vlw");
    FormattedTextBlock.FormattedText[] fText = new FormattedTextBlock.FormattedText[contents.length*2];
    for(int i = 0; i < contents.length; i++){
      fText[i*2] = new FormattedTextBlock.FormattedText(contents[i].page, bold);
      fText[i*2+1] = new FormattedTextBlock.FormattedText(
        separators[intraI] + contents[i].text + separators[interI], regular);
    }
    FormattedTextBlock textBlock = new FormattedTextBlock(fText, pageWidthPx*2/3, pg);
    
    //now draw the text
    drawBlockedText(textBlock, pg);
  }
  
  void drawBlockedText(FormattedTextBlock bt, PGraphics pg){
    FormattedTextBlock.FormattedLine currLine;
    float startX = pageWidthPx*2/12, currX = startX, currY = startX;
    pg.noFill();
    pg.stroke(100);
    pg.rect(startX, startX, pageWidthPx*2/3, pageHeightPx*2/3);
    pg.fill(0);
    pg.noStroke();
    ArrayList<FormattedTextBlock.FormattedLine> lines = bt.lines;
    for(int i = 0; i < lines.size(); i++){
      currLine = bt.lines.get(i);
      for(int w = 0; w < currLine.texts.size(); w++){
        FormattedTextBlock.FormattedText currContig = currLine.texts.get(w);
        pg.textFont(currContig.font);
        pg.text(currContig.text, currX, currY);
        currX += pg.textWidth(currContig.text);
      }
      if (currX != startX){
        currY += pg.textDescent() + pg.textAscent();
        currX = startX;
      }
    }
  }
  
  public void clickbait(String _heading, String _subheading, String _body, String _footer) {
       //his guy went to... What happens next will blow your mind 
       //These facts about childbirth will change the way you look at life FOREVER
       //What this little kid can do with a bongo drum will make you sob uncontrollably until you burst
       //18 Stages of getting addicted to...
       //TEMPLATES = ['{{quantity}} things {{group}} do to avoid {{event}}!', '{{quantity}} {{group}} that haven\'t aged well.', 'This {{individual}} took part in {{event}}. What happened next will amaze you!', 'Watch this {{individual}} {{activity}}. First you\'ll be shocked, then you\'ll be inspired.', 'He worked {{event}} and {{quantity}} {{group}} turned it into {{event}}.']

  }

  public void photo(String _heading, String _subheading, String _body, String _footer, PImage [] _images) {
        if (_images.length > 0) {
          //PImage img = loadImage(_images[0].getString("src"));
          println("loaded "+_images[0]);
          pg.image(_images[0], 0, 0, pageWidthPx, pageHeightPx);
        }
  }

  public void base(String _heading, String _subheading, String _body, String _footer, PImage [] _images) {
        if (_heading != null) {
          pg.textSize(headingSize);
          pg.text(_heading, leftOutsideMargin, topMargin, pageWidthPx-insideLeftMargin, pageHeightPx-bottomMargin);
        }
        if (_body != null) {
          pg.textSize(bodySize);
          pg.text(_body, leftOutsideMargin, baseLine, pageWidthPx-rightOutsideMargin, pageHeightPx-bottomMargin);
        }
        if (_images.length > 0) {
          //PImage img = loadImage(_images[0].getString("src"));
          println("loaded "+_images[0]);
          pg.image(_images[0], (pageWidthPx)/2, (pageHeightPx)/2);
        }
        if (_footer != null) {
          pg.textSize(footerSize);
          pg.text(_footer, leftOutsideMargin, pageHeightPx-300, pageWidthPx-rightOutsideMargin, pageHeightPx-bottomMargin);
        }

  }
  
  public PGraphics getPage() {
    return pg;
  }

  public int getWidth() {
    return spreadWidthPx;
  }

  public int getHeight() {
    return spreadHeightPx;
  }
  
  class Content{
    String page;
    String text;
    
    public Content(String page, String text){
      this.page = page;
      this.text = text;
    }
    
    public String toString(){
      return page + ". " + text;
    }
  }
}