import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;

class CommonSecure {
  static const String _defaultKey = String.fromEnvironment(
    'CONFIG_ENCRYPTION_KEY',
    defaultValue: 'local-dev-key-16',
  );

  static String encrypt(String plain, {String? key}) {
    final k = enc.Key.fromUtf8(key ?? _defaultKey);
    final ivBytes = _randomBytes(16);
    final iv = enc.IV(Uint8List.fromList(ivBytes));
    final encrypter = enc.Encrypter(
      enc.AES(k, mode: enc.AESMode.cbc, padding: 'PKCS7'),
    );
    final cipher = encrypter.encryptBytes(utf8.encode(plain), iv: iv).bytes;
    final combined = <int>[...ivBytes, ...cipher];
    return base64.encode(combined);
  }

  static String? decrypt(String data, {String? key}) {
    try {
      final cleaned = data.replaceAll(RegExp(r'\s'), '');
      final bytes = base64.decode(cleaned);
      if (bytes.length < 17) {
        return null;
      }
      final ivBytes = bytes.sublist(0, 16);
      final cipherBytes = bytes.sublist(16);
      final k = enc.Key.fromUtf8(key ?? _defaultKey);
      final iv = enc.IV(Uint8List.fromList(ivBytes));
      final encrypter = enc.Encrypter(
        enc.AES(k, mode: enc.AESMode.cbc, padding: 'PKCS7'),
      );
      final plainBytes = encrypter.decryptBytes(
        enc.Encrypted(cipherBytes),
        iv: iv,
      );
      return utf8.decode(plainBytes);
    } catch (e) {
      // ignore: avoid_print
      print('Decryption error: $e');
      return null;
    }
  }

  static List<int> _randomBytes(int length) {
    final rng = Random.secure();
    return List<int>.generate(length, (_) => rng.nextInt(256));
  }
}
