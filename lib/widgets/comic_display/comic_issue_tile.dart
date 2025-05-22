// lib/widgets/comic_display/comic_issue_tile.dart

import 'package:bookhero/model/comic_model.dart';
import 'package:flutter/material.dart';
import 'package:bookhero/config/events_data.dart';

class ComicIssueTile extends StatelessWidget {
  final String header;
  final Issue issue;
  final int index;
  final void Function(String, int) onTap;
  final String? overrideSeries;

  const ComicIssueTile({
    super.key,
    required this.header,
    required this.issue,
    required this.index,
    required this.onTap,
    this.overrideSeries,
  });

  @override
  Widget build(BuildContext context) {
    final titleText =
        overrideSeries != null
            ? '$overrideSeries — Issue #${issue.issueNumber}'
            : 'Issue #${issue.issueNumber}';

    final Widget subtitle =
        overrideSeries != null
            ? _buildEventModeSubtitle(context, overrideSeries!)
            : _buildIssueSubtext(issue.tags) ?? const SizedBox.shrink();

    return ListTile(
      leading: const Icon(Icons.book_rounded),
      title: Text(titleText),
      subtitle: subtitle,
      trailing: Icon(
        issue.obtained ? Icons.check_circle : Icons.radio_button_unchecked,
        color: issue.obtained ? Colors.green : null,
      ),
      onTap: () => onTap(header, index),
    );
  }

  Widget _buildEventModeSubtitle(BuildContext context, String seriesTitle) {
    // Only showing the series title (you can adjust this as needed)
    return Text(seriesTitle);
  }

  Widget? _buildIssueSubtext(List<String> tags) {
    if (tags.isEmpty) return null;

    String? event;
    final types = <String>[];

    for (var tag in tags) {
      if (knownEvents.contains(tag)) {
        event ??= tag;
      } else {
        types.add(tag);
      }
    }

    final parts = <String>[];
    if (event != null) parts.add("[$event]");
    if (types.isNotEmpty) parts.add("Type: ${types.join(', ')}");

    return Text(parts.join("  "));
  }
}
