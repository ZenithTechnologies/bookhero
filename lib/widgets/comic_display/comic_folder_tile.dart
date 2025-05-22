import 'package:flutter/material.dart';
import 'package:bookhero/model/comic_model.dart';
import 'package:bookhero/model/section_model.dart';

class ComicFolderTile extends StatelessWidget {
  final NeedsSection section;
  final Comic comic;
  final bool isExpanded;
  final List<Comic> needsData;
  final Set<String> expandedHeaders;
  final VoidCallback onToggleExpand;
  final VoidCallback? onLongPressEdit;
  final VoidCallback? onAddIssue;
  final Widget child;

  const ComicFolderTile({
    super.key,
    required this.section,
    required this.comic,
    required this.isExpanded,
    required this.needsData,
    required this.expandedHeaders,
    required this.onToggleExpand,
    this.onLongPressEdit,
    this.onAddIssue,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final header = section.header;
    final isEvent = section.isEventMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color:
                isExpanded
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: GestureDetector(
            onTap: onToggleExpand,
            onLongPress: isEvent ? null : onLongPressEdit,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Icon(isEvent ? Icons.event : Icons.folder),
              title:
                  isEvent
                      ? Text(
                        header,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      )
                      : _buildStyledHeader(comic),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isEvent && onAddIssue != null)
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'Add Issue',
                      onPressed: onAddIssue,
                    ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded)
          Padding(padding: const EdgeInsets.only(left: 16), child: child),
        const Divider(height: 1, thickness: 0.5, color: Colors.grey),
      ],
    );
  }

  Widget _buildStyledHeader(Comic comic) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 18),
        children: [
          TextSpan(
            text: '${comic.title} ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: '(${comic.yearRange}) : ',
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: comic.era,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: ' - ${comic.comicType}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
