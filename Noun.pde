public class Noun implements WorkshopText{
  String[] words = new String[]{
    "bathtub", "L.A.", "earth", "sand", "dog", "stick", "tire"};
  public String GetText(XML xml, VarService vars){
    return words[(int)random(words.length)];
  }
}