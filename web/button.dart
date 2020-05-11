
import 'dart:html';
import 'component.dart';

class Button extends Component {
  int _id;
  num _x, _y, _wd, _ht;
  ImageElement _imgBase;
  ImageElement _imgHover;
  ImageElement _imgClicked;
  bool _enabled = true;
  int _state = 0;
  
  Button(this._id, this._x, this._y, this._wd, this._ht);

  int getId() {
    return _id;
  }
  
  void setImage(ImageElement imgBase, ImageElement imgHover, ImageElement imgClicked) {
    this._imgBase = imgBase;
    this._imgHover = imgHover;
    this._imgClicked = imgClicked;
  }
  
  void setEnabled(bool enabled) {
    this._enabled = enabled;
  }
  
  void render(CanvasRenderingContext2D context) {
    if (!_enabled) {
      return;
    }
    switch (_state) {
      case 1:    
        context.drawImageScaled(_imgHover, _x, _y, _wd, _ht);
        break;
      case 2:
        context.drawImageScaled(_imgClicked, _x, _y, _wd, _ht);
        break;
      default:
        context.drawImageScaled(_imgBase, _x, _y, _wd, _ht);
        break;
    }
  }
  
  void onMouseMove(CanvasRenderingContext2D context, MouseEvent evt) {
    if (!_enabled) {
      return;
    }
    Rectangle clientBoundingRect = context.canvas.getBoundingClientRect();
    num mx = (evt.client.x - clientBoundingRect.left);
    num my = (evt.client.y - clientBoundingRect.top);
    if (_state != 2 && mx > _x && mx < _x+_wd && my > _y && my < _y+_ht) {
      _state = 1;
    } else {
      _state = 0;
    }
  }
  
  void onMouseDown(CanvasRenderingContext2D context, MouseEvent evt) {
    if (!_enabled) {
      return;
    }
    Rectangle clientBoundingRect = context.canvas.getBoundingClientRect();
    num mx = (evt.client.x - clientBoundingRect.left);
    num my = (evt.client.y - clientBoundingRect.top);
    if (mx > _x && mx < _x+_wd && my > _y && my < _y+_ht) {
      _state = 2;
    }    
  }

  void onMouseUp(CanvasRenderingContext2D context, MouseEvent evt) {
    if (!_enabled) {
      return;
    }
    Rectangle clientBoundingRect = context.canvas.getBoundingClientRect();
    num mx = (evt.client.x - clientBoundingRect.left);
    num my = (evt.client.y - clientBoundingRect.top);
    if (mx > _x && mx < _x+_wd && my > _y && my < _y+_ht) {
      _state = 0;
    }    
  }

  bool onClick(CanvasRenderingContext2D context, MouseEvent evt) {
    if (!_enabled) {
      return false;
    }
    Rectangle clientBoundingRect = context.canvas.getBoundingClientRect();
    num mx = (evt.client.x - clientBoundingRect.left);
    num my = (evt.client.y - clientBoundingRect.top);
    if (mx > _x && mx < _x+_wd && my > _y && my < _y+_ht) {
      _state = 0;
      return true;
    }
    return false;
  }
}

