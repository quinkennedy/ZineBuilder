class KeywordService implements WorkshopText{
  
  private Map<String, String> keywordCache = new HashMap<String, String>();
  private String[] words;
  
  private void loadWords(){
    File directory = new File(getDirectory());
    String filename = "nounlist.txt";//String.format(xml.getString("src"), parseInt(vars.Get("num")));
    File file = new File(directory, filename);
    words = loadStrings(file.getAbsolutePath());
  }
  
  public String GetText(XML xml, VarService vars){
    String copy = vars.Get("num");
    String index = xml.getString("keywordIndex");
    String numKeywords = xml.getString("keywordAmount");
    String key = String.format("%s,%s", copy, index);
    if (!keywordCache.containsKey(key)){
      if (words == null){
        loadWords();
      }
      keywordCache.put(key, words[(int)random(words.length)]);
    }
    return keywordCache.get(key);
  }
}