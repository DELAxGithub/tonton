かしこまりました。FlutterとHealthKitを使用して指定された健康データを取得・表示するPoC（概念実証）のための、コードを含む完全な手順書を作成します。

---

## Flutter HealthKit PoC 手順書

**目標：**
iOSデバイスのHealthKitから以下のデータを取得し、Flutterアプリの画面に表示する。
* 今日行ったワークアウトの種類
* 今日行ったワークアウトで消費したアクティブカロリー
* 昨日のトータルカロリー（基礎代謝 + アクティブ）
* 昨日の体重（最新値）
* 昨日の体脂肪率（最新値）

**前提条件：**
* Flutter SDKがインストールされ、正しく設定されていること (`flutter doctor`で確認済みであること)。
* Xcodeがインストールされていること。
* テスト用のiOS物理デバイス（iPhone）があること。
* Visual Studio Code (VSCode) がインストールされていること。
* Apple Developerアカウント（HealthKitのCapabilityを追加するために必要）。

---

### ステップ1: Flutterプロジェクトの新規作成

1.  **ターミナルを開き、指定のディレクトリに移動します。**
    ```bash
    cd /Users/hiroshikodera/repos/_active/apps/poc
    ```

2.  **新しいFlutterプロジェクトを作成します。**
    ここではプロジェクト名を `health_poc_app` とします。

    ```bash
    flutter create health_poc_app
    ```

3.  **作成したプロジェクトディレクトリに移動します。**
    ```bash
    cd health_poc_app
    ```

4.  **VSCodeでプロジェクトを開きます。**
    ```bash
    code .
    ```

---

### ステップ2: `health` プラグインの追加

1.  **VSCodeで `pubspec.yaml` ファイルを開きます。**
    このファイルはプロジェクトのルートディレクトリにあります。

2.  **`dependencies:` セクションに `health` プラグインを追加します。**
    `#LATEST_VERSION#` 部分は、[pub.devのhealthパッケージページ](https://pub.dev/packages/health)で最新バージョンを確認して置き換えてください。（例: `^7.0.0`）

    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      cupertino_icons: ^1.0.2 # これは元からあるかもしれません
      health: ^7.0.0 #LATEST_VERSION# を最新版に置き換えてください
    ```

3.  **ファイルを保存します。**

4.  **VSCodeのターミナル（またはシステムのターミナルでプロジェクトディレクトリに移動して）以下のコマンドを実行し、プラグインをインストールします。**
    ```bash
    flutter pub get
    ```

---

### ステップ3: iOSプロジェクトの設定 (Xcode)

HealthKitを利用するためには、iOSネイティブプロジェクトの設定が必要です。

1.  **XcodeでiOSプロジェクトを開きます。**
    VSCodeのプロジェクトエクスプローラーで `ios` フォルダ内の `Runner.xcworkspace` ファイルを右クリックし、「Open in Xcode」を選択するか、ターミナルで以下のコマンドを実行します。
    ```bash
    open ios/Runner.xcworkspace
    ```

2.  **HealthKit Capabilityを追加します。**
    a. Xcodeの左側のプロジェクトナビゲーターで `Runner` プロジェクトを選択します。
    b. 中央のエリアで `Runner` ターゲットを選択します。
    c. 上部のタブから `Signing & Capabilities` を選択します。
    d. `+ Capability` ボタン（左上隅近く）をクリックします。
    e. 表示されるリストから `HealthKit` を検索し、ダブルクリックして追加します。
        * リストに `Clinical Health Records` のチェックボックスが表示されることがありますが、今回のPoCでは不要です。

3.  **`Info.plist` にHealthKitの利用目的を記述します。**
    ユーザーにアクセス許可を求める際に表示されるメッセージです。
    a. Xcodeのプロジェクトナビゲーターで `Runner` フォルダ内にある `Info.plist` ファイルを選択します。
    b. `Info.plist` のエディタ内で、空いている行を右クリックし、「Add Row」を選択します。
    c. 以下の2つのキーと、それぞれのValue（説明文）を追加します。説明文はアプリの内容に合わせて適宜変更してください。

    | Key                                 | Type   | Value (例)                                                                 |
    | :---------------------------------- | :----- | :------------------------------------------------------------------------- |
    | `Privacy - Health Share Usage Description` | String | `ワークアウトデータや健康記録を読み取るためにヘルスケアデータへのアクセスを許可してください。`                                   |
    | `Privacy - Health Update Usage Description` | String | `健康データをヘルスケアアプリに記録するためにアクセスを許可してください。(このPoCでは書き込みは行いません)` |

    * もしXcodeでRaw Keys and Valuesとして表示されている場合は、以下のようになります。
        ```xml
        <key>NSHealthShareUsageDescription</key>
        <string>ワークアウトデータや健康記録を読み取るためにヘルスケアデータへのアクセスを許可してください。</string>
        <key>NSHealthUpdateUsageDescription</key>
        <string>健康データをヘルスケアアプリに記録するためにアクセスを許可してください。(このPoCでは書き込みは行いません)</string>
        ```

---

### ステップ4: Flutterコードの実装

VSCodeで `lib/main.dart` ファイルを開き、以下の内容に置き換えます。

```dart
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health PoC',
      theme: ThemeData(
        primarySwatch: Colors.pink, // テーマカラーをピンク系に変更
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HealthDataScreen(),
    );
  }
}

class HealthDataScreen extends StatefulWidget {
  @override
  _HealthDataScreenState createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  String _todayWorkoutTypes = 'データ未取得';
  String _todayWorkoutCalories = 'データ未取得';
  String _yesterdayTotalCalories = 'データ未取得';
  String _yesterdayWeight = 'データ未取得';
  String _yesterdayBodyFat = 'データ未取得';

  bool _isLoading = false;
  String _statusMessage = 'ボタンを押してデータを取得してください';

  // HealthFactoryのインスタンスを作成
  // v7.0.0以降、HealthFactory() の引数で types を渡す必要がなくなりました。
  HealthFactory health = HealthFactory();

  // 取得したいデータ型を定義
  static final types = [
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.WEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
  ];

  // 各データ型に対する権限（今回は全て読み取りのみ）
  final permissions = types.map((e) => HealthDataAccess.READ).toList();

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'HealthKitにアクセス中...';
    });

    // 権限リクエスト
    // v7.0.0以降、requestAuthorizationはboolではなく、権限が付与されたかどうかを返します。
    bool? authRequested = await health.requestAuthorization(types, permissions: permissions);

    if (authRequested == true) { // trueなら権限が付与された
      try {
        // 今日の日付範囲
        DateTime now = DateTime.now();
        DateTime todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
        DateTime todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999); // ミリ秒も考慮

        // 昨日の日付範囲
        DateTime yesterdayEnd = todayStart.subtract(Duration(microseconds: 1)); // 今日の0時の直前
        DateTime yesterdayStart = yesterdayEnd.subtract(Duration(days: 1)).add(Duration(microseconds: 1));


        // --- 1. 今日のワークアウトの種類とアクティブカロリー ---
        List<HealthDataPoint> todayWorkoutsData = await health.getHealthDataFromTypes(
          startTime: todayStart,
          endTime: todayEnd,
          types: [HealthDataType.WORKOUT],
        );

        List<String> workoutTypesList = [];
        double totalWorkoutCalories = 0;

        // デバッグ用に取得した全ワークアウトデータを表示
        // print("今日のワークアウトデータ: ${todayWorkoutsData.map((e) => e.toJson()).toList()}");

        for (var workout in todayWorkoutsData) {
          // workout.typeString は HealthWorkoutActivityType.AEROBICS のような文字列
          workoutTypesList.add(workout.typeString ?? '不明');

          // HealthDataPoint.value は HealthValue 型
          // WORKOUT の場合、 HealthWorkoutValue? にキャストできるか確認
          final value = workout.value;
          if (value is HealthWorkoutValue) {
             // HealthWorkoutValue には totalEnergyBurned が含まれているはず
            totalWorkoutCalories += value.totalEnergyBurned?.toDouble() ?? 0.0;
          } else {
            // 古いバージョンのプラグインや予期せぬデータ型の場合のフォールバック
            // (v7.x.xでは上記が期待される)
            // print("今日のワークアウト ${workout.typeString} の value は HealthWorkoutValue ではありませんでした: ${value.runtimeType}");
            // print("Value details: ${value.toJson()}");
          }

          try {
            if (workout.workoutSummary != null) {
              print("  workout.workoutSummary は存在します。");
              // print("    workoutSummary.workoutActivityType: ${workout.workoutSummary?.workoutActivityType}"); // ← ここをコメントアウト
              print("    workoutSummary.totalEnergyBurned: ${workout.workoutSummary?.totalEnergyBurned}");
            } else {
              print("  workout.workoutSummary は null です。");
            }
          } catch (e) {
            print("  workout.workoutSummary のアクセス中にエラー: $e");
          }
        }
        _todayWorkoutTypes = workoutTypesList.isNotEmpty ? workoutTypesList.toSet().join(', ') : 'ワークアウトなし';
        _todayWorkoutCalories = '${totalWorkoutCalories.toStringAsFixed(0)} kcal';


        // --- 2. 昨日のトータルカロリー (アクティブ + 基礎代謝) ---
        List<HealthDataPoint> yesterdayActiveEnergy = await health.getHealthDataFromTypes(
          startTime: yesterdayStart,
          endTime: yesterdayEnd,
          types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        );
        List<HealthDataPoint> yesterdayBasalEnergy = await health.getHealthDataFromTypes(
          startTime: yesterdayStart,
          endTime: yesterdayEnd,
          types: [HealthDataType.BASAL_ENERGY_BURNED],
        );

        double totalActive = yesterdayActiveEnergy.fold(0, (prev, e) {
          final val = e.value;
          return prev + (val is NumericHealthValue ? val.numericValue.toDouble() : 0.0);
        });
        double totalBasal = yesterdayBasalEnergy.fold(0, (prev, e) {
          final val = e.value;
          return prev + (val is NumericHealthValue ? val.numericValue.toDouble() : 0.0);
        });
        _yesterdayTotalCalories = '${(totalActive + totalBasal).toStringAsFixed(0)} kcal';


        // --- 3. 昨日の体重 (最新値) ---
        List<HealthDataPoint> yesterdayWeightData = await health.getHealthDataFromTypes(
          startTime: yesterdayStart,
          endTime: yesterdayEnd,
          types: [HealthDataType.WEIGHT],
        );
        if (yesterdayWeightData.isNotEmpty) {
          yesterdayWeightData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom)); // 新しい順
          final val = yesterdayWeightData.first.value;
          _yesterdayWeight = val is NumericHealthValue ? '${val.numericValue.toStringAsFixed(1)} kg' : 'データなし';
        } else {
          _yesterdayWeight = 'データなし';
        }


        // --- 4. 昨日の体脂肪率 (最新値) ---
        List<HealthDataPoint> yesterdayBodyFatData = await health.getHealthDataFromTypes(
          startTime: yesterdayStart,
          endTime: yesterdayEnd,
          types: [HealthDataType.BODY_FAT_PERCENTAGE],
        );
        if (yesterdayBodyFatData.isNotEmpty) {
          yesterdayBodyFatData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom)); // 新しい順
          final val = yesterdayBodyFatData.first.value;
          if (val is NumericHealthValue) {
            double bodyFatValue = val.numericValue.toDouble();
            _yesterdayBodyFat = '${(bodyFatValue * 100).toStringAsFixed(1)} %'; // 0.xx -> xx.x %
          } else {
             _yesterdayBodyFat = 'データなし';
          }
        } else {
          _yesterdayBodyFat = 'データなし';
        }

        _statusMessage = 'データの取得が完了しました。';

      } catch (error, stackTrace) {
        print("HealthKitデータ取得エラー: $error");
        print("スタックトレース: $stackTrace");
        _statusMessage = 'エラー: $error';
        // 各データをリセット
        _todayWorkoutTypes = 'エラー';
        _todayWorkoutCalories = 'エラー';
        _yesterdayTotalCalories = 'エラー';
        _yesterdayWeight = 'エラー';
        _yesterdayBodyFat = 'エラー';
      }
    } else {
      _statusMessage = 'HealthKitへのアクセスが許可されませんでした。設定アプリから許可してください。';
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Health PoC'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton.icon(
              icon: Icon(Icons.health_and_safety),
              label: Text('HealthKitからデータを取得', style: TextStyle(fontSize: 16)),
              onPressed: _isLoading ? null : fetchData,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else ...[
              Text(_statusMessage, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
              SizedBox(height: 20),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("今日のデータ", style: Theme.of(context).textTheme.headlineSmall),
                      Divider(),
                      _buildDataRow('ワークアウト種類:', _todayWorkoutTypes),
                      _buildDataRow('ワークアウト消費カロリー:', _todayWorkoutCalories),
                      SizedBox(height: 20),
                      Text("昨日のデータ", style: Theme.of(context).textTheme.headlineSmall),
                      Divider(),
                      _buildDataRow('トータル消費カロリー:', _yesterdayTotalCalories),
                      _buildDataRow('体重:', _yesterdayWeight),
                      _buildDataRow('体脂肪率:', _yesterdayBodyFat),
                    ],
                  ),
                ),
              ),
            ],
            Spacer(),
             Text(
              "注意: HealthKitのデータはiOS「ヘルスケア」アプリに登録されている必要があります。",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
```

**主な変更点・注意点:**
* **`HealthFactory()`の初期化**: `health`プラグインのv7.0.0以降、コンストラクタで`types`を渡す必要がなくなりました。
* **`requestAuthorization()`の戻り値**: `bool?` に変更され、`true`が付与成功を示します。
* **`getHealthDataFromTypes()`の引数名**: `startTime`, `endTime`, `types` に変更されています。
* **`HealthWorkoutValue`**: ワークアウトの消費カロリーは `HealthDataPoint.value` (型は `HealthValue`) を `HealthWorkoutValue` にキャストして `totalEnergyBurned` を取得することを試みています。これは `health` プラグインの一般的な使い方です。実際のデータ構造は、デバッグプリント(`print(workout.toJson());` や `print(value.toJson());`)で確認することが重要です。
* **日付範囲の修正**: `yesterdayEnd` を今日の0時の直前（マイクロ秒単位で調整）にし、`yesterdayStart` をそこから1日前としました。これにより、昨日丸一日を正確にカバーします。
* **UIの改善**: `Card` や `Divider` を使って見やすくしました。ステータスメッセージも表示します。
* **エラーハンドリング**: `try-catch`ブロックでエラーを捕捉し、ユーザーにメッセージを表示するようにしています。スタックトレースもコンソールに出力します。

---

### ステップ5: iOS「ヘルスケア」アプリにテストデータを準備

このPoCをテストするには、iPhoneの「ヘルスケア」アプリに以下のデータが登録されている必要があります。

* **今日:**
    * 何らかのワークアウト（例: ウォーキング 30分、消費カロリー 150kcal）
* **昨日:**
    * アクティブカロリーと基礎代謝カロリー (これらが合計されて「トータルカロリー」となる)
    * 体重
    * 体脂肪率

これらのデータは、「ヘルスケア」アプリを開き、「ブラウズ」タブから各項目を選んで手動で「データを追加」することで入力できます。

---

### ステップ6: Flutterアプリを実機で実行

1.  **iPhoneをMacにUSBで接続します。**

2.  **VSCodeで実行デバイスとして接続したiPhoneを選択します。**
    VSCodeの右下隅に表示されているデバイス名（例: `iPhone SE`、`My iPhone`など）をクリックし、リストから実機を選択します。

3.  **VSCodeのターミナルで以下のコマンドを実行してアプリを起動します。**
    ```bash
    flutter run
    ```
    または、VSCodeの「実行」メニューから「デバッグなしで実行」(Ctrl+F5 or Cmd+F5) を選択します。

4.  **アプリが起動すると、最初にHealthKitへのアクセス許可を求めるダイアログが表示されます。**
    「すべてオンにする」または必要な項目（ワークアウト、アクティブエネルギー、基礎代謝エネルギー、体重、体脂肪率など）をオンにして、右上の「許可」をタップします。

5.  **アプリ画面の「HealthKitからデータを取得」ボタンをタップします。**

---

### ステップ7: 動作検証とデバッグ

* ボタンをタップ後、ヘルスケアアプリに登録したデータが正しく画面に表示されるか確認します。
* 特に「今日のワークアウト消費カロリー」が正しく取得できるか注意してください。`HealthWorkoutValue` の `totalEnergyBurned` が `null` であったり、期待する値でない場合は、`WorkspaceData` メソッド内の `print` 文をアンコメントしてコンソールに出力される実際のデータ構造を確認し、アクセス方法を調整してください。
    ```dart
    // デバッグ用に取得した全ワークアウトデータを表示
    // print("今日のワークアウトデータ: ${todayWorkoutsData.map((e) => e.toJson()).toList()}");
    // ...
    // print("今日のワークアウト ${workout.typeString} の value は HealthWorkoutValue ではありませんでした: ${value.runtimeType}");
    // print("Value details: ${value.toJson()}");
    ```
* エラーメッセージが表示された場合は、VSCodeの「デバッグコンソール」やターミナルのログを確認して原因を特定します。

---

これで、FlutterとHealthKitを連携させたPoCアプリの作成とテストを行うことができます。ご不明な点があれば、お気軽にお尋ねください。