import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:io';
import 'package:maya_on_the_fly/main.dart';
import 'package:maya_on_the_fly/features/settings/data/database/app_database.dart';
import 'package:maya_on_the_fly/features/onboarding/data/onboarding_service.dart';
import 'package:path/path.dart' as p;

class UniquePathProvider extends PathProviderPlatform with MockPlatformInterfaceMixin {
  final String base;
  UniquePathProvider(this.base);

  @override
  Future<String> getApplicationDocumentsPath() async => base;
  @override
  Future<String> getTemporaryPath() async => base;
  @override
  Future<String?> getApplicationSupportPath() async => base;
  @override
  Future<String?> getLibraryPath() async => base;
  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async => [base];
  @override
  Future<String?> getApplicationCachePath() async => base;
  @override
  Future<String?> getDownloadsPath() async => base;
  @override
  Future<List<String>?> getExternalCachePaths() async => [base];
}

const _mockSecureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

void main() {
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.systemTemp.path, 'widget_test_${DateTime.now().millisecondsSinceEpoch}');
    await Directory(testDir).create(recursive: true);

    final storage = <String, String>{};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_mockSecureStorageChannel, (methodCall) async {
      if (methodCall.method == 'read') {
        final args = methodCall.arguments as Map;
        return storage[args['key'] as String];
      }
      if (methodCall.method == 'write') {
        final args = methodCall.arguments as Map;
        storage[args['key'] as String] = args['value'] as String;
        return null;
      }
      return null;
    });

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = UniquePathProvider(testDir);
    await AppDatabase.instance.initialize();
    await OnboardingService.instance.completeOnboarding();
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_mockSecureStorageChannel, null);
    await Directory(testDir).delete(recursive: true);
  });

  testWidgets('App renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(const MayaOnTheFlyApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Maya'), findsWidgets);
  });
}
