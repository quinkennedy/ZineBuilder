class DictionaryService implements WorkshopText{
  
  private Map<String, String> keywordCache = new HashMap<String, String>();
  private JSONObject dict;
  
  private void loadDict(){
    File directory = new File(getDirectory());
    String filename = "dictionary.json";//String.format(xml.getString("src"), parseInt(vars.Get("num")));
    File file = new File(directory, filename);
    dict = loadJSONObject(file.getAbsolutePath());
  }
  
  public String GetText(XML xml, VarService vars){
    String word = xml.getString("word");
    if (word == null){
      if (xml.hasAttribute("useKeyword")){
        word = vars.Get("keyword", xml);
      } else {
        return "";
      }
    }
    println("[DictionaryService.GetText] looking up " + word);
    if (dict == null){
      loadDict();
    }
    return dict.getString(word.toUpperCase());
  }
}