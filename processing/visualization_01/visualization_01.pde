import de.bezier.data.sql.*;
import de.bezier.data.sql.mapper.*;

public PShape planta;
SQLite db;
ArrayList<Session> sessions;
float scale = 0.22 * 1920.0/960.0;


void setup() {
 size(1920, 1080, P3D);
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


void generateSessions(){
  
  
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

float MAX_RADIUS = 100;

public void createSessionVisualizations(Session s) {

  color c = colors[(int) random(colors.length)]; //color(random(255), random(255), random(255));
  float radius = random(MAX_RADIUS);

  for (Visit v : s.visits) {
    v.radius = radius;
    float [] params = planta.getChild(v.gameId).getParams();    
    v.fillColor = c;
    PVector center = new PVector(XOFF + (params[0] * scale) + (params[2] * scale / 2), YOFF + (params[1] * scale) + (params[3] * scale / 2), random(radius) ); 
    
    v.center = center;
    v.alfa = random(TWO_PI);
    v.alfaInc = random(-.005, .005);
  }
}


boolean sessionExists(String s) {
  for (Session session : sessions) {
    if (session.equals(s)) return true;
  }    
  return false;
}
int XOFF = 50;
int YOFF = 50;

boolean draw = true;
int iterations = 0;
void draw() {
  background(0);
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



void renderSession(Session s) {
  for (Visit v : s.visits) {
    // HACK !!!
    if (v.gameId.equals("game_7")) continue;         
    float siz = v.getDuration();
    fill(v.fillColor, 250);
    noStroke();
    stroke(0, 125);
    v.alfa += v.alfaInc;
    //pushMatrix();
    //translate(0,0,v.center.z*2);
    ellipse(
    v.center.x + sin(v.alfa) * (v.radius + 0.1 * v.radius * noise(v.alfa)), 
    v.center.y + cos(v.alfa) * (v.radius + 0.1 * v.radius * noise(v.alfa)), 
    50 * siz, 50 * siz);
    //popMatrix();
  }
}
