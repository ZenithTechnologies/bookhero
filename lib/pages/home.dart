import 'package:bookhero/config/comic_data.dart';
import 'package:bookhero/database/sync.dart';
import 'package:bookhero/pages/eras.dart';
import 'package:bookhero/pages/events.dart';
import 'package:bookhero/pages/needs/needs.dart';
import 'package:bookhero/pages/obtained/obtained.dart';
import 'package:bookhero/widgets/sync/sync_popup.dart';
import 'package:flutter/material.dart';
import 'package:bookhero/controllers/comic_collection_controller.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late TabController _tabController;
  late final ComicCollectionController controller;

  final Set<String> expandedHeaders = {};
  final GlobalKey<NeedsPageState> _needsPageKey = GlobalKey<NeedsPageState>();
  bool _needsSync = false;

  @override
  void initState() {
    controller = ComicCollectionController();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    _checkSyncStatus(); // 👈 Add this
  }

  Future<void> _checkSyncStatus() async {
    final needsSync = await SyncStatusService().isSyncRequired();
    if (mounted) {
      setState(() {
        _needsSync = needsSync;
      });
    }
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.cloud_sync),
                tooltip: 'Sync with Server',
                onPressed: () async {
                  final itemsToSync = await getUnsyncedIssues();
                  if (context.mounted) {
                    showSyncDialog(context, itemsToSync, () {
                      _needsPageKey.currentState
                          ?.reloadData(); // ✅ Refresh list
                      setState(() => _needsSync = false); // ✅ Hide red dot
                    });
                  }
                },
              ),
              if (_needsSync)
                const Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(radius: 5, backgroundColor: Colors.red),
                ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NeedsPage(
            key: _needsPageKey,
            expandedHeaders: controller.needsHeaders,
            toggleObtained:
                controller.toggleObtainedByIssueId, // <-- this now matches
            onLocalChange: () => setState(() => _needsSync = true),
          ),

          Obtained(
            // obtainedData: controller.obtainedList,
            // expandedHeaders: controller.obtainedHeaders,
            // syncToCloud: controller.syncObtained,
          ),
        ],
      ),
    );
  }
}
