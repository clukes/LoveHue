import 'dart:math';

const String codeAlphabet =
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
const int linkCodeLength = 5;
final _random = Random();

String generateLinkCode() {
  String code = '';

  for (int i = 0; i < linkCodeLength; i++) {
    code += codeAlphabet[_random.nextInt(codeAlphabet.length)];
  }

  return code;
}
