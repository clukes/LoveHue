import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/resources/unique_link_code_generator.dart';

void main() {
  test('link codes are correct length', () {
    String code = generateLinkCode();
    expect(code.length, linkCodeLength);
  });

  test('link codes are different', () {
    Set<String> codes = {};
    for (int i = 0; i < 10; i++) {
      String code = generateLinkCode();
      expect(codes.add(code), isTrue);
    }
  });
}
