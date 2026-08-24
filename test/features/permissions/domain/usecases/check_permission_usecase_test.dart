import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_status.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_type.dart';
import 'package:scriptless/features/permissions/domain/repositories/permission_repository.dart';
import 'package:scriptless/features/permissions/domain/usecases/check_permission_usecase.dart';

class MockPermissionRepository extends Mock implements PermissionRepository {}

void main() {
  late MockPermissionRepository mockRepository;
  late CheckPermissionUseCase useCase;

  setUp(() {
    mockRepository = MockPermissionRepository();
    useCase = CheckPermissionUseCase(mockRepository);
  });

  group('CheckPermissionUseCase', () {
    test(
      'should return AppPermissionStatus when repository succeeds',
      () async {
        when(
          () => mockRepository.checkPermission(AppPermissionType.microphone),
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
          () => mockRepository.checkPermission(AppPermissionType.microphone),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return PermissionFailure when repository fails', () async {
      const tFailure = PermissionFailure('Check failed');
      when(
        () => mockRepository.checkPermission(AppPermissionType.notification),
      ).thenAnswer(
        (_) async => const Left<Failure, AppPermissionStatus>(tFailure),
      );

      final result = await useCase(AppPermissionType.notification);

      expect(
        result,
        const Left<Failure, AppPermissionStatus>(tFailure),
      );
      verify(
        () => mockRepository.checkPermission(AppPermissionType.notification),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
