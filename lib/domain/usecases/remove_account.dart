// lib/domain/usecases/remove_account.dart

import '../repositories/i_account_repository.dart';

class RemoveAccount {
  final IAccountRepository _repository;
  RemoveAccount(this._repository);

  Future<void> call(int accountId) => _repository.removeAccount(accountId);
}