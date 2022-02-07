import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'base_state.dart';

// ignore: must_be_immutable
class SizeChanged extends StatelessWidget {
  final Widget child;
  Function(Size size)? onSizeChanged;

  SizeChanged({
    Key? key,
    required this.child,
    this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      child: SizeChangedLayoutNotifier(
        child: child,
      ),
      onNotification: (notification) {
        if (onSizeChanged != null) {
          delay(() => onSizeChanged!(notification.size), milliseconds: 32);
        }
        return true;
      },
    );
  }
}

class SizeChangedLayoutNotification extends LayoutChangedNotification {
  Size size;

  SizeChangedLayoutNotification(this.size);
}

class SizeChangedLayoutNotifier extends SingleChildRenderObjectWidget {
  const SizeChangedLayoutNotifier({
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  _SizeChangedWithCallback createRenderObject(BuildContext context) {
    return _SizeChangedWithCallback(onLayoutChangedCallback: (Size size) {
      SizeChangedLayoutNotification(size).dispatch(context);
    });
  }
}

typedef VoidCallbackWithParam = Function(Size size);

class _SizeChangedWithCallback extends RenderProxyBox {
  _SizeChangedWithCallback({
    RenderBox? child,
    required this.onLayoutChangedCallback,
  }) : super(child);

  final VoidCallbackWithParam onLayoutChangedCallback;

  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    //在第一次layout结束后就会进行通知
    if (size != _oldSize) onLayoutChangedCallback(size);
    _oldSize = size;
  }
}
