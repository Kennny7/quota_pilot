// lib/data/repositories/account_repository.dart

import '../../domain/entities/account.dart';
import '../../domain/repositories/i_account_repository.dart';
import '../datasources/local/dao/account_dao.dart';
import '../models/account.dart';

class AccountRepositoryImpl implements IAccountRepository {
  final AccountDao _dao;
  AccountRepositoryImpl(this._dao);

  @override
  Future<List<Account>> getAllAccounts() => _dao.getAll();

  @override
  Future<Account?> getAccountById(int id) => _dao.getById(id);

  @override
  Future<int> addAccount(Account account) =>
      _dao.insert(AccountModel.fromEntity(account));

  @override
  Future<void> updateAccount(Account account) =>
      _dao.update(AccountModel.fromEntity(account));

  @override
  Future<void> removeAccount(int accountId) => _dao.delete(accountId);
}