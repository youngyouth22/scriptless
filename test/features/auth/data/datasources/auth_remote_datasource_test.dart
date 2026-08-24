import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/exceptions.dart';
import 'package:scriptless/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockUserResponse extends Mock implements UserResponse {}

class MockResendResponse extends Mock implements ResendResponse {}

void main() {

  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuth;
  late AuthRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(OAuthProvider.google);
    registerFallbackValue(OtpType.recovery);
    registerFallbackValue(UserAttributes());
  });



  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuth = MockGoogleSignInAuthentication();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(
      () => mockGoogleSignIn.initialize(
        serverClientId: any(named: 'serverClientId'),
      ),
    ).thenAnswer((_) async {});

    dataSource = AuthRemoteDataSourceImpl(
      mockSupabaseClient,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('signInWithGoogle', () {
    const tIdToken = 'fake-google-id-token';

    test(
      'should exchange idToken with Supabase when Google sign-in succeeds',
      () async {
        when(
          () => mockGoogleSignIn.authenticate(),
        ).thenAnswer((_) async => mockGoogleSignInAccount);
        when(
          () => mockGoogleSignInAccount.authentication,
        ).thenReturn(mockGoogleSignInAuth);
        when(() => mockGoogleSignInAuth.idToken).thenReturn(tIdToken);
        when(
          () => mockGoTrueClient.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: tIdToken,
          ),
        ).thenAnswer(
          (_) async => AuthResponse(),
        );

        await dataSource.signInWithGoogle();

        verify(() => mockGoogleSignIn.authenticate()).called(1);
        verify(
          () => mockGoTrueClient.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: tIdToken,
          ),
        ).called(1);
      },
    );

    test(
      'should throw AuthExceptionWrapper when Google Sign-In is cancelled',
      () async {
        when(() => mockGoogleSignIn.authenticate()).thenThrow(
          const GoogleSignInException(
            code: GoogleSignInExceptionCode.canceled,
            description: 'User cancelled',
          ),
        );

        expect(
          () => dataSource.signInWithGoogle(),
          throwsA(
            isA<AuthExceptionWrapper>().having(
              (e) => e.message,
              'message',
              'Google sign in was cancelled.',
            ),
          ),
        );
      },
    );

    test('should throw AuthExceptionWrapper when idToken is null', () async {
      when(
        () => mockGoogleSignIn.authenticate(),
      ).thenAnswer((_) async => mockGoogleSignInAccount);
      when(
        () => mockGoogleSignInAccount.authentication,
      ).thenReturn(mockGoogleSignInAuth);
      when(() => mockGoogleSignInAuth.idToken).thenReturn(null);

      expect(
        () => dataSource.signInWithGoogle(),
        throwsA(
          isA<AuthExceptionWrapper>().having(
            (e) => e.message,
            'message',
            'No ID token found for Google sign in.',
          ),
        ),
      );
    });
  });

  group('sendPasswordResetOtp', () {
    const tEmail = 'test@example.com';

    test('should call resetPasswordForEmail on Supabase auth', () async {
      when(
        () => mockGoTrueClient.resetPasswordForEmail(any()),
      ).thenAnswer((_) async {});

      await dataSource.sendPasswordResetOtp(email: tEmail);

      verify(() => mockGoTrueClient.resetPasswordForEmail(tEmail)).called(1);
    });

    test('should throw AuthExceptionWrapper on AuthException', () async {
      when(
        () => mockGoTrueClient.resetPasswordForEmail(any()),
      ).thenThrow(const AuthException('User not found'));

      expect(
        () => dataSource.sendPasswordResetOtp(email: tEmail),
        throwsA(
          isA<AuthExceptionWrapper>().having(
            (e) => e.message,
            'message',
            'User not found',
          ),
        ),
      );
    });
  });

  group('verifyPasswordResetOtp', () {
    const tEmail = 'test@example.com';
    const tToken = '123456';

    test('should call verifyOTP on Supabase auth', () async {
      when(
        () => mockGoTrueClient.verifyOTP(
          email: any(named: 'email'),
          token: any(named: 'token'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) async => AuthResponse());

      await dataSource.verifyPasswordResetOtp(email: tEmail, token: tToken);

      verify(
        () => mockGoTrueClient.verifyOTP(
          email: tEmail,
          token: tToken,
          type: OtpType.recovery,
        ),
      ).called(1);
    });
  });

  group('updatePassword', () {
    const tNewPassword = 'newPassword123!';

    test('should call updateUser on Supabase auth', () async {
      when(
        () => mockGoTrueClient.updateUser(any()),
      ).thenAnswer((_) async => MockUserResponse());

      await dataSource.updatePassword(newPassword: tNewPassword);

      verify(() => mockGoTrueClient.updateUser(any())).called(1);
    });
  });

  group('resendPasswordResetOtp', () {
    const tEmail = 'test@example.com';

    test('should call resend on Supabase auth', () async {
      when(
        () => mockGoTrueClient.resend(
          email: any(named: 'email'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) async => MockResendResponse());

      await dataSource.resendPasswordResetOtp(email: tEmail);

      verify(
        () => mockGoTrueClient.resend(
          email: tEmail,
          type: OtpType.recovery,
        ),
      ).called(1);
    });
  });

  group('verifySignUpOtp', () {
    const tEmail = 'test@example.com';
    const tToken = '123456';

    test('should call verifyOTP with OtpType.signup', () async {
      when(
        () => mockGoTrueClient.verifyOTP(
          email: any(named: 'email'),
          token: any(named: 'token'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) async => AuthResponse());

      await dataSource.verifySignUpOtp(email: tEmail, token: tToken);

      verify(
        () => mockGoTrueClient.verifyOTP(
          email: tEmail,
          token: tToken,
          type: OtpType.signup,
        ),
      ).called(1);
    });
  });

  group('resendSignUpOtp', () {
    const tEmail = 'test@example.com';

    test('should call resend with OtpType.signup', () async {
      when(
        () => mockGoTrueClient.resend(
          email: any(named: 'email'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) async => MockResendResponse());

      await dataSource.resendSignUpOtp(email: tEmail);

      verify(
        () => mockGoTrueClient.resend(
          email: tEmail,
          type: OtpType.signup,
        ),
      ).called(1);
    });
  });
}
