// lib/domain/usecases/add_account.dart

import '../entities/account.dart';
import '../repositories/i_account_repository.dart';

class AddAccount {
  final IAccountRepository _repository;
  AddAccount(this._repository);

  Future<void> call(Account account) => _repository.addAccount(account);
}