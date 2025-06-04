class Issue {
  int? id;
  int seriesId;
  int issueNumber;
  bool obtained;
  List<String> tags; // derived from below fields
  int? eventId;
  String? coverType;
  String? variant;
  String? specialEdition;
  String? description;

  Issue({
    this.id,
    required this.seriesId,
    required this.issueNumber,
    this.obtained = false,
    this.tags = const [],
    this.eventId,
    this.coverType,
    this.variant,
    this.specialEdition,
    this.description,
  });

  factory Issue.fromMap(Map<String, dynamic> map) {
    final rawTags =
        map['tags']
            ?.toString()
            .split(',')
            .where((t) => t.isNotEmpty)
            .toList() ??
        [];

    return Issue(
      id: map['id'],
      seriesId: map['series_id'],
      issueNumber: map['issue_number'],
      obtained: map['obtained'] == 1,
      eventId: map['event_id'],
      coverType: map['cover_type'],
      variant: map['variant'],
      specialEdition: map['special_edition'],
      description: map['description'],
      tags: rawTags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'series_id': seriesId,
      'issue_number': issueNumber,
      'obtained': obtained ? 1 : 0,
      'tags': tags.join(','),
      'event_id': eventId,
      'cover_type': coverType,
      'variant': variant,
      'special_edition': specialEdition,
      'description': description,
    };
  }
}

class Comic {
  int? id;
  String title;
  String era;
  String yearRange;
  String comicType;
  List<Issue> issues;

  Comic({
    this.id,
    required this.title,
    required this.era,
    required this.yearRange,
    required this.comicType,
    this.issues = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'era': era,
      'year_range': yearRange,
      'comic_type': comicType,
    };
  }

  factory Comic.fromMap(Map<String, dynamic> map) {
    return Comic(
      id: map['id'],
      title: map['title'],
      era: map['era'],
      yearRange: map['year_range'],
      comicType: map['comic_type'],
      issues: [], // Loaded separately
    );
  }

  @override
  String toString() {
    return '$title ($yearRange): $era - $comicType';
  }
}
