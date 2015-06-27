import processing.pdf.*;
PFont myFont;
float margin = 50;
float paperWidth = 8.5; //inches
float paperHeight = 11; //inches
int desiredDPI = 300; //pixels per inch
int compWidth = int(paperWidth * desiredDPI);
int compHeight = int(paperHeight * desiredDPI);
// how many folds you want to create for your zine
int widthFolds = 1;
int heightFolds = 1;

//how many pages you plan to print on, 
//so for a quarter size book each printer page represents 8 of the book pages
int printerPages = 2; 
int topMargin = 200;
int bottomMargin = 300;
int centerLeft = 50;
int centerRight = 50;
String bookTitle = "Sensory Aesthetics";

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
*/


void setup() {
  size(400, 400);
  noLoop();
  PGraphics pdf = createGraphics(compWidth, compHeight, PDF, "sensory.pdf");
  
  int numPages = ((widthFolds * 2) * (heightFolds * 2) * 2) * printerPages;
  println ("Your zine will have "+numPages+" pages");
  //// CHECK WHAT FONTS ARE ON THE SYSTEM
  //String[] fontList = PFont.list();
  //println(fontList);
  
  myFont = createFont("DINPro-Black", 48); //<>//
  textFont(myFont);
  textAlign(CENTER, CENTER);
  
  pdf.beginDraw();
  pdf.background(255);

  pdf.rect(margin, margin, pdf.width/2-(margin*2), pdf.height/2-(margin*2)); // top left rect
  pdf.rect(pdf.width/2+margin, margin, pdf.width/2-(margin*2), pdf.height/2-(margin*2)); // top right rect
  pdf.rect(margin, pdf.height/2+margin, pdf.width/2-(margin*2), pdf.height/2-(margin*2)); // bottom left rect
  pdf.rect(pdf.width/2+margin, pdf.height/2+margin, pdf.width/2-(margin*2), pdf.height/2-(margin*2)); // top right rect
    
  pdf.line(pdf.width/2, 0, pdf.width/2, pdf.height);
  pdf.line(0, pdf.height/2, pdf.width, pdf.height/2);
  
  pdf.fill(0);
  pdf.text("One", margin*2, margin*2);

  pdf.text("Sensory Aesthetics", pdf.width/2, pdf.height/2);
  println("PDF output");
  
  // creating a second page
  PGraphicsPDF pdfg = (PGraphicsPDF) pdf;  // Get the renderer
  pdfg.nextPage();  // Tell it to go to the next page
  pdf.line(pdf.width/2, 0, pdf.width/2, pdf.height);
  pdf.line(0, pdf.height/2, pdf.width, pdf.height/2);
  
  pdf.dispose();
  pdf.endDraw();
  
}

void draw() {
  


  
}