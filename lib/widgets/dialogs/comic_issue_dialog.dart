import 'package:bookhero/config/eras_data.dart';
import 'package:bookhero/config/events_data.dart';
import 'package:bookhero/model/comic_model.dart';
import 'package:flutter/material.dart';

Future<void> showAdvancedMultiAddDialog({
  required BuildContext context,
  required int comicId,
  required String header,
  required List<Comic> comicList,
  required VoidCallback onIssuesAdded,
}) async {
  final List<String> issueNumbers = List.generate(
    100,
    (i) => (i + 1).toString(),
  );
  final List<String> eventTags = knownEvents;
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

  await showDialog(
    context: context,
    builder:
        (context) => StatefulBuilder(
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
                                      issueNumbers
                                          .map(
                                            (num) => DropdownMenuItem(
                                              value: num,
                                              child: Text(num),
                                            ),
                                          )
                                          .toList(),
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
                                onPressed:
                                    () => setDialogState(
                                      () => issues.removeAt(index),
                                    ),
                              ),
                            ],
                          ),
                          DropdownButtonFormField<String>(
                            value: issueData['event'],
                            decoration: const InputDecoration(
                              labelText: 'Event Tag',
                            ),
                            items:
                                eventTags
                                    .map(
                                      (tag) => DropdownMenuItem(
                                        value: tag,
                                        child: Text(tag),
                                      ),
                                    )
                                    .toList(),
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
                      icon: const Icon(Icons.add),
                      label: const Text("Add Another Issue"),
                      onPressed: () {
                        setDialogState(() {
                          issues.add({
                            'issue': null,
                            'event': null,
                            'tags': <String>{},
                          });
                        });
                      },
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
                    final matchedComic = comicList.firstWhere(
                      (c) => c.id == comicId,
                    );

                    for (var item in issues) {
                      if (item['issue'] != null) {
                        final eventTag = item['event'] as String?;
                        final tagList = (item['tags'] as Set<String>).toList();

                        final newIssue = Issue(
                          id: null,
                          seriesId: matchedComic.id!,
                          issueNumber: int.parse(item['issue']),
                          obtained: false,
                          eventId:
                              eventTag != null
                                  ? knownEvents.indexOf(eventTag) + 1
                                  : null,
                          tags: [if (eventTag != null) eventTag, ...tagList],
                          coverType:
                              tagList.contains('Foil Cover')
                                  ? 'Foil Cover'
                                  : null,
                          variant:
                              tagList.contains('Variant Cover')
                                  ? 'Variant Cover'
                                  : null,
                          specialEdition:
                              tagList.contains('Annual') ? 'Annual' : null,
                        );

                        matchedComic.issues.add(newIssue);
                      }
                    }

                    onIssuesAdded();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add All'),
                ),
              ],
            );
          },
        ),
  );
}

Future<void> showEditIssueDialog({
  required BuildContext context,
  required Issue issue,
  required VoidCallback onSave,
}) async {
  final List<String> chips = [
    'Annual',
    'Foil Cover',
    'Variant Cover',
    'Reprint',
    'One-Shot',
  ];
  final TextEditingController issueNumberController = TextEditingController(
    text: issue.issueNumber.toString(),
  );
  String? selectedEvent =
      issue.tags.where((tag) => knownEvents.contains(tag)).isNotEmpty
          ? issue.tags.firstWhere((tag) => knownEvents.contains(tag))
          : null;

  Set<String> selectedTags = {...issue.tags};

  await showDialog(
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Issue'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: issueNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Issue Number',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedEvent,
                      decoration: const InputDecoration(labelText: 'Event Tag'),
                      items:
                          knownEvents
                              .map(
                                (tag) => DropdownMenuItem(
                                  value: tag,
                                  child: Text(tag),
                                ),
                              )
                              .toList(),
                      onChanged: (val) => setState(() => selectedEvent = val),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children:
                          chips.map((chip) {
                            final isSelected = selectedTags.contains(chip);
                            return FilterChip(
                              label: Text(chip),
                              selected: isSelected,
                              onSelected: (value) {
                                setState(() {
                                  value
                                      ? selectedTags.add(chip)
                                      : selectedTags.remove(chip);
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
                    final updatedNumber = int.tryParse(
                      issueNumberController.text,
                    );
                    if (updatedNumber != null) {
                      issue.issueNumber = updatedNumber;
                      issue.eventId =
                          selectedEvent != null
                              ? knownEvents.indexOf(selectedEvent!) + 1
                              : null;
                      issue.tags = [
                        if (selectedEvent != null) selectedEvent!,
                        ...selectedTags,
                      ];
                      issue.coverType =
                          selectedTags.contains('Foil Cover')
                              ? 'Foil Cover'
                              : null;
                      issue.variant =
                          selectedTags.contains('Variant Cover')
                              ? 'Variant Cover'
                              : null;
                      issue.specialEdition =
                          selectedTags.contains('Annual') ? 'Annual' : null;

                      onSave();
                      Navigator.of(context).pop();
                    }
                  },

                  child: const Text('Save'),
                ),
              ],
            );
          },
        ),
  );
}

Future<void> showConfirmDeleteIssueDialog({
  required BuildContext context,
  required int issueNumber,
  required VoidCallback onConfirm,
  required VoidCallback onUndo,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Delete Issue'),
          content: Text(
            'Are you sure you want to delete Issue #$issueNumber? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
  );

  if (confirmed == true) {
    onConfirm();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Issue #$issueNumber deleted'),
        action: SnackBarAction(label: 'Undo', onPressed: onUndo),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
