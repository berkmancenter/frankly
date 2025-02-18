import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

T? watchProviderOrNull<T>(BuildContext context) {
  try {
    return Provider.of<T>(context);
  } on ProviderNotFoundException {
    return null;
  }
}

T? providerOrNull<T>(T Function() getProvider) {
  try {
    return getProvider();
  } on ProviderNotFoundException {
    return null;
  }
}

T? readProviderOrNull<T>(BuildContext context) {
  try {
    return Provider.of<T>(context, listen: false);
  } on ProviderNotFoundException {
    return null;
  }
}
