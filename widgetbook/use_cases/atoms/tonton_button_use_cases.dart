import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:tonton/design_system/atoms/tonton_button.dart';
import 'package:tonton/utils/icon_mapper.dart';

final tontonButtonUseCases = WidgetbookComponent(
  name: 'TontonButton',
  useCases: [
    WidgetbookUseCase(
      name: 'Primary Button',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Primary Button',
        );
        final isEnabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );
        final isLoading = context.knobs.boolean(
          label: 'Loading',
          initialValue: false,
        );
        final hasIcon = context.knobs.boolean(
          label: 'Show Icon',
          initialValue: false,
        );

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TontonButton(
              label: label,
              onPressed: isEnabled ? () {} : null,
              isLoading: isLoading,
              icon: hasIcon ? TontonIcons.add : null,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Secondary Button',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Secondary Button',
        );
        final isEnabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TontonButton.secondary(
              label: label,
              onPressed: isEnabled ? () {} : null,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Text Button',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Text Button',
        );
        final isEnabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TontonButton.text(
              label: label,
              onPressed: isEnabled ? () {} : null,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Button Sizes',
      builder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TontonButton.small(
                  label: 'Small Button',
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                TontonButton(
                  label: 'Medium Button',
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                TontonButton.large(
                  label: 'Large Button',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'All Variants',
      builder: (context) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSection('Primary', [
                  TontonButton(
                    label: 'Enabled',
                    onPressed: () {},
                  ),
                  TontonButton(
                    label: 'Disabled',
                    onPressed: null,
                  ),
                  TontonButton(
                    label: 'Loading',
                    onPressed: () {},
                    isLoading: true,
                  ),
                  TontonButton(
                    label: 'With Icon',
                    icon: TontonIcons.piggybank,
                    onPressed: () {},
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection('Secondary', [
                  TontonButton.secondary(
                    label: 'Enabled',
                    onPressed: () {},
                  ),
                  TontonButton.secondary(
                    label: 'Disabled',
                    onPressed: null,
                  ),
                  TontonButton.secondary(
                    label: 'With Icon',
                    icon: TontonIcons.add,
                    onPressed: () {},
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection('Text', [
                  TontonButton.text(
                    label: 'Enabled',
                    onPressed: () {},
                  ),
                  TontonButton.text(
                    label: 'Disabled',
                    onPressed: null,
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    ),
  ],
);

Widget _buildSection(String title, List<Widget> buttons) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      ...buttons.map((button) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: button,
          )),
    ],
  );
}