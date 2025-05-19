# Hive Persistence Debugging Guide

This document provides guidance on using the built-in debugging tools to diagnose and fix Hive persistence issues in the TonTon app, especially related to hot restart problems.

## Comprehensive Logging System

The app includes a dedicated `HiveDebugHelper` class designed to provide detailed insights into the state of Hive persistence throughout the application lifecycle. This helps identify issues with box initialization, data saving, and file handling, especially during hot restarts.

## Debug Log Categories

The logging system uses clear category markers to help filter logs in the console:

1. **[HIVE_INIT]** - Logs related to Hive initialization
2. **[HIVE_BOX]** - Logs for box operations (open, close, read)
3. **[HIVE_OP]** - Logs for specific operations (save, delete, update)
4. **[HIVE_FILE]** - Logs for file system status and checks
5. **[HIVE_LIFECYCLE]** - Logs for app lifecycle events
6. **[HIVE_RESTART]** - Logs specific to hot restart detection
7. **[HIVE_WRITE]** - Logs for data write operations
8. **[HIVE_REPO]** - Logs from the repository implementation

## Key Diagnostic Points

### 1. Hot Restart Detection

```dart
// In the HiveBoxManager
// Hot restart detection
static bool _hasRunBefore = false;

// In the initialize method
if (_hasRunBefore) {
  developer.log('HOT RESTART DETECTED during Hive initialization', name: 'Hive.manager');
  await hiveDebugHelper.logHotRestart();
} else {
  _hasRunBefore = true;
}
```

When a hot restart is detected, special logging is triggered to capture:
- Application directory paths
- Registered adapters
- Open boxes
- Box file existence and sizes

### 2. Box State Verification

```dart
Future<void> logBoxState(Box box, {String? operationContext}) async {
  // Logs detailed box information including:
  // - Path
  // - Open status
  // - Item count
  // - Keys list
  // - Box file existence and size
}
```

This allows you to track the complete state of boxes before and after operations.

### 3. File System Monitoring

```dart
Future<void> logFilesInAppDirectory() async {
  // Logs all files in the app directory
  // Specifically checks for Hive files and their sizes
}
```

This helps verify if Hive files are being created, modified, and persisted correctly.

### 4. Write Operation Validation

```dart
Future<void> logWriteOperation(String operationType, MealRecord record, Box<MealRecord> box)
Future<void> logAfterWriteOperation(String operationType, String recordId, Box<MealRecord> box)
```

These methods log the complete state of a box before and after write operations, helping to identify issues with data persistence.

### 5. Instance Tracking

```dart
// In HiveMealRecordRepository
final String _instanceId = DateTime.now().millisecondsSinceEpoch.toString();
```

Each repository instance gets a unique ID to track recreation during hot restarts.

## How to Debug Hive Persistence Issues

### 1. Check Initialization Sequence

Look for `[HIVE_INIT]` logs to ensure initialization happens in the correct order:
- Hive.initFlutter() is called before box operations
- Adapters are registered correctly
- Initialization path is consistent

### 2. Monitor Box Lifecycle

Look for `[HIVE_BOX]` logs to verify box handling:
- Boxes are opened successfully
- Box paths remain consistent across restarts
- Box state (open/closed) is maintained appropriately

### 3. Verify File Persistence

Check `[HIVE_FILE]` logs to ensure file persistence:
- .hive files exist in the expected directory
- File sizes change when data is written
- Files persist after app pauses or hot restarts

### 4. Track Write Operations

Use `[HIVE_WRITE]` logs to verify data is saved correctly:
- Data is written to the box
- Flush operations complete successfully
- Data can be retrieved after writing

### 5. Analyze Hot Restart Issues

When a hot restart occurs, look for:
- `HOT RESTART DETECTED` messages
- Changes in box path or application directory
- Missing or unregistered adapters
- Box open status after restart

## Common Diagnostics

### Checking Path Consistency

Verify that the application directory remains consistent:

```
[HIVE_INIT] App documents directory: /path/to/documents
```

### Verifying Box File Existence

Look for logs confirming box files exist:

```
[HIVE_BOX][AFTER_OPEN] Box: meal_records state:
[HIVE_BOX][AFTER_OPEN] - Box file exists: true
[HIVE_BOX][AFTER_OPEN] - Box file size: 2.3 KB
```

### Tracking Box Contents

Verify box contents are maintained:

```
[HIVE_BOX][GET_ALL_RECORDS] Box: meal_records state:
[HIVE_BOX][GET_ALL_RECORDS] - Item count: 5
[HIVE_BOX][GET_ALL_RECORDS] - Keys: [record1, record2, record3, record4, record5]
```

## Troubleshooting Process

1. **Initialization Issues**
   - Check `[HIVE_INIT]` logs to verify initialization sequence
   - Verify adapter registration logs
   - Confirm application directory paths are consistent

2. **Box Opening Issues**
   - Check `[HIVE_BOX]` logs for box open operations
   - Verify box paths and file existence
   - Check for errors during box opening

3. **Data Persistence Issues**
   - Compare box state before and after write operations
   - Verify file sizes after flush operations
   - Check if data is accessible after hot restart

4. **Lifecycle Issues**
   - Review `[HIVE_LIFECYCLE]` logs to see how the app handles paused/resumed states
   - Verify boxes are flushed when app is paused
   - Confirm boxes are properly reopened when resumed

## Identifying Hot Restart Issues

Hot restart issues typically manifest in these patterns:

1. **Box Path Changes**
   - The box path changes after hot restart
   - This can cause data to be stored in different locations

2. **Adapter Registration Issues**
   - Adapters are not re-registered after hot restart
   - This causes "No type adapter found" errors

3. **Box State Confusion**
   - Box references are lost during hot restart
   - Box is reported as open but contains no data

4. **File System Issues**
   - .hive files exist but box reports empty
   - .hive files are not updated after write operations

## Debugging in Action

To diagnose a specific issue:

1. Filter logs by `[HIVE_RESTART]` to see what happens during hot restart
2. Check `[HIVE_BOX]` logs to verify box state before and after restart  
3. Review file system status through `[HIVE_FILE]` logs
4. Monitor write operations with `[HIVE_WRITE]` logs
5. Check for any errors or inconsistencies in the logs

## Example Debug Workflow

1. Start the app and observe initialization logs
2. Perform some data operations (save, get, delete)
3. Trigger a hot restart
4. Check if the previously saved data is still accessible
5. Look through logs to identify any issues in the restart process

By systematically analyzing these logs, you can identify and fix most Hive persistence issues, especially those related to hot restart scenarios.