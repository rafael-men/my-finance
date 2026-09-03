import 'package:firebase_auth/firebase_auth.dart' as fb;

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String photoBase64;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoBase64 = '',
  });

  factory AppUser.fromFirebase(fb.User user, {String? name}) {
    return AppUser(
      uid: user.uid,
      name: name ?? user.displayName ?? '',
      email: user.email ?? '',
    );
  }

  AppUser copyWith({
    String? name,
    String? photoBase64,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoBase64: photoBase64 ?? this.photoBase64,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoBase64': photoBase64,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoBase64: map['photoBase64'] ?? '',
    );
  }
}
