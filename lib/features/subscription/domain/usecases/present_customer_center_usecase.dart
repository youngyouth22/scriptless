import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/subscription/domain/repositories/subscription_repository.dart';

/// Opens RevenueCat Customer Center for self-service subscription management.
class PresentCustomerCenterUseCase implements UseCase<Unit, NoParams> {
  /// Creates a [PresentCustomerCenterUseCase].
  const PresentCustomerCenterUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) =>
      _repository.presentCustomerCenter();
}
