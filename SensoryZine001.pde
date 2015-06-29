import controlP5.*; //<>//
import processing.pdf.*;
PGraphics pdf;
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
int printerPages = 2; // double sided
int numPages = ((widthFolds * 2) * (heightFolds * 2) * 2) * printerPages;
int pageWidth = compWidth/2;
int pageHeight = compHeight/2;

int topMargin = 200;
int bottomMargin = 300;
int centerLeft = 50;
int centerRight = 50;
String bookTitle = "Sensory Aesthetics";
Composition[] pages = new Composition[numPages];

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

We should make textbox class - the one in controlP5 has rendering problems
*/


void setup() {
  size(400, 400);
  noLoop();
  pdf = createGraphics(compWidth, compHeight, PDF, "sensory.pdf");
  
  println ("Your zine will have "+numPages+" pages");
  //// CHECK WHAT FONTS ARE ON THE SYSTEM
  //String[] fontList = PFont.list();
  //println(fontList);
  
  pdf.beginDraw();
  PGraphicsPDF pdfg = (PGraphicsPDF) pdf; // Get the renderer

  // Create a set of Compositions
  for (int k=1; k<=numPages; k++) {
    pages[k-1] = new Composition(k, pageWidth, pageHeight); 
  }
  println("---------------------");
  
  
  coverPage();

  for (int j=1; j<=printerPages*2; j++) {
       
     pdfg.nextPage();  // Tell it to go to the next page
     println("Printer Page: "+j);
  }

  

  //PGraphicsPDF pdfg = (PGraphicsPDF) pdf;  // Get the renderer
  //pdfg.nextPage();  // Tell it to go to the next page
  
  myFont = createFont("DINPro-Black", 48);
  textFont(myFont);
  textAlign(CENTER, CENTER);
  


  pdf.rect(margin, margin, pdf.width/2-(margin*2), pdf.height/2-(margin*2)); // top left rect
  pdf.rect(pdf.width/2+margin, margin, pdf.width/2-(margin*2), pdf.height/2-(margin*2)); // top right rect
  pdf.rect(margin, pdf.height/2+margin, pdf.width/2-(margin*2), pdf.height/2-(margin*2)); // bottom left rect
  pdf.rect(pdf.width/2+margin, pdf.height/2+margin, pdf.width/2-(margin*2), pdf.height/2-(margin*2)); // top right rect
    
  pdf.line(pdf.width/2, 0, pdf.width/2, pdf.height);
  pdf.line(0, pdf.height/2, pdf.width, pdf.height/2);
  
  pdf.fill(0);
  pdf.text("One", margin*2, margin*2);

  
  // creating a second page
  //pdfg.nextPage();  // Tell it to go to the next page
  pdf.line(pdf.width/2, 0, pdf.width/2, pdf.height);
  pdf.line(0, pdf.height/2, pdf.width, pdf.height/2);
  
  pdf.dispose();
  pdf.endDraw();
  
  println("PDF output");

}

void coverPage() {
  // Create the cover page
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
  pdf.text("This book is "+paperWidth+" in. wide x "+paperHeight+" in. height", reportX, reportHeight);
  reportHeight += reportSpace;
  pdf.text("Targeting a DPI of: " + desiredDPI, reportX, reportHeight);
  reportHeight += reportSpace;
  pdf.text("It should be folded "+widthFolds+" time on the width and "+heightFolds+" on the height.", reportX, reportHeight);
  reportHeight += reportSpace;
  pdf.text("In order to bind the "+numPages+" pages using "+printerPages+" printer pages.", reportX, reportHeight);
  
  pdf.noFill();
  
  float tXPos = 0;
  float tYPos = 50;
  for (int k=0; k<numPages; k++) { // this repeats for each spread
      
    // even or odd to set the x

    if (k%2 == 0) {
      tXPos = column2 + pages[k].getWidth()/10;
    } else {
      tXPos = column2;
      tYPos += 300;

    }
    
    pdf.image(pages[k].getPage(), tXPos, tYPos, pages[k].getWidth()/10, pages[k].getHeight()/10);
    pdf.rect(tXPos, tYPos, pages[k].getWidth()/10, pages[k].getHeight()/10);
  
  }
  
  
  //for (int k=0; k<numPages; k++) { // this repeats for each spread
  //  //for (int l=0; l<2; l++) { // this uses both pages
  //  if (k%2 = 0) { // its even
  //    float tXPos = float(reportX + 1500) + (k*pages[k].getWidth()/10);
  //    float tYPos = 50+(k*300);
  //    pdf.image(pages[k].getPage(), tXPos, tYPos, pages[k].getWidth()/10, pages[k].getHeight()/10);
  //    pdf.rect(tXPos, tYPos, pages[k].getWidth()/10, pages[k].getHeight()/10);
  //  } else {
  //    pdf.image(pages[k].getPage(), tXPos, tYPos, pages[k].getWidth()/10, pages[k].getHeight()/10);
  //    pdf.rect(tXPos, tYPos, pages[k].getWidth()/10, pages[k].getHeight()/10);
  //}
}

void draw() {
  


  
}