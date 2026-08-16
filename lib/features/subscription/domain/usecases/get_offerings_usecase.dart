import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_package.dart';
import 'package:scriptless/features/subscription/domain/repositories/subscription_repository.dart';

/// Fetches available subscription offerings and purchasable packages.
class GetOfferingsUseCase
    implements UseCase<List<SubscriptionPackage>, NoParams> {
  /// Creates a [GetOfferingsUseCase].
  const GetOfferingsUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, List<SubscriptionPackage>>> call(NoParams params) =>
      _repository.getOfferings();
}
