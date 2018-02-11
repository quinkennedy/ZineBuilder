import java.util.Map;
import java.util.HashMap;
import processing.data.XML;

class VarService{
  
  private Map<String, String> vars = new HashMap<String, String>();
  private Map<String, WorkshopText> generators = new HashMap<String, WorkshopText>();
  
  public void put(String key, String value){
    vars.put(key, value);
  }
  
  public void put(String key, WorkshopText generator){
    generators.put(key, generator);
  }
  
  public VarService(ZineBuilder zineBuilder){
    put("noun", zineBuilder.new Noun());
    put("verb", zineBuilder.new Verb());
    put("keyword", zineBuilder.new KeywordService());
    put("definition", zineBuilder.new DictionaryService());
  }
  
  public String Get(String key){
    return Get(key, new XML(key));
  }
  
  public String Get(String key, XML xml){
    if (vars.containsKey(key)){
      return vars.get(key);
    } else if (generators.containsKey(key)){
      return generators.get(key).GetText(xml, this);
    } else {
      System.out.println("[VarService.Get] nothing for " + key);
      return null;
    }
  }
}