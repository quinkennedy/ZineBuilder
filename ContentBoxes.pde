class ImageBox implements IContentBox{
  PImage image;
  public ImageBox(PImage img){
    img = image;
  }
  
  public Rectangle render(Rectangle area, PGraphics pg){
    float scale = 1;
    scale = Math.min(scale, area.h / image.height);
    scale = Math.min(scale, area.w / image.width);
    float sWidth = image.width * scale;
    float sHeight = image.height * scale;
    pg.image(image, area.x + area.w - sWidth, area.y, sWidth, sHeight);
    return new Rectangle(area.x + area.w - sWidth, area.y, sWidth, sHeight);
  }
}

class TextBox implements IContentBox{
  String text;
  PFont font;
  public TextBox(String txt, PFont fnt){
    text = txt;
    font = fnt;
  }
  public Rectangle render(Rectangle area, PGraphics pg){
    FormattedTextBlock.FormattedText[] fText = 
      {new FormattedTextBlock.FormattedText(text, font)};
    FormattedTextBlock block = new FormattedTextBlock(fText, (int)area.w, pg);
    pg.pushMatrix();
    pg.translate(area.x, area.y);
    block.render(pg);
    pg.popMatrix();
    return new Rectangle(area.x, area.y, block.maxWidth, block.totalHeight);
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
  public Rectangle render(Rectangle area, PGraphics pg){
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
      block.render(pg);
      pg.popMatrix();
      return area;
    } else {
      return new Rectangle(area.x, area.y, 0, 0);
    }
  }
}