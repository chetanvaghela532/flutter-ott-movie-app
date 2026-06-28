import 'package:equatable/equatable.dart';
import '../../domain/entities/person_entity.dart';

abstract class PersonDetailsState extends Equatable {
  const PersonDetailsState();

  @override
  List<Object> get props => [];
}

class PersonDetailsInitial extends PersonDetailsState {}

class PersonDetailsLoading extends PersonDetailsState {}

class PersonDetailsLoaded extends PersonDetailsState {
  final PersonEntity person;
  final Map<String, List<PersonMovieCreditEntity>>? movieCredits;

  const PersonDetailsLoaded({
    required this.person,
    this.movieCredits,
  });

  @override
  List<Object> get props => [person, movieCredits ?? {}];
  
  PersonDetailsLoaded copyWith({
    PersonEntity? person,
    Map<String, List<PersonMovieCreditEntity>>? movieCredits,
  }) {
    return PersonDetailsLoaded(
      person: person ?? this.person,
      movieCredits: movieCredits ?? this.movieCredits,
    );
  }
}

class PersonDetailsError extends PersonDetailsState {
  final String message;

  const PersonDetailsError(this.message);

  @override
  List<Object> get props => [message];
}

