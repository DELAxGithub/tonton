import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:tonton/theme/typography.dart';

final typographyShowcaseUseCase = WidgetbookComponent(
  name: 'Typography',
  useCases: [
    WidgetbookUseCase(
      name: 'Display Styles',
      builder: (context) {
        final sampleText = context.knobs.string(
          label: 'Sample Text',
          initialValue: 'The quick brown fox jumps',
        );
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypographyExample(
                'Large Title',
                sampleText,
                TontonTypography.largeTitle,
                '34pt / Regular',
              ),
              _buildTypographyExample(
                'Title 1',
                sampleText,
                TontonTypography.title1,
                '28pt / Regular',
              ),
              _buildTypographyExample(
                'Title 2',
                sampleText,
                TontonTypography.title2,
                '22pt / Regular',
              ),
              _buildTypographyExample(
                'Title 3',
                sampleText,
                TontonTypography.title3,
                '20pt / Regular',
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Body Styles',
      builder: (context) {
        final sampleText = context.knobs.string(
          label: 'Sample Text',
          initialValue: 'The quick brown fox jumps over the lazy dog',
        );
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypographyExample(
                'Headline',
                sampleText,
                TontonTypography.headline,
                '17pt / Semibold',
              ),
              _buildTypographyExample(
                'Body',
                sampleText,
                TontonTypography.body,
                '17pt / Regular',
              ),
              _buildTypographyExample(
                'Callout',
                sampleText,
                TontonTypography.callout,
                '16pt / Regular',
              ),
              _buildTypographyExample(
                'Subheadline',
                sampleText,
                TontonTypography.subheadline,
                '15pt / Regular',
              ),
              _buildTypographyExample(
                'Footnote',
                sampleText,
                TontonTypography.footnote,
                '13pt / Regular',
              ),
              _buildTypographyExample(
                'Caption 1',
                sampleText,
                TontonTypography.caption1,
                '12pt / Regular',
              ),
              _buildTypographyExample(
                'Caption 2',
                sampleText,
                TontonTypography.caption2,
                '11pt / Regular',
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Weight Variations',
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Body Text Weight Variations'),
              _buildTypographyExample(
                'Thin (100)',
                'The quick brown fox',
                TontonTypography.thin(TontonTypography.body),
                'FontWeight.w100',
              ),
              _buildTypographyExample(
                'Light (300)',
                'The quick brown fox',
                TontonTypography.light(TontonTypography.body),
                'FontWeight.w300',
              ),
              _buildTypographyExample(
                'Regular (400)',
                'The quick brown fox',
                TontonTypography.regular(TontonTypography.body),
                'FontWeight.w400',
              ),
              _buildTypographyExample(
                'Medium (500)',
                'The quick brown fox',
                TontonTypography.medium(TontonTypography.body),
                'FontWeight.w500',
              ),
              _buildTypographyExample(
                'Semibold (600)',
                'The quick brown fox',
                TontonTypography.semibold(TontonTypography.body),
                'FontWeight.w600',
              ),
              _buildTypographyExample(
                'Bold (700)',
                'The quick brown fox',
                TontonTypography.bold(TontonTypography.body),
                'FontWeight.w700',
              ),
              _buildTypographyExample(
                'Heavy (900)',
                'The quick brown fox',
                TontonTypography.heavy(TontonTypography.body),
                'FontWeight.w900',
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Semantic Styles',
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Navigation & UI Elements'),
              _buildTypographyExample(
                'Navigation Title',
                'Settings',
                TontonTypography.navigationTitle,
                'Used in navigation bars',
              ),
              _buildTypographyExample(
                'Tab Label',
                'Home',
                TontonTypography.tabLabel,
                'Used in tab bars',
              ),
              _buildTypographyExample(
                'Button',
                'Save Changes',
                TontonTypography.button,
                'Used for button labels',
              ),
              _buildTypographyExample(
                'Text Field',
                'Enter your email',
                TontonTypography.textField,
                'Used for input text',
              ),
              _buildTypographyExample(
                'Placeholder',
                'example@email.com',
                TontonTypography.placeholder,
                'Used for placeholders',
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('List & Card Elements'),
              _buildTypographyExample(
                'List Title',
                'Breakfast - Oatmeal with fruits',
                TontonTypography.listTitle,
                'Used in list items',
              ),
              _buildTypographyExample(
                'List Subtitle',
                '350 calories • 8:30 AM',
                TontonTypography.listSubtitle,
                'Used for secondary info',
              ),
              _buildTypographyExample(
                'Section Header',
                'TODAY\'S MEALS',
                TontonTypography.sectionHeader,
                'Used for grouped sections',
              ),
              _buildTypographyExample(
                'Card Title',
                'Daily Summary',
                TontonTypography.cardTitle,
                'Used in card headers',
              ),
              _buildTypographyExample(
                'Card Subtitle',
                'Last updated 5 minutes ago',
                TontonTypography.cardSubtitle,
                'Used for card metadata',
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Metrics & Data'),
              _buildTypographyExample(
                'Metric Value',
                '2,450',
                TontonTypography.metricValue,
                'Used for large numbers',
              ),
              _buildTypographyExample(
                'Metric Label',
                'CALORIES',
                TontonTypography.metricLabel,
                'Used below metrics',
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Japanese Text',
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('日本語テキストサンプル'),
              _buildTypographyExample(
                'Large Title',
                '今日のカロリー貯金',
                TontonTypography.largeTitle,
                '34pt / Regular',
              ),
              _buildTypographyExample(
                'Title 1',
                '月間目標達成率',
                TontonTypography.title1,
                '28pt / Regular',
              ),
              _buildTypographyExample(
                'Headline',
                '朝食を記録しました',
                TontonTypography.headline,
                '17pt / Semibold',
              ),
              _buildTypographyExample(
                'Body',
                'トントンは、毎日の食事と運動を記録して、カロリー貯金を楽しく管理できるアプリです。',
                TontonTypography.body,
                '17pt / Regular',
              ),
              _buildTypographyExample(
                'Caption',
                '※ 基礎代謝は年齢・性別・体重から自動計算されます',
                TontonTypography.caption1,
                '12pt / Regular',
              ),
            ],
          ),
        );
      },
    ),
  ],
);

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16, top: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget _buildTypographyExample(
  String name,
  String text,
  TextStyle style,
  String description,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: style,
        ),
      ],
    ),
  );
}