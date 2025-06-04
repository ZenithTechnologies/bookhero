import 'package:bookhero/database/database_helper.dart';
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

  void toggleObtainedByIssueId(int issueId) async {
    final db = DatabaseHelper();

    // Fetch the issue from the database
    final issueRows = await db.db.then(
      (db) => db.query('issues', where: 'id = ?', whereArgs: [issueId]),
    );

    if (issueRows.isEmpty) return;

    final issue = Issue.fromMap(issueRows.first);
    issue.obtained = !issue.obtained;

    await db.updateIssue(issueId, issue.toMap());

    // Optionally: refresh needsList and obtainedList here if you're displaying from controller
  }

  void syncObtained() {
    // Replace with actual sync logic
    print("Syncing obtained issues to cloud...");
  }
}
