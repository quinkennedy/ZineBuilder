//this function is portrait/landscape agnostic,
//later perhaps we could allow specifying a fold order.
//ASSUMPTIONS
// - using both sides of the page.
// - all horizontal folds before all vertical folds.
// - signatures are combined after folding
ZinePageLayout[][][] getLayout(int horizontalFolds, int verticalFolds, int paperSides){
  int vFoldsLeft = verticalFolds;
  int hFoldsLeft = horizontalFolds;
  ZinePageLayout[][][] prev = new ZinePageLayout[1][1][1];
  int zinePages = 1;
  for(int i = 0; i < prev.length; i++){
    prev[i][0][0] = new ZinePageLayout(i+1, false, false);
  }
  ZinePageLayout[][][] next = prev;
  while(hFoldsLeft > 0){
    zinePages *= 2;
    next = horizontalFold(prev);
    hFoldsLeft--;
    prev = next;
  }
  while(vFoldsLeft > 0){
    zinePages *= 2;
    next = verticalFold(prev);
    vFoldsLeft--;
    prev = next;
  }
  //each side of a piece of paper exists 
  //before the folds are applied
  if (paperSides > 1){
    if (horizontalFolds > 0 || verticalFolds > 0){
      zinePages *= 2;
      next = addPagesPreFold(prev, 2);
    } else {
      zinePages *= paperSides;
      next = addPagesPreFold(prev, paperSides);
    }
    prev = next;
  }
  //sub-signatures are then nested together after folding
  if (paperSides > 2 && (horizontalFolds > 0 || verticalFolds > 0)){
    zinePages *= paperSides/2;
    next = addPagesPostFold(prev, paperSides/2);
    prev = next;
  }
  return next;
}

ZinePageLayout[][][] horizontalFold(ZinePageLayout[][][] prev){
  int zinePages = getNumPages(prev) * 2;
  ZinePageLayout[][][] next = new ZinePageLayout[prev.length][prev[0].length*2][prev[0][0].length];
  for(int i = 0; i < prev[0].length; i++){
    for(int paper = 0; paper < prev.length; paper++){
      int upperIndex = i*2;
      int lowerIndex = upperIndex+1;
      int targetIndex = (i%2 == 0) ? upperIndex : lowerIndex;
      int otherIndex = (i%2 == 0) ? lowerIndex : upperIndex;
      for(int j = 0; j < prev[0][0].length; j++){
        next[paper][targetIndex][j] = prev[paper][i][j];
        next[paper][otherIndex][j] = new ZinePageLayout(
          zinePages - (prev[paper][i][j].getNumber() - 1), 
          !prev[paper][i][j].getHFlip(), 
          false);
      }
    }
  }
  return next;
}

ZinePageLayout[][][] verticalFold(ZinePageLayout[][][] prev){
  int zinePages = getNumPages(prev) * 2;
  ZinePageLayout[][][] next = new ZinePageLayout[prev.length][prev[0].length][prev[0][0].length*2];
  for(int i = 0; i < prev[0][0].length; i++){
    for(int paper = 0; paper < prev.length; paper++){
      int leftIndex = i*2;
      int rightIndex = leftIndex+1;
      int targetIndex = (i%2 == 0) ? leftIndex : rightIndex;
      int otherIndex = (i%2 == 0) ? rightIndex : leftIndex;
      if (paper == 0 && prev[0][0].length == 1){
        //the first page the first time is an odd one
        int temp = targetIndex;
        targetIndex = otherIndex;
        otherIndex = temp;
      }
      for(int j = 0; j < prev[0].length; j++){
        next[paper][j][targetIndex] = prev[paper][j][i];
        next[paper][j][otherIndex] = new ZinePageLayout(
          zinePages - (prev[paper][j][i].getNumber() - 1), 
          prev[paper][j][i].getHFlip(), 
          false);
      }
    }
  }
  return next;
}

ZinePageLayout[][][] addPagesPreFold(ZinePageLayout[][][] prev, int numPages){
  int zinePages = getNumPages(prev) * numPages;
  ZinePageLayout[][][] next = new ZinePageLayout[numPages][prev[0].length][prev[0][0].length];
  for(int i = 0; i < prev[0].length; i++){
    for(int j = 0; j < prev[0][0].length; j++){
      ZinePageLayout cpg = prev[0][i][j];
      boolean isEven = cpg.getNumber()%2 == 0;
      if (isEven){
        next[0][i][j] = new ZinePageLayout(cpg.getNumber()*numPages, cpg.getHFlip(), cpg.getVFlip());
      } else {
        next[0][i][j] = new ZinePageLayout((cpg.getNumber()-1)*numPages+1, cpg.getHFlip(), cpg.getVFlip());
      }
      cpg = next[0][i][j];
      for(int page = 1; page < next.length; page++){
        int destj = ((page%2 == 0) ? j : (prev[0][0].length - j - 1));
        next[page][i][destj] = new ZinePageLayout(
          cpg.getNumber() + (isEven ? -page : page),
          cpg.getHFlip(),
          cpg.getVFlip());
      }
    }
  }
  return next;
}

ZinePageLayout[][][] addPagesPostFold(ZinePageLayout[][][] prev, int numPages){
  int lastZinePages = getNumPages(prev);
  int halfLast = lastZinePages/2;
  int zinePages = lastZinePages * numPages;
  ZinePageLayout[][][] next = new ZinePageLayout[prev.length * numPages][prev[0].length][prev[0][0].length];
  for(int r = 0; r < prev[0].length; r++){
    for(int c = 0; c < prev[0][0].length; c++){
      for(int p = 0; p < prev.length; p++){
        ZinePageLayout og = prev[p][r][c];
        for(int d = 0; d < numPages; d++){
          if (og.getNumber() <= halfLast){
            next[p+prev.length*d][r][c] = new ZinePageLayout(
                                                og.getNumber() + halfLast*d, 
                                                og.getHFlip(), 
                                                og.getVFlip());
          } else {
            next[p+prev.length*d][r][c] = new ZinePageLayout(
                                                zinePages - halfLast*d - (lastZinePages - og.getNumber()),
                                                og.getHFlip(),
                                                og.getVFlip());
          }
        }
      }
    }
  }
  return next;
}

ZinePageLayout[][][] addSignatures(ZinePageLayout[][][] prev, int numSignatures){
  int zinePages = getNumPages(prev) * numSignatures;
  return prev;
}

int getNumPages(ZinePageLayout[][][] zine){
  int output = 0;
  for(int i = 0; i < zine.length; i++){
    for(int j = 0; j < zine[i].length; j++){
      output += zine[i][j].length;
    }
  }
  return output;
}

String getLayoutString(ZinePageLayout[][][] layout){
  String output = "";
  for(int page = 0; page < layout.length; page++){
    output += "P"+(page+1)+".";
    for(int h = 0; h < layout[0].length; h++){
      for(int c = 0; c < layout[0][0].length; c++){
        ZinePageLayout cpg = layout[page][h][c];
        output += "|"+(cpg == null ? "00??" : layout[page][h][c].toString())+"";
      }
      output += "|.";
    }
  }
  return output;
}

void printLayout(ZinePageLayout[][][] layout){
  for(int page = 0; page < layout.length; page++){
    println("+++ page "+(page+1)+" +++");
    for(int h = 0; h < layout[0].length; h++){
      for(int c = 0; c < layout[0][0].length; c++){
        ZinePageLayout cpg = layout[page][h][c];
        print("| "+(cpg == null ? "00??" : layout[page][h][c].toString())+" ");
      }
      println("|");
    }
  }
}

class ZinePageLayout{
  private int number;
  private boolean hFlip;
  private boolean vFlip;
  
  public ZinePageLayout(){
    number = 0;
    hFlip = false;
    vFlip = false;
  }
  
  public ZinePageLayout(int number, boolean hFlip, boolean vFlip){
    set(number, hFlip, vFlip);
  }
  
  public void set(int number, boolean hFlip, boolean vFlip){
    this.number = number;
    this.hFlip = hFlip;
    this.vFlip = vFlip;
  }
  
  public int getNumber(){
    return number;
  }
  
  public boolean getVFlip(){
    return vFlip;
  }
  
  public boolean getHFlip(){
    return hFlip;
  }
  
  public String toString(){
    return String.format("%02d:%s%s",number,(hFlip?"H":"h"),(vFlip?"V":"v"));
  }
}

void testLayout(){
  println("start testing");
  int num = 0;
  String layout = getLayoutString(getLayout(0, 0, 0));
  String startLayout = "P1.|01:hv|.";
  if (!layout.equals(startLayout)){
    println("failed num "+ num);
  }
  num++;
  layout = getLayoutString(getLayout(0, 0, 1));
  if (!layout.equals(startLayout)){
    println("failed num "+ num);
  }
  num++;
  layout = getLayoutString(getLayout(1, 0, 1));
  if (!layout.equals("P1.|01:hv|.|02:Hv|.")){
    println("failed num "+ num);
  }
  num++;
  layout = getLayoutString(getLayout(0, 1, 1));
  if (!layout.equals("P1.|02:hv|01:hv|.")){
    println("failed num "+ num);
  }
  num++;
  layout = getLayoutString(getLayout(1, 1, 1));
  if (!layout.equals("P1.|04:hv|01:hv|.|03:Hv|02:Hv|.")){
    println("failed num "+ num);
  }
  num++;
  layout = getLayoutString(getLayout(1, 1, 2));
  if (!layout.equals("P1.|08:hv|01:hv|.|05:Hv|04:Hv|.P2.|02:hv|07:hv|.|03:Hv|06:Hv|.")){
    println("failed num "+ num);
  }
  num++;
  layout = getLayoutString(getLayout(0, 0, 2));
  if (!layout.equals("P1.|01:hv|.P2.|02:hv|.")){
    println("failed num "+num);
  }
  num++;
  layout = getLayoutString(getLayout(0, 0, 4));
  if (!layout.equals("P1.|01:hv|.P2.|02:hv|.P3.|03:hv|.P4.|04:hv|.")){
    println("failed num "+num);
  }
  num++;
  layout = getLayoutString(getLayout(0, 1, 4));
  if (!layout.equals("P1.|08:hv|01:hv|.P2.|02:hv|07:hv|.P3.|06:hv|03:hv|.P4.|04:hv|05:hv|.")){
    printLayout(getLayout(0, 1, 4));
    println(layout);
    println("failed num "+num);
  }
  num++;
  layout = getLayoutString(getLayout(1, 1, 4));
  if (!layout.equals("P1.|16:hv|01:hv|.|13:Hv|04:Hv|."+
                     "P2.|02:hv|15:hv|.|03:Hv|14:Hv|."+
                     "P3.|12:hv|05:hv|.|09:Hv|08:Hv|."+
                     "P4.|06:hv|11:hv|.|07:Hv|10:Hv|.")){
    printLayout(getLayout(1, 1, 4));
    println(layout);
    println("failed num "+num);
  }
  num++;
  println("done testing");
  printLayout(getLayout(1, 1, 4));
}
