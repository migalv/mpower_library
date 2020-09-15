import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/models/question_model.dart';
import 'package:meta/meta.dart';

class DynamicForm {
  final String id;
  final String title;
  final String greetingTitle;
  final String greetingSubtitle;
  final List<String> emailList;
  List<Question> _questions;
  List<Question> get questions => _questions;

  DynamicForm(
    this.id, {
    this.title,
    this.greetingTitle,
    this.greetingSubtitle,
    this.emailList,
    questions = const [],
  }) {
    _questions = questions;
    if (_questions != null)
      _questions.sort((q1, q2) => q1.index.compareTo(q2.index));
  }

  DynamicForm.fromJson(
      {@required this.id,
      @required Map<String, dynamic> json,
      List<Question> questions})
      : title = json["title"],
        emailList = json["email_list"] != null && json["email_list"].isNotEmpty
            ? List<String>.from(json["email_list"])
            : null,
        greetingTitle = json["greeting_title"],
        greetingSubtitle = json["greeting_subtitle"],
        _questions = questions {
    if (_questions != null)
      _questions.sort((q1, q2) => q1.index.compareTo(q2.index));
  }

  void setQuestions(List<Question> questions) {
    _questions = questions;
    _questions.sort((q1, q2) => q1.index.compareTo(q2.index));
  }

  @override
  String toString() {
    return "$id";
  }
}
