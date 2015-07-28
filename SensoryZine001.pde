//for PDF //<>//
import processing.pdf.*;
//for Map
import java.util.*;

PFont screenFont;
boolean testLayout = false;
boolean debug = false;
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
int totalCopies = 1;

int topMargin = 200;
int bottomMargin = 300;
int centerLeft = 50;
int centerRight = 50;
String bookTitle = "Sensory Aesthetics";
Spread[] spreads = new Spread[numSpreads];
Spread[] cover = new Spread[coverPages];
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
  println("creating info page");
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

void draw() {
  background(0);
  ConstructionState entryState = zineState.state;
  if (zineState.pdf != null){
    zineState.pdf.beginDraw();
  }
  PGraphicsPDF pdfg = (PGraphicsPDF) zineState.pdf; // Get the renderer
  switch(zineState.state){
    case Init:
      vars.put("num", str(zineState.copyNum));
      String sn = "000" + zineState.copyNum;
      sn = sn.substring(sn.length() - 4);
      zineState.pdf = createGraphics(paperWidthPx, paperHeightPx, PDF, "sensory_"+sn+".pdf");
      zineState.pdf.beginDraw();
      zineState.state = ConstructionState.GenSpreads;
      break;
    case GenSpreads:
      int k = zineState.progress;
      println("assembling spread " + k);
      spreads[k-1] = new Spread(k, pageWidthPx * 2, pageHeightPx, false); 
      spreads[k-1].setMargins(100,100,100,100,50,50);
      //spreads[k-1].setMargins(200,200,200,200,100,100);
      int currHeadingSize = spreads[k-1].getMaxHeadingSize();
      if (zineState.minHeadingSize == -1){
        zineState.minHeadingSize = currHeadingSize;
      } else if (zineState.minHeadingSize > currHeadingSize){
        zineState.minHeadingSize = currHeadingSize;
      }
      zineState.maxFooterHeight = Math.max(zineState.maxFooterHeight, spreads[k-1].getMaxFooterHeight());
      zineState.progress++;
      if (zineState.progress > zineState.limit){
        for(int i = 0; i < numSpreads; i++){
          spreads[i].setHeadingSize(zineState.minHeadingSize);
          spreads[i].setFooterHeight(zineState.maxFooterHeight);
        }
        zineState.state = ConstructionState.CreateCover;
      }
      break;
    case CreateCover:
      int q = zineState.progress;
      println("beginning cover " + q);
      cover[q-1] = new Spread(q, pageWidthPx * 2, pageHeightPx, true);
      zineState.progress++;
      if (zineState.progress > zineState.limit){
        zineState.state = ConstructionState.CreateInfo;
      }
      break;
    case CreateInfo:
      infoPage(zineState.pdf); //start with an info page with spread thumbnails
      zineState.state = ConstructionState.RenderCover;
    case RenderCover:
      int p = zineState.progress;
      pdfg.nextPage();
      zineState.pdf.image(cover[p-1].getPage(), 0, 0);
      zineState.pdf.image(cover[p-1].getPage(), 0, paperHeightPx/2);
      zineState.progress++;
      if (zineState.progress > zineState.limit){
        zineState.state = ConstructionState.LayoutPaper;
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
      if (cell == 0 && row == 0){
        //new page
        pdfg.nextPage();  // Tell it to go to the next page
        pdfg.endDraw();
        zineState.paperg = createGraphics(paperWidthPx, paperHeightPx);
        paperg = zineState.paperg;
      }
      paperg.beginDraw();
      println("placing cell " + (zineState.progress));
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
      }
      zineState.progress++;
      if (zineState.progress >= zineState.limit){
        zineState.state = ConstructionState.Done;
      }
      break;
    case Done:
      if (zineState.copyNum >= totalCopies){
        noLoop();
        pushStyle();
        textAlign(CENTER, CENTER);
        textSize(100);
        text("FIN", width/2, height/2);
        popStyle();
      } else {
        zineState.copyNum++;
        zineState.state = ConstructionState.Init;
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
        zineState.progress = 1;
        zineState.limit = numSpreads;
        zineState.minHeadingSize = -1;
        zineState.maxFooterHeight = 0;
        break;
      case CreateInfo:
        zineState.progress = 1;
        zineState.limit = 1;
        break;
      case CreateCover:
      case RenderCover:
        zineState.progress = 1;
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
        zineState.pdf.dispose();
        zineState.pdf = null;
        break;
    }
  }
  zineState.draw();
  //for(int m = 1; m <= totalCopies; m++){
    ////####### NOW LIVES IN Init STATE ######
    //vars.put("num", str(m));
    //String sm = "0000"+m;
    //sm = sm.substring(sm.length()-5);
    //pdf = createGraphics(paperWidthPx, paperHeightPx, PDF, "sensory_"+sm+".pdf");
    //pdf.beginDraw();
    //PGraphicsPDF pdfg = (PGraphicsPDF) pdf; // Get the renderer
  
    ////####### NOW LIVES IN GenSpreads STATE ######
    //int minHeadingSize = -1;
    //int currHeadingSize;
    //int maxFooterHeight = 0;
    // Create a set of Compositions
    //for (int k=1; k <= numSpreads; k++) {
    //  println("assembling spread " + k);
    //  spreads[k-1] = new Spread(k, pageWidthPx * 2, pageHeightPx, false); 
    //  spreads[k-1].setMargins(100,100,100,100,50,50);
    //  //spreads[k-1].setMargins(200,200,200,200,100,100);
    //  currHeadingSize = spreads[k-1].getMaxHeadingSize();
    //  if (minHeadingSize == -1){
    //    minHeadingSize = currHeadingSize;
    //  } else if (minHeadingSize > currHeadingSize){
    //    minHeadingSize = currHeadingSize;
    //  }
    //  maxFooterHeight = Math.max(maxFooterHeight, spreads[k-1].getMaxFooterHeight());
    //}
    //for(int i = 0; i < numSpreads; i++){
    //  spreads[i].setHeadingSize(minHeadingSize);
    //  spreads[i].setFooterHeight(maxFooterHeight);
    //}
    
    ////####### NOW LIVES IN CreateCover STATE ######
    //println("Creating cover");
    
    //for (int q=1; q <= coverPages; q++) {
    //  println("beginning cover " + q);
    //  cover[q-1] = new Spread(q, pageWidthPx * 2, pageHeightPx, true);
    //}
  
    //println("---------------------");
    
    
    //infoPage(); //start with an info page with spread thumbnails
    
    //pdfg.nextPage(); 
    //// layout cover
  
    //pdf.image(cover[0].getPage(), 0, 0);
    //pdf.image(cover[0].getPage(), 0, paperHeightPx/2);
  
    //pdfg.nextPage(); 
    //// layout inside cover 
    //pdf.image(cover[1].getPage(), 0, 0);
    //pdf.image(cover[1].getPage(), 0, paperHeightPx/2);
    
    ////####### NOW LIVES IN LayoutPaper STATE ######
    //int progress = 0;
    //for(int page = 0; page < zpl.length; page++){
    //  pdfg.nextPage();  // Tell it to go to the next page
    //  pdfg.endDraw();
    //  PGraphics paperg = createGraphics(paperWidthPx, paperHeightPx);
    //  paperg.beginDraw();
    //  for(int row = 0; row < zpl[0].length; row++){
    //    for(int cell = 0; cell < zpl[0][0].length; cell++){
    //      println("placing cell " + (++progress));
    //      ZinePageLayout cpg = zpl[page][row][cell];
    //      int spreadI = ((cpg.getNumber() / 2) % numSpreads);
    //      boolean leftPage = cpg.getNumber()%2 == 0;
    //      Spread comp = spreads[spreadI];
    //      if (cpg.getHFlip()){
    //        paperg.copy(comp.getPage(),
    //          leftPage ? pageWidthPx : (pageWidthPx*2), pageHeightPx, -pageWidthPx, -pageHeightPx,
    //          pageWidthPx * cell, pageHeightPx * row, pageWidthPx, pageHeightPx);
    //      } else {
    //        paperg.copy(comp.getPage(), 
    //          leftPage ? 0 : pageWidthPx, 0, pageWidthPx, pageHeightPx, 
    //          pageWidthPx * cell, pageHeightPx * row, pageWidthPx, pageHeightPx);
    //      }
    //    }
    //  }
    //  paperg.endDraw();
    //  pdf.beginDraw();
    //  pdf.image(paperg, 0, 0);
    //}
    
    /////////////// nowhere?? //////
    //textFont(screenFont);
    //textAlign(CENTER, CENTER);
    
    //pdf.dispose();
    //pdf.endDraw();
    
    //println("PDF output");
  //}
}

ZineState zineState;
class ZineState{
  int copyNum = 0;
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