import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/main.dart';
import 'package:student_app/demo_auth.dart';
import 'package:student_app/calculator_screen.dart';

void main() {
  setUp(() {
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
    DemoAuth.logout();
  });

  Finder navTab(String label) => find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      );

  testWidgets('Test 1 & 2: Empty login validation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const StudentApp());

    // Test 1: Login appears first
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Test 2: Submit empty login fields
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Enter your username.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
  });

  testWidgets('Test 3: Incorrect credentials rejected', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const StudentApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'wronguser');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Invalid username or password.'), findsOneWidget);
  });

  testWidgets('Test 4 & 5: Admin login opens Dashboard with greeting', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const StudentApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Welcome, admin!'), findsOneWidget);
  });

  testWidgets('Test 6 & 7: Calculator operations and state preservation across tab switches', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const StudentApp());

    // Login as admin
    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Switch to Calculator tab via NavigationBar
    await tester.tap(navTab('Calculator'));
    await tester.pumpAndSettle();

    expect(find.text('BASIC CALCULATOR'), findsOneWidget);

    // Enter 20 and 5, calculate all 4 operations
    final inputs = find.descendant(of: find.byType(CalculatorScreen), matching: find.byType(TextField));
    await tester.enterText(inputs.at(0), '20');
    await tester.enterText(inputs.at(1), '5');

    // Addition (+)
    await tester.tap(find.widgetWithText(ElevatedButton, '+'));
    await tester.pump();
    expect(find.text('25.0'), findsOneWidget);

    // Subtraction (-)
    await tester.tap(find.widgetWithText(ElevatedButton, '-'));
    await tester.pump();
    expect(find.text('15.0'), findsOneWidget);

    // Multiplication (×)
    await tester.tap(find.widgetWithText(ElevatedButton, '×'));
    await tester.pump();
    expect(find.text('100.0'), findsOneWidget);

    // Division (÷)
    await tester.tap(find.widgetWithText(ElevatedButton, '÷'));
    await tester.pump();
    expect(find.text('4.0'), findsOneWidget);

    // Test 10 + 5 = 15.0 as specified in checklist test #6
    await tester.enterText(inputs.at(0), '10');
    await tester.enterText(inputs.at(1), '5');
    await tester.tap(find.widgetWithText(ElevatedButton, '+'));
    await tester.pump();
    expect(find.text('15.0'), findsOneWidget);

    // Test 7: Switch tabs to Social and return to Calculator
    await tester.tap(navTab('Social'));
    await tester.pumpAndSettle();

    await tester.tap(navTab('Calculator'));
    await tester.pumpAndSettle();

    // Verify inputs and result remain preserved
    expect(find.text('15.0'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('Test 8, 9, 10: Social interactions, post creation, and state preservation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const StudentApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Switch to Social tab
    await tester.tap(navTab('Social'));
    await tester.pumpAndSettle();

    // Test 9: Like a post and add a comment
    final likeButton = find.widgetWithText(TextButton, 'Like').first;
    await tester.ensureVisible(likeButton);
    await tester.tap(likeButton);
    await tester.pump();
    expect(find.text('Liked'), findsOneWidget);

    final commentInputs = find.widgetWithText(TextField, 'Add a comment...');
    await tester.ensureVisible(commentInputs.first);
    await tester.enterText(commentInputs.first, 'Awesome post!');

    final sendButton = find.byIcon(Icons.send).first;
    await tester.ensureVisible(sendButton);
    await tester.tap(sendButton);
    await tester.pump();
    expect(find.text('Awesome post!'), findsOneWidget);
    expect(find.text('1 Comments'), findsOneWidget);

    // Test 10: Switch to Profile and return to Social -> state preserved
    await tester.tap(navTab('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(navTab('Social'));
    await tester.pumpAndSettle();

    expect(find.text('Liked'), findsOneWidget);
    expect(find.text('Awesome post!'), findsOneWidget);
  });

  testWidgets('Test 11 & 12: Profile details and Logout flow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const StudentApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Switch to Profile tab
    await tester.tap(navTab('Profile'));
    await tester.pumpAndSettle();

    // Test 11: Student information and username appear
    expect(find.text('Logged in as: admin'), findsOneWidget);
    expect(find.text('Jasper Wenceslao'), findsOneWidget);
    expect(find.text('553682'), findsOneWidget);
    expect(find.text('BSIT — CCE106-3447'), findsOneWidget);

    // Test 12: Tap Logout
    final logoutBtn = find.widgetWithText(ElevatedButton, 'Logout');
    await tester.ensureVisible(logoutBtn);
    await tester.tap(logoutBtn);
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(DemoAuth.currentUsername, isNull);
  });

  testWidgets('Test 13 & 14: Register a valid account, log in, and create post', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const StudentApp());

    // Navigate to Register
    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();

    expect(find.text('Create an Account'), findsOneWidget);

    // Test registration validation
    await tester.enterText(find.byType(TextFormField).at(0), 'ad'); // too short
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pump();
    expect(find.text('Username must be at least 3 characters.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'admin'); // reserved
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pump();
    expect(find.text('admin is reserved.'), findsOneWidget);

    // Valid registration
    await tester.enterText(find.byType(TextFormField).at(0), 'maria_santos');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    // Back to Login screen and clear SnackBar
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Log in with new credentials
    await tester.enterText(find.byType(TextFormField).at(0), 'maria_santos');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Test 13: Dashboard displays registered username
    expect(find.text('Welcome, maria_santos!'), findsOneWidget);

    // Switch to Social tab
    await tester.tap(navTab('Social'));
    await tester.pumpAndSettle();

    // Test 14: Create a post using registered account
    await tester.tap(find.byTooltip('Create Post'));
    await tester.pumpAndSettle();

    expect(find.text('Create Post'), findsOneWidget);

    // Fill form
    final sheetInputs = find.descendant(of: find.byType(SingleChildScrollView), matching: find.byType(TextField));
    await tester.enterText(sheetInputs.at(0), 'Hello from Maria!');
    await tester.enterText(sheetInputs.at(1), 'https://picsum.photos/id/10/600/400');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    // Verify post displays registered username
    expect(find.text('maria_santos'), findsOneWidget);
    expect(find.text('Hello from Maria!'), findsOneWidget);
  });
}
