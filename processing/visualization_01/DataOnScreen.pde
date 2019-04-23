PFont merlo;

void createFonts(){
  merlo = loadFont("MerloNeueRound-Bold-100.vlw");
}

int paddingX = 150;
int paddingY = 770;

void renderTexts(String... args){
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
