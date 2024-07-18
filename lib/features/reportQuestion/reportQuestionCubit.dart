import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/reportQuestion/reportQuestionRepository.dart';

abstract class ReportQuestionState {}

class ReportQuestionInitial extends ReportQuestionState {}

class ReportQuestionInProgress extends ReportQuestionState {}

class ReportQuestionSuccess extends ReportQuestionState {}

class ReportQuestionFailure extends ReportQuestionState {
  ReportQuestionFailure(this.errorMessageCode);

  final String errorMessageCode;
}

class ReportQuestionCubit extends Cubit<ReportQuestionState> {
  ReportQuestionCubit(this.reportQuestionRepository)
      : super(ReportQuestionInitial());
  ReportQuestionRepository reportQuestionRepository;

  void reportQuestion({required String questionId, required String message}) {
    emit(ReportQuestionInProgress());
    reportQuestionRepository
        .reportQuestion(message: message, questionId: questionId)
        .then((value) {
      emit(ReportQuestionSuccess());
    }).catchError((Object e) {
      emit(ReportQuestionFailure(e.toString()));
    });
  }
}
