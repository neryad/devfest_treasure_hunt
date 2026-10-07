import 'package:flutter/material.dart';

const networkErrorMessage = 'Sin conexión, intenta de nuevo';

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showNetworkError(BuildContext context) =>
    showSnack(context, networkErrorMessage);
