import processing.core.PFont;
import processing.core.PGraphics;
import java.util.ArrayList;

public class FormattedTextBlock{ //<>//
  FormattedText[] text;
  int maxWidth;
  ArrayList<FormattedLine> lines;
  int totalHeight, constrainHeight;
  
  public FormattedTextBlock(FormattedText[] text, int maxWidth, PGraphics pg){
    this.text = text;
    this.maxWidth = maxWidth;
    calculateLines(pg);
  }
  
  //split the formatted text into separate lines of text
  //based on computed text lengths and given maximum text block width
  private void calculateLines(PGraphics pg){
    //all the lines
    lines = new ArrayList<FormattedLine>();
    //the current line we are populating
    FormattedLine line = newLine(lines);
    //the width of the FormattedText text that has 
    //been committed to the current line
    float currWidth = 0;
    //the current text that can concatenate on the current line
    //but has not yet been committed
    String contig = "";
    int prevDescent = 0, currDescent = 0, currAscent = 0, currY = 0;
    FormattedText tempText;
    
    //for each formatted text element
    for(int ti = 0; ti < text.length; ti++){
      FormattedText currT = text[ti];
      //set the PGraphics font for accurate width calculation
      pg.textFont(currT.font, currT.fontSize);
      
      //split the formatted text into words
      SplitText[] words = currT.split();
      //for each word
      for(int wi = 0; wi < words.length; wi++){
        currDescent = (int)Math.max(currDescent, Math.ceil(pg.textDescent()));
        if (pg.textAscent() > currAscent){
          currY += pg.textAscent() - currAscent;
          updateLineAscent(line, currY);
          currAscent = (int)Math.ceil(pg.textAscent());
        }
        SplitText currW = words[wi];
        //get the width of the uncommitted text along with
        //the current word we are testing
        //TODO: understand the difference between unseen separators (spaces)
        // and seen separators (hyphens)
        float contigWidth = pg.textWidth(contig + currW.text);
        float contigNsepWidth = pg.textWidth(contig + currW.toString());
        
        //if the word doesn't fit
        if (currWidth + contigWidth > maxWidth){
          //commit all un-committed text
          if (contig.length() > 0){
            tempText = new FormattedText(contig, currT.font, currT.fontSize);
            line.add(tempText);
            tempText.startX = currWidth;
            tempText.startY = currY;
          }
          //create the new line to fill
          line = newLine(lines);
          currWidth = 0;
          currAscent = (int)Math.ceil(pg.textAscent());
          currY += currDescent + currAscent;
          prevDescent = currDescent;
          currDescent = (int)Math.ceil(pg.textDescent());
          contig = "";
        }
        //add this word to the un-committed text
        contig += currW.toString();
        //if we have a newline character, and have content on this line
        if (currW.postSep.equals("\n") && (contig.length() > 0 || line.texts.size() > 0)){
          //force a newline (unless we just did a newline)
          
          //commit text
          //let's not include the newline character
          if (contig.length() > 1){
            tempText = new FormattedText(contig.substring(0, contig.length() - 1), currT.font, currT.fontSize);
            line.add(tempText);
            tempText.startX = currWidth;
            tempText.startY = currY;
          }
          contig = "";
          //start a new line
          line = newLine(lines);
          currWidth = 0;
          currY += currDescent;
          prevDescent = currDescent;
          currAscent = 0;
          currDescent = 0;
        }
      }
      //end of current FormattedText element
      //commit any uncommitted text
      if (contig.length() > 0){
        tempText = new FormattedText(contig, currT.font, currT.fontSize);
        line.add(tempText);
        tempText.startX = currWidth;
        tempText.startY = currY;
        currWidth += pg.textWidth(contig);
        contig = "";
      }
    }
    totalHeight = currY + currDescent;
  }
  
  public void constrainHeight(int maxHeight, PGraphics pg){
    constrainHeight = maxHeight;
    if (totalHeight <= maxHeight){
      //already fits!
      return;
    }
    //backup original text
    FormattedText[] origText = text;
    text = new FormattedText[text.length];
    for(int i = 0; i < text.length; i++){
      text[i] = new FormattedText(origText[i].text, origText[i].font, origText[i].fontSize);
    }
    
    boolean nochange = false;
    int lastChange = 0;
    double scaleAmount = 1;
    double lastAdjust = 1;
    double bestFitScaleAmount = 1;
    boolean didFit = false;
    int limit = 100;
    int iterations = 0;
    while(!nochange && iterations < limit){
      iterations++;
      nochange = true;
      if (totalHeight > maxHeight){
        if (!didFit){
          bestFitScaleAmount = scaleAmount;
        }
        lastAdjust /= 2;
        scaleAmount -= lastAdjust;
      } else {
        didFit = true;
        bestFitScaleAmount = scaleAmount;
        lastAdjust /= 2;
        scaleAmount += lastAdjust;
      }
      for(int i = 0; i < text.length; i++){
        int lastSize = text[i].fontSize;
        text[i].fontSize = (int)(origText[i].fontSize * scaleAmount);
        nochange &= (text[i].fontSize == lastSize);
      }
      if (!nochange){
        calculateLines(pg);
      }
    }
    
    //scale according to best fit
    for(int i = 0; i < text.length; i++){
      text[i].fontSize = (int)(origText[i].fontSize * bestFitScaleAmount);
    }
    calculateLines(pg);
  }
  
  public void render(PGraphics g){
    render(g, false);
  }
  
  public void render(PGraphics g, boolean debug){
    if (debug){
      g.pushStyle();
      g.noFill();
      g.stroke(255);
      g.rect(0, 0, maxWidth, constrainHeight);
      g.stroke(0);
      g.rect(0, 0, maxWidth, totalHeight);
      g.popStyle();
    }
    FormattedLine currLine;
    for (int i = 0; i < lines.size(); i++) {
      currLine = lines.get(i);
      for (int w = 0; w < currLine.texts.size(); w++) {
        FormattedText currContig = currLine.texts.get(w);
        g.textFont(currContig.font, currContig.fontSize);
        g.text(currContig.text, currContig.startX, currContig.startY);
      }
    }
  }
  
  private void updateLineAscent(FormattedLine line, int newY){
    for(int i = 0; i < line.texts.size(); i++){
      line.texts.get(i).startY = newY;
    }
  }
  
  private FormattedLine newLine(ArrayList<FormattedLine> lines){
    FormattedLine fresh = new FormattedLine();
    lines.add(fresh);
    return fresh;
  }
  
  public String toString(){
    String output = "[BLOCKED TEXT]\n";
    for(int i = 0; i < text.length; i++){
      output += text[i].toString() + "\n";
    }
    return output;
  }
  
  public static class FormattedText{
    String text;
    PFont font;
    int fontSize;
    float startX, startY;
    
    public FormattedText(String text, PFont font){
      init(text, font, font.getSize());
    }
    
    public FormattedText(String text, PFont font, int fontSize){
      init(text, font, fontSize);
    }
    
    private void init(String _text, PFont _font, int _fontSize){
      this.text = _text;
      this.font = _font;
      this.fontSize = _fontSize;
    }
    
    public SplitText[] split(){
      String restText = text;
      int i;
      char[] splitGlyphs = {' ', '\n'};
      ArrayList<SplitText> sText = new ArrayList<SplitText>();
      
      do{
        i = indexOf(restText, splitGlyphs);
        if (i == -1){
          sText.add(new SplitText(restText, ""));
        } else {
          String item = restText.substring(0, i);//startIndex, endIndex
          String sep = restText.substring(i, i+1);
          restText = restText.substring(i + 1);
          sText.add(new SplitText(item, sep));
        }
      }while(i >= 0 && restText.length() > 0);
      
      return sText.toArray(new SplitText[sText.size()]);
    }
    
    private int indexOf(String s, char[] glyphs){
      if (s == null){
        return -1;
      }
      int lowestIndex = -1;
      int currIndex;
      for(int i=0; i < glyphs.length; i++){
        currIndex = s.indexOf(glyphs[i]);
        if (currIndex == -1){
          continue;
        } else if (lowestIndex == -1 || currIndex < lowestIndex){
          lowestIndex = currIndex;
        }
      }
      return lowestIndex;
    }
    
    public void setPos(int startX, int startY){
      this.startX = startX;
      this.startY = startY;
    }
    
    public String toString(){
      String output =  font.getName() + ":" + text;
      return output;
    }
  }
  
  public static class SplitText{
    String postSep;
    String text;
    
    public SplitText(String t, String pSep){
      postSep = pSep;
      text = t;
    }
    
    public String toString(){
      return text+postSep;
    }
  }
  
  public static class FormattedLine{
    ArrayList<FormattedText> texts = new ArrayList<FormattedText>();
    
    public void add(FormattedText text){
      texts.add(text);
    }
  }
}