class Issue {
  int? id;
  int seriesId;
  int issueNumber;
  bool obtained;
  List<String> tags;
  String? event;
  String? coverType;
  String? variant;
  String? specialEdition;

  Issue({
    this.id,
    required this.seriesId,
    required this.issueNumber,
    this.obtained = false,
    this.tags = const [],
    this.event,
    this.coverType,
    this.variant,
    this.specialEdition,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'series_id': seriesId,
      'issue_number': issueNumber,
      'obtained': obtained ? 1 : 0,
      'event': event,
      'cover_type': coverType,
      'variant': variant,
      'special_edition': specialEdition,
      // We don’t store tags directly in DB — reconstruct from event + chip fields
    };
  }

  factory Issue.fromMap(Map<String, dynamic> map) {
    final tags = <String>[
      if (map['event'] != null) map['event'],
      if (map['cover_type'] != null) map['cover_type'],
      if (map['variant'] != null) map['variant'],
      if (map['special_edition'] != null) map['special_edition'],
    ];

    return Issue(
      id: map['id'],
      seriesId: map['series_id'],
      issueNumber: map['issue_number'],
      obtained: map['obtained'] == 1,
      event: map['event'],
      coverType: map['cover_type'],
      variant: map['variant'],
      specialEdition: map['special_edition'],
      tags: tags,
    );
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
      issues: [], // Load separately
    );
  }

  @override
  String toString() {
    return '$title ($yearRange) : $era - $comicType';
  }
}
