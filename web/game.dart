import 'ai.dart';
import 'board.dart';
import 'dart:async';
import 'dart:math';
import 'gomoku.dart';

class Game {

  static final int BOARD_SIZE = 15;

  Board board;
  int playerTurn = 0;
  int playerWinner = -1;
  int remainingCounters = 1;
  int playerAi = 1;
  AI ai;
  bool aiHasChosen = false;
  DateTime startGameTime;
  MoveListener moveListener;

  Game(MoveListener moveListener) {
    this.moveListener = moveListener;
    board = new Board(BOARD_SIZE);
    ai = new AI(board, playerAi);
    playerTurn = 0;
    playerWinner = -1;
    remainingCounters = 1;
    var rng = new Random();
    playerAi = rng.nextInt(2);
    startGameTime = new DateTime.now();
  }

  void updateGame() {
    // Update game logic here.
    if (playerWinner < 0 && playerTurn == playerAi && !aiHasChosen) {
      List<int> aiMove = ai.doMove();
      aiHasChosen = true;
      //mouseHoverX = aiMove[0];
      //mouseHoverY = aiMove[1];

      new Future.delayed(new Duration(milliseconds: 500),
              () => performMove(aiMove[0], aiMove[1]));
    }
  }

  bool isComplete() {
    return (playerWinner >= 0);
  }

  void performMove(int x, int y) {
    int gameTime = new DateTime.now().difference(startGameTime).inMilliseconds;
    print("perform move $x, $y to $playerTurn at $gameTime");
    board.setCounterAt(x, y, playerTurn, gameTime);
    --remainingCounters;
    if (remainingCounters < 1) {
      remainingCounters = 1;
      ++playerTurn;
      if (playerTurn > 1) {
        playerTurn = 0;
      }
    }
    aiHasChosen = false;
    playerWinner = board.checkForWin();
    moveListener.moved();
  }

}

abstract class MoveListener{
  void moved();
}



