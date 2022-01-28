import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// ignore: unused_import
import 'package:meta/meta.dart';

class SecureStorageHandler {
  static final SecureStorageHandler _instance = SecureStorageHandler._internal();

  factory SecureStorageHandler() => _instance;
  SecureStorageHandler._internal();
  static SecureStorageHandler getInstance() => _instance;

  static const FlutterSecureStorage _flutterSecureStorage = FlutterSecureStorage();

  Future<void> write({required String key, String? value}) async {
    await _flutterSecureStorage.write(key: key, value: value);
  }

  Future<void> delete({required String key}) async {
    await _flutterSecureStorage.delete(key: key);
  }

  Future<String?> read({required String key}) async {
    return await _flutterSecureStorage.read(key: key);
  }
}
