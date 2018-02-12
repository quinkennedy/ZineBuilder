public void DrawWord(Rectangle rect, PGraphics pg, int WordIndex, int R, int G, int B)
{
    String[] words1 = new String[]{
       "look", "feel", "embrace", "contemplate", "juggle", "touch", "shout" 
    };
    String[] words2 = new String[]{
       "before"
    };
    String[] words3 = new String[]{
          "you"
    };
    String[] words4 = new String[]{
      "leap", "run", "crash", "hit", "cry", "eat", "walk", "judge", "love", "bite", "fail", "succeed", "draw"};
   pg.blendMode(MULTIPLY);

   pg.translate(pg.width/4, pg.height/2);

   pg.textAlign(CENTER);
   pg.textSize(200);
   
   String s = ",.-'`'-.,";
      if(WordIndex == 0)
        s = words1[(int)random(words1.length-1)];
      else if(WordIndex == 1)
        s = words2[(int)random(words2.length-1)];
      else if(WordIndex == 2)
        s = words3[(int)random(words3.length-1)];
      else if(WordIndex == 3)
        s = words4[(int)random(words4.length-1)];
        
   
   int c = 30;
   for(int i =0; i<c; i++)
   {
      float n = pow((float)i/(float)c, 6);
      pg.fill(R, G, B, n*255);

      pg.rotate(i*random(-.005, .007) );
      
      pg.text(s, 0, 0);
   }
}