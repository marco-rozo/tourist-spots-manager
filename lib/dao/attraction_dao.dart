import 'package:attractions_app/database/database_provider.dart';
import 'package:attractions_app/model/attraction_model.dart';
import 'package:sqflite/sqflite.dart';

class AttractionDao {
  final dbProvider = DatabaseProvider.instance;

  Future<bool> salvar(AttractionModel attraction) async {
    final database = await dbProvider.database;
    final values = attraction.toMap();
    if (attraction.id == null) {
      attraction.id = await database.insert(AttractionModel.TABLE_NAME, values);
      return true;
    } else {
      final recordsUpdated = await database.update(
        AttractionModel.TABLE_NAME,
        values,
        where: '${AttractionModel.FIELD_ID} = ?',
        whereArgs: [attraction.id],
      );
      return recordsUpdated > 0;
    }
  }

  Future<bool> remover(int id) async {
    final database = await dbProvider.database;
    final recordsUpdated = await database.delete(
      AttractionModel.TABLE_NAME,
      where: '${AttractionModel.FIELD_ID} = ?',
      whereArgs: [id],
    );
    return recordsUpdated > 0;
  }

  Future<List<AttractionModel>> listar(
      {String filter = '',
      String fieldOrder = AttractionModel.FIELD_ID,
      bool isDescOrder = false}) async {
    String? where;
    if (filter.isNotEmpty) {
      where =
          "UPPER(${AttractionModel.FIELD_DESCRIPTION}) LIKE '${filter.toUpperCase()}%'";
    }
    var orderBy = fieldOrder;

    if (isDescOrder) {
      orderBy += ' DESC';
    }
    final database = await dbProvider.database;
    final records = await database.query(
      AttractionModel.TABLE_NAME,
      columns: [
        AttractionModel.FIELD_ID,
        AttractionModel.FIELD_TITLE,
        AttractionModel.FIELD_DESCRIPTION,
        AttractionModel.FIELD_DIFFERENTIAL,
        AttractionModel.FIELD_DATE
      ],
      where: where,
      orderBy: orderBy,
    );
    return records.map((m) => AttractionModel.fromMap(m)).toList();
  }
}
