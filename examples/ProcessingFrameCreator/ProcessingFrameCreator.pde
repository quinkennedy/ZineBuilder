import java.util.*;

ArrayList<Integer> squares = new ArrayList<Integer>(Arrays.asList(new Integer[]{255, 100, 0}));

void setup(){
size(255, 255);
rectMode(CENTER);
}

void draw(){
  for(int i : squares){
    noStroke();
    fill(i);
    rect(width/2, height/2, i, i);
  }
  saveFrame();
  if (squares.size() >= 256){
    noLoop();
  } else {
    int insertBefore = (int)random(1, squares.size());
    squares.add(insertBefore, (int)random(squares.get(insertBefore) + 1, squares.get(insertBefore - 1)));
  }
}