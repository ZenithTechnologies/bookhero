import 'package:bookhero/pages/eras.dart';
import 'package:bookhero/pages/events.dart';
import 'package:bookhero/pages/needs.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, List<Map<String, dynamic>>> needsData = {
    'Superman New 52 (2012–2015)': [
      {
        'issue': '1',
        'tags': ['Trinity War'],
        'obtained': false,
      },
      {'issue': '4', 'tags': [], 'obtained': false},
      {
        'issue': '7',
        'tags': ['Doomed'],
        'obtained': false,
      },
      {'issue': '8', 'tags': [], 'obtained': false},
      {
        'issue': '9',
        'tags': ['Forever Evil'],
        'obtained': false,
      },
    ],
  };

  final Map<String, List<Map<String, dynamic>>> obtainedData = {};
  final Set<String> expandedHeaders = {};

  void _toggleObtained(String header, int index) {
    setState(() {
      needsData[header]![index]['obtained'] =
          !(needsData[header]![index]['obtained'] as bool);
    });
  }

  void _syncObtained() {
    setState(() {
      needsData.forEach((header, issues) {
        final obtained =
            issues.where((issue) => issue['obtained'] == true).toList();
        needsData[header]!.removeWhere((issue) => issue['obtained'] == true);
        if (obtained.isNotEmpty) {
          obtainedData
              .putIfAbsent(header, () => [])
              .addAll(obtained.map((e) => {...e, 'obtained': true}));
        }
      });
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  Widget _buildObtainedTab() {
    return ListView(
      children:
          obtainedData.entries.map((entry) {
            final header = entry.key;
            final issues = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    header,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...issues.map(
                  (issue) => ListTile(
                    title: Text('Issue #${issue['issue']}'),
                    subtitle:
                        issue['tags'].isNotEmpty
                            ? Text('Tags: ${issue['tags'].join(', ')}')
                            : null,
                    trailing: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                ),
                const Divider(),
              ],
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Text(
                'BookHero Menu',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text('Events'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EventsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.timelapse),
              title: Text('Era'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ErasPage()),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("BookHero"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: "Needs"), Tab(text: "Obtained")],
        ),
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: "Sync obtained",
              onPressed: _syncObtained,
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NeedsPage(
            needsData: needsData,
            expandedHeaders: expandedHeaders,
            toggleObtained: _toggleObtained,
          ),
          _buildObtainedTab(),
        ],
      ),
    );
  }
}
