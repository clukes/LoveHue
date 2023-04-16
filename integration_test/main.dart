import 'package:integration_test/integration_test.dart';
import 'skip_login_test.dart' as skip_login;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  skip_login.main();
}
