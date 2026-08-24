import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/permissions/domain/repositories/permission_repository.dart';
import 'package:scriptless/features/permissions/domain/usecases/open_app_settings_usecase.dart';

class MockPermissionRepository extends Mock implements PermissionRepository {}

void main() {
  late MockPermissionRepository mockRepository;
  late OpenAppSettingsUseCase useCase;

  setUp(() {
    mockRepository = MockPermissionRepository();
    useCase = OpenAppSettingsUseCase(mockRepository);
  });

  group('OpenAppSettingsUseCase', () {
    test('should return true when openAppSettings succeeds', () async {
      when(
        () => mockRepository.openAppSettings(),
      ).thenAnswer((_) async => const Right<Failure, bool>(true));

      final result = await useCase(const NoParams());

      expect(result, const Right<Failure, bool>(true));
      verify(() => mockRepository.openAppSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return PermissionFailure when openAppSettings fails',
      () async {
        const tFailure = PermissionFailure('Unable to open settings');
        when(
          () => mockRepository.openAppSettings(),
        ).thenAnswer((_) async => const Left<Failure, bool>(tFailure));

        final result = await useCase(const NoParams());

        expect(result, const Left<Failure, bool>(tFailure));
        verify(() => mockRepository.openAppSettings()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}
