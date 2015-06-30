//this function is portrait/landscape agnostic,
//later perhaps we could allow specifying a fold order.
//ASSUMPTIONS
// - using both sides of the page.
// - all horizontal folds before all vertical folds.
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
    next = new ZinePageLayout[prev.length][prev[0].length*2][prev[0][0].length];
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
    hFoldsLeft--;
    prev = next;
  }
  while(vFoldsLeft > 0){
    zinePages *= 2;
    next = new ZinePageLayout[prev.length][prev[0].length][prev[0][0].length*2];
    for(int i = 0; i < prev[0][0].length; i++){
      for(int paper = 0; paper < prev.length; paper++){
        int leftIndex = i*2;
        int rightIndex = leftIndex+1;
        int targetIndex = (i%2 == 0) ? leftIndex : rightIndex;
        int otherIndex = (i%2 == 0) ? rightIndex : leftIndex;
        if (paper == 0 && vFoldsLeft == verticalFolds){
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
    vFoldsLeft--;
    prev = next;
  }
  //int pagesPerPaper = zinePages;
  if (paperSides > 1){
    zinePages *= paperSides;
    next = new ZinePageLayout[paperSides][prev[0].length][prev[0][0].length];
    for(int i = 0; i < prev[0].length; i++){
      for(int j = 0; j < prev[0][0].length; j++){
        ZinePageLayout cpg = prev[0][i][j];
        boolean isEven = cpg.getNumber()%2 == 0;
        if (isEven){
          next[0][i][j] = new ZinePageLayout(cpg.getNumber()*paperSides, cpg.getHFlip(), cpg.getVFlip());
        } else {
          next[0][i][j] = new ZinePageLayout((cpg.getNumber()-1)*paperSides+1, cpg.getHFlip(), cpg.getVFlip());
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
  }
  return next;
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