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
    pg.background(255);
    pg.textFont(myPGFont);
    pg.fill(0);

    //draw page-specific content
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

    //draw spread-general content
    pg.textSize(500);
    pg.line(random(0, _spreadWidthPx), random(0, _spreadHeightPx), 
      random(0, _spreadWidthPx), random(0, _spreadHeightPx));
    pg.rect(0, 0, 100, 100);
    pg.text(String.format("%02d", spreadNum), _spreadWidthPx/3, _spreadHeightPx/2);

    pg.endDraw();
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

  public void quote(String _heading, String _subheading, String _body, String _footer, String _quote, String _author) {
    pg.fill(0);
    pg.textSize(120);
    pg.text(_quote, 100, 100, pageWidthPx-100, pageHeightPx-100);
    pg.textSize(50);
    pg.text(_author, 100, pageHeightPx-200);
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
        if (_heading != null) {
          pg.textSize(50);
          pg.text(_heading, 100, 100);
        }
        if (_body != null) {
          pg.textSize(12);
          pg.text(_body, 100, 300, 400, 700);
        }
        if (_images.length > 0) {
          //PImage img = loadImage(_images[0].getString("src"));
          println("loaded "+_images[0]);
          pg.image(_images[0], 0, 0, pageWidthPx, pageHeightPx);
        }
        if (_footer != null) {
          pg.text(_footer, -100, -100);
        }
  }

  public void base(String _heading, String _subheading, String _body, String _footer, PImage [] _images) {
        if (_heading != null) {
          pg.textSize(50);
          pg.text(_heading, 100, 100);
        }
        if (_body != null) {
          pg.textSize(12);
          pg.text(_body, 100, 300, 400, 700);
        }
        if (_images.length > 0) {
          //PImage img = loadImage(_images[0].getString("src"));
          println("loaded "+_images[0]);
          pg.image(_images[0], (pageWidthPx)/2, (pageHeightPx)/2);
        }
        if (_footer != null) {
          pg.text(_footer, -100, -100);
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