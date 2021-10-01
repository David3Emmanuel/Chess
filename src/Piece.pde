class Piece {
//  int i,j;
 char colr, type;
 String id;
  
  Piece(String id) {
//    this.i = i;
//    this.j = j;
    
    this.colr = id.charAt(0);
    this.type = id.charAt(1);
    this.id = id;
  }
  
  void show(int i,int j) {
    PImage img = piecesImg.get(id);
    image(img,j*w,i*w,w,w);
  }
}

class Tuple {
  int i,j;
  
  Tuple(int i,int j) {
    this.i = i;
    this.j = j;
  }
  
  Tuple(float i,float j) {
    this.i = floor(i);
    this.j = floor(j);
  }
}