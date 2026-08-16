import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/subscription/domain/repositories/subscription_repository.dart';

/// Synchronizes authenticated user identity with RevenueCat.
class SyncSubscriptionAuthUseCase implements UseCase<Unit, String?> {
  /// Creates a [SyncSubscriptionAuthUseCase].
  const SyncSubscriptionAuthUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String? userId) async {
    if (userId != null && userId.isNotEmpty) {
      return _repository.logIn(userId);
    } else {
      return _repository.logOut();
    }
  }
}
