import 'package:cons_calc_lib/src/models/question_model.dart';

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

  @override
  String toString() {
    return "$id";
  }
}
