// First, define the helper models at the top or in a separate file
import 'package:bookhero/model/comic_model.dart';

class IssueRowData {
  final String seriesTitle;
  final Issue issue;

  IssueRowData({required this.seriesTitle, required this.issue});
}

class NeedsSection {
  final String header;
  final List<IssueRowData> issues;
  final bool isEventMode;

  NeedsSection({
    required this.header,
    required this.issues,
    this.isEventMode = false,
  });
}
