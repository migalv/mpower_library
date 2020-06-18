import 'package:cons_calc_lib/src/models/question_model.dart';

class DynamicForm {
  final String id;
  final List<Question> questions;
  final String title;
  final List<String> emailList;

  DynamicForm(this.id, this.questions, {this.title, this.emailList}) {
    this.questions.sort((q1, q2) => q1.index.compareTo(q2.index));
  }
}
