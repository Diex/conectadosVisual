import de.bezier.data.sql.*;
import de.bezier.data.sql.mapper.*;

import oscP5.*;
import netP5.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

import de.looksgood.ani.*;
OscP5 oscP5;



public PShape planta;

SQLite db;
ArrayList<Session> sessions;
float scale = 0.5; //0.5; // 0.22 * 1920.0/960.0;
Session s;
PImage layer_1;
Ani showVisitTimeout;
float showVisitTimeoutDummy;
void setup() {

  // Ani.init() must be called always first!
  Ani.init(this);
 
   
  //size(1920, 1080, P3D);
  size(960, 540, P3D);
  noCursor();

  planta = loadShape(dataPath("plantasensores.svg")); 
  planta.scale(scale);

  layer_1 = loadImage("layer_1.png");
  showAllChildren(planta);

  sessions = new ArrayList<Session>();

  db = new SQLite( this, "conectadxs_sqlite.db" );  // open database file
  generateSessions();
  oscP5 = new OscP5(this, 9999);
  
  createFonts();
}

boolean lastSession = false;

void draw() {
  background(#00ABE8);
  shape(planta, 0, 0);

  if (lastSession) {
    s.renderSession();
    renderTexts("Estas viendo la visita de: " + s.visitorName);
  } else {

    for (Session session : sessions) {
      session.renderSession();
    }
    
    renderTexts(
    "Hoy pasaron " + sessions.size() + " visitantes", 
    "");
  }
  
  

  
  image(layer_1, 0, 0, width, height);
}


void generateSessions(){
  addNewSessions(sessions);
  for (Session session : sessions) {
    getVisitsForSession(session);
    session.createSessionVisualizations();
  }
}

String convertData(String cualca) {
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
  if(key != ' ') return;
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

public void OnShowVisitEnd(){
    lastSession = false;

}

boolean sessionExists(String s) {
  for (Session session : sessions) {
    if (session.equals(s)) return true;
  }    
  return false;
}


void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/visitEnd")==true) {
    println(" typetag: "+theOscMessage.get(0).stringValue());
    newVisitor(theOscMessage.get(0).stringValue());
    //generateSessions();
  }
}


void newVisitor(String id){
 
  if(s != null) sessions.add(s); // el primero esta vacio..
  //Session news = getSession();
    Session news = getSession(id);
  //createSessionVisualizations(news);  
  news.createSessionVisualizations();
  news.visitorName = getVisitorName(news.sessionId);
  s = news;
  lastSession = true;    
  showVisitTimeout = new Ani(this, 5.0, "showVisitTimeoutDummy", 0.0, Ani.LINEAR, "onEnd:OnShowVisitEnd"); 

}
