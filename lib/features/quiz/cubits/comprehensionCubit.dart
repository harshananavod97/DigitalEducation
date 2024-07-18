import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/comprehension.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';

abstract class ComprehensionState {}

class ComprehensionInitial extends ComprehensionState {}

class ComprehensionProgress extends ComprehensionState {}

class ComprehensionSuccess extends ComprehensionState {
  ComprehensionSuccess(this.getComprehension);

  final List<Comprehension> getComprehension;
}

class ComprehensionFailure extends ComprehensionState {
  ComprehensionFailure(this.errorMessage);

  final String errorMessage;
}

class ComprehensionCubit extends Cubit<ComprehensionState> {
  ComprehensionCubit(this._quizRepository) : super(ComprehensionInitial());
  final QuizRepository _quizRepository;

  Future<void> getComprehension({
    required String languageId,
    required String type,
    required String typeId,
  }) async {
    emit(ComprehensionProgress());
    await _quizRepository
        .getComprehension(
          languageId: languageId,
          type: type,
          typeId: typeId,
        )
        .then((val) => emit(ComprehensionSuccess(val)))
        .catchError((Object e) {
      emit(ComprehensionFailure(e.toString()));
    });
  }
}
