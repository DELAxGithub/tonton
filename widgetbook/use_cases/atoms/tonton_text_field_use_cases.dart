import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:tonton/design_system/atoms/tonton_text_field.dart';
import 'package:tonton/design_system/atoms/tonton_labeled_text_field.dart';
import 'package:tonton/utils/icon_mapper.dart';

final tontonTextFieldUseCases = WidgetbookComponent(
  name: 'TontonTextField',
  useCases: [
    WidgetbookUseCase(
      name: 'Basic TextField',
      builder: (context) {
        final placeholder = context.knobs.string(
          label: 'Placeholder',
          initialValue: 'Enter text here',
        );
        final isEnabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );
        final hasError = context.knobs.boolean(
          label: 'Show Error',
          initialValue: false,
        );
        final errorText = context.knobs.string(
          label: 'Error Text',
          initialValue: 'This field is required',
        );
        
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TontonTextField(
              controller: TextEditingController(),
              placeholder: placeholder,
              enabled: isEnabled,
              errorText: hasError ? errorText : null,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Labeled TextField',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Email Address',
        );
        final placeholder = context.knobs.string(
          label: 'Placeholder',
          initialValue: 'example@email.com',
        );
        final helperText = context.knobs.string(
          label: 'Helper Text',
          initialValue: 'We\'ll never share your email',
        );
        final isRequired = context.knobs.boolean(
          label: 'Required',
          initialValue: true,
        );
        
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TontonLabeledTextField(
              label: label,
              controller: TextEditingController(),
              placeholder: placeholder,
              helperText: helperText,
              isRequired: isRequired,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'TextField Types',
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TontonTextField(
                controller: TextEditingController(),
                placeholder: 'Standard text field',
              ),
              const SizedBox(height: 16),
              TontonTextField(
                controller: TextEditingController(),
                placeholder: 'Password field',
                obscureText: true,
                suffixIcon: Icons.visibility_off,
              ),
              const SizedBox(height: 16),
              TontonTextField(
                controller: TextEditingController(),
                placeholder: 'Search field',
                prefixIcon: Icons.search,
                suffixIcon: Icons.clear,
              ),
              const SizedBox(height: 16),
              TontonTextField(
                controller: TextEditingController(),
                placeholder: 'Number field',
                keyboardType: TextInputType.number,
                prefixIcon: TontonIcons.coin,
              ),
              const SizedBox(height: 16),
              TontonTextField(
                controller: TextEditingController(text: '500'),
                placeholder: 'Calories',
                keyboardType: TextInputType.number,
                suffix: const Text('kcal'),
              ),
              const SizedBox(height: 16),
              TontonTextField(
                controller: TextEditingController(),
                placeholder: 'Multiline text field',
                maxLines: 3,
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'TextField States',
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TontonLabeledTextField(
                label: 'Empty State',
                controller: TextEditingController(),
                placeholder: 'Enter your name',
              ),
              const SizedBox(height: 16),
              TontonLabeledTextField(
                label: 'Filled State',
                controller: TextEditingController(text: 'John Doe'),
                placeholder: 'Enter your name',
              ),
              const SizedBox(height: 16),
              TontonLabeledTextField(
                label: 'Focused State',
                controller: TextEditingController(),
                placeholder: 'Click to focus',
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TontonLabeledTextField(
                label: 'Error State',
                controller: TextEditingController(),
                placeholder: 'Enter your email',
                errorText: 'Please enter a valid email address',
              ),
              const SizedBox(height: 16),
              TontonLabeledTextField(
                label: 'Disabled State',
                controller: TextEditingController(text: 'Cannot edit'),
                placeholder: 'Disabled field',
                enabled: false,
              ),
              const SizedBox(height: 16),
              TontonLabeledTextField(
                label: 'With Helper Text',
                controller: TextEditingController(),
                placeholder: 'Enter weight',
                helperText: 'Enter your weight in kilograms',
                suffix: const Text('kg'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Form Example',
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'User Profile Form',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TontonLabeledTextField(
                label: 'Full Name',
                controller: TextEditingController(),
                placeholder: 'John Doe',
                isRequired: true,
              ),
              const SizedBox(height: 16),
              TontonLabeledTextField(
                label: 'Email',
                controller: TextEditingController(),
                placeholder: 'john.doe@example.com',
                keyboardType: TextInputType.emailAddress,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              TontonLabeledTextField(
                label: 'Age',
                controller: TextEditingController(),
                placeholder: '25',
                keyboardType: TextInputType.number,
                suffix: const Text('years'),
              ),
              const SizedBox(height: 16),
              TontonLabeledTextField(
                label: 'Weight',
                controller: TextEditingController(),
                placeholder: '70.5',
                keyboardType: TextInputType.number,
                suffix: const Text('kg'),
                helperText: 'Used to calculate your calorie needs',
              ),
              const SizedBox(height: 16),
              TontonLabeledTextField(
                label: 'Height',
                controller: TextEditingController(),
                placeholder: '175',
                keyboardType: TextInputType.number,
                suffix: const Text('cm'),
                helperText: 'Used to calculate your BMI',
              ),
            ],
          ),
        );
      },
    ),
  ],
);