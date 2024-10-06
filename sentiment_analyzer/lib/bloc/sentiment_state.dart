part of 'sentiment_bloc.dart';

@immutable
sealed class SentimentState {}

final class SentimentInitial extends SentimentState {}

class LoadingState extends SentimentState {}

class LoadedState extends SentimentState {
  final String text;

  LoadedState({required this.text});
}
