import controlP5.*; //<>// //<>//
//for PDF //<>// //<>//
import processing.pdf.*;
//for Map
import java.util.*;

//boolean separateCopies = false;
boolean debug = false;
PFont screenFont;
boolean testLayout = false;
int paperWidthPx;
int paperHeightPx;
int pageWidthPx;
int pageHeightPx;
int compWidthPx;
int compHeightPx;
int numPages;
int numSpreads;
int coverPages = 2;
Spread[] spreads;
Spread[] cover;
VarService vars;
ZinePageLayout[][][] zpl;
ControlP5 cp5;


/*
 *  SensoryZine001.pde
 *
 *  SUMMARY: A first attempt at a generative zine creation tool.
 *
 *  DESCRIPTION: Define a size, dpi, and number of folds and the
 *  program will output a pdf.
 *
 *  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
 */

/* NOTES AND TODO

 Define the data model and then it puts itself together right? right?!? ;-(
 paper width 8.5
 paper height 11
 desired dpi 300
 size 0.5 (half size), 0.25 (quarter size), 0.0833 (one twelfth), 0.0625 (one sixteenth)
 top margin
 bottom margin
 centerleft margin
 centerright margin
 number of pages (dependent on size)

 Take the parameters and generate the first page which
 is just some summary info and each of the spreads.

 Then paginate and layout the book for printing in the subsequent pages.

 Eventually we can use the processing window to show the controls

 Lets special case the cover

 Content Block Types (Information Blocks):
 * Quote
 * Quotation
 * Author
 * Table of Contents
 * Table (Page number, title)
 * Information Block
 * Photo
 * Drawing (Generative)

 Potential Block Types: (Also the idea of maps for navigation and summary vs content blocks)
 * Analogy
 * Metaphor / Simile
 * Checklist
 * Classification List / Table
 * Classification Tree
 * Comment
 * Cycle Chart
 * Decision Table
 * Definition
 * Description
 * Diagram
 * Discourse (Horn pg. 187)
 * Infographic / Data Vis
 * Meme
 * Example / Non-example
 * Fact
 * Flow Chart
 * Flow Diagram
 * Formula
 * Input - Procedure - Output
 * Propaganda
 * Notation
 * Goals / Objectives
 * Outline
 * Parts-Function table
 * Parts table
 * Prerequisites
 * Principle
 * Review
 * Rant
 * Interview
 * Case Study
 * Parable
 * Zinger
 * Comic
 * Message Exchange (IM, SMS, etc.)
 * User Generated Content
 * Testimonial
 * Newsjacking
 * Puzzle / Game
 * Background
 * FAQ
 * Map
 * Bio
 * Procedure
 * Purpose
 * Rule(s)
 * Synonym
 * When to Use
 * Theorem
 * Who does what / Org chart
 * Worksheet
 * Overview
 * Compare and Contrast
 * Advice
 * Summary
 * Test / Practice
 * Clickbait
 * Listicle
 * Structure
 * Concept
 * Process
 * Table of Contents
 * Index



 Base Class
 * heading
 * subheading
 * body
 * footer
 * image
 */


void setup() {
  size(400, 400, P3D);
  vars = new VarService(this);
  setupUI();
  loadDir();
  if (testLayout){
    testLayout();
    return;
  }

  //// CHECK WHAT FONTS ARE ON THE SYSTEM
  //String[] fontList = PFont.list();
  //println(fontList);
  screenFont = createFont("SourceSansPro-Bold", 48);

  zineState = new ZineState();
}

Numberbox paperWidthIn, paperHeightIn;

private void setupUI(){
  cp5 = new ControlP5(this);
  Textarea myTextarea;
  
  cp5.addTab("details");

  int row;
  
  // Default tab
  row = 40;
  cp5.addTextfield("Directory")
    .setSize(width - 20 - 20, 20)
    .setPosition(20, row);
  cp5.addButton("Choose")
    .setPosition(width - 20 - 70, row+20+10);
  row += 40;
  cp5.addNumberbox("Copies")
    .setPosition(20, row)
    .setValue(1);
  row += 40;
  cp5.addNumberbox("startAtIndex")
    .setPosition(20, row);
  row += 40;
  cp5.addRadioButton("exportType")
    .setPosition(20, row)
    .setItemsPerRow(4)
    .setSpacingColumn(60)
    .addItem("Cover", 0)
    .addItem("Spreads", 1)
    .addItem("Inner Pages", 2)
    .addItem("All", 3);
   row += 40;
   myTextarea = cp5.addTextarea("myTxt")
     .setPosition(20, row)
     .setSize(width - 20 - 20, height - row - 40)
     .setLineHeight(14);
    myTextarea.setText("Welcome to the Zine Builder. From here you can select a "
                       +"folder containing a zine.xml file. You can make selections "
                       +"in the details tab and they will be saved to a settings.xml "
                       +"file and loaded automatically next time you open the same zine folder. "
                       +"When you are ready to generate a PDF for your zine select \"READY\" button");

  // Details tab
  row = 40;
  cp5.addTextfield("title")
    .moveTo("details")
    .setPosition(20, row);
  row += 40;
  paperWidthIn = cp5.addNumberbox("paperWidth")
    .moveTo("details")
    .setPosition(20, row)
    .setMultiplier(0.01);
  paperHeightIn = cp5.addNumberbox("paperHeight")
    .moveTo("details")
    .setPosition(100, row)
    .setMultiplier(0.01);
  cp5.addButton("rotatePaper")
    .moveTo("details")
    .setPosition(180, row);
  row += 40;
  cp5.addRadioButton("standardPapers")
    .moveTo("details")
    .setPosition(20, row)
    .setItemsPerRow(5)
    .setSpacingColumn(50)
    .addItem("A4", 3)
    .addItem("A3", 4)
    .addItem("A2", 5)
    .addItem("A1", 6)
    .addItem("A0", 7)
    .addItem("US std", 0)
    .addItem("US legal", 1)
    .addItem("US Tabloid", 2);
  row += 40;
  cp5.addNumberbox("totalCopies")
    .moveTo("details")
    .setPosition(20, row)
    .setValue(1);
  row += 40;
  cp5.addNumberbox("dpi")
    .moveTo("details")
    .setPosition(20, row)
    .setValue(300);
  row += 40;

  cp5.addNumberbox("margin")
    .moveTo("details")
    .setPosition(20, row);
  cp5.addNumberbox("topMargin")
    .moveTo("details")
    .setPosition(100, row);
  cp5.addNumberbox("bottomMargin")
    .moveTo("details")
    .setPosition(180, row);
  cp5.addNumberbox("centerLeftMargin")
    .moveTo("details")
    .setPosition(260, row);
  cp5.addNumberbox("centerRightMargin")
    .moveTo("details")
    .setPosition(340, row);
  row += 40;

  cp5.addNumberbox("widthFolds")
    .moveTo("details")
    .setPosition(20, row);
  cp5.addNumberbox("heightFolds")
    .moveTo("details")
    .setPosition(100, row);
//how many pages you plan to print on,
//so for a quarter size book each printer page represents 8 of the book pages
  cp5.addNumberbox("printerPages")
    .moveTo("details")
    .setPosition(180, row)
    .setValue(1);
  row += 40;

  cp5.addNumberbox("coverPages")
    .moveTo("details")
    .setPosition(20, row)
    .setValue(2);

  cp5.addButton("Ready")
    .setPosition(width - 20 - 70, height - 20 - 20);
  cp5.addButton("TestLayout")
    .setPosition(width - 20 - 70 - 10 - 70, height - 20 - 20);
}

private void setPaperSize(float w, float h){
    paperWidthIn.setValue(w);
    paperHeightIn.setValue(h);
}

public void standardPapers(int i){
  switch(i){
    case 0:
      setPaperSize(8.5, 11);
      break;
    case 1:
      setPaperSize(8.5, 14);
      break;
    case 2:
      setPaperSize(11, 17);
      break;
    case 3:
      setPaperSize(8.3, 11.7);
      break;
    case 4:
      setPaperSize(11.7, 16.5);
      break;
    case 5:
      setPaperSize(16.5, 23.4);
      break;
    case 6:
      setPaperSize(23.4, 33.1);
      break;
    case 7:
      setPaperSize(33.1, 46.8);
      break;
  }
}

public void rotatePaper(){
  setPaperSize(
    paperHeightIn.getValue(),
    paperWidthIn.getValue());
}

private void computeVars(){
  int widthFolds = getWidthFolds();
  int heightFolds = getHeightFolds();
  int printerPages = getPrinterPages();


  testLayout = false;
  float paperWidthIn = getPaperWidth(); //inches
  float paperHeightIn = getPaperHeight(); //inches
  int desiredDPI = getDPI(); //pixels per inch
  paperWidthPx = int(paperWidthIn * desiredDPI);
  paperHeightPx = int(paperHeightIn * desiredDPI);


  pageWidthPx = paperWidthPx / (int)Math.pow(2, widthFolds);
  pageHeightPx = paperHeightPx / (int)Math.pow(2, heightFolds);
  compWidthPx = pageWidthPx * 2;
  compHeightPx = pageHeightPx;
  numPages = (int)Math.pow(2, widthFolds) * (int)Math.pow(2, heightFolds) * 2 * printerPages;
  numSpreads = numPages/2;//front and back covers share the first spread


  spreads = new Spread[numSpreads];
  cover = new Spread[coverPages * 2];


  println ("Your zine will have "+numPages+" pages");

  zpl = getLayout(heightFolds, widthFolds, printerPages*2);
}

public void Choose(){
  selectFolder("Select a folder to process:", "folderSelected");
}

public void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    cp5.get(Textfield.class, "Directory").setText(selection.getAbsolutePath());
    ParseSettings();
  }
}

public void ParseSettings(){
  //load settings
  File directory = new File(getDirectory());
  File settingsFile = new File(directory, "settings.xml");
  if (settingsFile.exists()){
    XML settings = loadXML(settingsFile.getAbsolutePath());
    List<Numberbox> numbers = cp5.getAll(Numberbox.class);
    for(Numberbox number : numbers){
      number.setValue(settings.getChild(number.getName()).getFloatContent());
    }
    cp5.get(Textfield.class, "title").setValue(settings.getChild("title").getContent());
    //TODO: export type
  }
}

public void SaveSettings(){
  File directory = new File(getDirectory());
  File settingsFile = new File(directory, "settings.xml");
  XML settings = new XML("settings");
  List<Numberbox> numbers = cp5.getAll(Numberbox.class);
  for(Numberbox number : numbers){
    XML xmlNum = settings.addChild(number.getName());
    xmlNum.setContent(String.format("%.2f", number.getValue()));
  }
  settings.addChild("title").setContent(cp5.get(Textfield.class, "title").getText());
  //TODO: export type
  saveXML(settings, settingsFile.getAbsolutePath());
}

public void Ready(){
  String dir = getDirectory();
  if (dir == null || dir.equals("")){
    println("Please choose directory");
  } else {
    computeVars();
    SaveSettings();
    zineState.state = ConstructionState.Init;
  }
}

public void TestLayout(){
  computeVars();
  testLayout();
}

private String getDirectory(){
  return cp5.get(Textfield.class, "Directory").getText();
}

private void loadDir(){

}

private String getTitle(){
  return cp5.get(Textfield.class, "title").getText();
}

private int getGUIInt(String name){
  return (int)getGUIFloat(name);
}

private float getGUIFloat(String name){
  return cp5.get(Numberbox.class, name).getValue();
}

private int getWidthFolds(){
  return getGUIInt("widthFolds");
}

private int getHeightFolds(){
  return getGUIInt("heightFolds");
}

private int getPrinterPages(){
  return getGUIInt("printerPages");
}

private int getDPI(){
  return getGUIInt("dpi");
}

private int getMargin(){
  return getGUIInt("margin");
}

private float getPaperWidth(){
  return getGUIFloat("paperWidth");
}

private float getPaperHeight(){
  return getGUIFloat("paperHeight");
}

private int getStartAt(){
  return getGUIInt("startAtIndex");
}

private int getTotalCopies(){
  return getGUIInt("totalCopies");
}

private int getNumCopies(){
  int numCopies = getGUIInt("Copies");
  return max(numCopies, 1);
}

private OutputType getOutputType(){
  int index = (int)(cp5.get(RadioButton.class, "exportType").getValue());
  switch(index){
    case 0:
      return OutputType.Cover;
    case 1:
      return OutputType.Spreads;
    case 2:
      return OutputType.InnerPages;
    case 3:
      return OutputType.All;
    default:
      return OutputType.Cover;
  }
}

public void infoPage(PGraphics pdf) {
  // Create the cover page
  pdf.background(255);
  pdf.textFont(screenFont);
  //textAlign(CENTER, CENTER);
  pdf.fill(0);
  pdf.textSize(48);
  int reportHeight = 100;
  int reportSpace = 100;
  int reportX = 100;
  int column2 = reportX+1200;
  int column3 = column2 + 500;
  pdf.text(getTitle(), 100, reportHeight);
  text(getTitle(), width/2, 100);
  reportHeight += reportSpace;
  pdf.text("This book is "+getPaperWidth()+" in. wide x "+getPaperHeight()+" in. height", reportX, reportHeight, column2, pageHeightPx);
  text("This book is "+getPaperWidth()+" in. wide x "+getPaperHeight()+" in. height", width/2, 120);
  text("Please check the Sketch folder for the output PDF file", width/2, 140);
  reportHeight += reportSpace;
  pdf.text("Targeting a DPI of: " + getDPI(), reportX, reportHeight, column2, pageHeightPx);
  reportHeight += reportSpace;
  pdf.text("It should be folded "+getWidthFolds()+" time on the width and "+getHeightFolds()+" on the height.", reportX, reportHeight, column2, pageHeightPx);
  reportHeight += reportSpace;
  pdf.text("In order to bind the "+numPages+" pages using "+getPrinterPages()+" printer pages.", reportX, reportHeight, column2, pageHeightPx);

  pdf.noFill();


  float tXPos = 0;
  float tYPos = 50;
  // print covers
  for (int p=0; p<cover.length; p++) {
    tXPos = column3;

    pdf.image(cover[p].getPage(),
      tXPos, tYPos,
      cover[p].getWidth()/10, cover[p].getHeight()/10);
    pdf.rect(tXPos, tYPos, cover[p].getWidth()/10, cover[p].getHeight()/10);
    tYPos += 300;
  }

  tXPos = 0;
  tYPos = 50;

  for (int k=0; k<numSpreads; k++) { // this repeats for each spread

    tXPos = column2;

    pdf.image(spreads[k].getPage(),
      tXPos, tYPos,
      spreads[k].getWidth()/10, spreads[k].getHeight()/10);
    pdf.rect(tXPos, tYPos, spreads[k].getWidth()/10, spreads[k].getHeight()/10);
    tYPos += 300;
  }
}

ConstructionState nextState(ConstructionState currState, OutputType outputType){
  switch(currState){
    case Gather:
      return ConstructionState.Init;
    case Init:
      switch(outputType){
        case All:
        case Spreads:
        case InnerPages:
          return ConstructionState.GenSpreads;
        case Cover:
          return ConstructionState.CreateCover;
      }
    case GenSpreads:
      switch(outputType){
        case All:
        case Cover:
        case Spreads:
          return ConstructionState.CreateCover;
        case InnerPages:
          return ConstructionState.LayoutPaper;
      }
    case CreateCover:
      switch(outputType){
        case All:
          return ConstructionState.CreateInfo;
        case Cover:
        case Spreads:
          return ConstructionState.RenderCover;
        case InnerPages:
          return ConstructionState.LayoutPaper;
      }
    case CreateInfo:
      switch(outputType){
        case All:
        case Cover:
        case Spreads:
          return ConstructionState.RenderCover;
        case InnerPages:
          return ConstructionState.LayoutPaper;
      }
    case RenderCover:
      switch(outputType){
        case All:
        case InnerPages:
          return ConstructionState.LayoutPaper;
        case Spreads:
          return ConstructionState.RenderSpreads;
        case Cover:
          return ConstructionState.Done;
      }
    case RenderSpreads:
      return ConstructionState.Done;
    case LayoutPaper:
      return ConstructionState.Done;
    case Done:
      return ConstructionState.Gather;
  }
  return ConstructionState.Gather;
}

void nextPage(ZineState zineState, int totalCopies, int numContiguousCopies, OutputType outType){
  //if ((zineState.copyNum >= totalCopies) || zineState.copyNum % numContiguousCopies == 0){
  //  if ((outType == OutputType.All || outType == OutputType.InnerPages) &&
  //      zineState.state == ConstructionState.LayoutPaper &&
  //      zineState.progress >= zineState.limit - 1){
  //    //no newline
  //    return;
  //  }
  //  if (outType == OutputType.Cover && zineState.state == ConstructionState.RenderCover &&
  //      zineState.progress >= zineState.limit - 1){
  //    //no newline
  //    return;
  //  }
  //}
  ((PGraphicsPDF)zineState.pdf).nextPage();
}

void update(){
  if (zineState.state == ConstructionState.Gather){
  }
}

void draw() {
  background(0);
  ConstructionState entryState = zineState.state;
  if (zineState.pdf != null){
    zineState.pdf.beginDraw();
  }
  switch(zineState.state){
    case Gather:
      break;
    case Init:
      vars.put("num", str(zineState.copyNum));
      if (zineState.pdf == null){
        //assemble copy number as 4-digits with leading zeros
        String sn;
        sn = "000" + zineState.copyNum;
        sn = sn.substring(sn.length() - 4);
        
        File directory = new File(getDirectory());
        String filename = getTitle()+"_"+getOutputType().toString()+"_"+sn+".pdf";
        File outputFile = new File(directory, filename);
        if (getOutputType() == OutputType.Spreads){
          zineState.pdf = createGraphics(pageWidthPx * 2, pageHeightPx, PDF, outputFile.getAbsolutePath());
        } else {
          zineState.pdf = createGraphics(paperWidthPx, paperHeightPx, PDF, outputFile.getAbsolutePath());
        }
        zineState.pdf.beginDraw();
      }
      zineState.state = nextState(zineState.state, getOutputType());
      break;
    case GenSpreads:
      int k = zineState.progress;
      spreads[k] = new Spread(k+1, pageWidthPx * 2, pageHeightPx, false);
      spreads[k].setMargins(70,100,100,100,100,100);
      //spreads[k].setMargins(200,200,200,200,100,100);
      int currHeadingSize = spreads[k].getMaxHeadingSize();
      if (zineState.minHeadingSize == -1){
        zineState.minHeadingSize = currHeadingSize;
      } else if (zineState.minHeadingSize > currHeadingSize){
        zineState.minHeadingSize = currHeadingSize;
      }
      zineState.maxFooterHeight = Math.max(zineState.maxFooterHeight, spreads[k].getMaxFooterHeight());
      zineState.progress++;
      if (zineState.progress >= zineState.limit){
        for(int i = 0; i < numSpreads; i++){
          spreads[i].setHeadingSize(zineState.minHeadingSize);
          spreads[i].setFooterHeight(zineState.maxFooterHeight);
        }
        zineState.state = nextState(zineState.state, getOutputType());
      }
      break;
    case CreateCover:
      int q = zineState.progress * 2;
      vars.put("num", str(zineState.copyNum * 2 - 1));
      cover[q] = new Spread(q/2+1, pageWidthPx * 2, pageHeightPx, true);
      vars.put("num", str(zineState.copyNum * 2));
      cover[q+1] = new Spread(q/2+1, pageWidthPx * 2, pageHeightPx, true);
      vars.put("num", str(zineState.copyNum));
      cover[q].setFooterHeight(cover[q].getMaxFooterHeight());
      cover[q+1].setFooterHeight(cover[q+1].getMaxFooterHeight());
      zineState.progress++;
      if (zineState.progress >= zineState.limit){
        zineState.state = nextState(zineState.state, getOutputType());
      }
      break;
    case CreateInfo:
      infoPage(zineState.pdf); //start with an info page with spread thumbnails
      nextPage(zineState, getTotalCopies(), getNumCopies(), getOutputType());
      zineState.state = nextState(zineState.state, getOutputType());
      break;
    case RenderCover:
      int p = zineState.progress * 2;
      vars.put("num", str(zineState.copyNum * 2 - 1));
      zineState.pdf.image(cover[p].getPage(), 0, 0);
      vars.put("num", str(zineState.copyNum * 2));
      zineState.pdf.image(cover[p+1].getPage(), 0, paperHeightPx/2);
      vars.put("num", str(zineState.copyNum));
      nextPage(zineState, getTotalCopies(), getNumCopies(), getOutputType());
      zineState.progress++;
      if (zineState.progress >= zineState.limit){
        zineState.state = nextState(zineState.state, getOutputType());
      }
      break;
    case RenderSpreads:
      int spreadNum = zineState.progress;
      Spread currSpread = spreads[spreadNum];
      zineState.pdf.image(currSpread.getPage(), 0, 0);
      ((PGraphicsPDF)zineState.pdf).nextPage();
      zineState.progress++;
      if (zineState.progress >= zineState.limit){
        zineState.state = nextState(zineState.state, getOutputType());
      }
      break;
    case LayoutPaper:
      int cellsPerRow = zpl[0][0].length;
      int rowsPerPage = zpl[0].length;
      int pagesPerZine = zpl.length;
      int totalCells = pagesPerZine * rowsPerPage * cellsPerRow;
      int cell = zineState.progress % cellsPerRow;
      int row = (zineState.progress / cellsPerRow) % rowsPerPage;
      int page = (zineState.progress / cellsPerRow / rowsPerPage) % pagesPerZine;
      PGraphics paperg = zineState.paperg;
      zineState.pdf.endDraw();
      if (cell == 0 && row == 0){
        zineState.paperg = createGraphics(paperWidthPx, paperHeightPx);
        paperg = zineState.paperg;
      }
      paperg.beginDraw();
      ZinePageLayout cpg = zpl[page][row][cell];
      int spreadI = ((cpg.getNumber() / 2) % numSpreads);
      boolean leftPage = cpg.getNumber()%2 == 0;
      Spread comp = spreads[spreadI];
      if (cpg.getHFlip()){
        paperg.copy(comp.getPage().copy(),
          leftPage ? pageWidthPx : (pageWidthPx*2), pageHeightPx, -pageWidthPx, -pageHeightPx,
          pageWidthPx * cell, pageHeightPx * row, pageWidthPx, pageHeightPx);
      } else {
        paperg.copy(comp.getPage().copy(),
          leftPage ? 0 : pageWidthPx, 0, pageWidthPx, pageHeightPx,
          pageWidthPx * cell, pageHeightPx * row, pageWidthPx, pageHeightPx);
      }
      paperg.endDraw();
      zineState.pdf.beginDraw();
      if (cell == cellsPerRow - 1 && row == rowsPerPage - 1){
        //filled page
        zineState.pdf.image(paperg, 0, 0);
        nextPage(zineState, getTotalCopies(), getNumCopies(), getOutputType());
      }
      zineState.progress++;
      if (zineState.progress >= zineState.limit){
        zineState.state = nextState(zineState.state, getOutputType());// ConstructionState.Done;
      }
      break;
    case Done:
      boolean dispose;
      if (zineState.copyNum >= getTotalCopies()){
        noLoop();
        pushStyle();
        textAlign(CENTER, CENTER);
        textSize(100);
        text("FIN", width/2, height/2);
        popStyle();
        dispose = true;
      } else {
        zineState.copyNum++;
        zineState.state = nextState(zineState.state, getOutputType());// ConstructionState.Init;
        dispose = zineState.copyNum%getNumCopies() == 0;
      }
      if (dispose && zineState.pdf != null){
        zineState.pdf.dispose();
        zineState.pdf = null;
      }
      break;
  }
  if (zineState.pdf != null){
    zineState.pdf.endDraw();
  }
  if (entryState != zineState.state){
    switch(zineState.state){
      case Init:
        break;
      case GenSpreads:
        zineState.progress = 0;
        zineState.limit = numSpreads;
        zineState.minHeadingSize = -1;
        zineState.maxFooterHeight = 0;
        break;
      case CreateInfo:
        zineState.progress = 0;
        zineState.limit = 1;
        break;
      case CreateCover:
      case RenderCover:
        zineState.progress = 0;
        zineState.limit = coverPages;
        break;
      case RenderSpreads:
        zineState.progress = 0;
        zineState.limit = numSpreads;
        break;
      case LayoutPaper:
        zineState.progress = 0;
        int cellsPerRow = zpl[0][0].length;
        int rowsPerPage = zpl[0].length;
        int pagesPerZine = zpl.length;
        int totalCells = pagesPerZine * rowsPerPage * cellsPerRow;
        zineState.limit = totalCells;
        break;
      case Done:
        break;
    }
  }
  if (zineState.state != ConstructionState.Gather){
    zineState.draw();
  }
}

ZineState zineState;
class ZineState{
  int copyNum = getStartAt() - 1;
  PGraphics pdf;
  PGraphics paperg;
  int progress = 0;
  int limit;
  ConstructionState state = ConstructionState.Done;
  int minHeadingSize = -1;
  int maxFooterHeight = 0;

  public void draw(){
    pushMatrix();
    translate(20, 280);
    text("zine " + copyNum + " of " + getTotalCopies(), 0, 0);
    noFill();
    stroke(255);
    translate(0, 5);
    scale(3, 1);
    rect(0, 0, 100, 10);
    fill(255);
    rect(0, 0, 100*((float)copyNum/getTotalCopies()), 10);

    scale(1/3.0, 1);
    translate(0, 20);
    text("state: " + state.name(), 0, 0);

    translate(0, 15);
    text("progress: " + progress + " of " + limit, 0, 0);
    noFill();
    stroke(255);
    translate(0, 5);
    scale(3, 1);
    rect(0, 0, 100, 10);
    fill(255);
    rect(0, 0, 100*((float)progress/limit), 10);
    popMatrix();
  }
}

public enum ConstructionState{
  Gather,
  Init,
  GenSpreads,
  CreateCover,
  CreateInfo,
  RenderCover,
  RenderSpreads,
  LayoutPaper,
  Done
}

public enum OutputType{
  Cover,
  Spreads,
  InnerPages,
  All
}