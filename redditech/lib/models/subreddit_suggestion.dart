class SubredditSuggestion {
  final String name;

  SubredditSuggestion({required this.name});

  static SubredditSuggestion fromJson(Map<String, dynamic> json) =>
      SubredditSuggestion(
        name: json["name"],
      );
}
