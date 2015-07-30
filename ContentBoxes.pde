class ImageBox extends ContentBox{
  PImage image;
  public ImageBox(PImage img){
    image = img;
  }
  
  public boolean isResizable(){
    return true;
  }
  
  public Rectangle render(Rectangle area, PGraphics pg, boolean debug){
    if (image == null){
      return new Rectangle(area.x, area.y, 0, 0);
    } else {
      float scale = 1;
      scale = Math.min(scale, area.h / Math.max(image.height, 1));
      scale = Math.min(scale, area.w / Math.max(image.width, 1));
      float sWidth = image.width * scale;
      float sHeight = image.height * scale;
      image.filter(GRAY);
      Rectangle destination = new Rectangle(area.x + (area.w - sWidth) / 2, area.y, sWidth, sHeight);
      pg.image(image, destination.x, destination.y, destination.w, destination.h);
      // Really want to get this blend working, but I'm too tired to figure out the right coordinates...
      //pg.blend(image, 0, 0, image.width, image.height, (int) destination.x, (int)destination.y, (int)destination.w, (int)destination.h, DARKEST); 
      return destination;
    }
  }
}

class TextBox extends ContentBox{
  FormattedTextBlock text;
  FontFamily font;
  float fontSize;
  boolean adjustFontSize = false;
  
  private TextBox(){}
  
  public TextBox(XML txt, FontFamily fnt, float size, PGraphics pg, Map<String, String> vars, boolean adjustSize){
    font = fnt;
    fontSize = size;
    text = new FormattedTextBlock(pg);
    parse(txt, fnt, FontWeight.REGULAR, FontEm.REGULAR, size, vars, text);
    adjustFontSize = adjustSize;
  }
  
  public TextBox(String txt, PFont fnt, float size, PGraphics pg, boolean adjustSize){
    fontSize = size;
    text = new FormattedTextBlock(pg);
    text.add(txt, fnt, size);
    adjustFontSize = adjustSize;
  }
  
  public boolean isResizable(){
    return adjustFontSize;
  }
  
  public Rectangle render(Rectangle area, PGraphics pg, boolean debug){
    text.setConstraints(area.w, area.h);
    pg.pushMatrix();
    pg.translate(area.x, area.y);
    text.render(pg, debug);
    pg.popMatrix();
    Rectangle used = new Rectangle(area.x, area.y, text.getWidth(), text.getHeight());
    return used;
  }
  
  //so what I want is a recursive function which edits a list and returns a string.
  //if it gets a string back, then it concatinates that string to it's own string, if there
  //  were nodes added to the List after this function was entered, add this function's text to the List
  protected void parse(XML txt, FontFamily fnt, FontWeight weight, FontEm em, 
      float size, Map<String, String> vars, FormattedTextBlock block){
    LinkedList<FormattedTextBlock.FormattedText> bits = 
      new LinkedList<FormattedTextBlock.FormattedText>();
    String result = parse(bits, txt, fnt, weight, em, size, vars);
    if (result != null && result.length() > 0){
      bits.add(new FormattedTextBlock.FormattedText(result, fnt.get(weight, em), size));
    }
    for(int i = 0; i < bits.size(); i++){
      block.add(bits.get(i));
    }
  }
  
  private String parse(
      LinkedList<FormattedTextBlock.FormattedText> bits, XML node, FontFamily fnt, 
      FontWeight weight, FontEm em, float size, Map<String, String> vars){
    FontWeight myWeight = weight;
    FontEm myEm = em;
    if (node == null){
      return null;
    }
    String currName = node.getName();
    if (currName.equals("#text")){
      return node.getContent();
    } else if (currName.equals("var")){
      if (vars.containsKey(node.getString("key"))){
        return vars.get(node.getString("key"));
      } else {
        return node.format(-1);
      }
    } else if (currName.equals("bold")){
      myWeight = FontWeight.BOLD;
    } else if (currName.equals("italic")){
      myEm = FontEm.ITALIC;
    }
    XML[] children = node.getChildren();
    String myText = "";
    int listLength = bits.size();
    for(XML child : children){
      String childText = parse(bits, child, fnt, myWeight, myEm, size, vars);
      if (bits.size() > listLength){
        if (myText.length() > 0){
          bits.add(listLength, new FormattedTextBlock.FormattedText(myText, fnt.get(myWeight, myEm), size));
          if (childText != null){
            myText = childText;
          } else {
            myText = "";
          }
        }
        listLength = bits.size();
      } else if (childText != null && childText.length() > 0){
        myText += childText;
      }
    }
    if (myText.length() > 0){
      bits.add(new FormattedTextBlock.FormattedText(myText, fnt.get(myWeight, myEm), size));
    }
    return null;
  }
}

class HeadingBox extends TextBox{
  float headingSize, subheadingSize;
  XML heading, subheading;
  boolean hasHeading, hasSubheading;
  Map<String, String> vars;
  
  public HeadingBox(XML _heading, XML _subheading, FontFamily fnt, float _headingSize, 
      float _subheadingSize, PGraphics pg, Map<String, String> _vars, boolean adjustSize){
    heading = _heading;
    subheading = _subheading;
    font = fnt;
    vars = _vars;
    headingSize = _headingSize;
    subheadingSize = _subheadingSize;
    text = new FormattedTextBlock(pg);
    parse(_heading, fnt, FontWeight.REGULAR, FontEm.REGULAR, _headingSize, vars, text);
    int numTexts = text.text.size();
    hasHeading = numTexts > 0;
    if (hasHeading){
      text.add("\n", fnt.getReg(), _subheadingSize);
    }
    parse(_subheading, fnt, FontWeight.LIGHT, FontEm.REGULAR, _subheadingSize, vars, text);
    hasSubheading = text.text.size() > numTexts;
    if (!hasSubheading){
      text.dropLast();
    }
    adjustFontSize = adjustSize;
  }
  public boolean isResizable(){
    return false;
  }
  private boolean hasHeading(){
    return hasHeading;
  }
  private boolean hasSubheading(){
    return hasSubheading;
  }
  public String getHeadingText(PGraphics pg){
    if(hasHeading){
      FormattedTextBlock hBlock = new FormattedTextBlock(pg);
      parse(heading, font, FontWeight.REGULAR, FontEm.REGULAR, headingSize, vars, hBlock);
      return hBlock.getString();
    } else {
      return null;
    }
    
  }
  private float getHeadingSize(){
    if (!hasHeading()){
      return 0;
    } else {
      return text.text.get(0).fontSize;
    }
  }
  private float getSubheadingSize(){
    if (!hasSubheading()){
      return 0;
    } else {
      return text.text.get(text.text.size() - 1).fontSize;
    }
  }
}