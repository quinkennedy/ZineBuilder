/*
 *  Composition
 *
 *  DESCRIPTION: A pretty generic composition class 
 * 
 *  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php 
 */

class Spread {
  public int spreadNum;
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
  private int headingSize = 100;
  private int subheadingSize = 50;
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
  private XML[] spreads;
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
    
    print(" I THINK MY SPREAD NUM IS "+spreadNum);
    // load content
    xml = loadXML("zine.xml");

    headingFamily = FontFamily.loadHeading(SensoryZine001.this);//FontFamily.loadSingle("fonts/source-sans-pro/TTF/SourceSansPro-Bold.ttf", 48, SensoryZine001.this);
    bodyFamily = FontFamily.loadBody(SensoryZine001.this);
    monoFamily = FontFamily.loadSingle("fonts/source-code-pro/TTF/SourceCodePro-Light.ttf", 48, SensoryZine001.this);
    footerFamily = FontFamily.loadSingle("fonts/source-sans-pro/TTF/SourceSansPro-Semibold.ttf", 48, SensoryZine001.this);

    spreads = xml.getChildren("spread");
    
    if (isCover == true) {
     createCover();
     println("laying out cover "+spreadNum);
    } else {
      // parse spreads
      
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


      pg = createGraphics(_spreadWidthPx, _spreadHeightPx);  


      //pg.textAlign(CENTER, CENTER);
      pg.beginDraw();

      //parse page-specific content
      pageData = new PageData[pages.length];
      for (int i = 0; i < pages.length; i++) {
        pageData[i] = new PageData();
        pageData[i].heading = pages[i].getChild("heading");
        pageData[i].subheading = pages[i].getChild("subheading");
        pageData[i].setBodyHeight();
        pageData[i].body = pages[i].getChild("body");
        pageData[i].footer = pages[i].getChild("footer");
        pageData[i].pageID = pages[i].getString("id");
        pageData[i].contentImages = extractImages(pages[i]);

        pageData[i].type = pages[i].getString("type");
        if (pageData[i].type == null) {
        } else if (pageData[i].type.equals("quote")) {
          pageData[i].quote = pages[i].getChild("quote");
          if (pageData[i].quote != null){
            pageData[i].author = pageData[i].quote.getString("author");
          }
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
      pageData[i].setBodyHeight();
    }
  }

  public int getMaxHeadingSize() {
    //PFont font = loadFont("bold-print.vlw");
    int headingSize = this.headingSize;
    for (int i = 0; i < pageData.length; i++) {
      HeadingBox hBox = new HeadingBox(pageData[i].heading, pageData[i].subheading, headingFamily, 
                                       headingSize, headingSize/2, pg, vars, true);
      Rectangle usedArea = hBox.layout(new Rectangle(0, 0, pageData[i].contentWidthPx, headingHeight), pg);
      if (hBox.hasHeading()){
        headingSize = (int)min(headingSize, hBox.getHeadingSize());
      } else if (hBox.hasSubheading()){
        headingSize = (int)min(headingSize, hBox.getSubheadingSize() * 2);
      }
    }
    return headingSize;
  }

  public int getMaxFooterHeight() {
    //PFont font = loadFont("footer-print.vlw");
    pg.textFont(footerFamily.get(FontWeight.REGULAR, FontEm.REGULAR));
    pg.textSize(footerSize);
    int maxFooterHeight = 0;
    for (int i = 0; i < pageData.length; i++) {
      TextBox fBox = new TextBox(pageData[i].footer, footerFamily, footerSize, pg, vars, false);
      Rectangle usedArea = fBox.layout(new Rectangle(0, 0, pageData[i].contentWidthPx, Float.POSITIVE_INFINITY), pg);
      maxFooterHeight = (int)Math.max(usedArea.h, maxFooterHeight);
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
    pg.textFont(bodyFamily.get(FontWeight.REGULAR, FontEm.REGULAR));
    pageNumWidth = (int)pg.textWidth("99");
    pageNumHeight = (int)pg.textAscent();
    pg.popStyle();
  }

  public PImage[] extractImages(XML _page) {
    XML [] tXML = _page.getChildren("image");
    PImage [] tImages = new PImage[tXML.length];
    for (int j=0; j<tXML.length; j++) {
      tImages[j] = loadImage(tXML[j].getString("src"));
    }
    return tImages;
  }

  public Content[] extractContents(XML[] _spreads) {
    ArrayList<Content> contents = new ArrayList<Content>();
    for(int i = 0; i < _spreads.length; i++){
      XML[] pages = _spreads[i].getChildren("page");
      for(int j = 0; j < pages.length; j++){
        HeadingBox hBox = new HeadingBox(pages[j].getChild("heading"), null, headingFamily, headingSize, subheadingSize, pg, vars, false);
        if (hBox.hasHeading()){
          contents.add(new Content(pages[j].getString("id"), hBox.getHeadingText(pg)));
        }
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
    if (isCover){
      headingHeight = contentHeightPx / 2;
    } else {
      headingHeight = contentHeightPx / 4;
    }
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
      pageData[i].heading = pages[i].getChild("heading");
      pageData[i].subheading = pages[i].getChild("subheading");
      pageData[i].body = pages[i].getChild("body");
      pageData[i].footer = pages[i].getChild("footer");
      pageData[i].contentImages = extractImages(pages[i]);

      //if (spreadNum < 2) {
      //  topMargin = 800;
      //} else {
        topMargin = 200;
      //}

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
    
    // background
    //if (spreads[spreadNum-1].getString("background")
    // print(spreads[spreadNum-1]);
    if (spreads[spreadNum-1].hasAttribute("background")) {
      print(spreads[spreadNum-1].getString("background"));
      String background = spreads[spreadNum-1].getString("background");
      if (background != null && background.equals("dots")) {
        for (int j=0; j<spreadWidthPx/10; j++) {
          for (int k=0; k<spreadHeightPx/10; k++) {
             //pg.rect(j*10, k*10, 5, 5); 
             pg.point(j*10, k*10);
          }
        }
      }
      if (background != null && background.equals("arch")) {
        PImage tImg = loadImage("images/U_2_694819491672_archigram.jpg");
        pg.image(tImg, 0,0,spreadWidthPx, spreadHeightPx);
      }
    }

    
    pg.textFont(bodyFamily.getReg());
    pg.fill(primaryColor);

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
      } else if (pageData[i].type.equals("toplist")) {
        toplist(pageData[i]);
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
    TextBox author = new TextBox(pd.author, bodyFamily.getReg(), headingSize, pg, true);
    Rectangle aRect = author.layout(new Rectangle(0, 0, pd.contentWidthPx, pd.bodyHeightPx/3), pg);
    TextBox quote = new TextBox(pd.quote, bodyFamily, quoteSize, pg, vars, true);
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
    TextBox code = new TextBox(pd.body, monoFamily, bodySize - 5, pg, vars, true);
    Rectangle cRect = code.layout(new Rectangle(0, 0, pd.contentWidthPx, pd.bodyHeightPx), pg);
    pg.pushStyle();
    pg.fill(255);
    pg.noStroke();
    pg.rect(cRect.x, cRect.y, cRect.w, cRect.h);
    pg.popStyle();
    code.render(new Rectangle(0, 0, pd.contentWidthPx, pd.bodyHeightPx),pg);
  }

  public void toplist(PageData pd) {
    TextBox tBox = null;
    tBox = new TextBox(pd.body, bodyFamily, subheadingSize, pg, vars, false);
    pd.bodyRect = tBox.layout(new Rectangle(0, 0, pd.contentWidthPx, pd.contentHeightPx), pg);
    tBox.render(new Rectangle(0, this.headingHeight, pd.contentWidthPx, headingHeight), pg, debug);
  }
  
  public void toc(PageData pd) {
    //parse the data into FormattedTextBlock;
    String[] separators = {" ", "|", "   ", " | ", " /**/ ", "\n"};
    int interI = (int)random(1, separators.length);
    int intraI = (int)random(0, interI);
    int size = headingSize;//headingFont.getSize();
    FormattedTextBlock cBox = new FormattedTextBlock(pg);
    
    //FormattedTextBlock.FormattedText[] fText = new FormattedTextBlock.FormattedText[pd.content.length*2];
    for (int i = 0; i < pd.content.length; i++) {
      cBox.add(pd.content[i].page, headingFamily.getReg(), size);
      cBox.add(separators[intraI] + pd.content[i].text + separators[interI], bodyFamily.getReg(), size);
      //fText[i*2] = new FormattedTextBlock.FormattedText(pd.content[i].page, headingFont, size);
      //fText[i*2+1] = new FormattedTextBlock.FormattedText(
      //  separators[intraI] + pd.content[i].text + separators[interI], bodyFont, size);
    }
    //FormattedTextBlock textBlock = new FormattedTextBlock(fText, contentWidthPx[0], pg);
    cBox.setConstraints(pd.contentWidthPx, pd.bodyHeightPx - headingHeight);
    //textBlock.constrainHeight(contentHeightPx, pg);

    //now draw the text
    pg.pushMatrix();
    if (pd.hasHeading() || pd.hasSubheading()){
      pg.translate(0, pd.contentHeightPx/4);
    }
    cBox.render(pg);
    //drawBlockedText(textBlock, pg);
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
    if (pd.body != null && pd.body.getChildren().length > 0) {
      // We should add an optional background for the content boxes.
      tBox = new TextBox(pd.body, bodyFamily, bodySize, pg, vars, false);
      pd.bodyRect = tBox.layout(new Rectangle(0, 0, pd.contentWidthPx, pd.contentHeightPx), pg);
      bodyHeight = pd.bodyRect.h;
    }
    float headingHeight = (pd.headingRect != null ? pd.headingRect.h : 0);
    
    //lets see how tall the image needs to be
    if (pd.contentImages != null && pd.contentImages.length > 0) {
      float targetImageHeight = 0;
      float maxImageHeight = pd.contentHeightPx - bodyHeight - headingHeight - footerHeight;
      float hopedImageHeight;
      if (isCover){
        hopedImageHeight = (pd.headingRect == null ? (pd.contentHeightPx - footerHeight) : (pd.contentHeightPx - footerHeight - headingHeight - 20));
      } else {
        hopedImageHeight = pd.contentHeightPx - bodyHeight - this.headingHeight - footerHeight;
      }
      ImageBox iBox = new ImageBox(pd.contentImages[0]);
      Rectangle rArea;
      if (isCover){
        rArea = new Rectangle(0, 0, pd.contentWidthPx, hopedImageHeight);
      } else {
        rArea = new Rectangle(0, 0, pd.contentWidthPx, maxImageHeight);
      }
      pd.imageRect = iBox.layout(rArea, pg);
      targetImageHeight = pd.imageRect.h;
      
      if (targetImageHeight <= hopedImageHeight){
        if (isCover){
          rArea = new Rectangle(-40, hopedImageHeight - targetImageHeight, pd.imageRect.w, targetImageHeight);
        } else {
          rArea = new Rectangle(0, this.headingHeight, pd.contentWidthPx, hopedImageHeight);
        }
      } else {
        if (isCover){
          rArea = new Rectangle(-40, 0, pd.imageRect.w, rArea.h);
        } else {
          rArea = new Rectangle(0, headingHeight, pd.contentWidthPx, pd.contentHeightPx - footerHeight - bodyHeight - headingHeight);
        }
      }
      pd.imageRect = iBox.render(rArea, pg);
      
      if (bodyHeight > 0){
        pd.bodyRect = tBox.render(new Rectangle(0, pd.imageRect.y + pd.imageRect.h, pd.contentWidthPx, bodyHeight), pg);
      }
    } else if (bodyHeight > 0){
      pd.bodyRect = tBox.render(new Rectangle(0, this.headingHeight, pd.contentWidthPx, bodyHeight), pg);
    }
  }

  private Rectangle renderHeading(PageData pd) {
    HeadingBox box = new HeadingBox(pd.heading, pd.subheading, headingFamily, headingSize, subheadingSize, pg, vars, false);
    Rectangle rArea;
    if (isCover){
      rArea = new Rectangle(0, pd.contentHeightPx / 2, pd.contentWidthPx, headingHeight);
      rArea = box.layout(rArea, pg);
      rArea = new Rectangle(0, pd.contentHeightPx - footerHeight - rArea.h - 20, pd.contentWidthPx, rArea.h);
    } else {
      rArea = new Rectangle(0, 0, pd.contentWidthPx, headingHeight);
    }
    return box.render(rArea, pg, debug);
  }

  private Rectangle renderFooter(PageData pd) {
    TextBox tBox = new TextBox(pd.footer, footerFamily, footerSize, pg, vars, false);
    return tBox.render(new Rectangle(0, pd.contentHeightPx - footerHeight, pd.contentWidthPx, footerHeight), pg, debug);
  }

  private void renderPageNum(PageData pd) {
    if (pd.pageID != null && pd.pageID.length() > 0) {
      //PFont fFont = loadFont("footer-print.vlw");
      pg.pushStyle();
      pg.textFont(bodyFamily.getReg());
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
    XML heading, subheading, body, footer, quote;
    String author, pageID, background;
    String type;
    PImage[] contentImages;
    Content[] content;
    int contentWidthPx, contentHeightPx, rightMarginPx, leftMarginPx, topMarginPx, bottomMarginPx;
    int bodyHeightPx;
    Side outsideEdge;
    Rectangle footerRect, headingRect, bodyRect, imageRect;
    boolean hasHeading() {
      return heading != null;
    }
    boolean hasSubheading() {
      return subheading != null;
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
}

static class FontFamily{
  Map<FontWeight, Map<FontEm, PFont>> fonts;
  
  private FontFamily(){
    fonts = new HashMap<FontWeight, Map<FontEm, PFont>>();
  }
  
  public void loadFont(FontWeight w, FontEm e, String path, float size, PApplet p){
    PFont f = p.createFont(path, size);
    if (!fonts.keySet().contains(w)){
      fonts.put(w, new HashMap<FontEm, PFont>());
    }
    Map<FontEm, PFont> currWeight = fonts.get(w);
    currWeight.put(e, f);
  }
  
  public PFont getReg(){
    return get(FontWeight.REGULAR, FontEm.REGULAR);
  }
  
  public PFont get(FontWeight w, FontEm e){
    if (fonts.keySet().contains(w) && fonts.get(w).keySet().contains(e)){
      return fonts.get(w).get(e);
    } else {
      return null;
    }
  }
  
  public static FontFamily loadBody(PApplet p){
    FontFamily fam = new FontFamily();
    fam.loadFont(FontWeight.REGULAR, FontEm.REGULAR, "fonts/source-serif-pro/TTF/SourceSerifPro-Regular.ttf", 48, p);
    fam.loadFont(FontWeight.BOLD, FontEm.REGULAR, "fonts/source-serif-pro/TTF/SourceSerifPro-Bold.ttf", 48, p);
    return fam;
  }
  
  public static FontFamily loadHeading(PApplet p){
    FontFamily fam = new FontFamily();
    fam.loadFont(FontWeight.REGULAR, FontEm.REGULAR, "fonts/source-sans-pro/TTF/SourceSansPro-Bold.ttf", 48, p);
    fam.loadFont(FontWeight.LIGHT, FontEm.REGULAR, "fonts/source-sans-pro/TTF/SourceSansPro-Semibold.ttf", 48, p);
    return fam;
  }
  
  public static FontFamily loadSingle(String path, float size, PApplet p){
    FontFamily fam = new FontFamily();
    fam.loadFont(FontWeight.REGULAR, FontEm.REGULAR, path, size, p);
    return fam;
  }
}

enum FontWeight{
  EXTRA_LIGHT, LIGHT, REGULAR, SEMI_BOLD, BOLD, BLACK;
}

enum FontEm{
  REGULAR, ITALIC
}