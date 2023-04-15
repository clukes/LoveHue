### How to run tests:
1. Run emulator: `firebase emulators:start`
2. Run chrome test driver: `chromedriver --port=4444`
3. Run test (haven't got multiple tests running yet), 
headless:
``` zsh
flutter drive \ 
  --driver=integration_test/test_driver/chrome_test_driver.dart \
  --target=integration_test/skip_login_test.dart \
  -d web-server
```
or not headless:
``` zsh
flutter drive \ 
  --driver=integration_test/test_driver/chrome_test_driver.dart \
  --target=integration_test/skip_login_test.dart \
  -d chrome
```

