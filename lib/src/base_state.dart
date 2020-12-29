import 'package:flutter/material.dart';

abstract class WidgetState<T extends StatefulWidget> extends State<T> {
  Size _widgetSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      onPostFrameFinished();
      if (_widgetSize == null ||
          (_widgetSize.width != context.size.width ||
              _widgetSize.height != context.size.height)) {
        onSizeChanged(context.size);
      }
      _widgetSize = context.size;
    });
  }

  ///
  ///界面绘制完后调用此方法
  @protected
  void onPostFrameFinished() {}

  @protected
  void onSizeChanged(Size size) {}

}
