import 'package:meta/meta.dart';

class FormResults {
  final String id;
  final Map results;
  final bool isCompleted;
  final String codeVersion;
  final int lastUpdatedAt;
  final List<String> notifyEmails;

  FormResults({
    @required this.id,
    @required this.results,
    @required this.isCompleted,
    @required this.codeVersion,
    @required this.lastUpdatedAt,
    @required this.notifyEmails,
  });

  FormResults.fromJson(String id, Map<String, dynamic> json)
      : this.id = id,
        this.results = Map.from(json["results"]),
        this.isCompleted = json.containsKey("completed_forms")
            ? json["completed_forms"] == null
            : false,
        this.codeVersion = json["last_answer_code_version"] ?? 0,
        this.lastUpdatedAt = json["last_updated_at"],
        this.notifyEmails = List<String>.from(json["notify_emails"]) ?? [];
}
