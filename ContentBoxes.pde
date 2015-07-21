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
      return destination;
    }
  }
}

class TextBox extends ContentBox{
  FormattedTextBlock text;
  FontFamily font;
  float fontSize;
  boolean adjustFontSize = false;
  
  public TextBox(XML txt, FontFamily fnt, float size, PGraphics pg, Map<String, String> vars, boolean adjustSize){
    font = fnt;
    fontSize = size;
    text = new FormattedTextBlock(pg);
    parse(txt, fnt, FontWeight.REGULAR, FontEm.REGULAR, size, vars, text);
    adjustFontSize = adjustSize;
  }
  
  public boolean isResizable(){
    return adjustFontSize;
  }
  
  public Rectangle render(Rectangle area, PGraphics pg, boolean debug){
    FormattedTextBlock.FormattedText[] fText = 
      {new FormattedTextBlock.FormattedText(text, font, (int)fontSize)};
    FormattedTextBlock block = new FormattedTextBlock(fText, (int)area.w, pg);
    if (block.totalHeight > area.h && adjustFontSize){
      block.constrainHeight((int)area.h, pg);
    }
    pg.pushMatrix();
    pg.translate(area.x, area.y);
    block.render(pg, debug);
    pg.popMatrix();
    Rectangle used = new Rectangle(area.x, area.y, block.maxWidth, block.totalHeight);
    return used;
  }
  
  //so what I want is a recursive function which edits a list and returns a string.
  //if it gets a string back, then it concatinates that string to it's own string, if there
  //  were nodes added to the List after this function was entered, add this function's text to the List
  private void parse(XML txt, FontFamily fnt, FontWeight weight, FontEm em, float size, Map<String, String> vars, FormattedTextBlock block){
    String currName = txt.getName();
    if (currName.equals("#text")){
      block.add(txt.getContent(), fnt.get(weight).get(em), size);
    } else if (currName.equals("bold")){
      weight = FontWeight.BOLD;
    } else if (currName.equals("italic")){
      weight = FontEm.ITALIC;
    } else if (currName.equals("var")){
      if (vars.containsKey(txt.getString("key"))){
        block.add(vars.get(txt.getString("key")), fnt.get(weight).get(em));
      } else {
        block.add(txt.format(-1), fnt.get(weight).get(em))
    }
    XML[] children = txt.getChildren();
    for(XML node : nodes){
    }
  }
  
  private Object parse(
      FormattedTextBlock block, XML node, FontFamily fnt, float size, 
      FontWeight weight, FontEm em, Map<String, String> vars){
    
  }
}

class HeadingBox extends ContentBox{
  String heading, subheading;
  PFont font;
  float headingSize, subheadingSize;
  public HeadingBox(String _heading, String _subheading, PFont _font, float _headingSize, float _subheadingSize){
    heading = _heading;
    subheading = _subheading;
    font = _font;
    headingSize = _headingSize;
    subheadingSize = _subheadingSize;
  }
  public boolean isResizable(){
    return false;
  }
  private boolean hasHeading(){
    return heading != null && heading.length() > 0;
  }
  private boolean hasSubheading(){
    return subheading != null && subheading.length() > 0;
  }
  public Rectangle render(Rectangle area, PGraphics pg, boolean debug){
    if (hasHeading() || hasSubheading()){
      FormattedTextBlock.FormattedText[] hText;
      if (hasHeading() && hasSubheading()){
        hText = new FormattedTextBlock.FormattedText[]{
          new FormattedTextBlock.FormattedText(heading + "\n", font, (int)headingSize),
          new FormattedTextBlock.FormattedText(subheading, font, (int)subheadingSize)};
      } else {
        hText = new FormattedTextBlock.FormattedText[]{
          new FormattedTextBlock.FormattedText(
            hasHeading() ? heading : subheading, 
            font, 
            (int)(hasHeading() ? headingSize : subheadingSize))};
      }
      FormattedTextBlock block = new FormattedTextBlock(hText, (int)area.w, pg);
      pg.pushMatrix();
      pg.translate(area.x, area.y);
      block.render(pg, debug);
      pg.popMatrix();
      if (debug){
        pg.pushStyle();
        pg.noFill();
        pg.stroke(170);
        pg.strokeWeight(1);
        pg.rect(area.x, area.y, area.w, area.h);
        pg.popStyle();
      }
      return new Rectangle(area.x, area.y, block.maxWidth, block.totalHeight);
    } else {
      return new Rectangle(area.x, area.y, 0, 0);
    }
  }
}