import 'package:bookhero/model/comic_model.dart';
import 'package:bookhero/config/comic_data.dart'; // where mockComics is defined

class ComicCollectionController {
  List<Comic> needsList =
      mockComics.where((comic) {
        return comic.issues.any((issue) => !issue.obtained);
      }).toList();

  List<Comic> obtainedList =
      mockComics.where((comic) {
        return comic.issues.any((issue) => issue.obtained);
      }).toList();

  final Set<String> needsHeaders = {};
  final Set<String> obtainedHeaders = {};

  void toggleObtained(String header, int index) {
    final comic = mockComics.firstWhere((comic) => comic.toString() == header);
    final issue = comic.issues[index];
    issue.obtained = !issue.obtained;
  }

  void syncObtained() {
    // Replace with actual sync logic
    print("Syncing obtained issues to cloud...");
  }
}
