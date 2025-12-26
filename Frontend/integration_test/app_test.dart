import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:baztami/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E Scenario: SignUp -> Logout -> Login -> Dashboard -> Transactions', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Set a large enough surface for sidebar to appear (Desktop view)
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpAndSettle();

    // --- 1. SIGN UP ---
    print('Starting Sign Up...');
    // Tap "Create an account"
    // Tap "Create an account"
    await tester.tap(find.byKey(const Key('createAccountLink'))); 
    await tester.pumpAndSettle();
    // Text check removed as we use Key now
    await tester.pumpAndSettle();

    // Verify we are on Sign Up page
    expect(find.text('Join BeztaMy'), findsOneWidget);

    // Fill Sign Up Form
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'testuser_$timestamp@example.com';
    final pass = 'password123';

    // Tap and enter text for each field with proper waits
    await tester.tap(find.byKey(const Key('firstNameField')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('firstNameField')), 'Test');
    await tester.pumpAndSettle();
    
    await tester.tap(find.byKey(const Key('lastNameField')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('lastNameField')), 'User');
    await tester.pumpAndSettle();
    
    await tester.tap(find.byKey(const Key('signupEmailField')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('signupEmailField')), email);
    await tester.pumpAndSettle();
    
    await tester.tap(find.byKey(const Key('phoneField')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('phoneField')), '1234567890');
    await tester.pumpAndSettle();
    
    await tester.tap(find.byKey(const Key('statusField')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('statusField')), 'Tester');
    await tester.pumpAndSettle();
    
    await tester.tap(find.byKey(const Key('signupPasswordField')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('signupPasswordField')), pass);
    await tester.pumpAndSettle();
    
    await tester.tap(find.byKey(const Key('confirmPasswordField')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('confirmPasswordField')), pass);
    await tester.pumpAndSettle();

    // Tap Checkbox (Terms)
    await tester.scrollUntilVisible(find.byKey(const Key('termsCheckbox')), 500);
    await tester.tap(find.byKey(const Key('termsCheckbox')));
    await tester.pumpAndSettle();

    // Tap Create Account
    await tester.tap(find.byKey(const Key('createAccountButton')));
    await tester.pumpAndSettle();
    
    // Wait for API (Create + Login + Navigate)
    await Future.delayed(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // --- 2. DASHBOARD VERIFICATION ---
    print('Verifying Dashboard access...');
    // Should be on dashboard
    expect(find.byKey(const Key('navLogOut')), findsOneWidget); // Sidebar should be visible
    expect(find.text('Total Balance'), findsOneWidget); // Common dashboard text

    // Scroll Down / Up
    await tester.drag(find.text('Total Balance'), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.drag(find.text('Total Balance'), const Offset(0, 300));
    await tester.pumpAndSettle();

    // --- 3. LOG OUT ---
    print('Logging Out...');
    await tester.tap(find.byKey(const Key('navLogOut')));
    await tester.pumpAndSettle();
    
    // Verify on Login Screen
    expect(find.byKey(const Key('signInButton')), findsOneWidget);

    // --- 4. LOGIN ---
    print('Logging In with new account...');
    await tester.tap(find.byKey(const Key('emailField')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('emailField')), email);
    await tester.pumpAndSettle();
    
    await tester.tap(find.byKey(const Key('passwordField')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('passwordField')), pass);
    await tester.pumpAndSettle();
    
    await tester.tap(find.byKey(const Key('signInButton')));
    await tester.pumpAndSettle();
    
    // Wait for login
    await Future.delayed(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Verify Dashboard again
    expect(find.text('Total Balance'), findsOneWidget);

    // --- 5. TRANSACTIONS ---
    print('Navigating to Transactions...');
    await tester.tap(find.byKey(const Key('navTransactions')));
    await tester.pumpAndSettle();

    // Verify Transactions Screen
    expect(find.text('Transactions'), findsOneWidget);

    // View Details (Tap first details button if any transactions exist)
    // If no transactions, we might need to create one first. 
    // Since it's a fresh account, likely empty.
    // So let's create one first via Sidebar -> Add Entry (as per original flow user mentioned sidebar click)
    
    // Navigate to Add Entry
    print('Adding Transaction...');
    await tester.tap(find.byKey(const Key('navAddEntry')));
    await tester.pumpAndSettle();

    // Add Income
    await tester.tap(find.byKey(const Key('incomeChoice')));
    await tester.pumpAndSettle();
    
    await tester.tap(find.byKey(const Key('amountField')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('amountField')), '1500');
    await tester.pumpAndSettle();
    
    await tester.tap(find.byKey(const Key('descField')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('descField')), 'Weekly Salary');
    await tester.pumpAndSettle();
    
    // Date
    await tester.tap(find.text('Select date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('saveTransactionButton')));
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    // Return to Transactions via Sidebar
    await tester.tap(find.byKey(const Key('navTransactions')));
    await tester.pumpAndSettle();

    // Now there should be one transaction. View Details.
    print('Viewing Details...');
    await tester.tap(find.text('Details').first);
    await tester.pumpAndSettle();
    
    // Close Details (Tap X or Close) - Dialog usually has a close button or we tap outside.
    // Code says: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context))
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Slide to Edit/Delete
    // Finding the slidable widget.
    // We can drag the transaction card.
    final transactionCard = find.byType(Card).first; // Or whatever valid widget holds the transaction
    // Actually the code uses Container with Slidable.
    // Let's find by text 'Weekly Salary'
    final itemFinder = find.text('Weekly Salary');
    
    // Slide Right to Left (Delete is usually on end pane)
    print('Sliding to Delete...');
    await tester.drag(itemFinder, const Offset(-200, 0));
    await tester.pumpAndSettle();
    
    // Check if Delete button is visible
    expect(find.text('Delete'), findsOneWidget);
    
    // Tap Delete (and Cancel dialog to not destroy data? User said "slide to supprime")
    await tester.tap(find.widgetWithText(SlidableAction, 'Delete'));
    await tester.pumpAndSettle();
    
    // Dialog appears
    expect(find.text('Delete Transaction'), findsOneWidget);
    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Slide for Edit (might be same direction or other)
    // Code says: children: [SlidableAction(label: 'Edit'), SlidableAction(label: 'Delete')] in endActionPane.
    // So both are on right side (drag left).
    
    // Slide again
    print('Sliding to Edit...');
    await tester.drag(itemFinder, const Offset(-200, 0));
    await tester.pumpAndSettle();

    // Tap Edit
    await tester.tap(find.widgetWithText(SlidableAction, 'Edit'));
    await tester.pumpAndSettle();
    
    // Verify Edit Screen (Add Entry screen with pre-filled data)
    expect(find.text('Update Transaction'), findsOneWidget);
    
    // Go back via Sidebar
    await tester.tap(find.byKey(const Key('navDashboard')));
    await tester.pumpAndSettle();

    print('E2E Test Completed Successfully');
  });
}
