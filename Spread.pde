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
  FontFamily headingFamily, bodyFamily, monoFamily, footerFamily;
  XML xml;
  private int topMargin = 200;
  private int bottomMargin = 200;
  private int leftOutsideMargin = 200;
  private int rightOutsideMargin = 200;
  private int insideLeftMargin = 200;
  private int insideRightMargin = 200;
  private int headingSize = 120;
  private int subheadingSize = 80;
  private int footerSize = 30;
  private int bodySize = 30;
  private int quoteSize = 120;
  private int footerHeight = 0;
  private int headingHeight = 0;
  private int pageNumWidth;
  private int pageNumHeight;
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

  /* Font Information
   /  This project uses the open source fonts available from Adobe.
   /  Specifically:
   /    * Source Sans Pro: https://github.com/adobe-fonts/source-sans-pro
   /    * Source Code Pro (monospaced): https://github.com/adobe-fonts/source-code-pro
   /    * Source Serif Pro: https://github.com/adobe-fonts/source-serif-pro
   /  
   /  These typeface were designed for UI. What could be more UI than a zine?!?
   */

  private int rightOfPageMargin[];
  private int leftOfPageMargin[];
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

    headingFamily = FontFamily.loadSingle("fonts/source-sans-pro/TTF/SourceSansPro-Bold.ttf", 48);
    bodyFamily = FontFamily.loadBody();
    monoFamily = FontFamily.loadSingle("fonts/source-code-pro/TTF/SourceCodePro-ExtraLight.ttf", 48);
    footerFamily = FontFamily.loadSingle("fonts/source-sans-pro/TTF/SourceSansPro-Semibold.ttf", 48);

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
      //String page = children[spreadNum-1].getChildren("page")[0].getContent();
      //heading = children[pageNum-1].getChild("heading").getContent();
      //body = children[pageNum-1].getChild("body").getContent();
      //println("Created Page: "+pageNum);


      pg = createGraphics(_spreadWidthPx, _spreadHeightPx);  


      //pg.textAlign(CENTER, CENTER);
      pg.beginDraw();

      //parse page-specific content
      pageData = new PageData[pages.length];
      for (int i = 0; i < pages.length; i++) {
        pageData[i] = new PageData();
        pageData[i].heading = extractString(pages[i], "heading");
        pageData[i].subheading = extractString(pages[i], "subheading");
        pageData[i].setBodyHeight();
        pageData[i].body = extractString(pages[i], "body");
        pageData[i].footer = extractString(pages[i], "footer");
        pageData[i].pageID = pages[i].getString("id");
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
      }

      pg.endDraw();
    }
    calculatePageNumDims();
    setMargins(topMargin, bottomMargin, 
      leftOutsideMargin, rightOutsideMargin, 
      insideLeftMargin, insideRightMargin);
  }

  public void setHeadingSize(int size) {
    headingSize = size;
    subheadingSize = size/2;
    for (int i = 0; i < pageData.length; i++) {
      if (pageData[i].hasHeading() || pageData[i].hasSubheading()) {
        FormattedTextBlock.FormattedText[] hText;
        if (pageData[i].hasHeading() && pageData[i].hasSubheading()) {
          hText = new FormattedTextBlock.FormattedText[]{
            new FormattedTextBlock.FormattedText(pageData[i].heading + "\n", headingFont, headingSize), 
            new FormattedTextBlock.FormattedText(pageData[i].subheading, headingFont, subheadingSize)};
        } else {
          hText = new FormattedTextBlock.FormattedText[]{
            new FormattedTextBlock.FormattedText(
            pageData[i].hasHeading() ? pageData[i].heading : pageData[i].subheading, 
            headingFont, 
            pageData[i].hasHeading() ? headingSize : subheadingSize)};
        }
        pageData[i].headingBlock = new FormattedTextBlock(hText, pageData[i].contentWidthPx, pg);
        pageData[i].setBodyHeight();
      }
    }
  }

  public int getMaxHeadingSize() {
    int allowedHeadingHeight = contentHeightPx/4;
    //PFont font = loadFont("bold-print.vlw");
    int headingSize = allowedHeadingHeight;
    for (int i = 0; i < pageData.length; i++) {
      if (pageData[i].heading != null && pageData[i].heading.length() > 0) {
        FormattedTextBlock.FormattedText[] text = 
          {new FormattedTextBlock.FormattedText(pageData[i].heading + "\n", headingFont, headingSize), 
          new FormattedTextBlock.FormattedText(pageData[i].subheading, headingFont, subheadingSize)};
        FormattedTextBlock textBlock = new FormattedTextBlock(text, pageData[i].contentWidthPx, pg);
        textBlock.constrainHeight(allowedHeadingHeight, pg);
        headingSize = textBlock.text[0].fontSize;
      }
    }
    return headingSize;
  }

  public int getMaxFooterHeight() {
    //PFont font = loadFont("footer-print.vlw");
    pg.textFont(footerFont);
    pg.textSize(footerSize);
    int maxFooterHeight = 0;
    for (int i = 0; i < pageData.length; i++) {
      if (pageData[i].footer != null && pageData[i].footer.length() > 0) {
        FormattedTextBlock.FormattedText[] text = {new FormattedTextBlock.FormattedText(pageData[i].footer, footerFont, footerSize)};
        FormattedTextBlock textBlock = new FormattedTextBlock(text, pageData[i].contentWidthPx - pageNumWidth, pg);
        maxFooterHeight = Math.max(textBlock.totalHeight, maxFooterHeight);
      }
    }
    return maxFooterHeight;
  }
  
  public void setFooterHeight(int h){
    footerHeight = h;
    for(int i = 0; i < pageData.length; i++){
      pageData[i].setBodyHeight();
    }
  }

  private void calculatePageNumDims() {
    //PFont fFont = loadFont("footer-print.vlw");
    pg.pushStyle();
    pg.textFont(bodyFont);
    pageNumWidth = (int)pg.textWidth("99");
    pageNumHeight = (int)pg.textAscent();
    pg.popStyle();
  }

  public String extractString(XML _page, String _tag) {
    XML tXML = _page.getChild(_tag);
    if (tXML == null) {
      return null;
    } else {
      String output = "";
      XML[] pieces = tXML.getChildren();
      for(int i = 0; i < pieces.length; i++){
        XML piece = pieces[i];
        String name = piece.getName();
        if (name.equals("#text")){
          output += piece.getContent();
        } else if (name.equals("var")){
          String key = piece.getString("key");
          if (key != null && vars.containsKey(key)){
            output += vars.get(key);
          } else {
            output += piece.format(-1);
          }
        }
      }
      return output;
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
    for (int i = 0; i < _spreads.length; i++) {
      XML[] temp = _spreads[i].getChildren("page");
      for (int j = 0; j < temp.length; j++) {
        pages.add(temp[j]);
      }
    }
    for (int i = 0; i < pages.size(); i++) {
      String heading = extractString(pages.get(i), "heading");
      String pageno = pages.get(i).getString("id");
      if (heading != null && heading.length() > 0) {
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


    rightOfPageMargin = new int[]{insideLeftMargin, rightOutsideMargin};
    leftOfPageMargin = new int[]{leftOutsideMargin, insideRightMargin};
    contentHeightPx = spreadHeightPx - topMargin - bottomMargin;
    contentWidthPx = new int[pageData.length];
    headingHeight = contentHeightPx / 4;
    for (int i = 0; i < contentWidthPx.length; i++) {
      contentWidthPx[i] = pageWidthPx - rightOfPageMargin[i] - leftOfPageMargin[i];
      pageData[i].contentWidthPx = contentWidthPx[i];
      pageData[i].contentHeightPx = contentHeightPx;
      pageData[i].topMarginPx = topMargin;
      pageData[i].bottomMarginPx = bottomMargin;
      if (i == 0) {
        pageData[i].outsideEdge = Side.LEFT;
        pageData[i].leftMarginPx = leftOutsideMargin;
        pageData[i].rightMarginPx = insideLeftMargin;
      } else {
        pageData[i].outsideEdge = Side.RIGHT;
        pageData[i].leftMarginPx = insideRightMargin;
        pageData[i].rightMarginPx = rightOutsideMargin;
      }
    }
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

    //myPGFont = createFont("SourceSansPro-Bold", 48);
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
    pg.textFont(bodyFont);
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
      //locate to correct 1/2 of spread
      pg.translate(pageWidthPx * i, 0);
      //adjust for margins
      pg.translate(pageData[i].leftMarginPx, pageData[i].topMarginPx);
      if (pageData[i].footer != null) {
        pageData[i].footerRect = renderFooter(pageData[i]);
      }
      if (pageData[i].hasHeading() || pageData[i].hasSubheading()) {
        pageData[i].headingRect = renderHeading(pageData[i]);
      }
      renderPageNum(pageData[i]);

      if (pageData[i].type == null) {
        base(pageData[i]);
      } else if (pageData[i].type.equals("quote")) {
        quote(pageData[i]);
      } else if (pageData[i].type.equals("toc")) {
        toc(pageData[i]);
      } else if (pageData[i].type.equals("photo")) {
        photo(pageData[i]);
      } else if (pageData[i].type.equals("code")) {
        code(pageData[i]);
      }
      pg.popMatrix();
      //quote = pages[i].getChild("quote");
    }

    //draw spread-general content for debugging purposes
    //pg.textSize(500);
    //pg.line(random(0, _spreadWidthPx), random(0, _spreadHeightPx), random(0, _spreadWidthPx), random(0, _spreadHeightPx));
    //pg.fill(0);
    //pg.rect(0, 0, leftOutsideMargin, topMargin);
    //pg.text(String.format("%02d", spreadNum), _spreadWidthPx/3, _spreadHeightPx/2);
    if (debug) {
      pg.stroke(0);
      pg.strokeWeight(1);
      pg.line(0, topMargin, spreadWidthPx, topMargin);
      pg.line(0, spreadHeightPx - bottomMargin, spreadWidthPx, spreadHeightPx - bottomMargin);
      pg.line(leftOutsideMargin, 0, leftOutsideMargin, spreadHeightPx);
      pg.line(spreadWidthPx / 2 - insideLeftMargin, 0, spreadWidthPx / 2 - insideLeftMargin, spreadHeightPx);
      pg.line(spreadWidthPx / 2 + insideRightMargin, 0, spreadWidthPx / 2 + insideRightMargin, spreadHeightPx);
      pg.line(spreadWidthPx - rightOutsideMargin, 0, spreadWidthPx - rightOutsideMargin, spreadHeightPx);
      pg.strokeWeight(6);
      pg.line(spreadWidthPx / 2, 0, spreadWidthPx / 2, spreadHeightPx);
    }
    pg.endDraw();
  }

  public void quote(PageData pd) {
    TextBox author = new TextBox(pd.author, bodyFont, headingSize, true);
    Rectangle aRect = author.layout(new Rectangle(0, 0, pd.contentWidthPx, pd.bodyHeightPx/3), pg);
    TextBox quote = new TextBox(pd.quote, bodyFont, quoteSize, true);
    quote.render(
      new Rectangle(0, pd.hasHeading() || pd.hasSubheading() ? headingHeight : 0, pd.contentWidthPx, pd.bodyHeightPx - aRect.h),
      pg,
      debug);
    author.render(
      new Rectangle(
        pd.contentWidthPx - aRect.w, 
        pd.contentHeightPx - footerHeight - aRect.h, 
        aRect.w, 
        aRect.h),
      pg,
      debug);
  }

  public void code(PageData pd) {
    // For code samples
    //PFont myCodeFont = createFont("SourceCodePro-ExtraLight", 48);

    pg.textFont(monoFont);
    pg.fill(primaryColor);
    pg.textSize(bodySize-5);
    pg.text(pd.body, 0, 0, pd.contentWidthPx, pd.contentHeightPx - footerHeight);
    pg.textSize(headingSize);
  }


  public void toc(PageData pd) {
    //parse the data into FormattedTextBlock;
    String[] separators = {" ", "|", "   ", " | ", " /**/ ", "\n"};
    int interI = (int)random(1, separators.length);
    int intraI = (int)random(0, interI);
    int size = headingFont.getSize();
    FormattedTextBlock.FormattedText[] fText = new FormattedTextBlock.FormattedText[pd.content.length*2];
    for (int i = 0; i < pd.content.length; i++) {
      fText[i*2] = new FormattedTextBlock.FormattedText(pd.content[i].page, headingFont, size);
      fText[i*2+1] = new FormattedTextBlock.FormattedText(
        separators[intraI] + pd.content[i].text + separators[interI], bodyFont, size);
    }
    FormattedTextBlock textBlock = new FormattedTextBlock(fText, contentWidthPx[0], pg);
    textBlock.constrainHeight(contentHeightPx, pg);

    //now draw the text
    pg.pushMatrix();
    if (pd.hasHeading() || pd.hasSubheading()){
      pg.translate(0, pd.contentHeightPx/4);
    }
    drawBlockedText(textBlock, pg);
    pg.popMatrix();
  }

  void drawBlockedText(FormattedTextBlock bt, PGraphics pg) {
    pg.fill(0);
    pg.noStroke();
    bt.render(pg);
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
      ImageBox iBox = new ImageBox(pd.contentImages[0]);
      float startY = (pd.hasHeading() || pd.hasSubheading()) ? pd.contentHeightPx / 4 : 0;
      iBox.render(new Rectangle(0, startY, pd.contentWidthPx, pd.contentHeightPx - startY - footerHeight), pg, debug);
    }
  }

  public void base(PageData pd) {
    float startY = 0;
    //lets see how much space the body text needs
    TextBox tBox = null;
    float bodyHeight = 0;
    if (pd.body != null && pd.body.length() > 0) {
      tBox = new TextBox(pd.body, bodyFont, bodySize, false);
      pd.bodyRect = tBox.layout(new Rectangle(0, 0, pd.contentWidthPx, pd.contentHeightPx), pg);
      bodyHeight = pd.bodyRect.h;
    }
    println("body: " + bodyHeight);
    float headingHeight = (pd.headingRect != null ? pd.headingRect.h : 0);
    println("head: " + headingHeight);
    
    //lets see how tall the image needs to be
    float targetImageHeight = 0;
    float maxImageHeight = pd.contentHeightPx - bodyHeight - headingHeight - footerHeight;
    float hopedImageHeight = pd.contentHeightPx - bodyHeight - this.headingHeight - footerHeight;
    if (pd.contentImages != null && pd.contentImages.length > 0) {
      ImageBox iBox = new ImageBox(pd.contentImages[0]);
      pd.imageRect = iBox.layout(new Rectangle(0, 0, pd.contentWidthPx, maxImageHeight), pg);
      targetImageHeight = pd.imageRect.h;
      
      if (targetImageHeight <= hopedImageHeight){
        println("img fits");
        pd.imageRect = iBox.render(new Rectangle(0, this.headingHeight, pd.contentWidthPx, hopedImageHeight), pg); 
      } else {
        Rectangle imageDest = new Rectangle(0, headingHeight, pd.contentWidthPx, pd.contentHeightPx - footerHeight - bodyHeight - headingHeight);
        println("img restricted: " + imageDest.toString());
        pd.imageRect = iBox.render(imageDest, pg);
      }
      
      if (bodyHeight > 0){
        pd.bodyRect = tBox.render(new Rectangle(0, pd.imageRect.y + pd.imageRect.h, pd.contentWidthPx, bodyHeight), pg);
      }
    } else if (bodyHeight > 0){
      pd.bodyRect = tBox.render(new Rectangle(0, this.headingHeight, pd.contentWidthPx, bodyHeight), pg);
    }
  }

  private Rectangle renderHeading(PageData pd) {
    HeadingBox box = new HeadingBox(pd.heading, pd.subheading, headingFont, headingSize, subheadingSize);
    return box.render(new Rectangle(0, 0, pd.contentWidthPx, headingHeight), pg, debug);
  }

  private Rectangle renderFooter(PageData pd) {
    TextBox tBox = new TextBox(pd.footer == null ? "" : pd.footer, footerFont, footerSize, false);
    return tBox.render(new Rectangle(0, pd.contentHeightPx - footerHeight, pd.contentWidthPx, footerHeight), pg, debug);
  }

  private void renderPageNum(PageData pd) {
    if (pd.pageID != null && pd.pageID.length() > 0) {
      //PFont fFont = loadFont("footer-print.vlw");
      pg.pushStyle();
      pg.textFont(bodyFont);
      pg.textSize(bodySize*0.7);
      int currWidth = (int)pg.textWidth(pd.pageID);
      int currHeight = bodySize; //(int)pg.lineHeight(pd.pageID);
      float myTempX;
      if (pd.outsideEdge == Side.LEFT){
        myTempX = 0-currWidth-20;
        //pg.text(pd.pageID, , pd.contentHeightPx + bodySize );
      } else {
        //int currWidth = (int)pg.textWidth(pd.pageID);
        myTempX = pd.contentWidthPx+20;
        //pg.text(pd.pageID, pd.contentWidthPx+20, pd.contentHeightPx + bodySize);
      }
      pg.text(pd.pageID, myTempX, pd.contentHeightPx + bodySize);
      println("rendering pg: " + pd.pageID);
      pg.pushMatrix();
      float tmpSize = 50;
      pg.translate(myTempX - tmpSize/2, pd.contentHeightPx + bodySize);
      PShape pageBox = createShape();
      pageBox.beginShape();
      float[] tmpStart = new float[4];
      tmpStart[0] = random(tmpSize);
      tmpStart[1] = random(tmpSize);
      tmpStart[2] = random(tmpSize);
      tmpStart[3] = random(tmpSize);
      //println(tmpStart[0], tmpStart[1], tmpStart[2], tmpStart[3]);
      pageBox.vertex(tmpStart[0], tmpStart[2]);
      pageBox.quadraticVertex(tmpStart[0], tmpStart[1], tmpStart[2], tmpStart[3]);
      pageBox.quadraticVertex(random(tmpSize), random(tmpSize), random(tmpSize), random(tmpSize));
      pageBox.quadraticVertex(random(tmpSize), random(tmpSize), random(tmpSize), random(tmpSize));
      pageBox.quadraticVertex(tmpStart[0], tmpStart[1], tmpStart[2], tmpStart[3]);
      pageBox.vertex(tmpStart[0], tmpStart[2]);
      pageBox.endShape();
      pg.shape(pageBox);
      pg.popMatrix();

      pg.popStyle();
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
    String heading, subheading, body, footer, quote, author, pageID;
    String type;
    PImage[] contentImages;
    Content[] content;
    int contentWidthPx, contentHeightPx, rightMarginPx, leftMarginPx, topMarginPx, bottomMarginPx;
    int bodyHeightPx;
    Side outsideEdge;
    FormattedTextBlock headingBlock;
    Rectangle footerRect, headingRect, bodyRect, imageRect;
    boolean hasHeading() {
      return heading != null && heading.length() > 0;
    }
    boolean hasSubheading() {
      return subheading != null && subheading.length() > 0;
    }
    void setBodyHeight(){
      bodyHeightPx = contentHeightPx - footerHeight;
      if (hasHeading() || hasSubheading()){
        bodyHeightPx -= headingHeight;
      }
    }
  }
}

enum Side {
  RIGHT, LEFT, NONE

class FontFamily{
  Map<FontWeight, Map<FontEm, PFont>> fonts;
  private FontFamily(){
    fam.fonts = new Map<FontWeight, Map<FontEm, PFont>>();
  }
  
  public loadFont(FontWeight w, FontEm e, String path, float size){
    PFont f = createFont(path, size);
    if (!fonts.hasKey(w)){
      fonts.put(w, new Map<FontEm, PFont>());
    }
    Map<FontEm, PFont> currWeight = fonts.get(w);
    currWeight.put(e, f);
  }
  
  public PFont getReg(){
    return get(FontWeight.REGULAR, FontEm.REGULAR);
  }
  
  public PFont get(FontWeight w, FontEm e){
    if (fonts.hasKey(w) && fonts.get(w).hasKey(e)){
      return fonts.get(w).get(e);
    } else {
      return null;
    }
  }
  
  public static FontFamily loadBody(){
    FontFamily fam = new FontFamily();
    fam.loadFont(FontWeight.REGULAR, FontEm.REGULAR, "fonts/source-serif-pro/TTF/SourceSerifPro-Regular.ttf", 48);
    fam.loadFont(FontWeight.BOLD, FontEm.REGULAR, "fonts/source-serif-pro/TTF/SourceSerifPro-Bold.ttf", 48);
    return fam;
  }
  
  public static FontFamily loadSingle(String path, float size){
    FontFamily fam = new FontFamily();
    fam.loadFont(FontWeight.REGULAR, FontEm.REGULAR, path, size);
    return fam;
  }
}

enum FontWeight{
  EXTRA_LIGHT, LIGHT, REGULAR, SEMI_BOLD, BOLD, BLACK;
}

enum FontEm{
  REGULAR, ITALIC
}