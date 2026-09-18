// lib/data/datasources/local/dao/service_dao.dart

import '../../../../core/errors/exceptions.dart';
import '../../../models/service_definition.dart';
import '../database_helper.dart';

class ServiceDao {
  final DatabaseHelper _helper;

  ServiceDao({DatabaseHelper? helper}) : _helper = helper ?? DatabaseHelper.instance;

  /// Upserts a single service definition.
  Future<void> upsert(ServiceDefinition service) async {
    try {
      final db = await _helper.database;
      await db.insert(
        DatabaseHelper.tableServiceDefinitions,
        service.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to upsert service ${service.id}: $e');
    }
  }

  /// Bulk upsert — useful for seeding the built-in catalog.
  Future<void> upsertAll(List<ServiceDefinition> services) async {
    final db = await _helper.database;
    final batch = db.batch();
    for (final s in services) {
      batch.insert(
        DatabaseHelper.tableServiceDefinitions,
        s.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    try {
      await batch.commit(noResult: true);
    } catch (e) {
      throw DatabaseException('Failed to seed service definitions: $e');
    }
  }

  Future<List<ServiceDefinition>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tableServiceDefinitions,
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(ServiceDefinition.fromMap).toList(growable: false);
  }

  Future<ServiceDefinition?> getById(String id) async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tableServiceDefinitions,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ServiceDefinition.fromMap(rows.first);
  }
}