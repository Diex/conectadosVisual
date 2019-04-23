import java.util.*; 

public class Session {

  private final String sessionId;
  ArrayList<Visit> visits;
  String visitorName;

  public Session(String sessionId) {
    this.sessionId = sessionId;
    visits = new ArrayList<Visit>();
  }


  @Override
    public boolean equals(Object obj) 
  {       
    return this.sessionId.equals((String) obj);
  }

  public void sortVisits() {
    Collections.sort(visits, new SortByTime()); 
    for (int i = 0; i < visits.size() - 1; i++) {
      visits.get(i).setEnd(visits.get(i+1).getStart());
    }
  }

  int fillAlpha = 150;
  float MAX_RADIUS = 50;
  int XOFF = 0;
  int YOFF = 0;
  color[] colors = {
    #488DBA, 
    #2778AD, 
    #09639E, 
    #064E7D, 
    #043D62, 
    #8CCDF7, 
    #5FB9F4, 
    #37A8F2, 
    #0E95EC, 
    #0484D7

  };

  public void createSessionVisualizations() {
    color c = colors[(int) random(colors.length)];   
    for (Visit v : this.visits) {    
      float [] params = planta.getChild(v.gameId).getParams();    
      v.fillColor = c;    
      float gameLoc_x = (params[0] * scale) + (params[2] * scale / 2);
      float gameLoc_y = (params[1] * scale) + (params[3] * scale / 2);

      PVector center = new PVector(
        XOFF + gameLoc_x, 
        YOFF + gameLoc_y); 

      v.radius = v.getDuration() * MAX_RADIUS * scale;
      v.center = center;
      v.alfa = random(TWO_PI);
      v.alfaInc = random(-.001, .001);
    }
  }

  void renderSession(boolean show) {
    pushStyle();
    for (Visit v : this.visits) {    
      float siz = v.getDuration() * scale;
      fill(v.fillColor, fillAlpha);
      stroke(0, 150);    
      v.alfa += v.alfaInc;
      v.currentPosition.x = v.center.x + sin(v.alfa) * (v.radius + 0.1 * v.radius * noise(v.alfa));
      v.currentPosition.y = v.center.y + cos(v.alfa) * (v.radius + 0.1 * v.radius * noise(v.alfa));
      ellipse(
        v.currentPosition.x, 
        v.currentPosition.y, 
        50 * siz, 50 * siz);
    }
    if(show){
      beginShape();
      noFill();
      strokeWeight(10);
      stroke(255, 200);
      for (Visit v : this.visits) {
        curveVertex(v.currentPosition.x, v.currentPosition.y);        
      }
      endShape();
    }
    popStyle();
  }
}

class SortByTime implements Comparator<Visit> 
{ 
  // Used for sorting in ascending order of 
  // roll number 
  public int compare(Visit a, Visit b) 
  { 
    return (int) (a.start - b.start);
  }
}
