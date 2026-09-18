// lib/data/datasources/local/database_helper.dart

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton helper that owns the SQLite connection and schema migrations.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  static const String _dbName = 'quota_pilot.db';
  static const int _dbVersion = 2;

  static const String tableAccounts = 'accounts';
  static const String tableQuotaHistory = 'quota_history';
  static const String tableServiceDefinitions = 'service_definitions';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    if (kIsWeb) {
      // In web builds without sqlite3_flutter_libs ffi web worker,
      // inMemoryDatabasePath is used so the app boots seamlessly.
      return openDatabase(
        inMemoryDatabasePath,
        version: _dbVersion,
        onCreate: _onCreate,
      );
    }

    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableAccounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        service_id TEXT NOT NULL,
        auth_type TEXT NOT NULL,
        api_key TEXT,
        base_url TEXT,
        auth_data TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableQuotaHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        quota_data TEXT,
        fetched_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES $tableAccounts (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableServiceDefinitions (
        id TEXT PRIMARY KEY,
        name TEXT,
        supports_api INTEGER,
        supports_manual INTEGER
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_accounts_service ON $tableAccounts (service_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_quota_account_time '
      'ON $tableQuotaHistory (account_id, fetched_at DESC)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE $tableAccounts ADD COLUMN api_key TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE $tableAccounts ADD COLUMN base_url TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE $tableAccounts ADD COLUMN updated_at TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE $tableAccounts ADD COLUMN is_active INTEGER DEFAULT 1');
      } catch (_) {}
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<void> deleteDatabaseFile() async {
    if (kIsWeb) {
      _db = null;
      return;
    }
    final path = join(await getDatabasesPath(), _dbName);
    await deleteDatabase(path);
    _db = null;
  }
}