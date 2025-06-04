import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:bookhero/database/database_helper.dart';

class UnsyncedIssue {
  final String title;
  final Map<String, dynamic> series;
  final Map<String, dynamic> issue;

  UnsyncedIssue({
    required this.title,
    required this.series,
    required this.issue,
  });
}

Future<List<UnsyncedIssue>> getUnsyncedIssues() async {
  final db = DatabaseHelper();
  final dio = Dio();

  final localDb = await db.db;
  final response = await dio.get(
    'https://uscmobileapps.com/comics/server_data/get_server_data/sync_script_and_schema.php',
  );

  if (response.data['success'] != true) return [];

  final serverSeries = response.data['series'] as List;
  final List<UnsyncedIssue> diffs = [];

  for (final series in serverSeries) {
    final issues = series['issues'] as List;

    for (final issue in issues) {
      final existing = await localDb.query(
        'issues',
        where: 'id = ?',
        whereArgs: [issue['id']],
      );

      if (existing.isEmpty) {
        final title = '${series['title']} #${issue['issue_number']}';
        diffs.add(UnsyncedIssue(title: title, series: series, issue: issue));
      }
    }
  }

  return diffs;
}

void showSyncDialog(
  BuildContext context,
  List<UnsyncedIssue> itemsToSync,
  VoidCallback onSyncComplete,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return _SyncDialog(
        itemsToSync: itemsToSync,
        onSyncComplete: onSyncComplete,
      );
    },
  );
}

class _SyncDialog extends StatefulWidget {
  final List<UnsyncedIssue> itemsToSync;
  final VoidCallback onSyncComplete;

  const _SyncDialog({required this.itemsToSync, required this.onSyncComplete});

  @override
  State<_SyncDialog> createState() => _SyncDialogState();
}

class _SyncDialogState extends State<_SyncDialog> {
  bool _isSyncing = false;

  Future<void> _performSync() async {
    setState(() => _isSyncing = true);

    final dbHelper = DatabaseHelper();
    final localDb = await dbHelper.db;

    for (final item in widget.itemsToSync) {
      final seriesId = item.series['id'];
      final exists = await localDb.query(
        'series',
        where: 'id = ?',
        whereArgs: [seriesId],
      );

      if (exists.isEmpty) {
        await localDb.insert('series', {
          'id': item.series['id'],
          'title': item.series['title'],
          'description': item.series['description'],
          'year_range': item.series['year_range'],
          'comic_type': item.series['comic_type'],
        });
      }

      await localDb.insert('issues', {
        'id': item.issue['id'],
        'series_id': item.issue['series_id'],
        'issue_number': item.issue['issue_number'],
        'obtained': item.issue['obtained'] ? 1 : 0,
        'tags':
            item.issue['tags'] != null
                ? (item.issue['tags'] as List).join(',')
                : null,
        'cover_type': item.issue['cover_type'],
        'variant': item.issue['variant'],
        'special_edition': item.issue['special_edition'],
        'description': item.issue['description'],
        'event_id': item.issue['event_id'],
      });
    }

    if (mounted) {
      widget.onSyncComplete();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Synced from cloud")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: _isSyncing ? null : _performSync,
                icon: const Icon(Icons.cloud_download),
                label: const Text("Pull from Cloud"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      _isSyncing
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text("Syncing data, please wait..."),
                            ],
                          )
                          : widget.itemsToSync.isEmpty
                          ? const Center(
                            child: Text("Everything is up to date."),
                          )
                          : ListView.builder(
                            itemCount: widget.itemsToSync.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(widget.itemsToSync[index].title),
                                leading: const Icon(Icons.bolt_outlined),
                              );
                            },
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
