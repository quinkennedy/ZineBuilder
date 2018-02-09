public class Verb implements WorkshopText{
  String[] words = new String[]{
    "run", "sleep", "hit", "cry", "walk", "think"};
  public String GetText(XML xml, VarService vars){
    return words[(int)random(words.length - 1)];
  }
}