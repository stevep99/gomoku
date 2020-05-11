
import 'dart:html';

abstract class Component {
  int getId();
  void render(CanvasRenderingContext2D context);
  void onMouseMove(CanvasRenderingContext2D context, MouseEvent evt);
  void onMouseDown(CanvasRenderingContext2D context, MouseEvent evt);
  void onMouseUp(CanvasRenderingContext2D context, MouseEvent evt);
  bool onClick(CanvasRenderingContext2D context, MouseEvent evt);
}


class ComponentHandler {

  CanvasRenderingContext2D context;
  List<Component> components = new List<Component>();

  ComponentHandler(this.context);

  void addComponent(Component c) {
    components.add(c);
  }

  Component findById(int id) {
    for(Component c in components) {
      if (c.getId() == id) {
        return c;
      }
    }
    return null;
  }

  void render() {
    for(Component c in components) {
      c.render(context);
    }
  }

  void onMouseMove(evt) {
    for(Component c in components) {
      c.onMouseMove(context, evt);
    }
  }

  void onMouseDown(evt) {
    for(Component c in components) {
      c.onMouseDown(context, evt);
    }
  }

  void onMouseUp(evt) {
    for(Component c in components) {
      c.onMouseUp(context, evt);
    }
  }

  Component onClick(evt) {
    bool clicked = false;
    for(Component c in components) {
      clicked = c.onClick(context, evt);
      if (clicked) {
        return c;
      }
    }
    return null;
  }
}