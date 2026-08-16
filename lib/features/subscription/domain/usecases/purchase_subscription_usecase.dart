import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_package.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_status.dart';
import 'package:scriptless/features/subscription/domain/repositories/subscription_repository.dart';

/// Purchases a given [SubscriptionPackage].
class PurchaseSubscriptionUseCase
    implements UseCase<SubscriptionStatus, SubscriptionPackage> {
  /// Creates a [PurchaseSubscriptionUseCase].
  const PurchaseSubscriptionUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, SubscriptionStatus>> call(
    SubscriptionPackage package,
  ) =>
      _repository.purchasePackage(package);
}
