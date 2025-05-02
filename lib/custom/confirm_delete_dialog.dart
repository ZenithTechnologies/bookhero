import 'package:flutter/material.dart';

Future<void> _confirmDelete(
  BuildContext context,
  String name,
  VoidCallback onConfirm,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete "$name"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
  );

  if (confirmed == true) {
    onConfirm();
  }
}
