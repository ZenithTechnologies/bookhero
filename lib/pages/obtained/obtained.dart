import 'package:bookhero/config/events_data.dart';
import 'package:bookhero/database/database_helper.dart';
import 'package:bookhero/model/comic_model.dart';
import 'package:bookhero/model/section_model.dart';
import 'package:bookhero/widgets/comic_display/comic_folder_tile.dart';
import 'package:bookhero/widgets/comic_display/comic_issue_tile.dart';
import 'package:flutter/material.dart';

class Obtained extends StatefulWidget {
  const Obtained({super.key});

  @override
  State<Obtained> createState() => _ObtainedState();
}

class _ObtainedState extends State<Obtained> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterMode = 'Series View';
  final List<String> _filterOptions = ['Series View', 'Event View'];
  final Set<int> _pendingRemovals = {};

  final Set<String> _expandedHeaders = {};

  List<Comic> _obtainedData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadObtainedData();
  }

  void _togglePendingRemoval(int issueId) {
    setState(() {
      if (_pendingRemovals.contains(issueId)) {
        _pendingRemovals.remove(issueId);
      } else {
        _pendingRemovals.add(issueId);
      }
    });
  }

  List<NeedsSection> _generateGroupedSections() {
    if (_filterMode == 'Series View') {
      return _obtainedData
          .where(
            (comic) =>
                comic.title.toLowerCase().contains(_searchQuery) &&
                comic.issues.any((i) => i.obtained),
          )
          .map(
            (comic) => NeedsSection(
              id: comic.id!,
              displayLabel: comic.toString(),
              issues:
                  comic.issues
                      .where((i) => i.obtained)
                      .map((i) => IssueRowData(seriesId: comic.id!, issue: i))
                      .toList(),
              isEventMode: false,
            ),
          )
          .toList();
    } else {
      final grouped = <String, List<IssueRowData>>{};
      for (var comic in _obtainedData) {
        for (var issue in comic.issues) {
          if (issue.obtained) {
            final events = issue.tags.where((tag) => knownEvents.contains(tag));
            for (var event in events) {
              if (event.toLowerCase().contains(_searchQuery)) {
                grouped.putIfAbsent(event, () => []);
                grouped[event]!.add(
                  IssueRowData(seriesId: comic.id!, issue: issue),
                );
              }
            }
          }
        }
      }

      return grouped.entries
          .map(
            (e) => NeedsSection(
              id: -1,
              displayLabel: e.key,
              issues: e.value,
              isEventMode: true,
            ),
          )
          .toList();
    }
  }

  Future<void> _loadObtainedData() async {
    final db = DatabaseHelper();
    final seriesRows = await db.getAllSeries();
    final List<Comic> comics = [];

    for (var series in seriesRows) {
      final issuesRaw = await db.getIssuesBySeriesId(series['id']);
      final issues =
          issuesRaw
              .map((i) => Issue.fromMap(i))
              .where((i) => i.obtained)
              .toList();

      if (issues.isNotEmpty) {
        comics.add(
          Comic(
            id: series['id'],
            title: series['title'],
            era: '', // Optional: load from eras_data if implemented
            yearRange: series['year_range'],
            comicType: series['comic_type'],
            issues: issues,
          ),
        );
      }
    }

    setState(() {
      _obtainedData = comics;
      _isLoading = false;
    });
  }

  void _showPendingRemovalDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Pending Removals"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                children: [
                  for (var comic in _obtainedData)
                    for (var issue in comic.issues)
                      if (_pendingRemovals.contains(issue.id))
                        ListTile(
                          title: Text("${comic.title} #${issue.issueNumber}"),
                          subtitle: const Text("Will be removed from Obtained"),
                          leading: const Icon(Icons.undo, color: Colors.orange),
                        ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final db = DatabaseHelper();

                  for (var comic in _obtainedData) {
                    for (var issue in comic.issues) {
                      if (_pendingRemovals.contains(issue.id)) {
                        issue.obtained = false;
                        await db.updateIssue(issue.id!, {'obtained': 0});
                      }
                    }
                  }

                  Navigator.of(context).pop();
                  setState(() {
                    _pendingRemovals.clear();
                    _loadObtainedData();
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Selected issues moved back to Needs"),
                    ),
                  );
                },
                child: const Text("Apply Changes"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedSections = _generateGroupedSections();
    return Scaffold(
      body: Column(
        children: [
          if (_pendingRemovals.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    "Pending Removal: ${_pendingRemovals.length}",
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _showPendingRemovalDialog,
                    icon: const Icon(Icons.list_alt),
                    label: const Text("Review"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search obtained comics...',
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    onChanged:
                        (value) => setState(() {
                          _searchQuery = value.trim().toLowerCase();
                        }),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filter View Mode',
                  onSelected: (value) => setState(() => _filterMode = value),
                  itemBuilder:
                      (context) =>
                          _filterOptions
                              .map(
                                (option) => PopupMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                ),
                              )
                              .toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: groupedSections.length,
              itemBuilder: (context, index) {
                final section = groupedSections[index];
                final isExpanded = _expandedHeaders.contains(
                  section.displayLabel,
                );

                final comic = _obtainedData.firstWhere(
                  (c) => c.id == section.id,
                  orElse:
                      () => Comic(
                        id: section.id,
                        title: '',
                        era: '',
                        yearRange: '',
                        comicType: '',
                        issues: [],
                      ),
                );

                return ComicFolderTile(
                  section: section,
                  comic: comic,
                  isExpanded: isExpanded,
                  needsData: _obtainedData,
                  expandedHeaders: _expandedHeaders,
                  onToggleExpand: () {
                    setState(() {
                      isExpanded
                          ? _expandedHeaders.remove(section.displayLabel)
                          : _expandedHeaders.add(section.displayLabel);
                    });
                  },
                  onLongPressEdit:
                      null, // Optional: disable folder editing here
                  onAddIssue: null, // Optional: hide add issue in obtained view
                  child: Column(
                    children:
                        section.issues.map((issueData) {
                          final comic = _obtainedData.firstWhere(
                            (c) => c.id == issueData.seriesId,
                          );
                          final comicIndex = comic.issues.indexWhere(
                            (i) => i.id == issueData.issue.id,
                          );

                          return ComicIssueTile(
                            header: comic.title,
                            issue: issueData.issue,
                            index: comicIndex,
                            overrideSeries:
                                section.isEventMode ? comic.title : null,
                            isPending: _pendingRemovals.contains(
                              issueData.issue.id,
                            ), //
                            currentObtained: true,
                            markPendingToggle: _togglePendingRemoval,
                          );
                        }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
