part of 'sentiment_bloc.dart';

@immutable
sealed class SentimentEvent {}

class LoadingEvent extends SentimentEvent {}

class LoadedEvent extends SentimentEvent {
  final String text;
  LoadedEvent({required this.text});
}
