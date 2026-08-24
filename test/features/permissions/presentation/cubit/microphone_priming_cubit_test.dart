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
import 'package:scriptless/features/permissions/presentation/cubit/microphone_priming_cubit.dart';
import 'package:scriptless/features/permissions/presentation/cubit/microphone_priming_state.dart';

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

  MicrophonePrimingCubit buildCubit() {
    return MicrophonePrimingCubit(
      checkPermission: mockCheckPermission,
      requestPermission: mockRequestPermission,
      openAppSettings: mockOpenAppSettings,
    );
  }

  group('MicrophonePrimingCubit', () {
    test('initial state should be MicrophonePrimingInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, const MicrophonePrimingInitial());
    });

    blocTest<MicrophonePrimingCubit, MicrophonePrimingState>(
      'checkStatus emits [MicrophonePrimingGranted] when status is granted',
      build: () {
        when(
          () => mockCheckPermission(AppPermissionType.microphone),
        ).thenAnswer((_) async => const Right(AppPermissionStatus.granted));
        return buildCubit();
      },
      act: (cubit) => cubit.checkStatus(),
      expect: () => [
        const MicrophonePrimingGranted(),
      ],
    );

    blocTest<MicrophonePrimingCubit, MicrophonePrimingState>(
      'checkStatus emits [MicrophonePrimingPermanentlyDenied] '
      'when permanently denied',
      build: () {
        when(
          () => mockCheckPermission(AppPermissionType.microphone),
        ).thenAnswer(
          (_) async => const Right(AppPermissionStatus.permanentlyDenied),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.checkStatus(),
      expect: () => [
        const MicrophonePrimingPermanentlyDenied(),
      ],
    );

    blocTest<MicrophonePrimingCubit, MicrophonePrimingState>(
      'checkStatus emits [MicrophonePrimingInitial(denied)] when denied',
      build: () {
        when(
          () => mockCheckPermission(AppPermissionType.microphone),
        ).thenAnswer((_) async => const Right(AppPermissionStatus.denied));
        return buildCubit();
      },
      act: (cubit) => cubit.checkStatus(),
      expect: () => [
        const MicrophonePrimingInitial(status: AppPermissionStatus.denied),
      ],
    );

    blocTest<MicrophonePrimingCubit, MicrophonePrimingState>(
      'checkStatus emits [MicrophonePrimingFailure] when check fails',
      build: () {
        when(
          () => mockCheckPermission(AppPermissionType.microphone),
        ).thenAnswer(
          (_) async => const Left(PermissionFailure('Check error')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.checkStatus(),
      expect: () => [
        const MicrophonePrimingFailure(PermissionFailure('Check error')),
      ],
    );

    blocTest<MicrophonePrimingCubit, MicrophonePrimingState>(
      'requestMicrophonePermission emits [Requesting, Granted] on success',
      build: () {
        when(
          () => mockRequestPermission(AppPermissionType.microphone),
        ).thenAnswer((_) async => const Right(AppPermissionStatus.granted));
        return buildCubit();
      },
      act: (cubit) => cubit.requestMicrophonePermission(),
      expect: () => [
        const MicrophonePrimingRequesting(),
        const MicrophonePrimingGranted(),
      ],
    );

    blocTest<MicrophonePrimingCubit, MicrophonePrimingState>(
      'requestMicrophonePermission emits [Requesting, Denied] when denied',
      build: () {
        when(
          () => mockRequestPermission(AppPermissionType.microphone),
        ).thenAnswer((_) async => const Right(AppPermissionStatus.denied));
        return buildCubit();
      },
      act: (cubit) => cubit.requestMicrophonePermission(),
      expect: () => [
        const MicrophonePrimingRequesting(),
        const MicrophonePrimingDenied(),
      ],
    );

    blocTest<MicrophonePrimingCubit, MicrophonePrimingState>(
      'requestMicrophonePermission emits [Requesting, PermanentlyDenied] '
      'when permanently denied',
      build: () {
        when(
          () => mockRequestPermission(AppPermissionType.microphone),
        ).thenAnswer(
          (_) async => const Right(AppPermissionStatus.permanentlyDenied),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.requestMicrophonePermission(),
      expect: () => [
        const MicrophonePrimingRequesting(),
        const MicrophonePrimingPermanentlyDenied(),
      ],
    );

    blocTest<MicrophonePrimingCubit, MicrophonePrimingState>(
      'requestMicrophonePermission emits [Requesting, Failure] on error',
      build: () {
        when(
          () => mockRequestPermission(AppPermissionType.microphone),
        ).thenAnswer(
          (_) async => const Left(PermissionFailure('Request error')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.requestMicrophonePermission(),
      expect: () => [
        const MicrophonePrimingRequesting(),
        const MicrophonePrimingFailure(PermissionFailure('Request error')),
      ],
    );

    blocTest<MicrophonePrimingCubit, MicrophonePrimingState>(
      'skip emits [MicrophonePrimingSkipped]',
      build: buildCubit,
      act: (cubit) => cubit.skip(),
      expect: () => [
        const MicrophonePrimingSkipped(),
      ],
    );

    blocTest<MicrophonePrimingCubit, MicrophonePrimingState>(
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
