import 'package:flutter/material.dart';

Future<List<T>> showMultiDeleteDialog<T>({
  required BuildContext context,
  required List<T> items,
  required String Function(T) getLabel,
  required String title,
}) async {
  final Set<T> selected = {};

  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children:
                      items.map((item) {
                        final isSelected = selected.contains(item);
                        return CheckboxListTile(
                          value: isSelected,
                          title: Text(getLabel(item)),
                          onChanged: (_) {
                            setState(() {
                              isSelected
                                  ? selected.remove(item)
                                  : selected.add(item);
                            });
                          },
                        );
                      }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete Selected'),
                ),
              ],
            );
          },
        ),
  );

  return confirmed == true ? selected.toList() : [];
}
