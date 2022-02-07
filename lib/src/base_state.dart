import 'package:flutter/material.dart';

abstract class WidgetState<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((callback) {
      onPostFrameFinished();
    });
  }

  ///
  ///界面绘制完后调用此方法
  @protected
  void onPostFrameFinished() {}
}

typedef DelayCallback<T> = T Function();

Future<T> delay<T>(
  DelayCallback<T> callback, {
  int milliseconds = 16,
}) =>
    Future<T>.delayed(
      Duration(milliseconds: milliseconds),
      () => callback.call(),
    );
