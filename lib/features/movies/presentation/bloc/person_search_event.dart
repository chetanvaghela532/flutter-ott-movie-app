import 'package:equatable/equatable.dart';

abstract class PersonSearchEvent extends Equatable {
  const PersonSearchEvent();

  @override
  List<Object> get props => [];
}

class SearchPersonEvent extends PersonSearchEvent {
  final String query;
  final int page;
  
  const SearchPersonEvent(this.query, {this.page = 1});

  @override
  List<Object> get props => [query, page];
}

class ClearPersonSearchEvent extends PersonSearchEvent {}

