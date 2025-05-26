import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart' as provider_pkg;

import '../providers/health_provider.dart';

/// Widget that displays the activity tab content of HomeScreen.
class ActivityContent extends StatelessWidget {
  const ActivityContent({super.key});

  @override
  Widget build(BuildContext context) {
    

    return provider_pkg.Consumer<HealthProvider>(
      builder: (context, provider, child) {


        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildFetchButton(provider),
              const SizedBox(height: 20),
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                Text(
                  provider.statusMessage,
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (provider.hasData)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildTodayCard(context, provider),
                          const SizedBox(height: 16),
                          _buildYesterdayCard(context, provider),
                        ],
                      ),
                    ),
                  )
                else
                  const Expanded(
                    child: Center(
                      child: Text('データがまだありません。「HealthKitからデータを取得」ボタンを押してください。'),
                    ),
                  ),
              ],
              const SizedBox(height: 20),
              const Text(
                '注意: HealthKitのデータはiOS「ヘルスケア」アプリに登録されている必要があります。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFetchButton(HealthProvider provider) {


    return ElevatedButton.icon(
      icon: Icon(
        defaultTargetPlatform == TargetPlatform.iOS
            ? CupertinoIcons.heart_circle
            : Icons.health_and_safety,
      ),
      label:
          const Text('HealthKitからデータを取得', style: TextStyle(fontSize: 16)),
      onPressed: provider.isLoading
          ? null
          : () {
              provider.fetchAllData();
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildTodayCard(BuildContext context, HealthProvider provider) {
    final activitySummary = provider.todayActivity;


    if (activitySummary == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('今日のデータはまだありません'),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日のデータ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildDataRow('今日のワークアウト:',
                activitySummary.hasWorkouts ? activitySummary.workoutTypes.join(', ') : 'ワークアウトなし'),
            _buildDataRow('ワークアウト消費カロリー:',
                '${activitySummary.workoutCalories.toStringAsFixed(0)} kcal'),
          ],
        ),
      ),
    );
  }

  Widget _buildYesterdayCard(BuildContext context, HealthProvider provider) {
    final activitySummary = provider.yesterdayActivity;
    final weightRecord = provider.yesterdayWeight;


    if (activitySummary == null && weightRecord == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('昨日のデータはまだありません'),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '昨日のデータ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            if (activitySummary != null) ...[
              _buildDataRow('トータル消費カロリー:',
                  '${activitySummary.totalCalories.toStringAsFixed(0)} kcal'),
            ],
            if (weightRecord != null) ...[
              _buildDataRow('体重:', weightRecord.formattedWeight),
              _buildDataRow('体脂肪率:', weightRecord.formattedBodyFat),
              _buildDataRow('体脂肪量:', weightRecord.formattedBodyFatMass),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
