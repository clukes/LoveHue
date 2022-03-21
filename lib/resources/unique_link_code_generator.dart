import 'dart:math';

/// Length is default 5.
const int linkCodeLength = 5;

const String _codeAlphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
final _random = Random();

/// Generate a code of length [linkCodeLength] with characters from [codeAlphabet].
String generateLinkCode() {
  String code = '';
  for (int i = 0; i < linkCodeLength; i++) {
    code += _codeAlphabet[_random.nextInt(_codeAlphabet.length)];
  }

  return code;
}
