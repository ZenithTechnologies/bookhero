import 'package:bookhero/model/comic_model.dart';
import 'package:flutter/material.dart';
import 'package:bookhero/config/events_data.dart';

class ComicIssueTile extends StatelessWidget {
  final String header;
  final Issue issue;
  final int index;
  final void Function(int) markPendingToggle;
  final String? overrideSeries;
  final bool isPending;
  final bool currentObtained;

  const ComicIssueTile({
    super.key,
    required this.header,
    required this.issue,
    required this.index,
    required this.markPendingToggle,
    this.overrideSeries,
    required this.isPending,
    required this.currentObtained,
  });

  @override
  Widget build(BuildContext context) {
    final titleText =
        overrideSeries != null
            ? '$overrideSeries — Issue #${issue.issueNumber}'
            : 'Issue #${issue.issueNumber}';

    final Widget subtitle =
        overrideSeries != null
            ? Text(overrideSeries!)
            : _buildIssueSubtext(issue.tags) ?? const SizedBox.shrink();

    IconData trailingIcon;
    Color? trailingColor;

    if (isPending) {
      trailingIcon = Icons.pending;
      trailingColor = Colors.orange;
    } else if (currentObtained) {
      trailingIcon = Icons.check_circle;
      trailingColor = Colors.green;
    } else {
      trailingIcon = Icons.radio_button_unchecked;
      trailingColor = null;
    }

    return ListTile(
      leading: const Icon(Icons.book_rounded),
      title: Text(titleText),
      subtitle: subtitle,
      trailing: Icon(
        isPending
            ? Icons.pending
            : currentObtained
            ? Icons.check_circle
            : Icons.radio_button_unchecked,
        color:
            isPending
                ? Colors.orange
                : currentObtained
                ? Colors.green
                : null,
      ),
      onTap: () => markPendingToggle(issue.id!),
    );
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
