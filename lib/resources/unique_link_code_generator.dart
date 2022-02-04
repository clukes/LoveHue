import 'dart:math';

const String codeAlphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
const int linkCodeLength = 5;
final _random = Random();

String generateLinkCode() {
  String code = '';
  for (int i = 0; i < linkCodeLength; i++) {
    code += codeAlphabet[_random.nextInt(codeAlphabet.length)];
  }

  return code;
}
