import 'package:flutter/material.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final List<String> _events = [
    'Darkseid War',
    'Trinity War',
    'Forever Evil',
    'Crisis on Infinite Earths',
    'Infinite Crisis',
    'Final Crisis',
  ];

  void _showAddEventSheet() {
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
                'Add New Event',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  hintText: 'e.g., Flashpoint',
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
                      final newEvent = _controller.text.trim();
                      if (newEvent.isNotEmpty && !_events.contains(newEvent)) {
                        setState(() {
                          _events.add(newEvent);
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Add Event'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeEvent(int index) {
    setState(() {
      _events.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comic Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddEventSheet,
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: _events.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final event = _events[index];
          return Dismissible(
            key: Key(event),
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
                      content: Text(
                        'Are you sure you want to delete "$event"?',
                      ),
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
            onDismissed: (_) => _removeEvent(index),
            child: ListTile(title: Text(event)),
          );
        },
      ),
    );
  }
}
