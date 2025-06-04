import 'package:dio/dio.dart';
import 'package:bookhero/database/database_helper.dart';

Future<void> syncFromServer() async {
  final dbHelper = DatabaseHelper();
  final dio = Dio();

  final response = await dio.get(
    'https://uscmobileapps.com/comics/server_data/get_server_data/sync_script_and_schema.php',
  );

  if (response.data['success'] != true) {
    throw Exception("Failed to sync data");
  }

  final eras = response.data['eras'] as List;
  final events = response.data['events'] as List;
  final seriesList = response.data['series'] as List;

  final localDb = await dbHelper.db;

  // Insert Eras if not present
  for (final era in eras) {
    final exists = await localDb.query(
      'eras',
      where: 'id = ?',
      whereArgs: [era['id']],
    );
    if (exists.isEmpty) {
      await localDb.insert('eras', {'id': era['id'], 'name': era['name']});
    }
  }

  // Insert Events if not present
  for (final event in events) {
    final exists = await localDb.query(
      'events',
      where: 'id = ?',
      whereArgs: [event['id']],
    );
    if (exists.isEmpty) {
      await localDb.insert('events', {
        'id': event['id'],
        'name': event['name'],
      });
    }
  }

  // Insert Series and Issues
  for (final series in seriesList) {
    final seriesId = series['id'];
    final exists = await localDb.query(
      'series',
      where: 'id = ?',
      whereArgs: [seriesId],
    );

    if (exists.isEmpty) {
      await localDb.insert('series', {
        'id': series['id'],
        'title': series['title'],
        'description': series['description'],
        'year_range': series['year_range'],
        'comic_type': series['comic_type'],
      });
    }

    final issues = series['issues'] as List;
    for (final issue in issues) {
      final issueExists = await localDb.query(
        'issues',
        where: 'id = ?',
        whereArgs: [issue['id']],
      );

      if (issueExists.isEmpty) {
        await localDb.insert('issues', {
          'id': issue['id'],
          'series_id': issue['series_id'],
          'issue_number': issue['issue_number'],
          'obtained': issue['obtained'] ? 1 : 0,
          'tags':
              issue['tags'] != null
                  ? (issue['tags'] as List).join(',') // or jsonEncode
                  : null,
          'cover_type': issue['cover_type'],
          'variant': issue['variant'],
          'special_edition': issue['special_edition'],
          'description': issue['description'],
          'event_id': issue['event_id'],
        });
      }
    }
  }
}

class SyncStatusService {
  Future<bool> isSyncRequired() async {
    final dbHelper = DatabaseHelper();
    final dio = Dio();

    final response = await dio.get(
      'https://uscmobileapps.com/comics/server_data/get_server_data/sync_script_and_schema.php',
    );

    if (response.data['success'] != true) return false;

    final localDb = await dbHelper.db;

    final List serverSeries = response.data['series'];
    final localSeries = await localDb.query('series');

    if (localSeries.length != serverSeries.length) return true;

    for (final series in serverSeries) {
      final match = localSeries.firstWhere(
        (row) => row['id'] == series['id'],
        orElse: () => <String, Object?>{}, // ✅ Fixed here
      );

      if (match.isEmpty ||
          match['title'] != series['title'] ||
          match['year_range'] != series['year_range']) {
        return true;
      }

      final localIssues = await localDb.query(
        'issues',
        where: 'series_id = ?',
        whereArgs: [series['id']],
      );

      if (localIssues.length != (series['issues'] as List).length) return true;
    }

    return false; // No mismatches
  }
}
