import java.util.Map;
import java.util.HashMap;

class WorkshopTexts{
  
  public Map<String, WorkshopText> texts = new HashMap<String, WorkshopText>();
  
  private static WorkshopTexts instance;
  
  private WorkshopTexts(ZineBuilder zineBuilder){
    texts.put("noun", zineBuilder.new Noun());
    texts.put("verb", zineBuilder.new Verb());
  }
  
  public static WorkshopTexts GetInstance(ZineBuilder zineBuilder){
    if (instance == null){
      instance = new WorkshopTexts(zineBuilder);
    }
    return instance;
  }
}