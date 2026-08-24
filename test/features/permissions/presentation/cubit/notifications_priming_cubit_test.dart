import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_status.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_type.dart';
import 'package:scriptless/features/permissions/domain/usecases/check_permission_usecase.dart';
import 'package:scriptless/features/permissions/domain/usecases/open_app_settings_usecase.dart';
import 'package:scriptless/features/permissions/domain/usecases/request_permission_usecase.dart';
import 'package:scriptless/features/permissions/presentation/cubit/notifications_priming_cubit.dart';
import 'package:scriptless/features/permissions/presentation/cubit/notifications_priming_state.dart';

class MockCheckPermissionUseCase extends Mock
    implements CheckPermissionUseCase {}

class MockRequestPermissionUseCase extends Mock
    implements RequestPermissionUseCase {}

class MockOpenAppSettingsUseCase extends Mock
    implements OpenAppSettingsUseCase {}

void main() {
  late MockCheckPermissionUseCase mockCheckPermission;
  late MockRequestPermissionUseCase mockRequestPermission;
  late MockOpenAppSettingsUseCase mockOpenAppSettings;

  setUp(() {
    mockCheckPermission = MockCheckPermissionUseCase();
    mockRequestPermission = MockRequestPermissionUseCase();
    mockOpenAppSettings = MockOpenAppSettingsUseCase();
  });

  NotificationsPrimingCubit buildCubit() {
    return NotificationsPrimingCubit(
      checkPermission: mockCheckPermission,
      requestPermission: mockRequestPermission,
      openAppSettings: mockOpenAppSettings,
    );
  }

  group('NotificationsPrimingCubit', () {
    test('initial state should be NotificationsPrimingInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, const NotificationsPrimingInitial());
    });

    blocTest<NotificationsPrimingCubit, NotificationsPrimingState>(
      'checkStatus emits [NotificationsPrimingGranted] when status is granted',
      build: () {
        when(
          () => mockCheckPermission(AppPermissionType.notification),
        ).thenAnswer((_) async => const Right(AppPermissionStatus.granted));
        return buildCubit();
      },
      act: (cubit) => cubit.checkStatus(),
      expect: () => [
        const NotificationsPrimingGranted(),
      ],
    );

    blocTest<NotificationsPrimingCubit, NotificationsPrimingState>(
      'checkStatus emits [NotificationsPrimingPermanentlyDenied] '
      'when permanently denied',
      build: () {
        when(
          () => mockCheckPermission(AppPermissionType.notification),
        ).thenAnswer(
          (_) async => const Right(AppPermissionStatus.permanentlyDenied),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.checkStatus(),
      expect: () => [
        const NotificationsPrimingPermanentlyDenied(),
      ],
    );

    blocTest<NotificationsPrimingCubit, NotificationsPrimingState>(
      'checkStatus emits [NotificationsPrimingInitial(denied)] when denied',
      build: () {
        when(
          () => mockCheckPermission(AppPermissionType.notification),
        ).thenAnswer((_) async => const Right(AppPermissionStatus.denied));
        return buildCubit();
      },
      act: (cubit) => cubit.checkStatus(),
      expect: () => [
        const NotificationsPrimingInitial(status: AppPermissionStatus.denied),
      ],
    );

    blocTest<NotificationsPrimingCubit, NotificationsPrimingState>(
      'checkStatus emits [NotificationsPrimingFailure] when check fails',
      build: () {
        when(
          () => mockCheckPermission(AppPermissionType.notification),
        ).thenAnswer(
          (_) async => const Left(PermissionFailure('Check error')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.checkStatus(),
      expect: () => [
        const NotificationsPrimingFailure(PermissionFailure('Check error')),
      ],
    );

    blocTest<NotificationsPrimingCubit, NotificationsPrimingState>(
      'requestNotificationPermission emits [Requesting, Granted] on success',
      build: () {
        when(
          () => mockRequestPermission(AppPermissionType.notification),
        ).thenAnswer((_) async => const Right(AppPermissionStatus.granted));
        return buildCubit();
      },
      act: (cubit) => cubit.requestNotificationPermission(),
      expect: () => [
        const NotificationsPrimingRequesting(),
        const NotificationsPrimingGranted(),
      ],
    );

    blocTest<NotificationsPrimingCubit, NotificationsPrimingState>(
      'requestNotificationPermission emits [Requesting, Denied] when denied',
      build: () {
        when(
          () => mockRequestPermission(AppPermissionType.notification),
        ).thenAnswer((_) async => const Right(AppPermissionStatus.denied));
        return buildCubit();
      },
      act: (cubit) => cubit.requestNotificationPermission(),
      expect: () => [
        const NotificationsPrimingRequesting(),
        const NotificationsPrimingDenied(),
      ],
    );

    blocTest<NotificationsPrimingCubit, NotificationsPrimingState>(
      'requestNotificationPermission emits [Requesting, PermanentlyDenied] '
      'when permanently denied',
      build: () {
        when(
          () => mockRequestPermission(AppPermissionType.notification),
        ).thenAnswer(
          (_) async => const Right(AppPermissionStatus.permanentlyDenied),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.requestNotificationPermission(),
      expect: () => [
        const NotificationsPrimingRequesting(),
        const NotificationsPrimingPermanentlyDenied(),
      ],
    );

    blocTest<NotificationsPrimingCubit, NotificationsPrimingState>(
      'requestNotificationPermission emits [Requesting, Failure] on error',
      build: () {
        when(
          () => mockRequestPermission(AppPermissionType.notification),
        ).thenAnswer(
          (_) async => const Left(PermissionFailure('Request error')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.requestNotificationPermission(),
      expect: () => [
        const NotificationsPrimingRequesting(),
        const NotificationsPrimingFailure(PermissionFailure('Request error')),
      ],
    );

    blocTest<NotificationsPrimingCubit, NotificationsPrimingState>(
      'skip emits [NotificationsPrimingSkipped]',
      build: buildCubit,
      act: (cubit) => cubit.skip(),
      expect: () => [
        const NotificationsPrimingSkipped(),
      ],
    );

    blocTest<NotificationsPrimingCubit, NotificationsPrimingState>(
      'openSettings delegates to OpenAppSettingsUseCase',
      build: () {
        when(
          () => mockOpenAppSettings(const NoParams()),
        ).thenAnswer((_) async => const Right(true));
        return buildCubit();
      },
      act: (cubit) => cubit.openSettings(),
      verify: (_) {
        verify(() => mockOpenAppSettings(const NoParams())).called(1);
      },
    );
  });
}
