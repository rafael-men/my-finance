import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_finance/models/user.dart';
import 'package:my_finance/services/auth_service.dart';
import 'package:my_finance/utils/photo_utils.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {
}

class MockUserStore extends Mock implements UserStore {
}

class MockUser extends Mock implements User {
}

class MockImagePicker extends Mock implements ImagePicker {
}

void main() {
  setUpAll(() {
    registerFallbackValue(ImageSource.gallery);
    registerFallbackValue(
      const AppUser(uid: 'fallback', name: 'fallback', email: 'fallback'),
    );
  });

  late MockFirebaseAuth mockAuth;
  late MockUserStore mockUserStore;
  late MockUser mockUser;
  late AuthService authService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUserStore = MockUserStore();
    mockUser = MockUser();

    when(() => mockAuth.authStateChanges()).thenAnswer(
      (_) => const Stream<User?>.empty(),
    );

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('uid-foto-123');
    when(() => mockUser.email).thenReturn('foto@teste.com');
    when(() => mockUser.displayName).thenReturn('Rafael');
    when(() => mockUserStore.saveUser(any())).thenAnswer((_) async {});

    authService = AuthService(
      auth: mockAuth,
      userStore: mockUserStore,
    );
  });

  group('pickProfilePhotoBase64', () {
    const imageBytes = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    late MockImagePicker mockPicker;

    setUp(() {
      mockPicker = MockImagePicker();
    });

    test('deve devolver base64 da foto selecionada', () async {
      final file = XFile.fromData(
        Uint8List.fromList(imageBytes),
        name: 'foto.png',
        mimeType: 'image/png',
      );

      when(() => mockPicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: any(named: 'maxWidth'),
            maxHeight: any(named: 'maxHeight'),
            imageQuality: any(named: 'imageQuality'),
          )).thenAnswer((_) async => file);

      final base64 = await pickProfilePhotoBase64(picker: mockPicker);

      expect(base64, base64Encode(imageBytes));
    });

    test('deve devolver null quando o usuário cancela a seleção', () async {
      when(() => mockPicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: any(named: 'maxWidth'),
            maxHeight: any(named: 'maxHeight'),
            imageQuality: any(named: 'imageQuality'),
          )).thenAnswer((_) async => null);

      final base64 = await pickProfilePhotoBase64(picker: mockPicker);

      expect(base64, isNull);
    });

    test('deve usar a galeria como fonte e requisitar redimensionamento',
        () async {
      final file = XFile.fromData(
        Uint8List.fromList(imageBytes),
        name: 'foto.png',
      );

      when(() => mockPicker.pickImage(
            source: any(named: 'source'),
            maxWidth: any(named: 'maxWidth'),
            maxHeight: any(named: 'maxHeight'),
            imageQuality: any(named: 'imageQuality'),
          )).thenAnswer((_) async => file);

      await pickProfilePhotoBase64(picker: mockPicker);

      verify(() => mockPicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 512,
            maxHeight: 512,
            imageQuality: 70,
          )).called(1);
    });
  });

  group('AuthService.updateProfilePhoto', () {
    const photoBase64 = 'iVBORw0KGgoAAAANSUhEUg==';

    test('deve salvar a foto de perfil preservando dados do usuário', () async {
      await authService.updateProfilePhoto(photoBase64);

      final savedUser = verify(
        () => mockUserStore.saveUser(captureAny()),
      ).captured.single as AppUser;

      expect(savedUser.uid, 'uid-foto-123');
      expect(savedUser.name, 'Rafael');
      expect(savedUser.email, 'foto@teste.com');
      expect(savedUser.photoBase64, photoBase64);
    });

    test('deve atualizar appUser com a nova foto e notificar listeners',
        () async {
      var notified = 0;
      authService.addListener(() => notified++);

      await authService.updateProfilePhoto(photoBase64);

      expect(authService.appUser?.photoBase64, photoBase64);
      expect(authService.appUser?.name, 'Rafael');
      expect(notified, 1);
    });

    test('deve substituir uma foto já existente mantendo o nome', () async {
      when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});

      await authService.updateProfile(name: 'Rafael');
      await authService.updateProfilePhoto('foto-primeira');
      await authService.updateProfilePhoto(photoBase64);

      final savedUsers = verify(
        () => mockUserStore.saveUser(captureAny()),
      ).captured.cast<AppUser>();

      expect(savedUsers.last.photoBase64, photoBase64);
      expect(savedUsers.last.name, 'Rafael');
    });

    test('deve manter o nome/email quando apenas a foto é alterada', () async {
      when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});

      await authService.updateProfile(name: 'Rafael Atualizado');
      await authService.updateProfilePhoto(photoBase64);

      final savedUser = verify(
        () => mockUserStore.saveUser(captureAny()),
      ).captured.last as AppUser;

      expect(savedUser.name, 'Rafael Atualizado');
      expect(savedUser.email, 'foto@teste.com');
      expect(savedUser.photoBase64, photoBase64);
    });

    test('não deve fazer nada quando não há usuário logado', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      await authService.updateProfilePhoto(photoBase64);

      verifyNever(() => mockUserStore.saveUser(any()));
      expect(authService.appUser, isNull);
    });
  });

  group('AppUser model - photoBase64', () {
    test('copyWith deve atualizar apenas a foto', () {
      const user = AppUser(
        uid: 'uid-copy',
        name: 'Rafael',
        email: 'rafael@teste.com',
      );

      final updated = user.copyWith(photoBase64: 'nova-foto-base64');

      expect(updated.uid, 'uid-copy');
      expect(updated.name, 'Rafael');
      expect(updated.email, 'rafael@teste.com');
      expect(updated.photoBase64, 'nova-foto-base64');
      expect(user.photoBase64, isEmpty);
    });

    test('toMap deve incluir photoBase64', () {
      const user = AppUser(
        uid: 'uid-map',
        name: 'Rafael',
        email: 'rafael@teste.com',
        photoBase64: 'foto-no-map',
      );

      final map = user.toMap();

      expect(map['photoBase64'], 'foto-no-map');
    });

    test('fromMap deve restaurar photoBase64', () {
      final map = {
        'uid': 'uid-map',
        'name': 'Rafael',
        'email': 'rafael@teste.com',
        'photoBase64': 'foto-restaurada',
      };

      final user = AppUser.fromMap(map);

      expect(user.photoBase64, 'foto-restaurada');
    });

    test('fromMap deve tratar photoBase64 ausente como vazio', () {
      const map = <String, dynamic>{};

      final user = AppUser.fromMap(map);

      expect(user.photoBase64, '');
    });

    test('toMap e fromMap devem ser inversos quanto à foto', () {
      const original = AppUser(
        uid: 'uid-roundtrip',
        name: 'Rafael',
        email: 'rafael@teste.com',
        photoBase64: 'foto-roundtrip-base64',
      );

      final restored = AppUser.fromMap(original.toMap());

      expect(restored.photoBase64, original.photoBase64);
    });
  });
}
