class Board {
  Piece[][] pieces;
  Tuple first, last;
  char player;

  boolean[][] moved;
  ArrayList<Tuple> available;

  Board() {
    player = 'w';
    setPieces();

    moved = new boolean[8][8];
    for (int i=0; i<8; i++) {
      for (int j=0; j<8; j++) {
        if (pieces[i][j] != null) {
          moved[i][j] =false;
        }
      }
    }
    available = new ArrayList<Tuple>();
  }

  void update(float x, float y) {
    available = new ArrayList<Tuple>();
    if (first == null) {
      first = new Tuple(y/w, x/w);
      Piece p = pieces[first.i][first.j];
      if (p == null) {
        first = null;
      } else if (pieces[first.i][first.j].colr != player) {
        first = null;
      } else {
        checkSpots();
      }
    } else if (last == null) {
      last = new Tuple(y/w, x/w);
      if (valid(first,last)) {
        if (pieces[first.i][first.j].type=='K' && castling(first,last)) {
          int dx = last.j - first.j;
          int j = (dx<0)?0:7;
          Piece rook = pieces[first.i][j];
          pieces[first.i][j] = null;
          j = first.j + (dx/2);
          pieces[first.i][j] = rook;
        }
        
        pieces[last.i][last.j] = pieces[first.i][first.j];
        pieces[first.i][first.j] = null;
        player = player=='w'?'b':'w';
        moved[first.i][first.j] = true;
//        moved[last.i][last.j] = true;
      } else {
        first = null;
        last = null;
        update(x, y);
      }
    } else {
      first = null;
      last = null;
      update(x, y);
    }
  }
  
  void checkSpots() {
    for (int i=0;i<8;i++) {
      for (int j=0;j<8;j++) {
        Tuple last = new Tuple(i,j);
        if (valid(first,last)) {
          available.add(last);
        }
      }
    }
  }

  boolean valid(Tuple first,Tuple last) {
    Piece firstPiece = pieces[first.i][first.j];
    Piece lastPiece = pieces[last.i][last.j];

    boolean possible = (lastPiece == null) ||
        (firstPiece.colr != lastPiece.colr);
    if (possible) {
      if (checkMove(first,last)) {
        if (firstPiece.type=='K' && castling(first,last)) {
          return true;
        } else {
          return !jump(first,last);
        }
      }
    }
    return false;
  }

  boolean checkMove(Tuple first,Tuple last) {
    Piece firstPiece = pieces[first.i][first.j];
    Piece lastPiece = pieces[last.i][last.j];

    int dx = last.j - first.j;
    int dy = last.i - first.i;

    char c = firstPiece.colr;

    if (firstPiece.type == 'K') {
      if (castling(first,last)) {
        return true;
      } else {
        return (dx>=-1 && dx<=1) && (dy>=-1 && dy<=1);
      }
    } else if (firstPiece.type == 'R') {
      return (dx==0 || dy==0);
    } else if (firstPiece.type == 'B') {
      return (abs(dx) == abs(dy));
    } else if (firstPiece.type == 'Q') {
      return (dx==0 || dy==0) || (abs(dx) == abs(dy));
    } else if (firstPiece.type == 'N') {
      return (abs(dx)==1 && abs(dy)==2) || (abs(dy)==1 && abs(dx)==2);
    } else if (firstPiece.type == 'P') {
      if ((dy>0&&c=='w')||(dy<0&&c=='b')) {
        return false;
      } else if (dx == 0) {
        if (lastPiece != null) {
          return false;
        } else if (abs(dy)==1) {
          return true;
        } else if (abs(dy) == 2) {
          int row = first.i;
          return (row==1) || (row==6);
        } else {
          return false;
        }
      } else if (abs(dx) == 1) {
        if (abs(dy) == 1) {
          if (lastPiece == null) {
            return enPassant(first,last);
          } else {
            return firstPiece.colr != lastPiece.colr;
          }
        }
      } else {
        return false;
      }
    }

    return false;
  }

  boolean jump(Tuple first,Tuple last) {
    int dx = last.j - first.j;
    int dy = last.i - first.i;

    if (dx == 0) {
      for (int i=min(first.i, last.i)+1; i<max(first.i, last.i); i++) {
        if (pieces[i][first.j] != null) {
          return true;
        }
      }
    } else if (dy == 0) {
      for (int j=min(first.j, last.j)+1; j<max(first.j, last.j); j++) {
        if (pieces[first.i][j] != null) {
          return true;
        }
      }
    } else if (abs(dx) == abs(dy)) {
      for (int d=1; d<abs(dy); d++) {
        int i = first.i + d*(dy/abs(dy));
        int j = first.j + d*(dx/abs(dx));
        if (pieces[i][j] != null) {
          return true;
        }
      }
    } else {
      return false;
    }

    return false;
  }

  boolean castling(Tuple first,Tuple last) {
    int dx = last.j - first.j;
    int dy = last.i - first.i;

    if (dy != 0) {
      return false;
    } else if (moved[first.i][first.j]) {
      return false;
    } else if (abs(dx)==2) {
      int j = (dx<0)?0:7;
      Piece rook = pieces[first.i][j];
      Piece king = pieces[first.i][first.j];
      if (rook == null) {
        return false;
      } else {
        boolean castle = (!moved[first.i][j])&&
          rook.type=='R'&&rook.colr==king.colr;
        return castle;
      }
    }

    return false;
  }

  boolean enPassant(Tuple first,Tuple last) {
    int dx = last.j - first.j;
    int dy = last.i - first.i;

    int j = first.j+dx;
    Piece firstPiece = pieces[first.i][first.j];
    Piece captured = pieces[first.i][j];
    
    if (captured == null) {
      return false;
    } else if (captured.colr != firstPiece.colr) {
      boolean pieceMoved = moved[first.i+dy][j];
      if (!pieceMoved) {
        pieces[first.i][j] = null;
        return true;
      }
    }

    return false;
  }

  void setPieces() {
    pieces = new Piece[8][8];

    pieces[0][0] = new Piece("bR");
    pieces[0][1] = new Piece("bN");
    pieces[0][2] = new Piece("bB");
    pieces[0][3] = new Piece("bQ");
    pieces[0][4] = new Piece("bK");
    pieces[0][5] = new Piece("bB");
    pieces[0][6] = new Piece("bN");
    pieces[0][7] = new Piece("bR");

    pieces[1][0] = new Piece("bP");
    pieces[1][1] = new Piece("bP");
    pieces[1][2] = new Piece("bP");
    pieces[1][3] = new Piece("bP");
    pieces[1][4] = new Piece("bP");
    pieces[1][5] = new Piece("bP");
    pieces[1][6] = new Piece("bP");
    pieces[1][7] = new Piece("bP");

    pieces[6][0] = new Piece("wP");
    pieces[6][1] = new Piece("wP");
    pieces[6][2] = new Piece("wP");
    pieces[6][3] = new Piece("wP");
    pieces[6][4] = new Piece("wP");
    pieces[6][5] = new Piece("wP");
    pieces[6][6] = new Piece("wP");
    pieces[6][7] = new Piece("wP");

    pieces[7][0] = new Piece("wR");
    pieces[7][1] = new Piece("wN");
    pieces[7][2] = new Piece("wB");
    pieces[7][3] = new Piece("wQ");
    pieces[7][4] = new Piece("wK");
    pieces[7][5] = new Piece("wB");
    pieces[7][6] = new Piece("wN");
    pieces[7][7] = new Piece("wR");
  }

  void show() {
    drawBoard();
    for (int i=0; i<8; i++) {
      for (int j=0; j<8; j++) {
        Piece p = pieces[i][j];
        if (p != null) {
          pieces[i][j].show(i, j);
        }
      }
    }
    fill(0,255,0,150);
    for (Tuple spot:available) {
      ellipse(spot.j*w+w/2,spot.i*w+w/2,w/2,w/2);
    }
  }

  void drawBoard() {
    noStroke();
    color c = DARK;
    for (int i=0; i<8; i++) {
      if (c == LIGHT) {
        c = DARK;
      } else {
        c = LIGHT;
      }
      for (int j=0; j<8; j++) {
        fill(c);
        rect(j*w, i*w, w, w);
        if (c == LIGHT) {
          c = DARK;
        } else {
          c = LIGHT;
        }
      }
    }

    if (first != null) {
      fill(255, 255, 0);
      rect(first.j*w, first.i*w, w, w);
    }
    if (last != null) {
      fill(0, 255, 0);
      rect(last.j*w, last.i*w, w, w);
    }
    fill(255,0,0,150);
    for (Tuple spot:available) {
      if (pieces[spot.i][spot.j] != null) {
        rect(spot.j*w,spot.i*w,w,w);
      }
    }
  }
}
