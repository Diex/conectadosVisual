import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import de.bezier.data.sql.*; 
import de.bezier.data.sql.mapper.*; 
import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class visualization_01 extends PApplet {




public PShape planta;
SQLite db;
ArrayList<Session> sessions;
float scale = 0.22f * 1920.0f/960.0f;


public void setup() {
 
 noCursor();
  planta = loadShape(dataPath("plantasensores2.svg")); 
  planta.scale(scale );
  println(planta.getChildCount());
  println(planta.getChild(1).getChildCount());

  PShape[] cosas = planta.getChild(1).getChildren();
  for (int i = 0; i < cosas.length; i ++) {
    println(cosas[i].getName());
  }
  
  planta.getChild("game_7").setVisible(false);


  sessions = new ArrayList<Session>();

  db = new SQLite( this, "conectadxs_sqlite.db" );  // open database file

  generateSessions();
  
  //background(#23B4F5);
  background(0);
  //background(255);
}


public void generateSessions(){
  
  
  if ( db.connect() ) {
    // list table names
    db.query( "SELECT * FROM visits ORDER BY ts ASC" );
    while (db.next()) {
      String session = db.getString("session"); 
      if (sessionExists(session)) {
      } else {
        if (sessions.size() > 3) sessions.remove(0);
        sessions.add(new Session(session));
      }
    }
    

    for (Session session : sessions) {
      println("+++++"+session.sessionId); 
      db.query( "SELECT * FROM visits WHERE session LIKE \""+session.sessionId +"\"" );
      while (db.next()) {
        String ts = db.getString("ts");
        String gameId = db.getString("gameId");

        session.visits.add(new Visit(Long.parseLong(ts), gameId));
      }
      session.sortVisits();
      createSessionVisualizations(session);
    }
  }
}

public void keyPressed (){
  generateSessions();
}

int[] colors = {
  0xff488DBA, 
  0xff2778AD, 
  0xff09639E, 
  0xff064E7D, 
  0xff043D62,
  0xff8CCDF7,
  0xff5FB9F4,
  0xff37A8F2,
  0xff0E95EC,
  0xff0484D7

};

float MAX_RADIUS = 100;

public void createSessionVisualizations(Session s) {

  int c = colors[(int) random(colors.length)]; //color(random(255), random(255), random(255));
  float radius = random(MAX_RADIUS);

  for (Visit v : s.visits) {
    v.radius = radius;
    float [] params = planta.getChild(v.gameId).getParams();    
    v.fillColor = c;
    PVector center = new PVector(XOFF + (params[0] * scale) + (params[2] * scale / 2), YOFF + (params[1] * scale) + (params[3] * scale / 2), random(radius) ); 
    
    v.center = center;
    v.alfa = random(TWO_PI);
    v.alfaInc = random(-.005f, .005f);
  }
}


public boolean sessionExists(String s) {
  for (Session session : sessions) {
    if (session.equals(s)) return true;
  }    
  return false;
}
int XOFF = 50;
int YOFF = 50;

boolean draw = true;
int iterations = 0;
public void draw() {
  iterations++;
//  println(iterations);
  if(iterations >= 60*60){
    
    iterations = 0;
    generateSessions();
  }
    
  fill(0,1);
  rect(-10,-10,width+10, height+10);
  //shape(planta, 50, 50);
  for (Session session : sessions) {
      renderSession(session);
    }  
}



public void renderSession(Session s) {
  for (Visit v : s.visits) {
    // HACK !!!
    if (v.gameId.equals("game_7")) continue; 
        
    float siz = v.getDuration();
    fill(v.fillColor, 18);
    noStroke();
    stroke(0, 5);
    v.alfa += v.alfaInc;
    //pushMatrix();
    //translate(0,0,v.center.z*2);
    ellipse(
    v.center.x + sin(v.alfa) * (v.radius + 0.1f * v.radius * noise(v.alfa)), 
    v.center.y + cos(v.alfa) * (v.radius + 0.1f * v.radius * noise(v.alfa)), 
    50 * siz, 50 * siz);
    //popMatrix();
  }
}
 

public class Session {

  private final String sessionId;
  ArrayList<Visit> visits;

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
    for(int i = 0; i < visits.size() - 1; i++){
      visits.get(i).setEnd(visits.get(i+1).getStart());
    }
    
    //visits.get(visits.size()-1).setEnd(visits.get(visits.size()-1).getStart() + 10000);
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
public class Visit{
  private long start;
  private long end = 0;
  private String gameId;
  private long MAX_TIME = 20000L; // segundos = 20 segundos...
  public int fillColor;
  
  public PVector center;
  public float alfa;
  public float alfaInc;
  public float radius;
  
  public Visit(long start, String gameId){
    this.start = start;    
    this.gameId = gameId;
  }
  
  public float getDuration(){
    return map( constrain(end - start, 0, MAX_TIME), 0, MAX_TIME, 0.0f, 1.0f);
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
  public void settings() {  size(1920, 1080, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--hide-stop", "visualization_01" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
