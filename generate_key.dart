import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

void main() {
  final now = DateTime.now();
  final dateStr = DateFormat('yyyyMMdd').format(now);
  final input = 'GANESHKUMAR$dateStr';
  
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  
  final key = digest.toString().substring(0, 8).toUpperCase();
  print('Date: $dateStr');
  print('Input: $input');
  print('Daily Key: $key');
}
