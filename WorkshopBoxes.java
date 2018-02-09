import java.util.Map;
import java.util.HashMap;

class WorkshopBoxes{
  
  public Map<String, WorkshopBox> boxes = new HashMap<String, WorkshopBox>();
  
  private static WorkshopBoxes instance;
  
  private WorkshopBoxes(ZineBuilder zineBuilder){
    boxes.put("helloworld", zineBuilder.new HelloWorld());
    boxes.put("threedee", zineBuilder.new ThreeDee());
  }
  
  public static WorkshopBoxes GetInstance(ZineBuilder zineBuilder){
    if (instance == null){
      instance = new WorkshopBoxes(zineBuilder);
    }
    return instance;
  }
}