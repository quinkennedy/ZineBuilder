import processing.core.PFont;
import processing.core.PGraphics;
import java.util.ArrayList;

public class FormattedTextBlock{ //<>//
  public ArrayList<FormattedText> text;
  PGraphics pg;
  private ArrayList<FormattedLine> lines;
  private float totalHeight, totalWidth;
  private float constrainHeight = Float.POSITIVE_INFINITY, constrainWidth = Float.POSITIVE_INFINITY;
  private boolean calculated = false;
  private VerticalResolutionTechnique vt = VerticalResolutionTechnique.Scale;
  private HorizontalResolutionTechnique ht = HorizontalResolutionTechnique.Overflow;
 // private ArrayList<Rectangle> blockedOut = new ArrayList<Rectangle>();
  
  //public FormattedTextBlock(FormattedText[] text, float targetWidth, PGraphics pg){
  //  this.text = new ArrayList<FormattedText>(text.length);
  //  for(int i = 0; i < text.length; i++){
  //    this.text.add(text[i]);
  //  }
  //  this.targetWidth = targetWidth;
  //  this.pg = pg;
  //}
  
  public FormattedTextBlock(PGraphics pg){
    text = new ArrayList<FormattedText>();
    this.pg = pg;
  }
  
  public float getHeight(){
    if (!calculated){
      constrain();
    }
    return totalHeight;
  }
  
  public float getWidth(){
    if (!calculated){
      constrain();
    }
    return totalWidth;
  }
  
  public void add(String txt, PFont font, float fontSize){
    add(new FormattedText(txt, font, fontSize));
  }
  
  public void add(FormattedText txt){
    text.add(txt);
    calculated = false;
  }
  
  public void dropLast(){
    if (text != null && text.size() > 0){
      text.remove(text.size() - 1);
    }
  }
  
  public void setConstraints(float width, float height){
    constrainWidth = width;
    constrainHeight = height;
    calculated = false;
  }
  
  //public void addBlocker(Rectangle block){
  //  blockedOut.add(block);
  //}
  
  //split the formatted text into separate lines of text
  //based on computed text lengths and given maximum text block width
  private void calculateLines(){
    //all the lines
    lines = new ArrayList<FormattedLine>();
    //the current line we are populating
    FormattedLine line = newLine(lines);
    //the width of the FormattedText text that has 
    //been committed to the current line
    float currWidth = 0;
    float largestWidth = 0;
    //the current text that can concatenate on the current line
    //but has not yet been committed
    String contig = "";
    String lastSep = "";
    int prevDescent = 0, currDescent = 0, currAscent = 0, currY = 0;
    FormattedText tempText;
    boolean autoNewline = false;
    
    //for each formatted text element
    for(int ti = 0; ti < text.size(); ti++){
      FormattedText currT = text.get(ti);
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
        float contigWidth = pg.textWidth(contig + lastSep + currW.text);
        
        //if the word doesn't fit
        if (currWidth + contigWidth > constrainWidth){
          //commit all un-committed text
          if (contig.length() > 0){
            tempText = new FormattedText(contig, currT.font, currT.fontSize);
            line.add(tempText);
            tempText.startX = currWidth;
            tempText.startY = currY;
            currWidth += pg.textWidth(contig);
          }
          //create the new line to fill
          line = newLine(lines);
          autoNewline = true;
          largestWidth = Math.max(currWidth, largestWidth);
          currWidth = 0;
          currAscent = (int)Math.ceil(pg.textAscent());
          currY += currDescent + currAscent;
          prevDescent = currDescent;
          currDescent = (int)Math.ceil(pg.textDescent());
          contig = "";
          lastSep = "";
        }
        //add this word to the un-committed text
        contig += lastSep + currW.text;
        lastSep = currW.postSep;
        //if we have a newline character, and have content on this line
        if (currW.postSep.equals("\n") && (!autoNewline || contig.length() > 0 || line.texts.size() > 0)){
          //force a newline (unless we just did a newline)
          
          //commit text
          //let's not include the newline character
          if (contig.length() > 1){
            tempText = new FormattedText(contig, currT.font, currT.fontSize);
            line.add(tempText);
            tempText.startX = currWidth;
            tempText.startY = currY;
            currWidth += pg.textWidth(tempText.text);
          }
          contig = "";
          lastSep = "";
          //start a new line
          line = newLine(lines);
          autoNewline = false;
          largestWidth = Math.max(currWidth, largestWidth);
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
    largestWidth = Math.max(currWidth, largestWidth);
    totalHeight = currY + currDescent;
    totalWidth = largestWidth;
  }
  
  public void constrain(){
    //TODO: constrain width as well
    calculateLines();
    if (totalHeight <= constrainHeight){
      //already fits!
      return;
    }
    //backup original text
    ArrayList<FormattedText> origText = text;
    text = new ArrayList<FormattedText>(origText.size());
    for(int i = 0; i < origText.size(); i++){
      text.add(new FormattedText(origText.get(i).text, origText.get(i).font, origText.get(i).fontSize));
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
      if (totalHeight > constrainHeight){
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
      for(int i = 0; i < text.size(); i++){
        float lastSize = text.get(i).fontSize;
        text.get(i).fontSize = (float)(origText.get(i).fontSize * scaleAmount);
        nochange &= (text.get(i).fontSize == lastSize);
      }
      if (!nochange){
        calculateLines();
      }
    }
    
    //scale according to best fit
    for(int i = 0; i < text.size(); i++){
      text.get(i).fontSize = (int)(origText.get(i).fontSize * bestFitScaleAmount);
    }
    calculateLines();
    calculated = true;
  }
  
  public void render(PGraphics g){
    render(g, false);
  }
  
  public void render(PGraphics g, boolean debug){
    if (!calculated){
      constrain();
    }
    if (debug){
      g.pushStyle();
      g.noFill();
      g.stroke(200);
      g.rect(0, 0, constrainWidth, constrainHeight);
      g.stroke(0);
      g.rect(0, 0, totalWidth, totalHeight);
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
    if (!calculated){
      constrain();
    }
    String output = "[BLOCKED TEXT]\n";
    for(int i = 0; i < text.size(); i++){
      output += text.get(i).toString() + "\n";
    }
    output += "[LINES]\n";
    for(int i = 0; i < lines.size(); i++){
      output += lines.get(i).toString() + "\n";
    }
    return output;
  }
  
  public String getString(){
    String output = "";
    for(int i = 0; i < text.size(); i++){
      output += text.get(i).getString();
    }
    return output;
  }
  
  public static class FormattedText{
    String text;
    PFont font;
    float fontSize;
    float startX, startY;
    
    public FormattedText(String text, PFont font){
      init(text, font, font.getSize());
    }
    
    public FormattedText(String text, PFont font, float fontSize){
      init(text, font, fontSize);
    }
    
    private void init(String _text, PFont _font, float _fontSize){
      this.text = _text;
      this.font = _font;
      this.fontSize = _fontSize;
    }
    
    public SplitText[] split(){
      String restText = text;
      int i;
      char[] visibleSplits = {'-'};
      char[] invisibleSplits = {' ', '\n'};
      char[] splitGlyphs = new char[visibleSplits.length + invisibleSplits.length];
      for(int j = 0; j < invisibleSplits.length; j++){
        splitGlyphs[j] = invisibleSplits[j];
      }
      for(int j = 0; j < visibleSplits.length; j++){
        splitGlyphs[invisibleSplits.length + j] = visibleSplits[j];
      }
      ArrayList<SplitText> sText = new ArrayList<SplitText>();
      
      do{
        i = indexOf(restText, splitGlyphs);
        if (i == -1){
          sText.add(new SplitText(restText, ""));
        } else {
          String item = restText.substring(0, i);//startIndex, endIndex
          String sep = restText.substring(i, i+1);
          if (sep != null && sep.length() > 0 && isIn(sep.charAt(0), visibleSplits)){
            item += sep;
            sep = "";
          }
          restText = restText.substring(i + 1);
          sText.add(new SplitText(item, sep));
        }
      }while(i >= 0 && restText.length() > 0);
      
      return sText.toArray(new SplitText[sText.size()]);
    }
    
    private boolean isIn(char c, char[] l){
      for(int i = 0; i < l.length; i++){
        if (c == l[i]){
          return true;
        }
      }
      return false;
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
    
    public String getString(){
      return text;
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
  
  public enum VerticalResolutionTechnique{
    Scale, Drop
  }
  public enum HorizontalResolutionTechnique{
    Scale, Overflow, Wrap, Drop
  }
}