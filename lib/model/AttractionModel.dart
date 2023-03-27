// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:intl/intl.dart';

class AttractionModel {
  static const FIELD_ID = 'id';
  static const FIELD_TITLE = 'title';
  static const FIELD_DESCRIPTION = 'description';
  static const FIELD_DIFFERENTIAL = 'differential';
  static const FIELD_DATE = 'date';

  int id;
  String title;
  String description;
  String? differential;
  DateTime? date;

  AttractionModel({
    required this.id,
    required this.title,
    required this.description,
    this.differential,
    this.date,
  });

  String get dateFormatted {
    if (date == null) {
      return "";
    }
    return DateFormat('dd/MM/yyyy').format(date!);
  }
}
