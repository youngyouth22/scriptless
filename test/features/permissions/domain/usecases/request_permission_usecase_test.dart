import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_status.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_type.dart';
import 'package:scriptless/features/permissions/domain/repositories/permission_repository.dart';
import 'package:scriptless/features/permissions/domain/usecases/request_permission_usecase.dart';

class MockPermissionRepository extends Mock implements PermissionRepository {}

void main() {
  late MockPermissionRepository mockRepository;
  late RequestPermissionUseCase useCase;

  setUp(() {
    mockRepository = MockPermissionRepository();
    useCase = RequestPermissionUseCase(mockRepository);
  });

  group('RequestPermissionUseCase', () {
    test('should return AppPermissionStatus when request succeeds', () async {
      when(
        () => mockRepository.requestPermission(AppPermissionType.microphone),
      ).thenAnswer(
        (_) async => const Right<Failure, AppPermissionStatus>(
          AppPermissionStatus.granted,
        ),
      );

      final result = await useCase(AppPermissionType.microphone);

      expect(
        result,
        const Right<Failure, AppPermissionStatus>(
          AppPermissionStatus.granted,
        ),
      );
      verify(
        () => mockRepository.requestPermission(AppPermissionType.microphone),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return PermissionFailure when request fails', () async {
      const tFailure = PermissionFailure('Request failed');
      when(
        () => mockRepository.requestPermission(AppPermissionType.notification),
      ).thenAnswer(
        (_) async => const Left<Failure, AppPermissionStatus>(tFailure),
      );

      final result = await useCase(AppPermissionType.notification);

      expect(
        result,
        const Left<Failure, AppPermissionStatus>(tFailure),
      );
      verify(
        () => mockRepository.requestPermission(AppPermissionType.notification),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
