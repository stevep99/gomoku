
import 'board.dart';
import 'dart:async';
import 'dart:core';
import 'dart:html';
import 'dart:math';
import 'component.dart';
import 'game.dart';
import 'button.dart';
import 'renderer.dart';

final int FRAME_RATE = 25;
final int FRAME_DT = 1000 ~/ FRAME_RATE;

final int MODE_LOADING = 0;
final int MODE_INTRO = 1;
final int MODE_GAME = 2;

void main() {
  new GoMoku().init();
}


class GoMoku {
  CanvasElement canvasElement;
  CanvasRenderingContext2D context;
  ComponentHandler componentHandler;
  int screenMode = MODE_LOADING;
  bool paused = false;
  Map<String, ImageElement> imageMap = new Map<String, ImageElement>();
  int mouseHoverX = -1,
      mouseHoverY = -1;
  int timeFrame = 0;
  Renderer renderer;
  Game game;

  void init() {
    canvasElement = querySelector("#gameCanvas");
    context = canvasElement.context2D;
    renderer = new Renderer(canvasElement, context, imageMap, Game.BOARD_SIZE);

    componentHandler = new ComponentHandler(context);

    loadResources();

    window.onKeyDown.listen(onKeyDown);
    canvasElement.onClick.listen((event) => onClick(event));
    canvasElement.onMouseMove.listen((event) => onMouseMove(event));
    canvasElement.onMouseUp.listen((event) => onMouseUp(event));
    canvasElement.onMouseDown.listen((event) => onMouseDown(event));

    gameLoop();
  }

  void loadResources() {
    imageMap['title'] = new ImageElement(src: "resources/title.png");
    imageMap['cross_fade'] = new ImageElement(src: "resources/cross_fade.png");
    imageMap['white'] = new ImageElement(src: "resources/counter_wht.png");
    imageMap['black'] = new ImageElement(src: "resources/counter_blk.png");
    imageMap['white_fade'] =
    new ImageElement(src: "resources/counter_wht_fade.png");
    imageMap['black_fade'] =
    new ImageElement(src: "resources/counter_blk_fade.png");
    imageMap['play_button_std'] =
    new ImageElement(src: "resources/play_button_std.png");
    imageMap['play_button_hover'] =
    new ImageElement(src: "resources/play_button_hover.png");
    imageMap['play_button_click'] =
    new ImageElement(src: "resources/play_button_click.png");
    imageMap['restart_button_std'] =
    new ImageElement(src: "resources/restart_button_std.png");
    imageMap['restart_button_hover'] =
    new ImageElement(src: "resources/restart_button_hover.png");
    imageMap['restart_button_click'] =
    new ImageElement(src: "resources/restart_button_click.png");
    int loadCount = 0;
    for (var item in imageMap.keys) {
      imageMap[item].onLoad.listen((e) {
        ++loadCount;
        print("loaded resource $loadCount");
        if (loadCount == imageMap.length) {
          print("load resources complete");
          setupButtons();
          screenMode = MODE_INTRO;
        }
      });
    }
  }

  void setupButtons() {
    componentHandler.addComponent(renderer.createPlayButton());
    componentHandler.addComponent(renderer.createRestartButton());
  }

  void restartGame() {
    var playButton = componentHandler.findById(
        Renderer.ID_BUTTON_PLAY) as Button;
    playButton.setEnabled(true);
    screenMode = MODE_INTRO;
  }

  void gameLoop() {
    int delay = FRAME_DT -
        (new DateTime.now().millisecondsSinceEpoch - timeFrame);
    //print("gameLoop delay $screenMode $delay");
    timeFrame = new DateTime.now().millisecondsSinceEpoch;
    if (game != null && !paused) {
      game.updateGame();
    }
    new Future.delayed(new Duration(milliseconds: delay), () => renderScreen());
  }


  void renderScreen() {
    renderer.renderBackground();

    switch (screenMode) {
      case 0: //loading
        renderer.renderScreenLoading();
        break;
      case 1: //intro
        renderer.renderScreenIntro();
        break;
      case 2: //game
        renderer.renderScreenGame(game);
        renderer.renderMouseHover(game, mouseHoverX, mouseHoverY);
        break;
    }

    componentHandler.render();

    gameLoop();
  }


  void onMouseUp(MouseEvent evt) {
    componentHandler.onMouseUp(evt);
  }

  void onMouseDown(MouseEvent evt) {
    componentHandler.onMouseDown(evt);
  }

  void onMouseMove(MouseEvent evt) {
    componentHandler.onMouseMove(evt);
    if (renderer.isAnimating() || game == null || game.isComplete()) return;

    Rectangle clientBoundingRect = context.canvas.getBoundingClientRect();
    int mx = (evt.client.x - clientBoundingRect.left).toInt();
    int my = (evt.client.y - clientBoundingRect.top).toInt();
    if (game != null && screenMode == MODE_GAME) {
      Board board = game.board;
      List pos = renderer.counterAt(mx, my);
      if (pos != null && board.counterValueAt(pos[0], pos[1]) == -1) {
        mouseHoverX = pos[0];
        mouseHoverY = pos[1];
      } else {
        mouseHoverX = -1;
        mouseHoverY = -1;
      }
    }
  }

  void onKeyDown(KeyboardEvent args) {
    switch (args.keyCode) {
      case 27: // esc
        break;
      case 72: // h
        break;
    }
  }

  void onClick(MouseEvent evt) {
    Component clicked = componentHandler.onClick(evt);
    if (clicked != null) {
      if (clicked is Button && clicked.getId() == Renderer.ID_BUTTON_PLAY) {
        clicked.setEnabled(false);
        game = new Game(new GameMoveListener(this));
        mouseHoverX = -1;
        mouseHoverY = -1;
        screenMode = MODE_GAME;
      } else
      if (clicked is Button && clicked.getId() == Renderer.ID_BUTTON_RESTART) {
        clicked.setEnabled(false);
        restartGame();
      }
    }
    if (renderer.isAnimating() || game == null || game.isComplete()) {
      return;
    }
    Rectangle clientBoundingRect = context.canvas.getBoundingClientRect();
    int mx = (evt.client.x - clientBoundingRect.left).toInt();
    int my = (evt.client.y - clientBoundingRect.top).toInt();

    if (game != null && screenMode == MODE_GAME) {
      Board board = game.board;
      List pos = renderer.counterAt(mx, my);
      if (pos != null && board.isValidMove(pos[0], pos[1])) {
        game.performMove(pos[0], pos[1]);
        mouseHoverX = -1;
        mouseHoverY = -1;
      }
    }
  }
}

class GameMoveListener implements MoveListener {
  GoMoku _app;

  GameMoveListener(GoMoku app) {
    _app = app;
  }

  @override
  void moved() {
    if (_app.game.isComplete()) {
      var restartButton = _app.componentHandler.findById(Renderer.ID_BUTTON_RESTART) as Button;
      restartButton.setEnabled(true);
    }
  }
}



