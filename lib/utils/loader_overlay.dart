import 'package:flutter/cupertino.dart';
import 'package:loader_overlay/loader_overlay.dart';

Future<dynamic> withLoaderOverlay(BuildContext context, Future<dynamic> Function() task) async
{
  context.loaderOverlay.show();
  var result = await task();
  if(context.mounted) {
    context.loaderOverlay.hide();
  }
  return result;
}