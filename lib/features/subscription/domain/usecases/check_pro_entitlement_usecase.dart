import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/subscription/domain/repositories/subscription_repository.dart';

/// Checks if the current user has an active Scriptless Pro entitlement.
class CheckProEntitlementUseCase implements UseCase<bool, NoParams> {
  /// Creates a [CheckProEntitlementUseCase].
  const CheckProEntitlementUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    final result = await _repository.getSubscriptionStatus();
    return result.map((status) => status.isPro);
  }
}
