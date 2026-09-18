// lib/domain/repositories/i_account_repository.dart

import '../entities/account.dart';

abstract class IAccountRepository {
  Future<List<Account>> getAllAccounts();
  Future<Account?> getAccountById(int id);
  Future<int> addAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> removeAccount(int accountId);
}