import 'package:restaurant_billing/data/database/database_helper.dart';
import 'package:restaurant_billing/data/models/table_model.dart';
import 'package:restaurant_billing/core/constants/db_constants.dart';

class TableRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<TableModel>> getAllTables() async {
    final results = await _dbHelper.query(
      DbConstants.tableTables,
      orderBy: '${DbConstants.columnTableNumber} ASC',
    );

    return results.map((map) => TableModel.fromMap(map)).toList();
  }

  Future<List<TableModel>> getTablesByStatus(String status) async {
    final results = await _dbHelper.query(
      DbConstants.tableTables,
      where: '${DbConstants.columnTableStatus} = ?',
      whereArgs: [status],
      orderBy: '${DbConstants.columnTableNumber} ASC',
    );

    return results.map((map) => TableModel.fromMap(map)).toList();
  }

  Future<TableModel?> getTableById(int id) async {
    final results = await _dbHelper.query(
      DbConstants.tableTables,
      where: '${DbConstants.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return TableModel.fromMap(results.first);
  }

  Future<TableModel?> getTableByNumber(String tableNumber) async {
    final results = await _dbHelper.query(
      DbConstants.tableTables,
      where: '${DbConstants.columnTableNumber} = ?',
      whereArgs: [tableNumber],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return TableModel.fromMap(results.first);
  }

  Future<int> createTable(TableModel table) async {
    return await _dbHelper.insert(
      DbConstants.tableTables,
      table.toMap(),
    );
  }

  Future<int> updateTable(TableModel table) async {
    return await _dbHelper.update(
      DbConstants.tableTables,
      table.toMap(),
      where: '${DbConstants.columnId} = ?',
      whereArgs: [table.id],
    );
  }

  Future<int> updateTableStatus(int id, String status) async {
    return await _dbHelper.update(
      DbConstants.tableTables,
      {DbConstants.columnTableStatus: status},
      where: '${DbConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTable(int id) async {
    return await _dbHelper.delete(
      DbConstants.tableTables,
      where: '${DbConstants.columnId} = ?',
      whereArgs: [id],
    );
  }
}
