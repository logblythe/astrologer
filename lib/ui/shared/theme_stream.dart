
import 'dart:async';

class ThemeStream{
  StreamController _controller=StreamController<bool>();
  addValue(bool val){
    _controller.sink.add(val);
  }
  Stream<bool> get getStream => _controller.stream;

  dispose(){
    _controller.close();
  }

}
