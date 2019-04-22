public class Visit{
  private long start;
  private long end = 0;
  private String gameId;
  private long MAX_TIME = 20000L; // segundos = 20 segundos...
  public color fillColor;
  
  public PVector center;
  public float alfa;
  public float alfaInc;
  public float radius;
  
  public Visit(long start, String gameId){
    this.start = start;    
    this.gameId = gameId;
  }
  
  public float getDuration(){
    return map( constrain(end - start, 0, MAX_TIME), 0, MAX_TIME, 0.0, 1.0);
  }
  
  public String getGameId(){
    return gameId;
  }  
  
  public void setEnd(long endTime){
    this.end = endTime;
  }
  
  public long getStart(){
    return start;
  }
}
