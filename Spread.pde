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
  private int insideLeftMargin = 200;
  private int insideRightMargin = 200;
  private int headingSize = 120;
  private int subheadingSize = 80;
  private int bodySize = 30;
  private int quoteSize = 120;
  private int footerSize = 30;
  private int baseLine = 700;
  private color bgColor = color(255);
  private color primaryColor = color(0);
  private color spotColor = color(122);
  private PageData[] pageData;
  private boolean rendered = false;
  private boolean isCover;
  /*
  / v-leftOutsideMargin
  / v     rightOutsideMargin
  / v______ ______v
  / |      |      |<-topMargin
  / |      |      |
  / |      |      |
  / |______|______|<-bottomMargin
  /       ^ ^-insideRightMargin
  /       ^-insideLeftMargin
  /*/
  private int rightOfPageMargin[] = {insideRightMargin, rightOutsideMargin};
  private int leftOfPageMargin[] = {leftOutsideMargin, insideLeftMargin};
  private int contentWidthPx[];
  private int contentHeightPx;
  private int pageWidthPx;

  Spread() {
  }

  Spread(int _spreadNum, int _spreadWidthPx, int _spreadHeightPx, boolean isCover) {
    spreadNum = _spreadNum;
    spreadWidthPx = _spreadWidthPx;
    spreadHeightPx = _spreadHeightPx;
    this.isCover = isCover;

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
      pageWidthPx = spreadWidthPx;
      if (numPages > 0) {
        pageWidthPx /= numPages;
      }
      contentWidthPx = new int[numPages];
      for(int i = 0; i < numPages; i++){
        contentWidthPx[i] = pageWidthPx - rightOfPageMargin[i] - leftOfPageMargin[i];
      }
      contentHeightPx = spreadHeightPx - topMargin - bottomMargin;
      //String page = children[spreadNum-1].getChildren("page")[0].getContent();
      //heading = children[pageNum-1].getChild("heading").getContent();
      //body = children[pageNum-1].getChild("body").getContent();
      //println("Created Page: "+pageNum);

      myPGFont = createFont("DINPro-Black", 48);
      pg = createGraphics(_spreadWidthPx, _spreadHeightPx);  


      //pg.textAlign(CENTER, CENTER);
      pg.beginDraw();

      //parse page-specific content
      pageData = new PageData[pages.length];
      for (int i = 0; i < pages.length; i++) {
        pageData[i] = new PageData();
        pageData[i].heading = extractString(pages[i], "heading");
        //heading = pages[i].getChild("heading");
        pageData[i].subheading = extractString(pages[i], "subheading");
        //subheading = pages[i].getChild("subheading");
        pageData[i].body = extractString(pages[i], "body");
        //body = pages[i].getChild("body");
        pageData[i].footer = extractString(pages[i], "footer");
        //footer = pages[i].getChild("footer");
        pageData[i].contentImages = extractImages(pages[i]);

        pageData[i].type = pages[i].getString("type");
        if (pageData[i].type == null) {
        } else if (pageData[i].type.equals("quote")) {
          pageData[i].quote = extractString(pages[i], "quote");
          pageData[i].author = pages[i].getChild("quote").getString("author");
        } else if (pageData[i].type.equals("toc")) {
          pageData[i].content = extractContents(spreads);
        } else if (pageData[i].type.equals("photo")) {
        }
        //quote = pages[i].getChild("quote");
      }

      pg.endDraw();
    }
  }

  public int getMaxHeadingSize() {
    int allowedHeadingHeight = contentHeightPx/4;
    PFont font = loadFont("bold-print.vlw");
    int headingSize = allowedHeadingHeight;
    for(int i = 0; i < pageData.length; i++){
      if (pageData[i].heading != null && pageData[i].heading.length() > 0){
        FormattedTextBlock.FormattedText[] text = {new FormattedTextBlock.FormattedText(pageData[i].heading, font, headingSize)};
        FormattedTextBlock textBlock = new FormattedTextBlock(text, contentWidthPx[i], pg);
        textBlock.constrainHeight(allowedHeadingHeight, pg);
        headingSize = textBlock.text[0].fontSize;
      }
    }
    return headingSize;
  }

  public void setHeadingSize(int size) {
    headingSize = size;
    subheadingSize = size/2;
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
    for (int j=0; j<tXML.length; j++) {
      tImages[j] = loadImage(tXML[j].getString("src")); 
      println(tImages[j]);
    }
    return tImages;
  }

  public Content[] extractContents(XML[] _spreads) {
    ArrayList<XML> pages = new ArrayList<XML>();
    ArrayList<Content> contents = new ArrayList<Content>();
    for(int i = 0; i < _spreads.length; i++){
      XML[] temp = _spreads[i].getChildren("page");
      for(int j = 0; j < temp.length; j++){
        pages.add(temp[j]);
      }
    }
    for(int i = 0; i < pages.size(); i++){
      String heading = extractString(pages.get(i), "heading");
      String pageno = pages.get(i).getString("id");
      if (heading != null && heading.length() > 0){
        contents.add(new Content(pageno, heading));
      }
    }
    return contents.toArray(new Content[contents.size()]);
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
    pageWidthPx = spreadWidthPx;
    if (numPages > 0) {
      pageWidthPx /= numPages;
    }

    myPGFont = createFont("DINPro-Black", 48);
    pg = createGraphics(spreadWidthPx, spreadHeightPx);  

    ////pg.textAlign(CENTER, CENTER);
    pg.beginDraw();



    pageData = new PageData[pages.length];
    for (int i = 0; i < pages.length; i++) {
      pageData[i] = new PageData();
      pageData[i].heading = extractString(pages[i], "heading");
      //heading = pages[i].getChild("heading");
      pageData[i].subheading = extractString(pages[i], "subheading");
      //subheading = pages[i].getChild("subheading");
      pageData[i].body = extractString(pages[i], "body");
      //body = pages[i].getChild("body");
      pageData[i].footer = extractString(pages[i], "footer");
      //footer = pages[i].getChild("footer");
      pageData[i].contentImages = extractImages(pages[i]);

      if (spreadNum < 2) {
        topMargin = 800;
      } else {
        topMargin = 200;
      }

      pageData[i].type = pages[i].getString("type");
      if (pageData[i].type == null) {
      }
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

  public void render() {
    //pg.textAlign(CENTER, CENTER);
    pg.beginDraw();
    pg.background(bgColor);
    pg.textFont(myPGFont);
    pg.fill(primaryColor);
    if (isCover) {
      pg.fill(255, 122, 255);
      pg.rect(0, 0, spreadWidthPx, spreadHeightPx);
      pg.fill(0);
    } else {
    }

    //parse page-specific content
    for (int i = 0; i < pageData.length; i++) {
      pg.pushMatrix();
      pg.translate(pageWidthPx * i, 0);

      if (pageData[i].type == null) {
        base(pageData[i]);
      } else if (pageData[i].type.equals("quote")) {
        quote(pageData[i]);
      } else if (pageData[i].type.equals("toc")) {
        toc(pageData[i]);
      } else if (pageData[i].type.equals("photo")) {
        photo(pageData[i]);
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

  public void quote(PageData pd) {
    // TODO: Check to see if the quote will fit and shrink to fit.
    pg.fill(primaryColor);
    pg.textSize(quoteSize);
    pg.text(pd.quote, topMargin, leftOutsideMargin, pageWidthPx-insideLeftMargin, pageHeightPx-bottomMargin);
    pg.textSize(headingSize);
    pg.text(pd.author, leftOutsideMargin, pageHeightPx-bottomMargin);
  }

  public void toc(PageData pd) {
    //parse the data into FormattedTextBlock;
    String[] separators = {" ", "|", "   ", " | ", " /**/ ", "\n"};
    int interI = (int)random(1, separators.length);
    int intraI = (int)random(0, interI);
    PFont regular = loadFont("reg-print.vlw");
    PFont bold = loadFont("bold-print.vlw");
    int size = regular.getSize();
    FormattedTextBlock.FormattedText[] fText = new FormattedTextBlock.FormattedText[pd.content.length*2];
    for (int i = 0; i < pd.content.length; i++) {
      fText[i*2] = new FormattedTextBlock.FormattedText(pd.content[i].page, bold, size);
      fText[i*2+1] = new FormattedTextBlock.FormattedText(
        separators[intraI] + pd.content[i].text + separators[interI], regular, size);
    }
    FormattedTextBlock textBlock = new FormattedTextBlock(fText, contentWidthPx[0], pg);
    textBlock.constrainHeight(contentHeightPx, pg);

    //now draw the text
    drawBlockedText(textBlock, pg);
  }

  void drawBlockedText(FormattedTextBlock bt, PGraphics pg) {
    pg.pushMatrix();
    pg.translate(insideRightMargin, topMargin);
    pg.fill(0);
    pg.noStroke();
    bt.render(pg);
    pg.popMatrix();
  }

  public void clickbait(String _heading, String _subheading, String _body, String _footer) {
    //his guy went to... What happens next will blow your mind 
    //These facts about childbirth will change the way you look at life FOREVER
    //What this little kid can do with a bongo drum will make you sob uncontrollably until you burst
    //18 Stages of getting addicted to...
    //TEMPLATES = ['{{quantity}} things {{group}} do to avoid {{event}}!', '{{quantity}} {{group}} that haven\'t aged well.', 'This {{individual}} took part in {{event}}. What happened next will amaze you!', 'Watch this {{individual}} {{activity}}. First you\'ll be shocked, then you\'ll be inspired.', 'He worked {{event}} and {{quantity}} {{group}} turned it into {{event}}.']
  }

  public void photo(PageData pd) {
    if (pd.contentImages != null && pd.contentImages.length > 0) {
      //PImage img = loadImage(pd.contentImages[0].getString("src"));
      println("loaded "+pd.contentImages[0]);
      pg.image(pd.contentImages[0], 0, 0, pageWidthPx, pageHeightPx);
    }
  }

  public void base(PageData pd) {
    if (pd.heading != null) {
      pg.textSize(headingSize);
      pg.text(pd.heading, leftOutsideMargin, topMargin, pageWidthPx-insideLeftMargin, pageHeightPx-bottomMargin);
    }
    if (pd.body != null) {
      pg.textSize(bodySize);
      pg.text(pd.body, leftOutsideMargin, baseLine, pageWidthPx-rightOutsideMargin-leftOutsideMargin, pageHeightPx-bottomMargin);
    }
    if (pd.contentImages.length > 0) {
      //PImage img = loadImage(pd.contentImages[0].getString("src"));
      println("loaded "+pd.contentImages[0]);
      pg.image(pd.contentImages[0], (pageWidthPx)/2, (pageHeightPx)/2);
    }
    if (pd.footer != null) {
      pg.textSize(footerSize);
      pg.text(pd.footer, leftOutsideMargin, pageHeightPx-300, pageWidthPx-rightOutsideMargin, pageHeightPx-bottomMargin);
    }
  }

  public PGraphics getPage() {
    if (!rendered) {
      render();
    }
    return pg;
  }

  public int getWidth() {
    return spreadWidthPx;
  }

  public int getHeight() {
    return spreadHeightPx;
  }

  class Content {
    String page;
    String text;

    public Content(String page, String text) {
      this.page = page;
      this.text = text;
    }

    public String toString() {
      return page + ". " + text;
    }
  }

  class PageData {
    String heading, subheading, body, footer, quote, author;
    String type;
    PImage[] contentImages;
    Content[] content;
  }
}