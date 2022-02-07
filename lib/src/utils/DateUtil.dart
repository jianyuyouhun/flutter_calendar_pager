import 'package:flutter/material.dart';

class DateUtil {
  static int second = 1000;
  static int minute = 60 * second;
  static int hour = 60 * minute;
  static int day = 24 * hour;
  static int week = 7 * day;
  static int month = 30 * day;

  static String dateTimeToString(
    DateTime? dateTime, {
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
    DateTime? dateTime, {
    year = '/',
    month = '/',
  }) {
    if (dateTime == null) {
      return "";
    }
    return "${dateTime.year}$year${dateTime.month}$month${dateTime.day}";
  }

  static DateTime? fromDateTimeString(
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

  static DateTime? fromDateString(
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
      default:
        return '';
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
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  ///获取目标周的时间戳
  ///cursor  周偏移量
  static List<DateTime> getTargetWeekGroup(int cursor) {
    var targetWeekDay = DateTime.now().add(Duration(days: cursor * 7));
    return getDateWeekGroup(targetWeekDay);
  }

  ///获取目标时间戳所在的周的时间戳
  static List<DateTime> getDateWeekGroup(DateTime dateTime) {
    List<DateTime> result = [];
    for (int i = 1; i <= 7; i++) {
      var j = dateTime.weekday - i;
      result.add(dateTime.subtract(Duration(days: j)));
    }
    return result;
  }

  ///获取目标时间戳所在的月的时间戳
  static List<DateTime> getDateMonthGroup(DateTime dateTime) {
    List<DateTime> result = [];
    DateTime firstDay = getFirstDayInMonth(dateTime);
    DateTime lastDay = getLastDayInMonth(dateTime);
    for (var i = 0; i < lastDay.day; i++) {
      result.add(firstDay.add(Duration(days: i)));
    }
    return result;
  }

  ///获取目标时间戳所在的月的时间戳，并前后补全周一到周日
  static List<DateTime> getDateMajorMonth(DateTime dateTime, int cursor) {
    var targetMonth = getTargetMonth(dateTime, cursor);
    var monthGroup = getDateMonthGroup(targetMonth);
    var firstWeekDay = monthGroup.first.weekday - 1; //补全前面的周到周一
    for (var i = 0; i < firstWeekDay; i++) {
      monthGroup.insert(0, monthGroup.first.subtract(Duration(days: 1)));
    }
    var lastWeekDay = 7 - monthGroup.last.weekday; //补全后面的周到周日
    for (var i = 0; i < lastWeekDay; i++) {
      monthGroup.add(monthGroup.last.add(Duration(days: 1)));
    }
    return monthGroup;
  }

  ///根据偏移量获取目标月份，比如下个月的31号，不满足的月份取最后一天。
  static DateTime getTargetMonth(DateTime dateTime, int cursor) {
    int totalMonth = dateTime.month + cursor;
    var yearOffset = totalMonth ~/ 12;
    var month = totalMonth % 12;
    //先获取目标月份的最后一天。
    var firstDayInTargetMonth = DateTime(dateTime.year + yearOffset, month, 1);
    var lastDayInTargetMonth = getLastDayInMonth(firstDayInTargetMonth);
    if (dateTime.day > lastDayInTargetMonth.day) {
      //如果当前日期的day大于目标月份的最大day值，返回目标月份最后一天
      return lastDayInTargetMonth;
    } //否则返回目标月份对应的当天日期。
    return DateTime(dateTime.year + yearOffset, month, dateTime.day);
  }

  ///根据偏移量获取目标周。
  static DateTime getTargetWeek(DateTime dateTime, int cursor) {
    return dateTime.add(Duration(days: 7 * cursor));
  }

  ///是否是同一天
  static isSameDay(DateTime firstDate, DateTime secondDate) {
    return dateToString(firstDate) == dateToString(secondDate);
  }

  ///是否是一周的同一天，比如都是周一，不管实际时间
  static isSameDayOfWeek(DateTime firstDate, DateTime secondDate) {
    return firstDate.weekday == secondDate.weekday;
  }

  ///是否是同一个月的同一天，比如都是1号，不管月份
  static isSameDayOfMonth(DateTime firstDate, DateTime secondDate) {
    return firstDate.day == secondDate.day;
  }

  ///获取月初的日期
  static DateTime getFirstDayInMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }

  ///获取月末的日期
  static DateTime getLastDayInMonth(DateTime dateTime) {
    if (dateTime.month == 12) {
      //12月直接返回12月31日
      return DateTime(dateTime.year, 12, 31);
    }
    return DateTime(dateTime.year, dateTime.month + 1, 1)
        .subtract(Duration(days: 1)); //其他先月份加1，然后减一天；
  }
}

//测试代码
main() {
  print(DateTime.parse("2020-12-12 18:09:23"));
  // print(DateUtil.getDateWeek(DateTime.now()));
  // print(DateUtil.getTargetWeek(1));
  // print(DateUtil.getTargetWeek(-1));
}
