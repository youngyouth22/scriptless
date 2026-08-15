// UseCase is intentionally an abstract class (interface) despite having a
// single method — removing it would break the contract-based architecture.
// ignore_for_file: one_member_abstracts
import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';

/// Base interface for all use cases.
///
/// [T] is the return type on success.
/// [P] is the parameter object passed to [call].
abstract class UseCase<T, P> {
  /// Executes the use case with [params].
  Future<Either<Failure, T>> call(P params);
}

/// Use this when a use case requires no input parameters.
class NoParams {
  /// Default constructor.
  const NoParams();
}
