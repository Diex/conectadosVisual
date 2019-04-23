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

public void createSessionVisualizations(Session s) {
  color c = colors[(int) random(colors.length)];   
  for (Visit v : s.visits) {    
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


int fillAlpha = 150;

void renderSession(Session s, boolean lastSession) {
  for (Visit v : s.visits) {    
    float siz = v.getDuration() * scale;
    fill(v.fillColor, fillAlpha);
    stroke(0, 150);    
    v.alfa += v.alfaInc;
    ellipse(
      v.center.x + sin(v.alfa) * (v.radius + 0.1 * v.radius * noise(v.alfa)), 
      v.center.y + cos(v.alfa) * (v.radius + 0.1 * v.radius * noise(v.alfa)), 
      50 * siz, 50 * siz);
  }
}
