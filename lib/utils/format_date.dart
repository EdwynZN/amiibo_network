import 'package:amiibo_network/generated/l10n.dart';
import 'package:flutter/material.dart';

enum _Format { FullDate, MonthYear, Year, NoDate }

class FormatDate {
  late final DateTime? _dateTime;
  late _Format _format;

  FormatDate._(
    this._dateTime,
    this._format
  );

  FormatDate(String dateString) {
    switch (dateString.length) {
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
      default:
        _dateTime = null;
        _format = _Format.NoDate;
        break;
    }
    if (_dateTime == null && _format != _Format.NoDate) {
      _format = _Format.NoDate;
    }
  }

  factory FormatDate.NoDateAvailable() => FormatDate._(null, _Format.NoDate);

  String localizedDate(BuildContext context) {
    if (_dateTime == null) {
      final S translate = S.of(context);
      return translate.no_date;
    }
    switch (_format) {
      case _Format.FullDate:
        String formatDate =
            MaterialLocalizations.of(context).formatShortDate(_dateTime);
        return formatDate;
      case _Format.MonthYear:
        return MaterialLocalizations.of(context).formatMonthYear(_dateTime);
      case _Format.Year:
      default:
        return MaterialLocalizations.of(context).formatYear(_dateTime);
    }
  }
}
