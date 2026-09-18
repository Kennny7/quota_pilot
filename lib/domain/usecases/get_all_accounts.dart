// lib/domain/usecases/get_all_accounts.dart

import '../entities/account.dart';
import '../repositories/i_account_repository.dart';

class GetAllAccounts {
  final IAccountRepository _repository;
  GetAllAccounts(this._repository);

  Future<List<Account>> call() => _repository.getAllAccounts();
}