class ImageBox implements IContentBox{
  PImage image;
  public ImageBox(PImage img){
    image = img;
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
      pg.image(image, area.x + area.w - sWidth, area.y, sWidth, sHeight);
      return new Rectangle(area.x + area.w - sWidth, area.y, sWidth, sHeight);
    }
  }
}

class TextBox implements IContentBox{
  String text;
  PFont font;
  float fontSize;
  public TextBox(String txt, PFont fnt){
    text = txt;
    font = fnt;
    fontSize = font.getSize();
  }
  public TextBox(String txt, PFont fnt, float size){
    text = txt;
    font = fnt;
    fontSize = size;
  }
    
  public Rectangle render(Rectangle area, PGraphics pg, boolean debug){
    FormattedTextBlock.FormattedText[] fText = 
      {new FormattedTextBlock.FormattedText(text, font)};
    FormattedTextBlock block = new FormattedTextBlock(fText, (int)area.w, pg);
    pg.pushMatrix();
    pg.translate(area.x, area.y);
    block.render(pg, debug);
    pg.popMatrix();
    Rectangle used = new Rectangle(area.x, area.y, block.maxWidth, block.totalHeight);
    return used;
  }
}

class HeadingBox implements IContentBox{
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
      return area;
    } else {
      return new Rectangle(area.x, area.y, 0, 0);
    }
  }
}