// First, define the helper models at the top or in a separate file
import 'package:bookhero/model/comic_model.dart';

// In IssueRowData
class IssueRowData {
  final int seriesId;
  final Issue issue;

  IssueRowData({required this.seriesId, required this.issue});
}

class NeedsSection {
  final int id; // for matching
  final String displayLabel; // for header UI
  final List<IssueRowData> issues;
  final bool isEventMode;

  NeedsSection({
    required this.id,
    required this.displayLabel,
    required this.issues,
    this.isEventMode = false,
  });
}
