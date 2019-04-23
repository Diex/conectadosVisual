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
float scale = 1; //0.5;
Session s;
PImage layer_1;
Ani showVisitTimeout;
float showVisitTimeoutDummy;
boolean lastSession = false;

void setup() {
  
<<<<<<< HEAD
  planta.getChild("game_7").setVisible(false);
=======
  size(1920, 1080, P3D);
  //size(960, 540, P3D);
  noCursor();
  Ani.init(this);

  planta = loadShape(dataPath("plantasensores.svg")); 
  planta.scale(scale);

  layer_1 = loadImage("layer_1.png");
  
  //showAllChildren(planta);

>>>>>>> 9f318135fdae22c80c234633fc0aace5189a0a6f
  sessions = new ArrayList<Session>();

  db = new SQLite( this, "conectadxs_sqlite.db" );  // open database file
  oscP5 = new OscP5(this, 9999);

  createFonts();
  generateSessions();
}



void draw() {

  background(#00ABE8);
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


void generateSessions() {
  getNewSessions(sessions);
  for (Session session : sessions) {
    getVisitsForSession(session);
    session.createSessionVisualizations();
    session.visitorName = getVisitorName(session.sessionId);
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

boolean sessionExists(String s) {
  for (Session session : sessions) {
    if (session.equals(s)) return true;
  }    
  return false;
}

<<<<<<< HEAD
boolean draw = true;
int iterations = 0;
void draw() {
 // background(0);
  iterations++;
//  println(iterations);
  if(iterations >= 60*60){    
    iterations = 0;
=======

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/visitEnd")==true) {
    println(" typetag: "+theOscMessage.get(0).stringValue());
    newVisitor(theOscMessage.get(0).stringValue());
>>>>>>> 9f318135fdae22c80c234633fc0aace5189a0a6f
    //generateSessions();
  }
}


void newVisitor(String id) {
  if(lastSession) return;
  
  Session news = getSession(id);  
  news.createSessionVisualizations();
  news.visitorName = getVisitorName(news.sessionId);
  sessions.add(news); // el primero esta vacio..
  if(sessions.size() > 75) sessions.remove(0);
  s = news;
  lastSession = true;    
  showVisitTimeout = new Ani(this, 60, "showVisitTimeoutDummy", 0.0, Ani.LINEAR, "onEnd:OnShowVisitEnd");
}
