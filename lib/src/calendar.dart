import 'package:flutter/material.dart';

import 'base_state.dart';
import 'size_changed.dart';
import 'utils/DateUtil.dart';

typedef DaySelectedJudgement = bool Function(
    DateTime dateTime, ViewType viewType);
typedef DayChildBuilder = Widget Function(DateTime dateTime, bool selected,
    bool isTop, bool enable, ViewType viewType);

// ignore: must_be_immutable
class Calendar extends StatefulWidget {
  DayChildBuilder? childBuilder;
  DateTime? initialDate;
  DaySelectedJudgement? selectedJudgement;
  Function(DateTime date) onDateChanged;
  Widget? child;
  ViewType? viewType;

  Calendar({
    Key? key,
    this.childBuilder,
    this.initialDate,
    this.selectedJudgement,
    required this.onDateChanged,
    this.child,
    this.viewType,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CalendarState(
        childBuilder: childBuilder,
        initialDate: initialDate,
        selectedJudgement: selectedJudgement,
        onDateChanged: onDateChanged,
        viewType: viewType,
      );
}

class CalendarState extends WidgetState<Calendar>
    with AutomaticKeepAliveClientMixin {
  late DateTime _initialDate; //初始时间

  PageController _pageController =
      PageController(initialPage: 1, keepPage: true, viewportFraction: 1.0);

  late DayChildBuilder _childBuilder; //生成每天的视图
  late DaySelectedJudgement _selectedJudgement; //判断当前dayView的选择状态
  late ViewType _viewType;

  ViewType get viewType => _viewType;

  Function(DateTime date)? _onDateChanged;

  double _childHeight = 10;

  CalendarState({
    DayChildBuilder? childBuilder,
    DateTime? initialDate,
    DaySelectedJudgement? selectedJudgement,
    Function(DateTime date)? onDateChanged,
    ViewType? viewType,
  }) {
    this._onDateChanged = onDateChanged;
    this._viewType = viewType ??= ViewType.WEEK;
    this._initialDate = initialDate ??= DateTime.now();
    this._selectedJudgement = selectedJudgement ??= (date, type) =>
        type == ViewType.MONTH
            ? DateUtil.isSameDayOfMonth(date, _initialDate)
            : DateUtil.isSameDayOfWeek(date, _initialDate);
    this._childBuilder =
        childBuilder ??= (dateTime, selected, isTop, enable, viewType) {
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
          Offstage(
            child: Container(
              padding: EdgeInsets.all(6),
              child: Text(
                DateUtil.getDayOfWeekTitle(context, dateTime.weekday),
                style: TextStyle(
                    color: DateUtil.getDayOfWeekColor(dateTime.weekday)),
              ),
            ),
            offstage: !isTop,
          ),
          Container(
            width: 32,
            height: 32,
            margin: EdgeInsets.only(top: 6, bottom: 6),
            alignment: Alignment.center,
            padding: EdgeInsets.all(6),
            decoration: (enable || viewType == ViewType.WEEK)
                ? decoration
                : BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    border: Border.all(color: Colors.transparent, width: 1)),
            child: Center(
              child: Text(
                dateTime.day.toString(),
                style: TextStyle(
                    color: (enable || viewType == ViewType.WEEK)
                        ? textColor
                        : Colors.grey.shade300),
              ),
            ),
          ),
        ],
      );
    };
  }

  _refreshHeight(double height) {
    setState(() {
      _childHeight = height;
    });
  }

  setInitialDate(DateTime dateTime) {
    setState(() {
      _initialDate = dateTime;
    });
  }

  switchViewType() {
    setState(() {
      _childHeight = 70;
      if (_viewType == ViewType.MONTH) {
        _viewType = ViewType.WEEK;
      } else {
        _viewType = ViewType.MONTH;
      }
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
        _changePage(0);
      }
      if (offset >= widgetWidth) {
        _pageController.jumpToPage(1);
        _changePage(2);
      }
    });
  }

  Widget buildChildPage(BuildContext context, int cursor) {
    return SingleChildScrollView(
      child: SizeChanged(
        child: ChildPageView(
          infoList: (_viewType == ViewType.MONTH
                  ? DateUtil.getDateMajorMonth(
                      DateTime(
                        _initialDate.year,
                        _initialDate.month,
                        _initialDate.day,
                      ),
                      cursor)
                  : DateUtil.getDateWeekGroup(
                      _initialDate.add(Duration(days: cursor * 7))))
              .map((e) => CalendarInfo(
                  dateTime: e, selected: _selectedJudgement(e, _viewType)))
              .toList(),
          month: DateUtil.getTargetMonth(_initialDate, cursor).month,
          childBuilder: _childBuilder,
          onClick: (e) {
            _onDateChanged?.call(e.dateTime);
            setState(() {
              _initialDate = e.dateTime;
            });
          },
          viewType: viewType,
        ),
        onSizeChanged: (size) {
          if (size.height > _childHeight) {
            _refreshHeight(size.height);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(children: <Widget>[
      Container(
          width: double.infinity,
          height: _childHeight,
          child: PageView(
            children: <Widget>[
              new Container(
                alignment: Alignment.topCenter,
                child: buildChildPage(context, -1),
                padding: EdgeInsets.all(0),
              ),
              new Container(
                alignment: Alignment.topCenter,
                child: buildChildPage(context, 0),
                padding: EdgeInsets.all(0),
              ),
              new Container(
                alignment: Alignment.topCenter,
                child: buildChildPage(context, 1),
                padding: EdgeInsets.all(0),
              ),
            ],
            scrollDirection: Axis.horizontal,
            controller: _pageController,
          )),
      widget.child == null ? Container() : widget.child!,
    ]);
  }

  _pageChanged(int index) {
    if (index == 0) {
      _pageController.jumpToPage(1);
      _changePage(0);
    }
    if (index == 2) {
      _pageController.jumpToPage(1);
      _changePage(2);
    }
  }

  _changePage(int pageCount) {
    //向后滚动
    setState(() {
      if (pageCount == 2) {
        if (_viewType == ViewType.MONTH) {
          _initialDate = DateUtil.getTargetMonth(_initialDate, 1);
        } else {
          _initialDate = DateUtil.getTargetWeek(_initialDate, 1);
        }
        _onDateChanged?.call(_initialDate);
      }
      //向前滚动
      if (pageCount == 0) {
        if (_viewType == ViewType.MONTH) {
          _initialDate = DateUtil.getTargetMonth(_initialDate, -1);
        } else {
          _initialDate = DateUtil.getTargetWeek(_initialDate, -1);
        }
        _onDateChanged?.call(_initialDate);
      }
    });
  }
}

///page视图
// ignore: must_be_immutable
class ChildPageView extends StatelessWidget {
  List<List<CalendarInfo>> dayList = [];
  DayChildBuilder childBuilder;
  Function(CalendarInfo) onClick;
  ViewType viewType;
  int month;

  ChildPageView({
    required List<CalendarInfo> infoList,
    required this.month,
    required this.childBuilder,
    required this.onClick,
    required this.viewType,
  }) {
    int group = infoList.length ~/ 7;
    if (infoList.length % 7 > 0) {
      group++;
    }
    for (var i = 0; i < group; i++) {
      if (i * 7 + 7 > infoList.length) {
        dayList.add(infoList.sublist(i * 7));
      } else {
        dayList.add(infoList.sublist(i * 7, i * 7 + 7));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> weekList = [];
    for (var i = 0; i < dayList.length; i++) {
      var weekDays = dayList[i];
      weekList.add(Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: weekDays
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
                      isTop: i == 0,
                      enable: e.dateTime.month == month,
                      viewType: viewType,
                    ),
                  ),
                  onTap: () {
                    onClick(e);
                  },
                ),
              ),
            )
            .toList(),
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: weekList,
    );
  }
}

///获取当前控件宽高
Size getCurrentWidgetSize(BuildContext context) {
  var renderBox = context.findRenderObject() as RenderBox;
  return renderBox.size;
}

///天视图
// ignore: must_be_immutable
class DayView extends StatelessWidget {
  DayChildBuilder childBuilder;
  DateTime dateTime;
  bool selected;
  bool isTop;
  bool enable;
  ViewType viewType;

  DayView({
    required this.dateTime,
    required this.childBuilder,
    this.selected = false,
    this.isTop = true,
    this.enable = true,
    required this.viewType,
  });

  @override
  Widget build(BuildContext context) {
    return childBuilder(dateTime, selected, isTop, enable, viewType);
  }
}

class CalendarInfo {
  DateTime dateTime;
  bool selected;

  CalendarInfo({required this.dateTime, this.selected = false});
}

enum ViewType {
  MONTH,
  WEEK,
}
