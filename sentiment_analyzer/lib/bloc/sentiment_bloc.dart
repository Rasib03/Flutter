import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'sentiment_event.dart';
part 'sentiment_state.dart';

class SentimentBloc extends Bloc<SentimentEvent, SentimentState> {
  SentimentBloc() : super(SentimentInitial()) {
    on<LoadingEvent>((event, emit) {
      print("loading event triggered");
      emit(LoadingState());
    });
    on<LoadedEvent>((event, emit) {
      emit(LoadedState(text: event.text));
    });
  }
}
