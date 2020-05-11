import 'board.dart';
import 'button.dart';
import 'dart:html';
import 'game.dart';

class Renderer {

  static final int HEADER_PX = 40;
  static final int FOOTER_PX = 32;

  static final int ID_BUTTON_PLAY = 0;
  static final int ID_BUTTON_RESTART = 1;

  CanvasElement _canvasElement;
  CanvasRenderingContext2D _context;
  Map<String, ImageElement> _imageMap;
  int _squarePixelsSize;
  bool _animating = false;
  int _boardSize;

  Renderer(CanvasElement canvasElement, CanvasRenderingContext2D context, Map<String, ImageElement> imageMap, int boardSize) {
    this._canvasElement = canvasElement;
    this._context = canvasElement.context2D;
    this._imageMap = imageMap;
    this._boardSize = boardSize;
    this._squarePixelsSize = canvasElement.width ~/ (boardSize + 2);
  }

  void renderBackground() {
    //context.clearRect(0, 0, context.canvas.width, context.canvas.height);
    CanvasGradient gradient = _context.createLinearGradient(_canvasElement.width/3, 0, _canvasElement.width*2/3, _canvasElement.height);
    gradient.addColorStop(0, '#0C0');
    gradient.addColorStop(0.5, '#0F0');
    gradient.addColorStop(1, '#0C0');
    _context.fillStyle = gradient;
    _context.fillRect(0, 0, _canvasElement.width, _canvasElement.height);
    _context.save();
  }

  void renderScreenLoading() {
    _context.fillText("Loading...", _canvasElement.width/2, _canvasElement.height/2, 200);
  }

  void renderScreenIntro() {
    //show header panel
    num tx = (_canvasElement.width - _imageMap['title'].width)/2;
    _context.drawImage(_imageMap['title'], tx, _canvasElement.height/4);
    _context.textAlign = 'center';
    _context.font = "12px Arial";
    _context.setStrokeColorRgb(0, 0, 0);
    _context.setFillColorRgb(0, 0, 0);
    int y = _canvasElement.height * 8 ~/ 10;
    _context.strokeText("A five-in-a-row game written in Dart", _canvasElement.width/2, y);
    y+=20;
    _context.strokeText("SteveP 2013-2020", _canvasElement.width/2, y);
  }

  List<int> counterAt(int px, int py) {
    List pos = new List<int>(2);
    pos[0] = (px ~/ _squarePixelsSize - 1);
    pos[1] = ((py - HEADER_PX) ~/ _squarePixelsSize - 1);
    if (pos[0] >= 0 && pos[1] >= 0 && pos[0] < _boardSize && pos[1] < _boardSize) {
      return pos;
    } else {
      return null;
    }
  }

  num squarePosX(int x) {
    return _squarePixelsSize * (x + 1);
  }

  num squarePosY(int y) {
    return _squarePixelsSize * (y + 1) + HEADER_PX;
  }

  void renderScreenGame(Game game) {
    //draw grid lines
    Board board = game.board;
    num minX = squarePosX(0);
    num maxX = squarePosX(board.getSize());
    num minY = squarePosY(0);
    num maxY = squarePosY(board.getSize());
    _context.beginPath();
    _context.setStrokeColorRgb(128, 128, 128);
    _context.lineWidth = 1;
    for (int c=0; c<board.getSize(); ++c) {
      _context.moveTo(squarePosX(c) + _squarePixelsSize/2, minY);
      _context.lineTo(squarePosX(c) + _squarePixelsSize/2, maxY);
      _context.moveTo(minX, squarePosY(c) + _squarePixelsSize/2);
      _context.lineTo(maxX, squarePosY(c) + _squarePixelsSize/2);
    }
    _context.closePath();
    _context.stroke();

    //draw counters
    bool animating = false;
    for (int y=0; y<board.getSize(); ++y) {
      for (int x=0; x<board.getSize(); ++x) {
        num xc = squarePosX(x) + (_squarePixelsSize/2);
        num yc = squarePosY(y) + (_squarePixelsSize/2);
        int gameTime = new DateTime.now().difference(game.startGameTime).inMilliseconds;
        num age = gameTime - board.counterTimeAt(x, y);
        num sz = _squarePixelsSize*4/5;
        if (board.counterValueAt(x, y) >= 0 && age < 0.2) {
          sz *= (0.04 - (0.2-age)*(0.2-age)) * 25;
          animating = true;
        }

        switch (board.counterValueAt(x, y)) {
          case 0:
            _context.drawImageScaled(_imageMap['black'], xc-sz/2, yc-sz/2, sz, sz);
            break;
          case 1:
            _context.drawImageScaled(_imageMap['white'], xc-sz/2, yc-sz/2, sz, sz);
            break;
          case -1:
            if (!board.isValidMove(x, y)) {
              _context.drawImageScaled(_imageMap['cross_fade'], xc-sz/2, yc-sz/2, sz, sz);
            }
        }
      }
    }
    this._animating = animating;

    //show winning position
    if (!animating && game.isComplete()) {
      List<int> winpos = board.getWinPos();
      num x0 = squarePosX(winpos[0]) + (_squarePixelsSize/2);
      num y0 = squarePosY(winpos[1]) + (_squarePixelsSize/2);
      num x1 = squarePosX(winpos[2]) + (_squarePixelsSize/2);
      num y1 = squarePosY(winpos[3]) + (_squarePixelsSize/2);
      _context.beginPath();
      _context.lineWidth = 4;
      _context.setStrokeColorRgb(255, 0, 0);
      _context.moveTo(x0, y0);
      _context.lineTo(x1, y1);
      _context.closePath();
      _context.stroke();
      _context.lineWidth = 1;
    }

    //show header panel
    _context.setStrokeColorRgb(172, 172, 172);
    _context.setFillColorRgb(172, 172, 172);
    _context.lineWidth = 1;
    _context.fillRect(0, 0, _canvasElement.width, HEADER_PX);
    num tx = (_canvasElement.width - _imageMap['title'].width)/2;
    _context.drawImage(_imageMap['title'], tx, 0);
    num sz = _squarePixelsSize*4/5;
    _context.drawImageScaled(_imageMap['black'], sz, HEADER_PX-2*sz, sz, sz);
    _context.drawImageScaled(_imageMap['white'], _canvasElement.width-2*sz, HEADER_PX-2*sz, sz, sz);
    String plr1name = (game.playerAi == 0) ? "Computer" : "Player";
    String plr2name = (game.playerAi == 1) ? "Computer" : "Player";
    _context.setStrokeColorRgb(0, 0, 0);
    _context.setFillColorRgb(0, 0, 0);
    _context.textBaseline = "bottom";
    _context.textAlign = 'left';
    _context.fillText(plr1name, sz, HEADER_PX, 200);
    _context.textAlign = 'right';
    _context.fillText(plr2name, _canvasElement.width-sz, HEADER_PX, 200);

    //show footer panel
    num panelY = _canvasElement.height-FOOTER_PX;
    _context.setStrokeColorRgb(172, 172, 172);
    _context.setFillColorRgb(172, 172, 172);
    _context.fillRect(0, panelY, _canvasElement.width, FOOTER_PX);
    if (!animating) {
      _context.textBaseline = "middle";
      _context.font = "${FOOTER_PX/2}px Arial";
      _context.textAlign = 'left';
      _context.setStrokeColorRgb(0, 0, 0);
      _context.setFillColorRgb(0, 0, 0);
      int plr = game.playerTurn;
      String text = "Current Turn: ";
      if (game.playerWinner >= 0) {
        text = "Winner: ";
        plr = game.playerWinner;
        _context.setStrokeColorRgb(255, 0, 0);
        _context.strokeRect(0, panelY, _canvasElement.width, FOOTER_PX);
      }
      _context.fillText(text, minX, panelY+FOOTER_PX/2, 200);
      num textWidth = _context.measureText(text).width;

      num sz = _squarePixelsSize*4/5;
      num xx = minX+textWidth;
      num yy = panelY+(FOOTER_PX-sz)/2;
      switch (plr) {
        case 0:
          _context.drawImageScaled(_imageMap['black'], xx, yy, sz, sz);
          if (game.playerWinner < 0 && game.remainingCounters >= 2) {
            xx += _squarePixelsSize;
            _context.drawImageScaled(_imageMap['black'], xx, yy, sz, sz);
          }
          break;
        case 1:
          _context.drawImageScaled(_imageMap['white'], xx, yy, sz, sz);
          if (game.playerWinner < 0 && game.remainingCounters >= 2) {
            xx += _squarePixelsSize;
            _context.drawImageScaled(_imageMap['white'], xx, yy, sz, sz);
          }
          break;
      }
    }
  }

  void renderMouseHover(Game game, int mouseHoverX, int mouseHoverY) {
    //show mouse hover pos
    if (game == null) return;
    Board board = game.board;
    if (!_animating && !game.isComplete()) {
      if (mouseHoverX >= 0 && mouseHoverY >= 0 && board.isValidMove(mouseHoverX, mouseHoverY)) {
        num sqsz = _squarePixelsSize;
        num sz = _squarePixelsSize*4/5;
        num xc = squarePosX(mouseHoverX) + (sqsz/2);
        num yc = squarePosY(mouseHoverY) + (sqsz/2);
        switch (game.playerTurn) {
          case 0:
            _context.drawImageScaled(_imageMap['black_fade'], xc-sz/2, yc-sz/2, sz, sz);
            break;
          case 1:
            _context.drawImageScaled(_imageMap['white_fade'], xc-sz/2, yc-sz/2, sz, sz);
            break;
        }
      }
    }
  }

  Button createPlayButton() {
    var playButton = new Button(ID_BUTTON_PLAY, _canvasElement.width/2-60, _canvasElement.height/2, 120, 48);
    playButton.setImage(_imageMap['play_button_std'], _imageMap['play_button_hover'], _imageMap['play_button_click']);
    //playButton.onClick((context, evt) { print("click!");} );
    //playButton.onClick = { print("click!");}
    return playButton;
  }

  Button createRestartButton() {
    num panelY = _canvasElement.height-FOOTER_PX;
    var restartButton = new Button(ID_BUTTON_RESTART, _canvasElement.width*2/3, panelY+(FOOTER_PX-24)/2, 30, 24);
    restartButton.setImage(_imageMap['restart_button_std'], _imageMap['restart_button_hover'], _imageMap['restart_button_click']);
    restartButton.setEnabled(false);
    return restartButton;
  }

  bool isAnimating() {
    return _animating;
  }

}