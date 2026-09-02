import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_finance/models/user.dart';
import 'package:my_finance/services/auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {
}
class MockUserCredential extends Mock implements UserCredential {
}
class MockUser extends Mock implements User {
}
class MockUserStore extends Mock implements UserStore {
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const AppUser(uid: 'fallback', name: 'fallback', email: 'fallback'),
    );
  });

  late MockFirebaseAuth mockAuth;
  late MockUserStore mockUserStore;
  late MockUserCredential mockCredential;
  late MockUser mockUser;
  late AuthService authService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUserStore = MockUserStore();
    mockCredential = MockUserCredential();
    mockUser = MockUser();

    when(() => mockAuth.authStateChanges()).thenAnswer(
      (_) => const Stream<User?>.empty(),
    );

    authService = AuthService(
      auth: mockAuth,
      userStore: mockUserStore,
    );
  });

  group('signIn', () {
    test('deve chamar signInWithEmailAndPassword com email e senha corretos',
        () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);

      await authService.signIn('teste@teste.com', 'Senha@123');

      verify(() => mockAuth.signInWithEmailAndPassword(
            email: 'teste@teste.com',
            password: 'Senha@123',
          )).called(1);
    });

    test('deve propagar erro quando credenciais são inválidas', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        FirebaseAuthException(
          code: 'invalid-credential',
          message: 'The supplied auth credential is incorrect.',
        ),
      );

      expect(
        () => authService.signIn('teste@teste.com', 'senhaerrada'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('deve propagar erro quando email não existe', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        FirebaseAuthException(
          code: 'user-not-found',
          message: 'There is no user corresponding to this email.',
        ),
      );

      expect(
        () => authService.signIn('naoexiste@teste.com', 'Senha@123'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('deve propagar erro quando senha está incorreta', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        FirebaseAuthException(
          code: 'wrong-password',
          message: 'The password is invalid.',
        ),
      );

      expect(
        () => authService.signIn('teste@teste.com', 'senhaerrada'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('deve propagar erro quando email é inválido', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        FirebaseAuthException(
          code: 'invalid-email',
          message: 'The email address is badly formatted.',
        ),
      );

      expect(
        () => authService.signIn('emailinvalido', 'Senha@123'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('deve propagar erro quando conta está desativada', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        FirebaseAuthException(
          code: 'user-disabled',
          message: 'The user account has been disabled.',
        ),
      );

      expect(
        () => authService.signIn('desativado@teste.com', 'Senha@123'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('deve propagar erro quando há muitas tentativas', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        FirebaseAuthException(
          code: 'too-many-requests',
          message: 'Too many requests.',
        ),
      );

      expect(
        () => authService.signIn('teste@teste.com', 'Senha@123'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  group('register', () {
    setUp(() {
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('uid-novo-123');
      when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});
      when(() => mockUserStore.saveUser(any())).thenAnswer((_) async {});
    });

    test('deve criar usuário e salvar dados no UserStore', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);

      await authService.register(
        name: 'Rafael',
        email: 'rafael@teste.com',
        password: 'Senha@123',
      );

      verify(() => mockAuth.createUserWithEmailAndPassword(
            email: 'rafael@teste.com',
            password: 'Senha@123',
          )).called(1);

      verify(() => mockUser.updateDisplayName('Rafael')).called(1);

      final savedUser = verify(
        () => mockUserStore.saveUser(captureAny()),
      ).captured.single as AppUser;

      expect(savedUser.uid, 'uid-novo-123');
      expect(savedUser.name, 'Rafael');
      expect(savedUser.email, 'rafael@teste.com');
    });

    test('deve usar o uid do usuário criado para salvar', () async {
      when(() => mockUser.uid).thenReturn('uid-especifico-456');
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);

      await authService.register(
        name: 'Maria',
        email: 'maria@teste.com',
        password: 'Senha@456',
      );

      final savedUser = verify(
        () => mockUserStore.saveUser(captureAny()),
      ).captured.single as AppUser;

      expect(savedUser.uid, 'uid-especifico-456');
      expect(savedUser.name, 'Maria');
    });

    test('deve propagar erro quando email já está em uso', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'The email address is already in use.',
        ),
      );

      expect(
        () => authService.register(
          name: 'Rafael',
          email: 'existente@teste.com',
          password: 'Senha@123',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('deve propagar erro quando senha é fraca', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        FirebaseAuthException(
          code: 'weak-password',
          message: 'The given password is too weak.',
        ),
      );

      expect(
        () => authService.register(
          name: 'Rafael',
          email: 'rafael@teste.com',
          password: '123',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('deve propagar erro quando email é inválido', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        FirebaseAuthException(
          code: 'invalid-email',
          message: 'The email address is badly formatted.',
        ),
      );

      expect(
        () => authService.register(
          name: 'Rafael',
          email: 'emailinvalido',
          password: 'Senha@123',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  group('signOut', () {
    test('deve chamar signOut no FirebaseAuth', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await authService.signOut();

      verify(() => mockAuth.signOut()).called(1);
    });

    test('deve definir appUser como null após signOut', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await authService.signOut();

      expect(authService.appUser, isNull);
    });

    test('deve propagar erro do FirebaseAuth ao fazer signOut', () async {
      when(() => mockAuth.signOut()).thenThrow(
        FirebaseAuthException(
          code: 'network-request-failed',
          message: 'A network error occurred.',
        ),
      );

      expect(
        () => authService.signOut(),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  group('authStateChanges', () {
    test('deve retornar stream do FirebaseAuth', () {
      final stream = authService.authStateChanges;

      expect(stream, isA<Stream<User?>>());
    });
  });

  group('firebaseUser', () {
    test('deve retornar currentUser do FirebaseAuth', () {
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      expect(authService.firebaseUser, equals(mockUser));
    });

    test('deve retornar null quando não há usuário logado', () {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(authService.firebaseUser, isNull);
    });
  });

  group('AppUser model', () {
    test('deve criar AppUser com dados corretos', () {
      const user = AppUser(
        uid: 'uid-123',
        name: 'Rafael',
        email: 'rafael@teste.com',
      );

      expect(user.uid, 'uid-123');
      expect(user.name, 'Rafael');
      expect(user.email, 'rafael@teste.com');
    });

    test('deve serializar para Map corretamente', () {
      const user = AppUser(
        uid: 'uid-123',
        name: 'Rafael',
        email: 'rafael@teste.com',
      );

      final map = user.toMap();

      expect(map['uid'], 'uid-123');
      expect(map['name'], 'Rafael');
      expect(map['email'], 'rafael@teste.com');
    });

    test('deve deserializar de Map corretamente', () {
      final map = {
        'uid': 'uid-456',
        'name': 'Maria',
        'email': 'maria@teste.com',
      };

      final user = AppUser.fromMap(map);

      expect(user.uid, 'uid-456');
      expect(user.name, 'Maria');
      expect(user.email, 'maria@teste.com');
    });

    test('deve tratar campos nulos no fromMap', () {
      final map = <String, dynamic>{};

      final user = AppUser.fromMap(map);

      expect(user.uid, '');
      expect(user.name, '');
      expect(user.email, '');
    });

    test('fromFirebase deve usar uid e email do User do Firebase', () {
      when(() => mockUser.uid).thenReturn('fb-uid-789');
      when(() => mockUser.email).thenReturn('firebase@teste.com');
      when(() => mockUser.displayName).thenReturn(null);

      final user = AppUser.fromFirebase(mockUser);

      expect(user.uid, 'fb-uid-789');
      expect(user.email, 'firebase@teste.com');
      expect(user.name, '');
    });

    test('fromFirebase deve usar displayName quando disponível', () {
      when(() => mockUser.uid).thenReturn('fb-uid-789');
      when(() => mockUser.email).thenReturn('firebase@teste.com');
      when(() => mockUser.displayName).thenReturn('Firebase User');

      final user = AppUser.fromFirebase(mockUser);

      expect(user.name, 'Firebase User');
    });

    test('fromFirebase deve aceitar name parametrizado', () {
      when(() => mockUser.uid).thenReturn('fb-uid-789');
      when(() => mockUser.email).thenReturn('firebase@teste.com');
      when(() => mockUser.displayName).thenReturn('Original');

      final user = AppUser.fromFirebase(mockUser, name: 'Custom Name');

      expect(user.name, 'Custom Name');
    });

    test('toMap e fromMap devem ser inversos', () {
      const original = AppUser(
        uid: 'uid-roundtrip',
        name: 'Roundtrip Test',
        email: 'roundtrip@teste.com',
      );

      final map = original.toMap();
      final restored = AppUser.fromMap(map);

      expect(restored.uid, original.uid);
      expect(restored.name, original.name);
      expect(restored.email, original.email);
    });
  });
}
