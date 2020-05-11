import 'board.dart';

class AI {
  Board _board;
  int _plr;
  int _nplr;
  
  AI(this._board, this._plr) {
    if (_plr == 0) {
      _nplr = 1;
    } else {
      _nplr = 0;
    }
  }
  
  List<int> doMove() {
    int bestX = -1;
    int bestY = -1;
    num bestScore = null;
    Board newBoard = _board.clone();
    for(int x=0; x<_board.getSize(); ++x) {
      for(int y=0; y<_board.getSize(); ++y) {
        if (newBoard.isValidMove(x, y)) {
          newBoard.setCounterAt(x, y, _plr, 0);
          num score = calcScore(newBoard);
          //print("AI move $x,$y score $score");
          if (bestScore == null || score > bestScore) {
            bestScore = score;
            bestX = x;
            bestY = y;
          }
          newBoard.setCounterAt(x, y, -1, 0);
        }
      }
    }
    print("AI found best move $bestX,$bestY score $bestScore");
    return [bestX, bestY];
  }
  
  num calcScore(Board board) {
    num score = 0;
    for(int x=0; x<board.getSize(); ++x) {
      for(int y=0; y<board.getSize(); ++y) {
        int val = board.counterValueAt(x, y);
        if (val < 0) {
          continue;
        }
        score -= (x-board.getSize()/2).abs();
        score -= (y-board.getSize()/2).abs();
        int count;
        count = board.countCountersDirection(x, y, val, 1, 0);
        if (board.counterValueAt(x-1, y) == -1 || board.counterValueAt(x+count, y) == -1) {
          score += (val==_plr) ? (count*count) : -1.2*(count*count);
        }
        count = board.countCountersDirection(x, y, val, 0, 1);
        if (board.counterValueAt(x, y-1) == -1 || board.counterValueAt(count, y+count) == -1) {
          score += (val==_plr) ? (count*count) : -1.2*(count*count);
        }
        count = board.countCountersDirection(x, y, val, 1, 1);
        if (board.counterValueAt(x-1, y-1) == -1 || board.counterValueAt(count+count, y+count) == -1) {
          score += (val==_plr) ? (count*count) : -1.2*(count*count);
        }
        count = board.countCountersDirection(x, y, val, 1, -1);
        if (board.counterValueAt(x-1, y+1) == -1 || board.counterValueAt(count+count, y-count) == -1) {
          score += (val==_plr) ? (count*count) : -1.2*(count*count);
        }
      }
    }
    return score;
  }
  
  
}