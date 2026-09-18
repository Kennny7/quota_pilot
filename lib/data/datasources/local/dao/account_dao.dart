// lib/data/datasources/local/dao/account_dao.dart

import 'package:sqflite/sqflite.dart';
import '../../../models/account.dart';
import '../database_helper.dart';

class AccountDao {
  final DatabaseHelper _helper;
  AccountDao(this._helper);

  Future<List<AccountModel>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query('accounts', orderBy: 'created_at DESC');
    return rows.map(AccountModel.fromMap).toList();
  }

  Future<AccountModel?> getById(int id) async {
    final db = await _helper.database;
    final rows = await db.query('accounts', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : AccountModel.fromMap(rows.first);
  }

  Future<int> insert(AccountModel account) async {
    final db = await _helper.database;
    return db.insert('accounts', account.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(AccountModel account) async {
    assert(account.id != null, 'Cannot update an account without an id');
    final db = await _helper.database;
    await db.update('accounts', account.toMap(),
        where: 'id = ?', whereArgs: [account.id]);
  }

  Future<void> delete(int id) async {
    final db = await _helper.database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }
}