import 'package:care247assignment/infrastructure/config/search_config.dart';
import 'package:care247assignment/screens/search_screen/widgets/search_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchTextFormField with a text config', () {
    testWidgets('shows the label from the config', (tester) async {
      var controller = TextEditingController();
      addTearDown(controller.dispose);

      await showField(tester, config: textConfig, controller: controller);

      expect(find.text('First Name'), findsOneWidget);
    });

    testWidgets('typing updates the controller', (tester) async {
      var controller = TextEditingController();
      addTearDown(controller.dispose);
      await showField(tester, config: textConfig, controller: controller);

      await tester.enterText(find.byType(TextFormField), 'John');

      expect(controller.text, 'John');
    });

    testWidgets('uses the name keyboard', (tester) async {
      var controller = TextEditingController();
      addTearDown(controller.dispose);
      await showField(tester, config: textConfig, controller: controller);

      var textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.keyboardType, TextInputType.name);
    });

    testWidgets('done action calls onSubmitted', (tester) async {
      var controller = TextEditingController();
      addTearDown(controller.dispose);
      var submitted = 0;
      await showField(
        tester,
        config: textConfig,
        controller: controller,
        action: TextInputAction.done,
        onSubmitted: () {
          submitted++;
        },
      );

      await tester.enterText(find.byType(TextFormField), 'John');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submitted, 1);
    });

    testWidgets('next action does not call onSubmitted', (tester) async {
      var controller = TextEditingController();
      addTearDown(controller.dispose);
      var submitted = 0;
      await showField(
        tester,
        config: textConfig,
        controller: controller,
        action: TextInputAction.next,
        onSubmitted: () {
          submitted++;
        },
      );

      await tester.enterText(find.byType(TextFormField), 'John');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      expect(submitted, 0);
    });
  });

  group('SearchTextFormField with a date config', () {
    testWidgets('shows the label and a calendar icon', (tester) async {
      var controller = TextEditingController();
      addTearDown(controller.dispose);

      await showField(tester, config: dateConfig, controller: controller);

      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('can not be typed into', (tester) async {
      var controller = TextEditingController();
      addTearDown(controller.dispose);
      await showField(tester, config: dateConfig, controller: controller);

      var textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.readOnly, true);
    });

    testWidgets('tap opens the date picker and OK fills the field as yyyy-MM-dd', (tester) async {
      var controller = TextEditingController();
      addTearDown(controller.dispose);
      await showField(tester, config: dateConfig, controller: controller);

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // the picker starts on 1 Jan 2000 when the field is empty
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(controller.text, '2000-01-01');
    });

    testWidgets('cancel leaves the field empty', (tester) async {
      var controller = TextEditingController();
      addTearDown(controller.dispose);
      await showField(tester, config: dateConfig, controller: controller);

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(controller.text, isEmpty);
    });
  });
}

var textConfig = const FieldConfig(
  key: 'firstName',
  type: FieldType.text,
  label: 'First Name',
  placeholder: 'Enter first name',
  renderOrder: 1,
);

var dateConfig = const FieldConfig(
  key: 'dateOfBirth',
  type: FieldType.date,
  label: 'Date of Birth',
  placeholder: 'Select date of birth',
  renderOrder: 3,
);

Future<void> showField(
    WidgetTester tester, {
      required FieldConfig config,
      required TextEditingController controller,
      TextInputAction action = TextInputAction.done,
      VoidCallback? onSubmitted,
    }) async {
  var focusNode = FocusNode();
  addTearDown(focusNode.dispose);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SearchTextFormField(
          config: config,
          controller: controller,
          focusNode: focusNode,
          textInputAction: action,
          onSubmitted: onSubmitted,
        ),
      ),
    ),
  );
}