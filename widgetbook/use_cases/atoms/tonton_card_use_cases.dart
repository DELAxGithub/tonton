import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:tonton/design_system/atoms/tonton_card_base.dart';
import 'package:tonton/theme/tokens.dart';

final tontonCardUseCases = WidgetbookComponent(
  name: 'TontonCardBase',
  useCases: [
    WidgetbookUseCase(
      name: 'Basic Card',
      builder: (context) {
        final hasHeader = context.knobs.boolean(
          label: 'Show Header',
          initialValue: true,
        );
        final hasFooter = context.knobs.boolean(
          label: 'Show Footer',
          initialValue: false,
        );
        final elevation = context.knobs.double.slider(
          label: 'Elevation',
          min: 0,
          max: 4,
          initialValue: 1,
        );

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TontonCardBase(
              header: hasHeader
                  ? const Text(
                      'Card Header',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
              footer: hasFooter
                  ? TextButton(
                      onPressed: () {},
                      child: const Text('View Details'),
                    )
                  : null,
              elevation: elevation,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'This is the card content. It can contain any widget.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Card with Action',
      builder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TontonCardBase(
              onTap: () {},
              child: const ListTile(
                leading: Icon(Icons.restaurant_menu),
                title: Text('Meal Card'),
                subtitle: Text('Tap to view details'),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Highlighted Card',
      builder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TontonCardBase(
              isHighlighted: true,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 48,
                      color: Colors.amber,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Achievement Unlocked!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'You saved 1000 calories',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Card Variations',
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TontonCardBase(
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Default Card'),
                ),
              ),
              const SizedBox(height: 16),
              TontonCardBase(
                elevation: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                    borderRadius: Radii.mediumBorderRadius,
                  ),
                  child: const Text('Flat Card with Border'),
                ),
              ),
              const SizedBox(height: 16),
              TontonCardBase(
                elevation: 3,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Elevated Card'),
                ),
              ),
              const SizedBox(height: 16),
              TontonCardBase(
                isHighlighted: true,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Highlighted Card'),
                ),
              ),
              const SizedBox(height: 16),
              TontonCardBase(
                header: const Text(
                  'Complete Card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                footer: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'This card has header, content, and footer sections.',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  ],
);