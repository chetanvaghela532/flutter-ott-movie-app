import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_person_details.dart';
import '../../domain/usecases/get_person_movie_credits.dart';
import '../../domain/entities/person_entity.dart';
import 'person_details_event.dart';
import 'person_details_state.dart';

class PersonDetailsBloc extends Bloc<PersonDetailsEvent, PersonDetailsState> {
  final GetPersonDetails getPersonDetails;
  final GetPersonMovieCredits getPersonMovieCredits;

  PersonDetailsBloc({
    required this.getPersonDetails,
    required this.getPersonMovieCredits,
  }) : super(PersonDetailsInitial()) {
    on<LoadPersonDetails>(_onLoadPersonDetails);
    on<LoadAllPersonDetails>(_onLoadAllPersonDetails);
  }

  Future<void> _onLoadPersonDetails(
    LoadPersonDetails event,
    Emitter<PersonDetailsState> emit,
  ) async {
    emit(PersonDetailsLoading());
    final result = await getPersonDetails(event.personId);
    result.fold(
      (failure) => emit(PersonDetailsError(failure.message)),
      (person) => emit(PersonDetailsLoaded(person: person)),
    );
  }

  Future<void> _onLoadAllPersonDetails(
    LoadAllPersonDetails event,
    Emitter<PersonDetailsState> emit,
  ) async {
    emit(PersonDetailsLoading());
    
    final personResult = await getPersonDetails(event.personId);
    
    PersonEntity? person;
    personResult.fold(
      (failure) {
        emit(PersonDetailsError(failure.message));
      },
      (p) {
        person = p;
      },
    );
    
    if (person == null) return;
    
    final creditsResult = await getPersonMovieCredits(event.personId);
    creditsResult.fold(
      (failure) {
        emit(PersonDetailsLoaded(person: person!));
      },
      (credits) {
        emit(PersonDetailsLoaded(person: person!, movieCredits: credits));
      },
    );
  }
}

