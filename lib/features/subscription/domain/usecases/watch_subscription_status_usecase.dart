import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_status.dart';
import 'package:scriptless/features/subscription/domain/repositories/subscription_repository.dart';

/// Stream-based use case to watch real-time subscription status changes.
class WatchSubscriptionStatusUseCase {
  /// Creates a [WatchSubscriptionStatusUseCase].
  const WatchSubscriptionStatusUseCase(this._repository);

  final SubscriptionRepository _repository;

  /// Returns a stream of [SubscriptionStatus] updates.
  Stream<Either<Failure, SubscriptionStatus>> call() =>
      _repository.watchSubscriptionStatus();
}
