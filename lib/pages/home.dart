import 'package:bookhero/config/comic_data.dart';
import 'package:bookhero/pages/eras.dart';
import 'package:bookhero/pages/events.dart';
import 'package:bookhero/pages/needs/needs.dart';
import 'package:bookhero/pages/obtained/obtained.dart';
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

  @override
  void initState() {
    controller = ComicCollectionController();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
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
              onPressed: () {},
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NeedsPage(
            needsData: controller.needsList,
            expandedHeaders: controller.needsHeaders,
            toggleObtained: controller.toggleObtained,
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
