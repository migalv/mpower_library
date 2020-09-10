import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/models/question_model.dart';
import 'package:meta/meta.dart';

class DynamicForm {
  final String id;
  final List<Question> questions;
  final String title;
  final String greetingTitle;
  final String greetingSubtitle;
  final List<String> emailList;

  DynamicForm(
    this.id,
    this.questions, {
    this.title,
    this.greetingTitle,
    this.greetingSubtitle,
    this.emailList,
  }) {
    this.questions.sort((q1, q2) => q1.index.compareTo(q2.index));
  }

  DynamicForm.fromJson(
      {@required this.id, @required Map<String, dynamic> json, this.questions})
      : title = json["title"],
        emailList = json["email_list"] != null && json["email_list"].isNotEmpty
            ? List<String>.from(json["email_list"])
            : null,
        greetingTitle = json["greeting_title"],
        greetingSubtitle = json["greeting_subtitle"];

  @override
  String toString() {
    return "$id";
  }
}
