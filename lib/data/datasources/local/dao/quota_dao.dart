// lib/data/datasources/local/dao/quota_dao.dart

import '../../../../core/errors/exceptions.dart';
import '../../../models/quota_info.dart';
import '../database_helper.dart';

class QuotaDao {
  final DatabaseHelper _helper;

  QuotaDao([DatabaseHelper? helper]) : _helper = helper ?? DatabaseHelper.instance;

  /// Inserts a single quota snapshot. Returns the new row id.
  Future<int> insertQuotaHistory(QuotaInfoModel info) async {
    try {
      final db = await _helper.database;
      return await db.insert(
        DatabaseHelper.tableQuotaHistory,
        info.toMap(),
      );
    } catch (e) {
      throw DatabaseException('Failed to insert quota history: $e');
    }
  }

  /// Alias for insertQuotaHistory
  Future<int> insert(QuotaInfoModel info) => insertQuotaHistory(info);

  /// Returns all snapshots for [accountId], newest first.
  Future<List<QuotaInfoModel>> getQuotaHistoryForAccount(int accountId) async {
    try {
      final db = await _helper.database;
      final rows = await db.query(
        DatabaseHelper.tableQuotaHistory,
        where: 'account_id = ?',
        whereArgs: [accountId],
        orderBy: 'fetched_at DESC',
      );
      return rows.map(QuotaInfoModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException(
        'Failed to fetch quota history for account $accountId: $e',
      );
    }
  }

  /// Alias for getQuotaHistoryForAccount
  Future<List<QuotaInfoModel>> getHistory(int accountId) =>
      getQuotaHistoryForAccount(accountId);

  /// Latest snapshot for [accountId] or null when none exists.
  Future<QuotaInfoModel?> getLatestForAccount(int accountId) async {
    try {
      final db = await _helper.database;
      final rows = await db.query(
        DatabaseHelper.tableQuotaHistory,
        where: 'account_id = ?',
        whereArgs: [accountId],
        orderBy: 'fetched_at DESC',
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return QuotaInfoModel.fromMap(rows.first);
    } catch (e) {
      return null;
    }
  }

  /// Alias for getLatestForAccount
  Future<QuotaInfoModel?> getLatest(int accountId) =>
      getLatestForAccount(accountId);

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