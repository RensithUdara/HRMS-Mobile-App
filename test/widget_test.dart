// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hr_mobile_app/main.dart';
import 'package:hr_mobile_app/services/notification_service.dart';

void main() {
  testWidgets('App starts and shows splash screen', (WidgetTester tester) async {
    // Create mock notification service
    final notificationService = NotificationService();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(notificationService: notificationService));

    // Verify that splash screen elements are present
    expect(find.text('HR Mobile'), findsOneWidget);
    expect(find.text('Human Resource Management System'), findsOneWidget);
  });
}
