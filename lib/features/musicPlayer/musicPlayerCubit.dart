import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

abstract class MusicPlayerState {}

class MusicPlayerInitial extends MusicPlayerState {}

class MusicPlayerLoaded extends MusicPlayerState {
  MusicPlayerLoaded({
    required this.audioDuration,
  });

  final Duration audioDuration;
}

class MusicPlayerFailure extends MusicPlayerState {
  MusicPlayerFailure(this.errorMessage);

  final String errorMessage;
}

class MusicPlayerLoading extends MusicPlayerState {}

class MusicPlayerCubit extends Cubit<MusicPlayerState> {
  MusicPlayerCubit() : super(MusicPlayerInitial());
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get audioPlayer => _audioPlayer;

  Future<void> initPlayer(String url) async {
    try {
      emit(MusicPlayerLoading());

      final result = await _audioPlayer.setUrl(url);

      emit(
        MusicPlayerLoaded(
          audioDuration: result!,
        ),
      );
    } catch (e) {
      emit(MusicPlayerFailure('Error while playing music'));
    }
  }

  void playAudio() {}

  @override
  Future<void> close() async {
    await _audioPlayer.dispose();
    await super.close();
  }
}
