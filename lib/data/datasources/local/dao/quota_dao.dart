// lib/data/datasources/local/dao/quota_dao.dart

import '../../../../core/errors/exceptions.dart';
import '../../../models/quota_info.dart';
import '../database_helper.dart';

class QuotaDao {
  final DatabaseHelper _helper;

  QuotaDao({DatabaseHelper? helper}) : _helper = helper ?? DatabaseHelper.instance;

  /// Inserts a single quota snapshot. Returns the new row id.
  Future<void> insertQuotaHistory(QuotaInfo info) async {
    try {
      final db = await _helper.database;
      await db.insert(
        DatabaseHelper.tableQuotaHistory,
        info.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to insert quota history: $e');
    }
  }

  /// Returns all snapshots for [accountId], newest first.
  Future<List<QuotaInfo>> getQuotaHistoryForAccount(int accountId) async {
    try {
      final db = await _helper.database;
      final rows = await db.query(
        DatabaseHelper.tableQuotaHistory,
        where: 'account_id = ?',
        whereArgs: [accountId],
        orderBy: 'fetched_at DESC',
      );
      return rows.map(QuotaInfo.fromMap).toList(growable: false);
    } catch (e) {
      throw DatabaseException(
        'Failed to fetch quota history for account $accountId: $e',
      );
    }
  }

  /// Latest snapshot for [accountId] or null when none exists.
  Future<QuotaInfo?> getLatestForAccount(int accountId) async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tableQuotaHistory,
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'fetched_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return QuotaInfo.fromMap(rows.first);
  }

  /// Deletes history older than the provided cutoff (retention policy).
  Future<int> purgeOlderThan(DateTime cutoff) async {
    final db = await _helper.database;
    return db.delete(
      DatabaseHelper.tableQuotaHistory,
      where: 'fetched_at < ?',
      whereArgs: [cutoff.toIso8601String()],
    );
  }
}