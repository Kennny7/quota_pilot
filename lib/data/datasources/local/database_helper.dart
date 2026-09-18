// lib/data/datasources/local/database_helper.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton helper that owns the SQLite connection and schema migrations.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'quota_pilot.db';
  static const int _dbVersion = 1;

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
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        // Enforce FK constraints (quota_history.account_id -> accounts.id)
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
        auth_data TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableQuotaHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER,
        quota_data TEXT,
        fetched_at TEXT,
        FOREIGN KEY (account_id) REFERENCES $tableAccounts (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableServiceDefinitions (
        id TEXT PRIMARY KEY,
        name TEXT,
        logo_url TEXT,
        supports_api INTEGER,
        supports_manual INTEGER
      )
    ''');

    // Helpful indexes for the most common query patterns.
    await db.execute(
      'CREATE INDEX idx_accounts_service ON $tableAccounts (service_id)',
    );
    await db.execute(
      'CREATE INDEX idx_quota_account_time '
      'ON $tableQuotaHistory (account_id, fetched_at DESC)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration hooks go here as the schema evolves.
  }

  /// For tests / logout flows.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<void> deleteDatabaseFile() async {
    final path = join(await getDatabasesPath(), _dbName);
    await deleteDatabase(path);
    _db = null;
  }
}