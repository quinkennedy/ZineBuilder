//for PDF //<>// //<>//
import processing.pdf.*;
//for Map
import java.util.*;

//Edit these for various PDF outputs for production
int totalCopies = 1;
int contiguousCopies = 201;
//boolean separateCopies = false;
OutputType output = OutputType.InnerPages;
boolean debug = false;
final static int START_AT = 1;

PFont screenFont;
boolean testLayout = false;
float margin = 50;
float paperWidthIn = 8.5; //inches
float paperHeightIn = 11; //inches
int desiredDPI = 300; //pixels per inch
int paperWidthPx = int(paperWidthIn * desiredDPI);
int paperHeightPx = int(paperHeightIn * desiredDPI);
// how many folds you want to create for your zine
int widthFolds = 1;
int heightFolds = 1;
int pageWidthPx = paperWidthPx / (int)Math.pow(2, widthFolds);
int pageHeightPx = paperHeightPx / (int)Math.pow(2, heightFolds);
int compWidthPx = pageWidthPx * 2;
int compHeightPx = pageHeightPx;
//how many pages you plan to print on, 
//so for a quarter size book each printer page represents 8 of the book pages
int printerPages = 2; // double sided
int numPages = (int)Math.pow(2, widthFolds) * (int)Math.pow(2, heightFolds) * 2 * printerPages;
int numSpreads = numPages/2;//front and back covers share the first spread
int coverPages = 2;
int topMargin = 200;
int bottomMargin = 300;
int centerLeft = 50;
int centerRight = 50;
String bookTitle = "Sensory Aesthetics";
Spread[] spreads = new Spread[numSpreads];
Spread[] cover = new Spread[coverPages * 2];
Map<String, String> vars = new HashMap<String, String>();
ZinePageLayout[][][] zpl;


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
  size(400, 400);
  if (testLayout){
    testLayout();
    return;
  }
  
  println ("Your zine will have "+numPages+" pages");
  //// CHECK WHAT FONTS ARE ON THE SYSTEM
  //String[] fontList = PFont.list();
  //println(fontList);
  screenFont = createFont("SourceSansPro-Bold", 48);

  zineState = new ZineState();
  zpl = getLayout(heightFolds, widthFolds, printerPages*2);
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
  pdf.text(bookTitle, 100, reportHeight);
  text(bookTitle, width/2, 100);
  reportHeight += reportSpace;
  pdf.text("This book is "+paperWidthIn+" in. wide x "+paperHeightIn+" in. height", reportX, reportHeight, column2, pageHeightPx);
  text("This book is "+paperWidthIn+" in. wide x "+paperHeightIn+" in. height", width/2, 120);
  text("Please check the Sketch folder for the output PDF file", width/2, 140);
  reportHeight += reportSpace;
  pdf.text("Targeting a DPI of: " + desiredDPI, reportX, reportHeight, column2, pageHeightPx);
  reportHeight += reportSpace;
  pdf.text("It should be folded "+widthFolds+" time on the width and "+heightFolds+" on the height.", reportX, reportHeight, column2, pageHeightPx);
  reportHeight += reportSpace;
  pdf.text("In order to bind the "+numPages+" pages using "+printerPages+" printer pages.", reportX, reportHeight, column2, pageHeightPx);

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
        case Spreads:
        case InnerPages:
          return ConstructionState.LayoutPaper;
        case Cover:
          return ConstructionState.Done;
      }
    case LayoutPaper:
      return ConstructionState.Done;
    case Done:
      return ConstructionState.Init;
  }
  return ConstructionState.Init;
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

void draw() {
  background(0);
  ConstructionState entryState = zineState.state;
  if (zineState.pdf != null){
    zineState.pdf.beginDraw();
  }
  switch(zineState.state){
    case Init:
      vars.put("num", str(zineState.copyNum));
      if (zineState.pdf == null){
        String sn;
        sn = "000" + zineState.copyNum;
        sn = sn.substring(sn.length() - 4);
        zineState.pdf = createGraphics(paperWidthPx, paperHeightPx, PDF, "sensory_"+output.toString()+"_"+sn+".pdf");
        zineState.pdf.beginDraw();
      }
      zineState.state = nextState(zineState.state, output);
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
        zineState.state = nextState(zineState.state, output);
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
        zineState.state = nextState(zineState.state, output);
      }
      break;
    case CreateInfo:
      infoPage(zineState.pdf); //start with an info page with spread thumbnails
      nextPage(zineState, totalCopies, contiguousCopies, output);
      zineState.state = nextState(zineState.state, output);
      break;
    case RenderCover:
      int p = zineState.progress * 2;
      vars.put("num", str(zineState.copyNum * 2 - 1));
      zineState.pdf.image(cover[p].getPage(), 0, 0);
      vars.put("num", str(zineState.copyNum * 2));
      zineState.pdf.image(cover[p+1].getPage(), 0, paperHeightPx/2);
      vars.put("num", str(zineState.copyNum));
      nextPage(zineState, totalCopies, contiguousCopies, output);
      zineState.progress++;
      if (zineState.progress >= zineState.limit){
        zineState.state = nextState(zineState.state, output);
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
        paperg.copy(comp.getPage(),
          leftPage ? pageWidthPx : (pageWidthPx*2), pageHeightPx, -pageWidthPx, -pageHeightPx,
          pageWidthPx * cell, pageHeightPx * row, pageWidthPx, pageHeightPx);
      } else {
        paperg.copy(comp.getPage(), 
          leftPage ? 0 : pageWidthPx, 0, pageWidthPx, pageHeightPx, 
          pageWidthPx * cell, pageHeightPx * row, pageWidthPx, pageHeightPx);
      }
      paperg.endDraw();
      zineState.pdf.beginDraw();
      if (cell == cellsPerRow - 1 && row == rowsPerPage - 1){
        //filled page
        zineState.pdf.image(paperg, 0, 0);
        nextPage(zineState, totalCopies, contiguousCopies, output);
      }
      zineState.progress++;
      if (zineState.progress >= zineState.limit){
        zineState.state = nextState(zineState.state, output);// ConstructionState.Done;
      }
      break;
    case Done:
      boolean dispose;
      if (zineState.copyNum >= totalCopies){
        noLoop();
        pushStyle();
        textAlign(CENTER, CENTER);
        textSize(100);
        text("FIN", width/2, height/2);
        popStyle();
        dispose = true;
      } else {
        zineState.copyNum++;
        zineState.state = nextState(zineState.state, output);// ConstructionState.Init;
        dispose = zineState.copyNum%contiguousCopies == 0;
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
  zineState.draw();
}

ZineState zineState;
class ZineState{
  int copyNum = START_AT - 1;
  PGraphics pdf;
  PGraphics paperg;
  int progress = 0;
  int limit;
  ConstructionState state = ConstructionState.Done;
  int minHeadingSize = -1;
  int maxFooterHeight = 0;
  
  public void draw(){
    pushMatrix();
    translate(20, 20);
    text("zine " + copyNum + " of " + totalCopies, 0, 0);
    noFill();
    stroke(255);
    translate(0, 5);
    scale(3, 1);
    rect(0, 0, 100, 10);
    fill(255);
    rect(0, 0, 100*((float)copyNum/totalCopies), 10);
    
    scale(1/3.0, 1);
    translate(0, 35);
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
  Init,
  GenSpreads,
  CreateCover,
  CreateInfo,
  RenderCover,
  LayoutPaper,
  Done
}

public enum OutputType{
  Cover,
  Spreads,
  InnerPages,
  All
}