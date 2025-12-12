import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LicenseService {
  static const String _masterKey = 'GANESHKUMAR2000';
  static const String _licenseKey = 'is_licensed';
  static const String _masterName = 'GANESHKUMAR';

  Future<bool> isLicensed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_licenseKey) ?? false;
  }

  Future<bool> activateLicense(String key) async {
    if (key.trim().isEmpty) return false;

    final normalizedKey = key.trim().toUpperCase();
    
    // Check Master Key
    if (normalizedKey == _masterKey) {
      await _saveLicenseStatus();
      return true;
    }

    // Check Daily Key
    final dailyKey = _generateDailyKey();
    if (normalizedKey == dailyKey) {
      await _saveLicenseStatus();
      return true;
    }

    return false;
  }

  Future<void> _saveLicenseStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_licenseKey, true);
  }

  String _generateDailyKey() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final input = '$_masterName$dateStr';
    
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    
    // Take first 8 characters of the hex string and uppercase them
    return digest.toString().substring(0, 8).toUpperCase();
  }
  
  // Helper method to get today's key for testing/admin purposes
  String getTodayKey() {
    return _generateDailyKey();
  }
}
