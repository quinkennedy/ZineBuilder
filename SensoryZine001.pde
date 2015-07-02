import controlP5.*; //<>// //<>// //<>//
import processing.pdf.*;
PGraphics pdf;
PFont myFont;
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

int topMargin = 200;
int bottomMargin = 300;
int centerLeft = 50;
int centerRight = 50;
String bookTitle = "Sensory Aesthetics";
Spread[] spreads = new Spread[numSpreads];

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
  noLoop();
  if (testLayout){
    testLayout();
    return;
  }
  pdf = createGraphics(paperWidthPx, paperHeightPx, PDF, "sensory.pdf");
  
  println ("Your zine will have "+numPages+" pages");
  //// CHECK WHAT FONTS ARE ON THE SYSTEM
  //String[] fontList = PFont.list();
  //println(fontList);
  
  pdf.beginDraw();
  PGraphicsPDF pdfg = (PGraphicsPDF) pdf; // Get the renderer

  // Create a set of Compositions
  for (int k=1; k <= numSpreads; k++) {
    println("assembling spread " + k);
    spreads[k-1] = new Spread(k, pageWidthPx * 2, pageHeightPx); 
  }
  println("---------------------");
  
  
  coverPage();
  println("calculating layout");
  ZinePageLayout[][][] zpl = getLayout(heightFolds, widthFolds, printerPages*2);
  int progress = 0;
  for(int page = 0; page < zpl.length; page++){
    pdfg.nextPage();  // Tell it to go to the next page
    pdfg.endDraw();
    PGraphics paperg = createGraphics(paperWidthPx, paperHeightPx);
    paperg.beginDraw();
    for(int row = 0; row < zpl[0].length; row++){
      for(int cell = 0; cell < zpl[0][0].length; cell++){
        println("placing cell " + (++progress));
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
      }
    }
    paperg.endDraw();
    pdf.beginDraw();
    pdf.image(paperg, 0, 0);
  }
  
  myFont = createFont("DINPro-Black", 48);
  textFont(myFont);
  textAlign(CENTER, CENTER);
  
  pdf.dispose();
  pdf.endDraw();
  
  println("PDF output");

}

void coverPage() {
  // Create the cover page
  println("creating cover page");
  pdf.background(255);
  myFont = createFont("DINPro-Black", 48);
  pdf.textFont(myFont);
  textAlign(CENTER, CENTER);
  pdf.fill(0);
  pdf.textSize(48);
  int reportHeight = 100;
  int reportSpace = 100;
  int reportX = 100;
  int column2 = reportX+1500;
  pdf.text(bookTitle, 100, reportHeight);
  reportHeight += reportSpace;
  pdf.text("This book is "+paperWidthIn+" in. wide x "+paperHeightIn+" in. height", reportX, reportHeight);
  reportHeight += reportSpace;
  pdf.text("Targeting a DPI of: " + desiredDPI, reportX, reportHeight);
  reportHeight += reportSpace;
  pdf.text("It should be folded "+widthFolds+" time on the width and "+heightFolds+" on the height.", reportX, reportHeight);
  reportHeight += reportSpace;
  pdf.text("In order to bind the "+numPages+" pages using "+printerPages+" printer pages.", reportX, reportHeight);
  
  pdf.noFill();
  
  float tXPos = 0;
  float tYPos = 50;
  for (int k=0; k<numSpreads; k++) { // this repeats for each spread
    
    tXPos = column2;
    
    pdf.image(spreads[k].getPage(), 
              tXPos, tYPos, 
              spreads[k].getWidth()/10, spreads[k].getHeight()/10);
    pdf.rect(tXPos, tYPos, spreads[k].getWidth()/10, spreads[k].getHeight()/10);
    tYPos += 300;
    
  }
  
}

void draw() {}