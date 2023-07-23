import 'package:flutter/cupertino.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lovehue/services/context_service.dart';

Future<dynamic> withLoaderOverlay(Future<dynamic>? Function() task,
    {BuildContext? currentContext}) async {
  getCurrentContext(currentContext)?.loaderOverlay.show();
  dynamic result;
  try {
    result = await task();
  } catch (_) {
    rethrow;
  } finally {
    getCurrentContext(currentContext)?.loaderOverlay.hide();
  }
  return result;
}

BuildContext? getCurrentContext(BuildContext? currentContext) =>
    currentContext ?? ContextService.currentContext;
