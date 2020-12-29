
import 'package:flutter/material.dart';

class DateUtil {
  static int SECOND = 1000;
  static int MINUTE = 60 * SECOND;
  static int HOUR = 60 * MINUTE;
  static int DAY = 24 * HOUR;
  static int WEEK = 7 * DAY;
  static int MONTH = 30 * DAY;

  static String dateTimeToString(
    DateTime dateTime, {
    year = '/',
    month = '/',
    day = ' ',
    hour = ':',
    minute = ':',
  }) {
    if (dateTime == null) {
      return "";
    }
    return "${dateTime.year}$year"
        "${dateTime.month}$month"
        "${dateTime.day}$day"
        "${dateTime.hour}$hour"
        "${dateTime.minute}$minute"
        "${dateTime.second < 10 ? '0' : ''}${dateTime.second}";
  }

  static String dateToString(
    DateTime dateTime, {
    year = '/',
    month = '/',
  }) {
    if (dateTime == null) {
      return "";
    }
    return "${dateTime.year}$year${dateTime.month}$month${dateTime.day}";
  }

  static DateTime fromDateTimeString(
    String dateString, {
    String formatYear = '年',
    String formatMonth = '月',
    String formatDay = '日',
    String formatHour = '时',
    String formatMinute = '分',
    String formatSecond = '秒',
  }) {
    var replaceAll = dateString
        .replaceAll(formatYear, '-')
        .replaceAll(formatMonth, '-')
        .replaceAll(formatDay, '')
        .replaceAll(formatHour, ':')
        .replaceAll(formatMinute, ':')
        .replaceAll(formatSecond, '')
        .trim();
    try {
      return DateTime.parse(replaceAll);
    } catch (e) {
      return null;
    }
  }

  static DateTime fromDateString(
    String dateString, {
    String formatYear = '年',
    String formatMonth = '月',
    String formatDay = '日',
  }) {
    var replaceAll = dateString
        .replaceAll(formatYear, '-')
        .replaceAll(formatMonth, '-')
        .replaceAll(formatDay, '')
        .trim();
    try {
      return DateTime.parse(replaceAll);
    } catch (e) {
      return null;
    }
  }

  static String getDayOfWeekTitle(BuildContext context, int day) {
    switch (day) {
      case 1:
        return '一';
      case 2:
        return '二';
      case 3:
        return '三';
      case 4:
        return '四';
      case 5:
        return '五';
      case 6:
        return '六';
      case 7:
        return '日';
    }
  }


  static Color getDayOfWeekColor(int day) {
    switch (day) {
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
        return Colors.black;
      case 6:
      case 7:
        return Colors.grey;
    }
  }

  ///获取目标周的时间戳
  ///cursor  周偏移量
  static List<DateTime> getTargetWeek(int cursor) {
    var targetWeekDay = DateTime.now().add(Duration(days: cursor * 7));
    return getDateWeek(targetWeekDay);
  }

  ///获取目标时间戳所在的周的时间戳
  static List<DateTime> getDateWeek(DateTime dateTime) {
    List<DateTime> result = [];
    for (int i = 1; i <= 7; i++) {
      var j = dateTime.weekday - i;
      result.add(dateTime.subtract(Duration(days: j)));
    }
    return result;
  }

  ///是否是同一天
  static isSameDay(DateTime firstDate, DateTime secondDate) {
    return dateToString(firstDate) == dateToString(secondDate);
  }

  ///是否是一周的同一天，比如都是周一，不管实际时间
  static isSameDayOfWeek(DateTime firstDate, DateTime secondDate) {
    return firstDate.weekday == secondDate.weekday;
  }
}

//测试代码
main() {
  print(DateTime.parse("2020-12-12 18:09:23"));
  // print(DateUtil.getDateWeek(DateTime.now()));
  // print(DateUtil.getTargetWeek(1));
  // print(DateUtil.getTargetWeek(-1));
}
