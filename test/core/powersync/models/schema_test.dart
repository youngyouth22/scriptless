import 'package:flutter_test/flutter_test.dart';
import 'package:scriptless/core/powersync/models/schema.dart';

void main() {
  group('PowerSync Schema Tests', () {
    test('schema should define all expected tables', () {
      final tableNames = schema.tables.map((t) => t.name).toSet();

      final expectedTables = {
        'scenario_categories',
        'scenarios',
        'achievements',
        'daily_tips',
        'profiles',
        'custom_personalities',
        'user_scenario_customizations',
        'conversations',
        'conversation_messages',
        'feedbacks',
        'user_progress',
        'user_achievements',
        'subscriptions',
        'notifications',
        'user_activity_logs',
      };

      for (final table in expectedTables) {
        expect(
          tableNames.contains(table),
          isTrue,
          reason: 'Missing table: $table',
        );
      }
    });

    test('tables should not declare id column in client schema', () {
      for (final table in schema.tables) {
        final columnNames = table.columns.map((c) => c.name).toList();
        expect(
          columnNames.contains('id'),
          isFalse,
          reason: 'Table ${table.name} must not declare id column',
        );
      }
    });

    test(
      'user_progress should not contain GENERATED ALWAYS recorded_date',
      () {
        final userProgressTable =
            schema.tables.firstWhere((t) => t.name == 'user_progress');
        final columnNames =
            userProgressTable.columns.map((c) => c.name).toList();
        expect(columnNames.contains('recorded_date'), isFalse);
      },
    );
  });
}
