import java.util.Map;
import java.util.HashMap;

class WorkshopBoxes{
  
  public Map<String, WorkshopBox> boxes = new HashMap<String, WorkshopBox>();
  
  private static WorkshopBoxes instance;
  
  private WorkshopBoxes(ZineBuilder zineBuilder){
    boxes.put("helloworld", zineBuilder.new HelloWorld());
    boxes.put("threedee", zineBuilder.new ThreeDee());
    boxes.put("body", zineBuilder.new WorkshopBody());
    boxes.put("image", zineBuilder.new WorkshopImage());
    boxes.put("JoshuaExample", zineBuilder.new JoshuaExample());
    boxes.put("JoshuaExampleFullBleed", zineBuilder.new JoshuaExampleFullBleed());
    boxes.put("JoshuaExampleFullSpread", zineBuilder.new JoshuaExampleFullSpread());
    boxes.put("JoshuaZinewave", zineBuilder.new JoshuaZinewave());
  }
  
  public static WorkshopBoxes GetInstance(ZineBuilder zineBuilder){
    if (instance == null){
      instance = new WorkshopBoxes(zineBuilder);
    }
    return instance;
  }
}