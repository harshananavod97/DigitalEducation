import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/exam/examRepository.dart';
import 'package:flutterquiz/features/exam/models/exam.dart';

abstract class ExamsState {}

class ExamsInitial extends ExamsState {}

class ExamsFetchInProgress extends ExamsState {}

class ExamsFetchSuccess extends ExamsState {
  ExamsFetchSuccess(this.exams);

  final List<Exam> exams;
}

class ExamsFetchFailure extends ExamsState {
  ExamsFetchFailure(this.errorMessage);

  final String errorMessage;
}

class ExamsCubit extends Cubit<ExamsState> {
  ExamsCubit(this._examRepository) : super(ExamsInitial());
  final ExamRepository _examRepository;

  Future<void> getExams({required String languageId}) async {
    emit(ExamsFetchInProgress());
    try {
      //today's all exam but unattempted
      //(status: 1-Not in Exam, 2-In exam, 3-Completed)
      final exams = (await _examRepository.getExams(languageId: languageId))
          .where((e) => e.examStatus == '1')
          .toList();

      emit(ExamsFetchSuccess(exams));
    } catch (e) {
      emit(ExamsFetchFailure(e.toString()));
    }
  }
}
