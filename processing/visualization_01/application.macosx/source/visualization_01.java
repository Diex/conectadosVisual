import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import de.bezier.data.sql.*; 
import de.bezier.data.sql.mapper.*; 
import oscP5.*; 
import netP5.*; 
import java.nio.charset.StandardCharsets; 
import java.nio.file.Files; 
import java.nio.file.Paths; 
import java.util.List; 
import de.looksgood.ani.*; 
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












OscP5 oscP5;



public PShape planta;

SQLite db;
ArrayList<Session> sessions;
float scale = 1; //0.5;
Session s;
PImage layer_1;
Ani showVisitTimeout;
float showVisitTimeoutDummy;
boolean lastSession = false;

public void setup() {
  
  
  //size(960, 540, P3D);
  noCursor();
  Ani.init(this);

  planta = loadShape(dataPath("plantasensores.svg")); 
  planta.scale(scale);

  layer_1 = loadImage("layer_1.png");
  
  //showAllChildren(planta);

  sessions = new ArrayList<Session>();

  db = new SQLite( this, "conectadxs_sqlite.db" );  // open database file
  oscP5 = new OscP5(this, 9999);

  createFonts();
  generateSessions();
}



public void draw() {

  background(0xff00ABE8);
  shape(planta, 0, 0);

  if (lastSession) {
    s.renderSession(true);
    renderTexts("Estas viendo la visita \nde: " + s.visitorName);
  } else {
    for (Session session : sessions) {
      session.renderSession(false);
    }
    renderTexts(
      "Hoy ya pasaron " + sessions.size() + " visitantes");
  }

  image(layer_1, 0, 0, width, height);
}


public void generateSessions() {
  getNewSessions(sessions);
  for (Session session : sessions) {
    getVisitsForSession(session);
    session.createSessionVisualizations();
    session.visitorName = getVisitorName(session.sessionId);
  }
}

public String convertData(String cualca) {
  String chinga = "";
  try {    
    byte[] originalBytes = cualca.getBytes(StandardCharsets.UTF_8);
    int count = 0;
    int value = -1;
    while (value < 0) {
      value = originalBytes[count];
      count++;
    }
    //for (byte b : originalBytes) {
    //  print(String.format("%02x", b) + " ");
    //}
    //println();
    //for (byte b : originalBytes) {
    //  print(b + " " );
    //}
    //println();
    chinga = new String(Arrays.copyOfRange(originalBytes, count-1, originalBytes.length));
  }
  catch (Exception e) {
    e.printStackTrace();
  }
  return chinga;
}

public void keyPressed () {
  if (key != ' ') return;
  String[] ids = {
    "﻿44471264-fb0c-4756-87ee-f1580cf63f0d", 
    "﻿f2a5f37f-3269-4aac-a14e-ac127087e08d", 
    "﻿e0987ab5-4f67-403e-8007-a97ba427199c", 
    "﻿1842476a-9eb1-405f-9ece-2491ca51db97", 
    "﻿210ad481-162f-4868-a91c-71ab43439fce", 
    "﻿e9976b70-1796-4832-a3bd-06e61e8e1258", 
    "﻿23580d8f-d3f5-486c-91c9-312be9b22e74"};

  newVisitor(convertData(ids[(int) random(ids.length)]));
}

public void OnShowVisitEnd() {
  lastSession = false;
}

public boolean sessionExists(String s) {
  for (Session session : sessions) {
    if (session.equals(s)) return true;
  }    
  return false;
}


public void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/visitEnd")==true) {
    println(" typetag: "+theOscMessage.get(0).stringValue());
    newVisitor(theOscMessage.get(0).stringValue());
    //generateSessions();
  }
}


public void newVisitor(String id) {
  if(lastSession) return;
  
  Session news = getSession(id);  
  news.createSessionVisualizations();
  news.visitorName = getVisitorName(news.sessionId);
  sessions.add(news); // el primero esta vacio..
  if(sessions.size() > 75) sessions.remove(0);
  s = news;
  lastSession = true;    
  showVisitTimeout = new Ani(this, 60, "showVisitTimeoutDummy", 0.0f, Ani.LINEAR, "onEnd:OnShowVisitEnd");
}

PFont merlo;

public void createFonts(){
  merlo = loadFont("MerloNeueRound-Bold-100.vlw");
}

int paddingX = 150;
int paddingY = 770;

public void renderTexts(String... args){
  pushStyle();
  pushMatrix();
  textFont(merlo);  
  translate(paddingX*scale, paddingY*scale);
  
  if(args[0] != null){    
    textSize(60*scale);
    fill(255,255);
    text(args[0], 0,0);
  }
  
  //if(args.length() > 1 && args[1] != null){
    
  //translate(0, textAscent()+textDescent());
  //textSize(48*scale);
  //fill(255,255);
  //text(args[1], 0,0);
  //}
  
  popMatrix();
  popStyle();
}

int __childDepth = 1;

public void showAllChildren(PShape mc)
{
    int numC = mc.getChildCount();
    String tabStr = "";

    for (int t = 0; t < __childDepth; t++)
    {
        tabStr = tabStr + "\t";
    }

    for(int i = 0; i < numC; i++)
    {
        PShape child = mc.getChild(i); 
        
        println(tabStr + "|" + __childDepth + "|" + mc.getChild(i).getName());

        if (child.getChildCount() > 0)
        {
            __childDepth ++;
            showAllChildren(child);
            __childDepth --;
        }
    }
}

public String getLastVisitor() {
  String lastSessionId = null;

  if ( db.connect() ) {
    db.query("SELECT COUNT(*) FROM visitors");
    db.next();
    int qty = db.getInt(1);
    println("Number of rows: " + qty);    
    //SELECT name FROM UnknownTable WHERE rowid = 1;
    db.query( "SELECT * FROM visitors WHERE rowid =" + qty);
    db.next();
    lastSessionId = db.getString("session");
  }
  db.close();
  return lastSessionId;
}

public String getVisitorName(String id) {
  String userName = "";

  if ( db.connect() ) {
    db.query("SELECT * FROM visitors WHERE session LIKE \""+ id +"\"");
    if (db.next()) {
      userName = db.getString("name");
    } else {
      userName = "Anónimo";
    }
  }
  //println(id, userName);
  db.close();
  return userName;
}

public void getVisitsForSession(Session session) {
  if (db.connect()) {
    db.query( "SELECT * FROM visits WHERE session LIKE \""+session.sessionId +"\"" );
    while (db.next()) {
      String ts = db.getString("ts");
      String gameId = db.getString("gameId");
      session.visits.add(new Visit(Long.parseLong(ts), gameId));
    }
  }
  db.close();
  session.sortVisits();
  session.createSessionVisualizations();
}

public void getNewSessions(ArrayList sessions) {

  if ( db.connect() ) {
    //db.query( "SELECT * FROM visits ORDER BY ts ASC" );    
    db.query( "SELECT * FROM visitors ORDER BY visitDate DESC LIMIT 10" );
    while (db.next()) {
      String session = db.getString("session");
      println("addNewSessions: " + session);
      // TODO hacer que el campo session en la tabla sea UNIQUE
      if (sessionExists(session)) {
        continue;
      } else {
        //if (sessions.size() > 20) sessions.remove(0);
        sessions.add(new Session(session));
      }
    }
  }else{
    println("db not connected");
  }
  db.close();
}

public Session getSession(String sessionId) {  
  Session s = new Session(sessionId);

  if ( db.connect() ) {       
    db.query( "SELECT * FROM visits WHERE session LIKE \""+s.sessionId +"\"" );
    println("query...");
    println(db.result);
    while (db.next()) {
      String ts = db.getString("ts");
      String gameId = db.getString("gameId");
      s.visits.add(new Visit(Long.parseLong(ts), gameId));
    }
    s.sortVisits();
  } else {
    println("cant connect");
  }

  db.close();
  return s;
}

 

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

  public void createSessionVisualizations() {
    int c = colors[(int) random(colors.length)];   
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
      v.alfaInc = random(-.001f, .001f);
    }
  }

  public void renderSession(boolean show) {
    pushStyle();
    for (Visit v : this.visits) {    
      float siz = v.getDuration() * scale;
      fill(v.fillColor, fillAlpha);
      stroke(0, 150);    
      v.alfa += v.alfaInc;
      v.currentPosition.x = v.center.x + sin(v.alfa) * (v.radius + 0.1f * v.radius * noise(v.alfa));
      v.currentPosition.y = v.center.y + cos(v.alfa) * (v.radius + 0.1f * v.radius * noise(v.alfa));
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

public class Visit{
  private long start;
  private long end = 0;
  private String gameId;
  private long MAX_TIME = 20000L; // segundos = 20 segundos...
  public int fillColor;
  
  public PVector center;
  public PVector currentPosition;
  public float alfa;
  public float alfaInc;
  public float radius;
  
  public Visit(long start, String gameId){
    this.start = start;    
    this.gameId = gameId;
    this.currentPosition = new PVector();
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
    String[] appletArgs = new String[] { "--present", "--window-color=#000000", "--hide-stop", "visualization_01" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
