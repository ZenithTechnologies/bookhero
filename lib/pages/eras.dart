import 'package:flutter/material.dart';

class ErasPage extends StatefulWidget {
  const ErasPage({super.key});

  @override
  State<ErasPage> createState() => _ErasPageState();
}

class _ErasPageState extends State<ErasPage> {
  final List<String> _eras = [
    'Golden',
    'Silver',
    'Modern',
    'New 52',
    'Rebirth',
    'Infinite Frontier',
    'Dawn of DC',
  ];

  void _showAddEraSheet() {
    final TextEditingController _controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                'Add New Era',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Era Name',
                  hintText: 'e.g., Dark Crisis',
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
                      final newEra = _controller.text.trim();
                      if (newEra.isNotEmpty && !_eras.contains(newEra)) {
                        setState(() {
                          _eras.add(newEra);
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Add Era'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeEra(int index) {
    setState(() {
      _eras.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DC Eras'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showAddEraSheet),
        ],
      ),
      body: ListView.separated(
        itemCount: _eras.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final era = _eras[index];
          return Dismissible(
            key: Key(era),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Confirm Deletion'),
                      content: Text('Are you sure you want to delete "$era"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
              );
            },
            onDismissed: (_) => _removeEra(index),
            child: ListTile(title: Text(era)),
          );
        },
      ),
    );
  }
}
