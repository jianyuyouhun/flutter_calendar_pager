import 'package:flutter/widgets.dart';

import 'base_state.dart';

// ignore: must_be_immutable
class SizeChanged extends StatefulWidget {
  final Widget child;

  Function(Size size) onSizeChanged;

  SizeChanged({
    Key key,
    @required this.child,
    this.onSizeChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SizeChangedState();
  }
}

class _SizeChangedState extends WidgetState<SizeChanged> {
  @override
  void onSizeChanged(Size size) {
    super.onSizeChanged(size);
    if (widget.onSizeChanged != null) widget.onSizeChanged(size);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
