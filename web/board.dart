
class Board { 
  int _size;
  List<int> _boardVal;
  List<num> _boardTime;
  int _remaining = 0;
  List<int> _winpos;
  
  Board(int size) {
    this._size = size;
    this._boardVal = new List(size*size);
    this._boardTime = new List(size*size);
    for(int i=0; i<_boardVal.length; ++i) {
      _boardVal[i] = -1;
      _boardTime[i] = -1.0;
      ++_remaining;
    }
  }
  
  int getSize() {
    return _size;
  }
  
  void setCounterAt(int x, int y, int val, num age) {
    int idx = x + y*_size;
    _boardVal[idx] = val;
    _boardTime[idx] = age;
    //print("setting board $x, $y to $val at $age" );
  }
  
  int counterValueAt(int x, int y) {
    if (x >= 0 && y >= 0 && x < _size && y < _size) {
      int idx = x + y*_size;
      return _boardVal[idx];
    }
    return -2;
  }
  
  num counterTimeAt(int x, int y) {
    if (x >= 0 && y >= 0 && x < _size && y < _size) {
      int idx = x + y*_size;
      return _boardTime[idx];
    }
    return 0;
  }

  bool isValidMove(int x, int y) {
    if (counterValueAt(x, y) == -1) {
      if (_remaining == _size*_size) {
        return (x == (_size-1)/2) && (y == (_size-1)/2);
      } else if (_remaining == _size*_size-2) {
        return !(x >= _size/3 && y >= _size/3 && x < _size*2/3 && y < _size*2/3);
      } else {
        return true;
      }
    } else {
      return false;
    }
  }
  
  int checkForWin() {
    _remaining = 0;
    int count;
    List<int> rcount = [0, 0];
    for(int x=0; x<_size; ++x) {
      for(int y=0; y<_size; ++y) {
        int val = counterValueAt(x, y);
        if (val < 0) {
          ++_remaining;
          continue;
        }
        if (rcount[val] < 5) {
          count = countCountersDirection(x, y, val, 1, 0);
          if (count <= 5 && count > rcount[val]) rcount[val] = count;
          if (count == 5) {
            _winpos = [x, y, x+4, y];
          }
        }
        if (rcount[val] < 5) {
          count = countCountersDirection(x, y, val, 0, 1);
          if (count <= 5 && count > rcount[val]) rcount[val] = count;
          if (count == 5) {
            _winpos = [x, y, x, y+4];
          }
        }
        if (rcount[val] < 5) {
          count = countCountersDirection(x, y, val, 1, 1);
          if (count <= 5 && count > rcount[val]) rcount[val] = count;
          if (count == 5) {
            _winpos = [x, y, x+4, y+4];
          }
        }
        if (rcount[val] < 5) {
          count = countCountersDirection(x, y, val, 1, -1);
          if (count <= 5 && count > rcount[val]) rcount[val] = count;
          if (count == 5) {
            _winpos = [x, y, x+4, y-4];
          }
        }
      }
    }
    
    //print("rcount : $rcount");
    if (rcount[0] == 5) {
      return 0;
    } else if (rcount[1] == 5) {
      return 1;
    } else {
      return -1;
    }
  }

  List<int> getWinPos() {
    return _winpos;
  }
  
  int countCountersDirection(int x, int y, int val, int dx, int dy) {
    int count = 1;
    do {
      x+=dx;
      y+=dy;
      if (x < 0 || y < 0 || x >=_size || y >= _size) return count;
      int cval = counterValueAt(x, y);
      if (cval == val) {
        ++count;
      } else {
        return count;
      }
    } while(true);
  }
  
  Board clone() {
    Board newBoard = new Board(this._size);
    newBoard._size = this._size;
    newBoard._remaining = this._remaining;
    for(int x=0; x<_size; ++x) {
      for(int y=0; y<_size; ++y) {
        newBoard.setCounterAt(x, y, counterValueAt(x, y), counterTimeAt(x, y));
      }      
    }
    return newBoard;
  }
}

