import 'dart:math';

/// Alphabet to generate codes from.
const String codeAlphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
/// Length is set to 5.
const int linkCodeLength = 5;
final _random = Random();

/// Generate a code of length [linkCodeLength] with characters from [codeAlphabet].
String generateLinkCode() {
  String code = '';
  for (int i = 0; i < linkCodeLength; i++) {
    code += codeAlphabet[_random.nextInt(codeAlphabet.length)];
  }

  return code;
}
