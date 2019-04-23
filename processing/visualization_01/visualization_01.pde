import de.bezier.data.sql.*;
import de.bezier.data.sql.mapper.*;

import oscP5.*;
import netP5.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
OscP5 oscP5;



public PShape planta;

SQLite db;
ArrayList<Session> sessions;
float scale = 0.5; //0.5; // 0.22 * 1920.0/960.0;
Session s;
PImage layer_1;

void setup() {

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

  //String lastVisitor = getLastVisitor();
  //println(lastVisitor);

  //s = getSession(convertData("﻿210ad481-162f-4868-a91c-71ab43439fce"));
  //createSessionVisualizations(s);
  //println(s.visits);
  //for (Visit v : s.visits) println(v.getDuration());
  //background(0);
  //println(s);
  //println( System.getProperty("file.encoding") );
}

boolean lastSession = false;

void draw() {
  background(#00ABE8);
  shape(planta, 0, 0);

  if(lastSession){
    renderSession(s, true);
  }else{
    
  for (Session session : sessions) {
    renderSession(session, false);
  } 
  }


  image(layer_1, 0, 0, width, height);
}

String convertData(String cualca) {
  String chinga = "";
  try {    
    byte[] originalBytes = cualca.getBytes(StandardCharsets.UTF_8);
    int count = 0;
    int value = -1;
    while(value < 0){
      value = originalBytes[count];
      count++;
    }
    
    for (byte b : originalBytes) {
      print(String.format("%02x", b) + " ");
    }
    println();
    for (byte b : originalBytes) {
      print(b + " " );
    }
    println();
    chinga = new String(Arrays.copyOfRange(originalBytes, count-1, originalBytes.length));  
  }
  catch (Exception e) {
    e.printStackTrace();
  }
  //println(chinga);
  return chinga;
}

public void keyPressed () {
  String[] ids = {
    "﻿44471264-fb0c-4756-87ee-f1580cf63f0d",
    "﻿f2a5f37f-3269-4aac-a14e-ac127087e08d",
    "﻿e0987ab5-4f67-403e-8007-a97ba427199c",
    "﻿1842476a-9eb1-405f-9ece-2491ca51db97",
    "﻿210ad481-162f-4868-a91c-71ab43439fce",
    "﻿e9976b70-1796-4832-a3bd-06e61e8e1258",
    "﻿23580d8f-d3f5-486c-91c9-312be9b22e74"};
    
  
  s = getSession(convertData(ids[(int) random(ids.length)]));
  createSessionVisualizations(s);   
  println(s.sessionId);
  println(s.visits);
  for (Visit v : s.visits) println(v.getDuration());
  println(s);
  lastSession = true;  
  //generateSessions();
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
    generateSessions();
  }
}
