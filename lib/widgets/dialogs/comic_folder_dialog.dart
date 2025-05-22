// lib/widgets/dialogs/comic_folder_dialogs.dart

import 'package:bookhero/widgets/dialogs/confirm_delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:bookhero/config/eras_data.dart';
import 'package:bookhero/model/comic_model.dart';

Future<Comic?> showAddFolderDialog(BuildContext context) async {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  String selectedEra = dcEras[0];
  String selectedType = 'Singles';

  return showModalBottomSheet<Comic?>(
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
                  controller: nameController,
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
                  controller: yearController,
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
                        ['Singles', 'Mini-Series', 'Trade'].map((type) {
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
                          nameController.text.trim(),
                        );
                        final year = yearController.text.trim();

                        if (name.isEmpty ||
                            year.isEmpty ||
                            selectedEra.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please fill out all fields before saving.',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final comic = Comic(
                          title: name,
                          era: selectedEra,
                          yearRange: year,
                          comicType: selectedType,
                          issues: [],
                        );
                        Navigator.of(context).pop(comic);
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

Future<void> showEditFolderDialog({
  required BuildContext context,
  required Comic comic,
  required void Function(Comic updatedComic, String oldHeader) onSave,
  required void Function(String headerToDelete) onDelete,
}) async {
  final TextEditingController nameController = TextEditingController(
    text: comic.title,
  );
  final TextEditingController yearController = TextEditingController(
    text: comic.yearRange,
  );
  String selectedEra = comic.era;
  String selectedType = comic.comicType;

  await showModalBottomSheet(
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
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Comic Name'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedEra,
                  items:
                      dcEras
                          .map(
                            (era) =>
                                DropdownMenuItem(value: era, child: Text(era)),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedEra = value);
                    }
                  },
                  decoration: const InputDecoration(labelText: 'DC Era'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Year or Range'),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 10,
                    children:
                        ['Singles', 'Mini-Series', 'Trade']
                            .map(
                              (type) => ChoiceChip(
                                label: Text(type),
                                selected: selectedType == type,
                                onSelected:
                                    (_) => setDialogState(
                                      () => selectedType = type,
                                    ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: Text(
                                  'Are you sure that you want to delete: ${comic.title}',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          onDelete(comic.title);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final name = nameController.text.trim();
                            final year = yearController.text.trim();
                            if (name.isNotEmpty && year.isNotEmpty) {
                              final updatedComic = Comic(
                                title: name,
                                era: selectedEra,
                                yearRange: year,
                                comicType: selectedType,
                                issues: comic.issues,
                              );
                              onSave(updatedComic, comic.title);
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Save Changes'),
                        ),
                      ],
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

Future<void> showConfirmDeleteDialog(
  BuildContext context,
  String folderName,
  VoidCallback onConfirm,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete "$folderName"? This action cannot be undone.',
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
  }
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
