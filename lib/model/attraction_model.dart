// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:intl/intl.dart';

class AttractionModel {
  static const TABLE_NAME = 'attractions';
  static const FIELD_ID = '_id';
  static const FIELD_TITLE = 'title';
  static const FIELD_DESCRIPTION = 'description';
  static const FIELD_DIFFERENTIAL = 'differential';
  static const FIELD_DATE = 'date';

  int? id;
  String title;
  String description;
  String? differential;
  DateTime? date;

  AttractionModel({
    this.id,
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

  AttractionModel copyWith({
    int? id,
    String? title,
    String? description,
    String? differential,
    DateTime? date,
  }) {
    return AttractionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      differential: differential ?? this.differential,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'id': id,
      'title': title,
      'description': description,
      'differential': differential,
      // 'date': date?.millisecondsSinceEpoch,
      'date': date == null ? null : DateFormat("yyyy-MM-dd").format(date!),
    };
  }

  factory AttractionModel.fromMap(Map<String, dynamic> map) {
    return AttractionModel(
      id: map[FIELD_ID] is int ? map[FIELD_ID] : null,
      title: map['title'] is String ? map['title'] : '',
      description: map['description'] is String ? map['description'] : '',
      differential:
          map['differential'] != null ? map['differential'] as String : null,
      date: map['date'] != null
          ? DateFormat("yyyy-MM-dd").parse(map['date'])
          // ? DateTime.fromMillisecondsSinceEpoch(map['date'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AttractionModel.fromJson(String source) =>
      AttractionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
