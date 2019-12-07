import 'package:rxdart/rxdart.dart';

final theme = ThemeStream();

class ThemeStream {
  BehaviorSubject _controller = BehaviorSubject<bool>();

  ValueObservable<bool> get themeStream => _controller.stream;

  bool get getTheme => _controller.value;

  changeValue(bool val) => _controller.sink.add(val);

  dispose() => _controller.close();
}
