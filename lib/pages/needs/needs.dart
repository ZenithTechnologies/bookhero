import 'package:bookhero/config/eras_data.dart';
import 'package:bookhero/config/events_data.dart';
import 'package:bookhero/database/database_helper.dart';
import 'package:bookhero/model/comic_model.dart';
import 'package:bookhero/model/section_model.dart';
import 'package:bookhero/widgets/dialogs/comic_folder_dialog.dart';
import 'package:bookhero/widgets/dialogs/comic_issue_dialog.dart';
import 'package:flutter/material.dart';
import 'package:bookhero/widgets/comic_display/comic_issue_tile.dart';
import 'package:bookhero/widgets/comic_display/comic_folder_tile.dart';

class NeedsPage extends StatefulWidget {
  final Set<String> expandedHeaders;
  final void Function(int) toggleObtained;
  final void Function()? onLocalChange; // ✅ optional callback

  const NeedsPage({
    super.key,
    required this.expandedHeaders,
    required this.toggleObtained,
    this.onLocalChange, // ✅ pass it here
  });

  @override
  State<NeedsPage> createState() => NeedsPageState();
}

class NeedsPageState extends State<NeedsPage> {
  int checkedCount = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterMode = 'Series View';
  final List<String> _filterOptions = ['Series View', 'Event View'];
  List<Comic> _needsData = [];
  bool _isLoading = true;
  final Set<int> pendingToggles = {};

  @override
  void initState() {
    super.initState();
    _updateCheckedCount();
    _loadNeedsData();
  }

  void reloadData() {
    _loadNeedsData();
  }

  Future<void> _loadNeedsData() async {
    final db = DatabaseHelper();
    final seriesRows = await db.getAllSeries();
    final List<Comic> comics = [];

    for (var series in seriesRows) {
      final issuesRaw = await db.getIssuesBySeriesId(series['id']);
      final issues = issuesRaw.map((i) => Issue.fromMap(i)).toList();

      comics.add(
        Comic(
          id: series['id'],
          title: series['title'],
          era: '', // You can load this from a separate eras table if needed
          yearRange: series['year_range'],
          comicType: series['comic_type'],
          issues: issues,
        ),
      );
    }

    setState(() {
      _needsData = comics;
      _updateCheckedCount();
      _isLoading = false;
    });
  }

  void _updateCheckedCount() {
    int count = 0;
    for (var comic in _needsData) {
      for (var issue in comic.issues) {
        if (issue.obtained) count++;
      }
    }
    setState(() {
      checkedCount = count;
    });
  }

  List<NeedsSection> _generateGroupedSections() {
    if (_filterMode == 'Series View') {
      return _needsData
          .where((comic) => comic.title.toLowerCase().contains(_searchQuery))
          .map(
            (comic) => NeedsSection(
              id: comic.id!,
              displayLabel: comic.toString(),
              issues:
                  comic.issues
                      .map((i) => IssueRowData(seriesId: comic.id!, issue: i))
                      .toList(),
              isEventMode: false,
            ),
          )
          .toList();
    } else {
      final grouped = <String, List<IssueRowData>>{};
      for (var comic in _needsData) {
        for (var issue in comic.issues) {
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
      return grouped.entries
          .map(
            (e) => NeedsSection(
              id: -1, // placeholder since it's event-based
              displayLabel: e.key,
              issues: e.value,
              isEventMode: true,
            ),
          )
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedSections = _generateGroupedSections();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.book, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      "Pending Changes:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${pendingToggles.length}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text("Pending Toggles"),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  height: 400, // optional height constraint
                                  child:
                                      pendingToggles.isEmpty
                                          ? const Center(
                                            child: Text("No pending changes."),
                                          )
                                          : ListView(
                                            children: [
                                              for (var comic in _needsData)
                                                for (var issue in comic.issues)
                                                  if (pendingToggles.contains(
                                                    issue.id,
                                                  ))
                                                    Dismissible(
                                                      key: ValueKey(issue.id),
                                                      direction:
                                                          DismissDirection
                                                              .endToStart,
                                                      background: Container(
                                                        alignment:
                                                            Alignment
                                                                .centerRight,
                                                        color: Colors.red,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                            ),
                                                        child: const Icon(
                                                          Icons.delete,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      onDismissed: (_) {
                                                        setState(() {
                                                          pendingToggles.remove(
                                                            issue.id,
                                                          );
                                                        });
                                                      },
                                                      child: ListTile(
                                                        title: Text(
                                                          "${comic.title} #${issue.issueNumber}",
                                                        ),
                                                        subtitle: Text(
                                                          "Current: ${issue.obtained ? "Obtained" : "Not Obtained"} → Will become ${!issue.obtained ? "Obtained" : "Not Obtained"}",
                                                        ),
                                                        leading: const Icon(
                                                          Icons.bolt_outlined,
                                                        ),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: const Text("Close"),
                                  ),
                                  if (pendingToggles.isNotEmpty)
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.check),
                                      label: const Text("Apply"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () async {
                                        final db = DatabaseHelper();

                                        for (var comic in _needsData) {
                                          comic.issues.removeWhere((issue) {
                                            if (pendingToggles.contains(
                                              issue.id,
                                            )) {
                                              issue.obtained = true;
                                              db.updateIssue(
                                                issue.id!,
                                                issue.toMap(),
                                              ); // Mark obtained in DB
                                              return true; // Remove from current comic.issues list
                                            }
                                            return false;
                                          });
                                        }

                                        setState(() {
                                          pendingToggles.clear();
                                          _updateCheckedCount(); // Ensure counts update
                                        });

                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Issues moved to Obtained",
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                ],
                              ),
                        );
                      },
                      icon: const Icon(Icons.preview),
                      label: const Text("Review"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),

                ElevatedButton.icon(
                  onPressed: () async {
                    final newComic = await showAddFolderDialog(context);
                    if (newComic == null) return;

                    final exists = _needsData.any(
                      (comic) =>
                          comic.title == newComic.title &&
                          comic.era == newComic.era &&
                          comic.yearRange == newComic.yearRange &&
                          comic.comicType == newComic.comicType,
                    );

                    if (exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Folder already exists.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    final db = DatabaseHelper();
                    final newId = await db.insertSeries(newComic.toMap());

                    final fullComic = Comic(
                      id: newId,
                      title: newComic.title,
                      era: newComic.era,
                      yearRange: newComic.yearRange,
                      comicType: newComic.comicType,
                      issues: [],
                    );

                    setState(() {
                      _needsData.add(fullComic);
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Folder"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
                      hintText: 'Search folders...',
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
                        borderSide: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    onChanged:
                        (value) => setState(
                          () => _searchQuery = value.trim().toLowerCase(),
                        ),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ),
            child: Text(
              _filterMode == 'Series View'
                  ? 'Viewing by Series'
                  : 'Viewing by Events',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                child: ListView.builder(
                  itemCount: groupedSections.length,
                  itemBuilder: (context, index) {
                    final section = groupedSections[index];
                    final isExpanded = widget.expandedHeaders.contains(
                      section.displayLabel,
                    );

                    final comic = _needsData.firstWhere(
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
                      needsData: _needsData,
                      expandedHeaders: widget.expandedHeaders,
                      onToggleExpand: () {
                        setState(() {
                          isExpanded
                              ? widget.expandedHeaders.remove(
                                section.displayLabel,
                              )
                              : widget.expandedHeaders.add(
                                section.displayLabel,
                              );
                        });
                      },
                      onLongPressEdit:
                          () => showEditFolderDialog(
                            context: context,
                            comic: comic,
                            onSave: (updatedComic, oldHeader) {
                              setState(() {
                                final index = _needsData.indexWhere(
                                  (c) => c.title == oldHeader,
                                );
                                if (index != -1) {
                                  _needsData[index] = updatedComic;
                                  if (widget.expandedHeaders.remove(
                                    oldHeader,
                                  )) {
                                    widget.expandedHeaders.add(
                                      updatedComic.title,
                                    );
                                  }
                                }
                              });
                            },
                            onDelete: (headerToDelete) {
                              setState(() {
                                _needsData.removeWhere(
                                  (c) => c.title == headerToDelete,
                                );
                                widget.expandedHeaders.remove(headerToDelete);
                              });
                            },
                          ),
                      onAddIssue:
                          () => showAdvancedMultiAddDialog(
                            context: context,
                            header: section.displayLabel, // ✅ Fix here
                            comicId: comic.id!,
                            comicList: _needsData,
                            onIssuesAdded: () => setState(() {}),
                          ),

                      child: Column(
                        children:
                            section.issues.map((issueData) {
                              final comic = _needsData.firstWhere(
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
                                markPendingToggle: (id) {
                                  setState(() {
                                    if (pendingToggles.contains(id)) {
                                      pendingToggles.remove(id);
                                    } else {
                                      pendingToggles.add(id);
                                    }
                                  });
                                },
                                isPending: pendingToggles.contains(
                                  issueData.issue.id,
                                ),
                                currentObtained: issueData.issue.obtained,
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
