import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/subscription/domain/repositories/subscription_repository.dart';

/// Parameters for presenting the paywall.
class PresentPaywallParams {
  /// Creates a [PresentPaywallParams].
  const PresentPaywallParams({
    this.onlyIfNeeded = true,
    this.requiredEntitlementId,
  });

  /// Whether to only show if the user lacks the required entitlement.
  final bool onlyIfNeeded;

  /// Optional specific entitlement ID to check against.
  final String? requiredEntitlementId;
}

/// Presents the native RevenueCat Paywall UI.
///
/// Returns `true` if pro access is available after paywall closes.
class PresentPaywallUseCase implements UseCase<bool, PresentPaywallParams> {
  /// Creates a [PresentPaywallUseCase].
  const PresentPaywallUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, bool>> call(PresentPaywallParams params) async {
    if (params.onlyIfNeeded) {
      return _repository.presentPaywallIfNeeded(
        requiredEntitlementId: params.requiredEntitlementId,
      );
    } else {
      final result = await _repository.presentPaywall();
      return result.fold(
        Left.new,
        (_) async {
          final statusResult = await _repository.getSubscriptionStatus();
          return statusResult.map((status) => status.isPro);
        },
      );
    }
  }
}
