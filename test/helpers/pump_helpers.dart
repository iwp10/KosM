import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper to cleanly dispose the widget tree and flush pending microtasks / timers
/// scheduled during teardown of Drift stream queries and Riverpod providers.
Future<void> disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

/// Sets the test viewport to a mobile phone screen portrait ratio (400x900, DPR 1.0)
/// and registers an automated teardown to reset dimensions.
void setPhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
