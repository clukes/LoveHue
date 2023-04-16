### How to run tests for web:
1. Run emulator: `firebase emulators:start`
2. Run chrome test driver: `chromedriver --port=4444`
3. Run tests
headless:
``` zsh
flutter drive --driver=integration_test/test_driver/test_driver.dart --target=integration_test/e2e_tests.dart -d web-server
```
or not headless:
``` zsh
flutter drive driver=integration_test/test_driver/test_driver.dart target=integration_test/e2e_tests.dart -d chrome
```

