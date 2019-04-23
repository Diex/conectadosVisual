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
