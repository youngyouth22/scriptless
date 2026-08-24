import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/permissions/data/datasources/permission_local_datasource.dart';
import 'package:scriptless/features/permissions/data/repositories/permission_repository_impl.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_status.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_type.dart';

class MockPermissionLocalDataSource extends Mock
    implements PermissionLocalDataSource {}

void main() {
  late MockPermissionLocalDataSource mockDataSource;
  late PermissionRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockPermissionLocalDataSource();
    repository = PermissionRepositoryImpl(mockDataSource);
  });

  group('PermissionRepositoryImpl', () {
    group('checkPermission', () {
      test(
        'should return AppPermissionStatus.granted when ph returns granted',
        () async {
          when(
            () => mockDataSource.checkPermission(AppPermissionType.microphone),
          ).thenAnswer((_) async => ph.PermissionStatus.granted);

          final result =
              await repository.checkPermission(AppPermissionType.microphone);

          expect(
            result,
            const Right<Failure, AppPermissionStatus>(
              AppPermissionStatus.granted,
            ),
          );
          verify(
            () => mockDataSource.checkPermission(AppPermissionType.microphone),
          ).called(1);
        },
      );

      test(
        'should return permanentlyDenied when ph returns permanentlyDenied',
        () async {
          when(
            () => mockDataSource.checkPermission(
              AppPermissionType.notification,
            ),
          ).thenAnswer((_) async => ph.PermissionStatus.permanentlyDenied);

          final result =
              await repository.checkPermission(AppPermissionType.notification);

          expect(
            result,
            const Right<Failure, AppPermissionStatus>(
              AppPermissionStatus.permanentlyDenied,
            ),
          );
        },
      );

      test(
        'should return PermissionFailure when datasource throws',
        () async {
          when(
            () => mockDataSource.checkPermission(AppPermissionType.microphone),
          ).thenThrow(Exception('Platform error'));

          final result =
              await repository.checkPermission(AppPermissionType.microphone);

          expect(result, isA<Left<Failure, AppPermissionStatus>>());
        },
      );
    });

    group('requestPermission', () {
      test(
        'should return AppPermissionStatus.granted when request is granted',
        () async {
          when(
            () =>
                mockDataSource.requestPermission(AppPermissionType.microphone),
          ).thenAnswer((_) async => ph.PermissionStatus.granted);

          final result =
              await repository.requestPermission(AppPermissionType.microphone);

          expect(
            result,
            const Right<Failure, AppPermissionStatus>(
              AppPermissionStatus.granted,
            ),
          );
        },
      );

      test(
        'should return AppPermissionStatus.denied when request is denied',
        () async {
          when(
            () => mockDataSource.requestPermission(
              AppPermissionType.notification,
            ),
          ).thenAnswer((_) async => ph.PermissionStatus.denied);

          final result =
              await repository.requestPermission(
            AppPermissionType.notification,
          );

          expect(
            result,
            const Right<Failure, AppPermissionStatus>(
              AppPermissionStatus.denied,
            ),
          );
        },
      );

      test(
        'should return PermissionFailure when request throws',
        () async {
          when(
            () =>
                mockDataSource.requestPermission(AppPermissionType.microphone),
          ).thenThrow(Exception('Request error'));

          final result =
              await repository.requestPermission(AppPermissionType.microphone);

          expect(result, isA<Left<Failure, AppPermissionStatus>>());
        },
      );
    });

    group('openAppSettings', () {
      test('should return true when openAppSettings succeeds', () async {
        when(
          () => mockDataSource.openAppSettings(),
        ).thenAnswer((_) async => true);

        final result = await repository.openAppSettings();

        expect(result, const Right<Failure, bool>(true));
      });

      test(
        'should return PermissionFailure when openAppSettings throws',
        () async {
          when(
            () => mockDataSource.openAppSettings(),
          ).thenThrow(Exception('Settings error'));

          final result = await repository.openAppSettings();

          expect(result, isA<Left<Failure, bool>>());
        },
      );
    });
  });
}
