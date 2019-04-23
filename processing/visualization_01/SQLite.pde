
String getLastVisitor() {
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

String getVisitorName(String id){
  String userName = "";
  
  if ( db.connect() ) {
    db.query("SELECT * FROM visitors WHERE session LIKE \""+ id +"\"");
    if(db.next()){
      userName = db.getString("name");
    }else{
      userName = "Anónimo";
    }    
  }
  //println(id, userName);
  db.close();
  return userName;
}

void generateSessions() {
  if ( db.connect() ) {
    // list table names
    db.query( "SELECT * FROM visits ORDER BY ts ASC" );
    while (db.next()) {
      String session = db.getString("session"); 
      if (sessionExists(session)) {
      } else {
        if (sessions.size() > 20) sessions.remove(0);
        sessions.add(new Session(session));
      }
    }


    for (Session session : sessions) {
      println(session.sessionId); 
      db.query( "SELECT * FROM visits WHERE session LIKE \""+session.sessionId +"\"" );
      while (db.next()) {
        String ts = db.getString("ts");
        String gameId = db.getString("gameId");
        session.visits.add(new Visit(Long.parseLong(ts), gameId));
      }
      session.sortVisits();
      createSessionVisualizations(session);
    }
    
    for (Session session : sessions) {
      String s = getVisitorName(session.sessionId);
      println(session.sessionId, s);
      session.visitorName = s; 
    }
  }
}


Session getSession(String sessionId) {  
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
  }else{
    println("cant connect");
  }

  db.close();
  return s;
}
