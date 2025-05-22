import 'package:bookhero/config/eras_data.dart';
import 'package:bookhero/config/events_data.dart';
import 'package:bookhero/model/comic_model.dart';
import 'package:bookhero/model/section_model.dart';
import 'package:bookhero/widgets/dialogs/comic_folder_dialog.dart';
import 'package:bookhero/widgets/dialogs/comic_issue_dialog.dart';
import 'package:flutter/material.dart';
import 'package:bookhero/widgets/comic_display/comic_issue_tile.dart';
import 'package:bookhero/widgets/comic_display/comic_folder_tile.dart';

class NeedsPage extends StatefulWidget {
  final List<Comic> needsData;
  final Set<String> expandedHeaders;
  final Function(String, int) toggleObtained;

  const NeedsPage({
    super.key,
    required this.needsData,
    required this.expandedHeaders,
    required this.toggleObtained,
  });

  @override
  State<NeedsPage> createState() => _NeedsPageState();
}

class _NeedsPageState extends State<NeedsPage> {
  int checkedCount = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterMode = 'Series View';
  final List<String> _filterOptions = ['Series View', 'Event View'];

  @override
  void initState() {
    super.initState();
    _updateCheckedCount();
  }

  void _updateCheckedCount() {
    int count = 0;
    for (var comic in widget.needsData) {
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
      return widget.needsData
          .where((comic) => comic.title.toLowerCase().contains(_searchQuery))
          .map(
            (comic) => NeedsSection(
              header: comic.toString(),
              issues:
                  comic.issues
                      .map(
                        (i) => IssueRowData(
                          seriesTitle: comic.toString(),
                          issue: i,
                        ),
                      )
                      .toList(),
              isEventMode: false,
            ),
          )
          .toList();
    } else {
      final grouped = <String, List<IssueRowData>>{};
      for (var comic in widget.needsData) {
        for (var issue in comic.issues) {
          final events = issue.tags.where((tag) => knownEvents.contains(tag));
          for (var event in events) {
            if (event.toLowerCase().contains(_searchQuery)) {
              grouped.putIfAbsent(event, () => []);
              grouped[event]!.add(
                IssueRowData(seriesTitle: comic.toString(), issue: issue),
              );
            }
          }
        }
      }
      return grouped.entries
          .map(
            (e) =>
                NeedsSection(header: e.key, issues: e.value, isEventMode: true),
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
                      "New Issues Found:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$checkedCount",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final newComic = await showAddFolderDialog(context);
                    if (newComic == null) return;

                    final exists = widget.needsData.any(
                      (comic) => comic.toString() == newComic.toString(),
                    );

                    if (!exists) {
                      setState(() {
                        widget.needsData.add(newComic);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Folder already exists.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
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
          Expanded(
            child: ListView.builder(
              itemCount: groupedSections.length,
              itemBuilder: (context, index) {
                final section = groupedSections[index];
                final header = section.header;
                final isExpanded = widget.expandedHeaders.contains(header);
                final comic = widget.needsData.firstWhere(
                  (c) => c.toString() == header,
                  orElse:
                      () => Comic(
                        title: header,
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
                  needsData: widget.needsData, // ✅ <-- Add this line
                  expandedHeaders: widget.expandedHeaders,
                  onToggleExpand: () {
                    setState(() {
                      isExpanded
                          ? widget.expandedHeaders.remove(header)
                          : widget.expandedHeaders.add(header);
                    });
                  },
                  onLongPressEdit:
                      () => showEditFolderDialog(
                        context: context,
                        comic: comic,
                        onSave: (updatedComic, oldHeader) {
                          setState(() {
                            final index = widget.needsData.indexWhere(
                              (c) => c.title == oldHeader,
                            );
                            if (index != -1) {
                              widget.needsData[index] = updatedComic;
                              if (widget.expandedHeaders.remove(oldHeader)) {
                                widget.expandedHeaders.add(updatedComic.title);
                              }
                            }
                          });
                        },
                        onDelete: (headerToDelete) {
                          setState(() {
                            widget.needsData.removeWhere(
                              (c) => c.title == headerToDelete,
                            );
                            widget.expandedHeaders.remove(headerToDelete);
                          });
                        },
                      ),
                  onAddIssue:
                      () => showAdvancedMultiAddDialog(
                        context: context,
                        header: header,
                        comicList: widget.needsData,
                        onIssuesAdded: () => setState(() {}),
                      ),
                  child: Column(
                    children:
                        section.issues.map((issueData) {
                          final comic = widget.needsData.firstWhere(
                            (c) => c.toString() == issueData.seriesTitle,
                          );
                          final comicIndex = comic.issues.indexOf(
                            issueData.issue,
                          );

                          return ComicIssueTile(
                            header: issueData.seriesTitle,
                            issue: issueData.issue,
                            index: comicIndex,
                            overrideSeries:
                                section.isEventMode
                                    ? issueData.seriesTitle
                                    : null,
                            onTap: (h, i) {
                              widget.toggleObtained(h, i);
                              _updateCheckedCount();
                            },
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
