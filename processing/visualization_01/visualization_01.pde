import de.bezier.data.sql.*;
import de.bezier.data.sql.mapper.*;

PShape planta ;
SQLite db;
  
void setup(){
  size(960, 540);
  planta =  loadShape("planta sensores.svg");
  planta.scale(0.22);
  println(planta.getChildCount());
  
  db = new SQLite( this, "conectadxs_sqlite.db" );  // open database file
  
  if ( db.connect() ) {
          // list table names
          db.query( "SELECT * FROM visits" );
          
          while (db.next()) 
              System.out.println( db.getString("gameId") );
          
          //// read all in table "table_one"
          //db.query( "SELECT * FROM table_one" );
          
          //while (db.next()) 
          //    System.out.println( db.getString("field_one") + "\n" + db.getInt("field_two") );
      }
      
}

void draw(){
  background(255);
  
  shape(planta, 50,50);
  //planta.getChild("base").setVisible(false);
  planta.getChild("game_7").setVisible(false);
  //planta.getChild("game_2").setVisible(false);

}
