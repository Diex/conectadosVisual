public PShape planta;

float scale = 0.5;

void setup(){
  size(960, 540);
   planta = loadShape(dataPath("plantasensores.svg")); 
}


void draw(){
  background(127);
shape(planta, 0, 0,planta.width * scale, planta.height * scale);

}
