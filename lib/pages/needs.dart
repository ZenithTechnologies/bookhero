import 'package:flutter/material.dart';

class NeedsPage extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> needsData;
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

  final List<String> folderTypes = ['Singles', 'Mini-Series', 'Trade'];
  String selectedType = 'Singles'; // default
  Map<String, bool> longPressedHeaders = {};

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _updateCheckedCount();
  }

  void _updateCheckedCount() {
    int count = 0;
    widget.needsData.forEach((_, issues) {
      for (var issue in issues) {
        if (issue['obtained'] == true) count++;
      }
    });
    setState(() {
      checkedCount = count;
    });
  }

  String _capitalizeEachWord(String input) {
    return input
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                  : '',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusScope.of(context).unfocus();
        }
      },
      behavior: HitTestBehavior.opaque, // Ensures taps outside are detected
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Current New Issues Found:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          "$checkedCount",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(width: 2, color: Colors.white),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Add a new folder here: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            _showAddFolderDialog();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.green,
                            ),
                            height: 25,
                            width: 25,
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search folders...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: ListView(
              children:
                  widget.needsData.entries
                      .where(
                        (entry) =>
                            _searchQuery.isEmpty ||
                            entry.key.toLowerCase().contains(_searchQuery),
                      )
                      .map((entry) {
                        final header = entry.key;
                        final issues = entry.value;
                        final isExpanded = widget.expandedHeaders.contains(
                          header,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTapDown: (_) {
                                setState(() {
                                  longPressedHeaders[header] = true;
                                });
                              },
                              onTapUp: (_) {
                                setState(() {
                                  longPressedHeaders[header] = false;
                                });
                              },
                              onTapCancel: () {
                                setState(() {
                                  longPressedHeaders[header] = false;
                                });
                              },
                              onTap: () {
                                setState(() {
                                  isExpanded
                                      ? widget.expandedHeaders.remove(header)
                                      : widget.expandedHeaders.add(header);
                                });
                              },
                              onLongPress: () {
                                _showEditFolderDialog(header);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.only(bottom: 1),
                                color:
                                    longPressedHeaders[header] == true
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.1)
                                        // darker grey
                                        : Theme.of(context).colorScheme.surface,
                                // light grey
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  dense: true, // makes it tighter vertically
                                  visualDensity: const VisualDensity(
                                    vertical: -2,
                                  ),
                                  title: _buildStyledHeader(header),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // IconButton(
                                      //   icon: const Icon(Icons.info_outline),
                                      //   tooltip: 'Edit Folder Info',
                                      //   onPressed: () {
                                      //     _showEditFolderDialog(header);
                                      //   },
                                      // ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        tooltip: 'Add Issue',
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(12),
                                                  ),
                                            ),
                                            builder: (context) {
                                              return Padding(
                                                padding: const EdgeInsets.all(
                                                  20.0,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Add to Folder",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    ListTile(
                                                      leading: const Icon(
                                                        Icons.add,
                                                      ),
                                                      title: const Text(
                                                        "Add Single Issue",
                                                      ),
                                                      onTap: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                        _showAddIssueDialog(
                                                          header,
                                                        );
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(
                                                        Icons.playlist_add,
                                                      ),
                                                      title: const Text(
                                                        "Add Multiple Issues",
                                                      ),
                                                      onTap: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                        _showAdvancedMultiAddDialog(
                                                          header,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      Icon(
                                        isExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      isExpanded
                                          ? widget.expandedHeaders.remove(
                                            header,
                                          )
                                          : widget.expandedHeaders.add(header);
                                    });
                                  },
                                ),
                              ),
                            ),
                            if (isExpanded)
                              ...issues.asMap().entries.map(
                                (e) => _buildIssueRow(header, e.value, e.key),
                              ),
                            const Divider(
                              height: 0,
                              thickness: 0,
                            ), // eliminates visible space
                          ],
                        );
                      })
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFolderDialog() {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _yearController = TextEditingController();
    final List<String> dcEras = [
      'Golden',
      'Silver',
      'Modern',
      'New 52',
      'Rebirth',
      'Infinite Frontier',
      'Dawn of DC',
    ];
    String selectedEra = dcEras[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Wrap(
                children: [
                  const Text(
                    'Add New Folder',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Comic Name',
                      hintText: 'e.g., Superman',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedEra,
                    items:
                        dcEras.map((era) {
                          return DropdownMenuItem(value: era, child: Text(era));
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedEra = value);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'DC Era'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Year or Range',
                      hintText: 'e.g., 2015 or 2019–2022',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 10,
                      children:
                          folderTypes.map((type) {
                            final isSelected = selectedType == type;
                            return ChoiceChip(
                              label: Text(type),
                              selected: isSelected,
                              onSelected: (_) {
                                setDialogState(() => selectedType = type);
                              },
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final name = _nameController.text.trim();
                          final year = _yearController.text.trim();
                          if (name.isNotEmpty && year.isNotEmpty) {
                            final formattedName =
                                '${_capitalizeEachWord(name)} ($year) : $selectedEra - $selectedType';

                            if (!widget.needsData.containsKey(formattedName)) {
                              setState(() {
                                widget.needsData[formattedName] = [];
                              });
                            }
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Add Folder'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditFolderDialog(String oldHeader) {
    final List<String> dcEras = [
      'Golden',
      'Silver',
      'Modern',
      'New 52',
      'Rebirth',
      'Infinite Frontier',
      'Dawn of DC',
    ];
    final List<String> folderTypes = ['Singles', 'Mini-Series', 'Trade'];

    final RegExp pattern = RegExp(r'^(.*?) \((.*?)\) : (.*?) - (.*?)$');
    final match = pattern.firstMatch(oldHeader);

    String initialName = match?.group(1) ?? '';
    String initialYear = match?.group(2) ?? '';
    String initialEra = match?.group(3) ?? dcEras[0];
    String initialType = match?.group(4) ?? folderTypes[0];

    final TextEditingController _nameController = TextEditingController(
      text: initialName,
    );
    final TextEditingController _yearController = TextEditingController(
      text: initialYear,
    );
    String selectedEra = initialEra;
    String selectedType = initialType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Wrap(
                children: [
                  const Text(
                    'Edit Folder Info',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Comic Name'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedEra,
                    items:
                        dcEras.map((era) {
                          return DropdownMenuItem(value: era, child: Text(era));
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedEra = value);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'DC Era'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Year or Range',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 10,
                      children:
                          folderTypes.map((type) {
                            final isSelected = selectedType == type;
                            return ChoiceChip(
                              label: Text(type),
                              selected: isSelected,
                              onSelected: (_) {
                                setDialogState(() => selectedType = type);
                              },
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final name = _capitalizeEachWord(
                            _nameController.text.trim(),
                          );
                          final year = _yearController.text.trim();
                          if (name.isEmpty || year.isEmpty) return;

                          final newHeader =
                              '$name ($year) : $selectedEra - $selectedType';

                          if (newHeader != oldHeader &&
                              !widget.needsData.containsKey(newHeader)) {
                            setState(() {
                              widget.needsData[newHeader] =
                                  widget.needsData.remove(oldHeader) ?? [];
                              if (widget.expandedHeaders.remove(oldHeader)) {
                                widget.expandedHeaders.add(newHeader);
                              }
                            });
                          }

                          Navigator.of(context).pop();
                        },
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIssueRow(String header, Map<String, dynamic> issue, int index) {
    return ListTile(
      title: Text('Issue #${issue['issue']}'),
      subtitle: _buildIssueSubtext(issue['tags']),
      trailing: Icon(
        issue['obtained'] ? Icons.check_circle : Icons.radio_button_unchecked,
        color: issue['obtained'] ? Colors.green : null,
      ),
      onTap: () {
        widget.toggleObtained(header, index);
        _updateCheckedCount(); // Recalculate after toggle
      },
    );
  }

  Widget _buildStyledHeader(String header) {
    final RegExp pattern = RegExp(r'^(.*?) \((.*?)\) : (.*?) - (.*?)$');
    final match = pattern.firstMatch(header);

    if (match != null) {
      final name = match.group(1) ?? '';
      final year = match.group(2) ?? '';
      final era = match.group(3) ?? '';
      final type = match.group(4) ?? '';

      return RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 18, color: Colors.black),
          children: [
            TextSpan(
              text: '$name ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '($year) : ',
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
            TextSpan(
              text: era,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            TextSpan(
              text: ' - $type',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    // fallback
    return Text(header, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  void _showAddIssueDialog(String header) {
    final List<String> availableIssues = List.generate(
      100,
      (index) => '${index + 1}',
    );
    final List<String> eventTags = ['Trinity War', 'Forever Evil', 'Doomed'];
    final List<String> chips = [
      'Annual',
      'Variant Cover',
      'Foil Cover',
      'Mini-Series',
      'One-Shot',
      'TPB',
      'Graphic Novel',
      'Reprint',
    ];

    final List<String> folderTypes = ['Singles', 'Mini-Series', 'TPB'];
    String selectedType = 'Singles'; // default

    String? selectedIssue;
    String? selectedTag;
    final Set<String> selectedChips = {};

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('Add New Issue'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Issue Number',
                      ),
                      value: selectedIssue,
                      items:
                          availableIssues.map((issue) {
                            return DropdownMenuItem(
                              value: issue,
                              child: Text(issue),
                            );
                          }).toList(),
                      onChanged:
                          (value) =>
                              setDialogState(() => selectedIssue = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Event Tag'),
                      value: selectedTag,
                      items:
                          eventTags.map((tag) {
                            return DropdownMenuItem(
                              value: tag,
                              child: Text(tag),
                            );
                          }).toList(),
                      onChanged:
                          (value) => setDialogState(() => selectedTag = value),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children:
                          chips.map((chip) {
                            final isSelected = selectedChips.contains(chip);
                            return FilterChip(
                              label: Text(chip),

                              selected: isSelected,
                              onSelected: (bool value) {
                                setDialogState(() {
                                  value
                                      ? selectedChips.add(chip)
                                      : selectedChips.remove(chip);
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedIssue != null) {
                      setState(() {
                        widget.needsData[header]?.add({
                          'issue': selectedIssue,
                          'tags': [
                            if (selectedTag != null) selectedTag,
                            ...selectedChips,
                          ],
                          'obtained': false,
                        });
                      });
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMultiAddDialog(String header) {
    final List<String> issueNumbers = List.generate(
      100,
      (i) => (i + 1).toString(),
    );
    final List<String> eventTags = ['Darkseid War', 'Doomed', 'Forever Evil'];
    final List<String> chips = [
      'Annual',
      'Foil Cover',
      'Variant Cover',
      'Reprint',
      'One-Shot',
    ];

    final Set<String> selectedIssues = {};
    final Set<String> selectedChips = {};
    String? selectedEvent;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Multiple Issues'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Issue Numbers:"),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          issueNumbers.map((issue) {
                            final selected = selectedIssues.contains(issue);
                            return ChoiceChip(
                              label: Text(issue),

                              selected: selected,
                              onSelected: (_) {
                                setDialogState(() {
                                  selected
                                      ? selectedIssues.remove(issue)
                                      : selectedIssues.add(issue);
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedEvent,
                      decoration: const InputDecoration(
                        labelText: 'Event Tag (optional)',
                      ),
                      items:
                          eventTags.map((tag) {
                            return DropdownMenuItem(
                              value: tag,
                              child: Text(tag),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedEvent = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Apply Tags (optional):"),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          chips.map((chip) {
                            final isSelected = selectedChips.contains(chip);
                            return FilterChip(
                              label: Text(chip),

                              selected: isSelected,
                              onSelected: (bool value) {
                                setDialogState(() {
                                  value
                                      ? selectedChips.add(chip)
                                      : selectedChips.remove(chip);
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedIssues.isNotEmpty) {
                      setState(() {
                        for (final issue in selectedIssues) {
                          widget.needsData[header]?.add({
                            'issue': issue,
                            'tags': [
                              if (selectedEvent != null) selectedEvent!,
                              ...selectedChips,
                            ],
                            'obtained': false,
                          });
                        }
                        widget.expandedHeaders.add(header); // auto-expand
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add All'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Add this method to your NeedsPage state class
  void _showAdvancedMultiAddDialog(String header) {
    final List<String> issueNumbers = List.generate(
      100,
      (i) => (i + 1).toString(),
    );
    final List<String> eventTags = ['Darkseid War', 'Doomed', 'Forever Evil'];
    final List<String> chips = [
      'Annual',
      'Foil Cover',
      'Variant Cover',
      'Reprint',
      'One-Shot',
    ];

    List<Map<String, dynamic>> issues = [
      {'issue': null, 'event': null, 'tags': <String>{}},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Multiple Issues (Advanced)'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...issues.asMap().entries.map((entry) {
                      final index = entry.key;
                      final issueData = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: issueData['issue'],
                                  decoration: const InputDecoration(
                                    labelText: 'Issue #',
                                  ),
                                  items:
                                      issueNumbers.map((number) {
                                        return DropdownMenuItem(
                                          value: number,
                                          child: Text(number),
                                        );
                                      }).toList(),
                                  onChanged:
                                      (val) => setDialogState(
                                        () => issueData['issue'] = val,
                                      ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setDialogState(() => issues.removeAt(index));
                                },
                              ),
                            ],
                          ),
                          DropdownButtonFormField<String>(
                            value: issueData['event'],
                            decoration: const InputDecoration(
                              labelText: 'Event Tag',
                            ),
                            items:
                                eventTags.map((tag) {
                                  return DropdownMenuItem(
                                    value: tag,
                                    child: Text(tag),
                                  );
                                }).toList(),
                            onChanged:
                                (val) => setDialogState(
                                  () => issueData['event'] = val,
                                ),
                          ),
                          Wrap(
                            spacing: 6,
                            children:
                                chips.map((chip) {
                                  final isSelected = issueData['tags'].contains(
                                    chip,
                                  );
                                  return FilterChip(
                                    label: Text(chip),

                                    selected: isSelected,
                                    onSelected: (value) {
                                      setDialogState(() {
                                        value
                                            ? issueData['tags'].add(chip)
                                            : issueData['tags'].remove(chip);
                                      });
                                    },
                                  );
                                }).toList(),
                          ),
                          const Divider(),
                        ],
                      );
                    }),
                    TextButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          issues.add({
                            'issue': null,
                            'event': null,
                            'tags': <String>{},
                          });
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Another Issue"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      for (var item in issues) {
                        if (item['issue'] != null) {
                          widget.needsData[header]?.add({
                            'issue': item['issue'],
                            'tags': [
                              if (item['event'] != null) item['event'],
                              ...item['tags'],
                            ],
                            'obtained': false,
                          });
                        }
                      }
                      widget.expandedHeaders.add(header);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add All'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget? _buildIssueSubtext(List<dynamic> tags) {
    if (tags.isEmpty) return null;

    String? event;
    final knownEvents = {
      "Trinity War",
      "Forever Evil",
      "Darkseid War",
      "Doomed",
    };
    final types = <String>[];

    for (var tag in tags) {
      if (knownEvents.contains(tag)) {
        event ??= tag; // Use the first recognized event
      } else {
        types.add(tag);
      }
    }

    final parts = <String>[];
    if (event != null) parts.add("[$event]");
    if (types.isNotEmpty) parts.add("Type: ${types.join(', ')}");

    return Text(parts.join("  "));
  }
}
