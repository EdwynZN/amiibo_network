import 'package:flutter/material.dart';

enum _Format{
  FullDate,
  MonthYear,
  Year,
  NoDate
}

class FormatDate {
  DateTime _dateTime;
  _Format _format;

  FormatDate(String dateString){
    switch(dateString.length){
      case 8:
        _dateTime = DateTime.tryParse(dateString);
        _format = _Format.FullDate;
        break;
      case 6:
        _dateTime = DateTime.tryParse('${dateString}01');
        _format = _Format.MonthYear;
        break;
      case 4:
        _dateTime = DateTime.tryParse('${dateString}0101');
        _format = _Format.Year;
        break;
    }
    if(_dateTime == null){
      _dateTime = DateTime.now();
      _format = _Format.NoDate;
    }
  }

  String localizedDate(BuildContext context){
    switch(_format){
      case _Format.FullDate:
        String formatDate = MaterialLocalizations.of(context).formatFullDate(_dateTime);
        formatDate = formatDate.substring(formatDate.indexOf(' ')+1);
        return formatDate;
      case _Format.MonthYear:
        return MaterialLocalizations.of(context).formatMonthYear(_dateTime);
      case _Format.Year:
      default:
        return MaterialLocalizations.of(context).formatYear(_dateTime);
    }
  }

}