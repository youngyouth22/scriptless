import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_status.dart';
import 'package:scriptless/features/subscription/domain/repositories/subscription_repository.dart';

/// Restores previously completed purchases for the user.
class RestorePurchasesUseCase implements UseCase<SubscriptionStatus, NoParams> {
  /// Creates a [RestorePurchasesUseCase].
  const RestorePurchasesUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, SubscriptionStatus>> call(NoParams params) =>
      _repository.restorePurchases();
}
