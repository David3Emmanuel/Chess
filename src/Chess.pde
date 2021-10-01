Board board;
float w;

color LIGHT = color(255,190,140);
color DARK = color(100,70,40);

HashMap<String,PImage> piecesImg;

void setup() {
  size(720,800);
  
  String[] piecesStr = new String[]
              {"bB","bK","bN","bP","bQ","bR",
               "wB","wK","wN","wP","wQ","wR"};
  piecesImg = new HashMap<String,PImage>();
  for (int i=0;i<12;i++) {
    piecesImg.put(piecesStr[i], loadImage(piecesStr[i]+".png"));
  }
  
  w = min(width,height)/8;
  board = new Board();
}

void mousePressed() {
  board.update(mouseX,mouseY);
}

void draw() {
  background(200,200,100);
  board.show();
}