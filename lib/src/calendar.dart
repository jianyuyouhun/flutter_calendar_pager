import 'package:flutter/material.dart';

import 'size_changed.dart';
import 'utils/DateUtil.dart';
import 'base_state.dart';

typedef DaySelectedJudgement = bool Function(DateTime dateTime);
typedef DayChildBuilder = Widget Function(DateTime dateTime, bool selected);

// ignore: must_be_immutable
class Calendar extends StatefulWidget {
  DayChildBuilder childBuilder;
  DateTime initialDate;
  DaySelectedJudgement selectedJudgement;
  Function(DateTime date) onDateChanged;
  Widget child;

  Calendar({
    Key key,
    this.childBuilder,
    this.initialDate,
    this.selectedJudgement,
    this.onDateChanged,
    this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CalendarState(
      childBuilder: childBuilder,
      initialDate: initialDate,
      selectedJudgement: selectedJudgement,
      onDateChanged: onDateChanged);
}

class CalendarState extends WidgetState<Calendar>
    with AutomaticKeepAliveClientMixin {
  DateTime _initialDate; //初始时间

  PageController _pageController =
      new PageController(initialPage: 1, keepPage: true, viewportFraction: 1.0);

  DayChildBuilder _childBuilder; //生成每天的视图
  DaySelectedJudgement selectedJudgement; //判断当前dayView的选择状态
  Function(DateTime date) onDateChanged;

  double childHeight = 100;

  CalendarState({
    DayChildBuilder childBuilder,
    DateTime initialDate,
    DaySelectedJudgement selectedJudgement,
    this.onDateChanged,
  }) {
    this._initialDate = initialDate ??= DateTime.now();
    this.selectedJudgement = selectedJudgement ??=
        (date) => DateUtil.isSameDayOfWeek(date, _initialDate);
    childBuilder ??= (dateTime, selected) {
      BoxDecoration decoration;
      bool isToday = DateUtil.isSameDay(dateTime, DateTime.now());
      var textColor;
      if (isToday) {
        //今天
        if (selected) {
          decoration = BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(20)));
          textColor = Colors.white;
        } else {
          decoration = BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              border: Border.all(color: Colors.blue, width: 1));
          textColor = Colors.blue;
        }
      } else {
        decoration = BoxDecoration(
            color: selected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(20)));
        textColor = selected
            ? Colors.white
            : DateUtil.getDayOfWeekColor(dateTime.weekday);
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(6),
            child: Text(
              DateUtil.getDayOfWeekTitle(context, dateTime.weekday),
              style: TextStyle(
                  color: DateUtil.getDayOfWeekColor(dateTime.weekday)),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            padding: EdgeInsets.all(6),
            decoration: decoration,
            child: Center(
              child: Text(
                dateTime.day.toString(),
                style: TextStyle(color: textColor),
              ),
            ),
          ),
        ],
      );
    };
    this._childBuilder = (dateTime, selected) {
      //包装一层，为了处理控件高度
      return SizeChanged(
        child: childBuilder(dateTime, selected),
        onSizeChanged: (size) {
          if (size.height != childHeight) {
            refreshHeight(size.height);
          }
        },
      );
    };
  }

  refreshHeight(double height) {
    setState(() {
      childHeight = height;
    });
  }

  setInitialDate(DateTime dateTime) {
    setState(() {
      _initialDate = dateTime;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      var offset = double.parse(_pageController.offset.toStringAsFixed(4));
      var widgetWidth = double.parse(
          (getCurrentWidgetSize(context).width * 2).toStringAsFixed(4));
      if (offset <= 0) {
        _pageController.jumpToPage(1);
        changePage(0);
      }
      if (offset >= widgetWidth) {
        _pageController.jumpToPage(1);
        changePage(2);
      }
    });
  }

  WeekView buildWeek(BuildContext context, int cursor) {
    return WeekView(
      infoList: DateUtil.getDateWeek(
              _initialDate.add(Duration(days: cursor * 7)))
          .map((e) => CalendarInfo(dateTime: e, selected: selectedJudgement(e)))
          .toList(),
      childBuilder: _childBuilder,
      onClick: (e) {
        onDateChanged?.call(e.dateTime);
        setState(() {
          _initialDate = e.dateTime;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(children: <Widget>[
      Container(
          width: double.infinity,
          height: childHeight,
          child: PageView(
            children: <Widget>[
              new Container(
                alignment: Alignment.center,
                child: buildWeek(context, -1),
                padding: EdgeInsets.all(0),
              ),
              new Container(
                alignment: Alignment.center,
                child: buildWeek(context, 0),
                padding: EdgeInsets.all(0),
              ),
              new Container(
                alignment: Alignment.center,
                child: buildWeek(context, 1),
                padding: EdgeInsets.all(0),
              ),
            ],
            scrollDirection: Axis.horizontal,
            controller: _pageController,
          )),
      widget.child == null ? Container() : widget.child,
    ]);
  }

  pageChanged(int index) {
    if (index == 0) {
      _pageController.jumpToPage(1);
      changePage(0);
    }
    if (index == 2) {
      _pageController.jumpToPage(1);
      changePage(2);
    }
  }

  void changePage(int pageCount) {
    //向后滚动
    setState(() {
      if (pageCount == 2) {
        _initialDate = _initialDate.add(Duration(days: 7));
        onDateChanged?.call(_initialDate);
      }
      //向前滚动
      if (pageCount == 0) {
        _initialDate = _initialDate.subtract(Duration(days: 7));
        onDateChanged?.call(_initialDate);
      }
    });
  }
}

///周视图
// ignore: must_be_immutable
class WeekView extends StatelessWidget {
  List<CalendarInfo> infoList;
  DayChildBuilder childBuilder;
  Function(CalendarInfo) onClick;

  WeekView({this.infoList, this.childBuilder, this.onClick});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: infoList
          .map(
            (e) => Expanded(
              flex: 1,
              child: GestureDetector(
                child: Container(
                  color: Colors.transparent,
                  child: DayView(
                    dateTime: e.dateTime,
                    childBuilder: childBuilder,
                    selected: e.selected,
                  ),
                ),
                onTap: () {
                  onClick(e);
                },
              ),
            ),
          )
          .toList(),
    );
  }
}

///获取当前控件宽高
Size getCurrentWidgetSize(BuildContext context) {
  var mediaQuery = MediaQuery.of(context);
  print(mediaQuery.toString());
  return mediaQuery.size;
}

///天视图
// ignore: must_be_immutable
class DayView extends StatelessWidget {
  DayChildBuilder childBuilder;
  DateTime dateTime;
  bool selected;

  DayView({
    @required this.dateTime,
    @required this.childBuilder,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return childBuilder(dateTime, selected);
  }
}

class CalendarInfo {
  DateTime dateTime;
  bool selected;

  CalendarInfo({@required this.dateTime, this.selected = false});
}
