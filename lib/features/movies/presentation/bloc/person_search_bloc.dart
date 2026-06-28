import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/search_person.dart';
import 'person_search_event.dart';
import 'person_search_state.dart';

class PersonSearchBloc extends Bloc<PersonSearchEvent, PersonSearchState> {
  final SearchPerson searchPerson;

  PersonSearchBloc({
    required this.searchPerson,
  }) : super(PersonSearchInitial()) {
    on<SearchPersonEvent>(_onSearchPerson);
    on<ClearPersonSearchEvent>(_onClearPersonSearch);
  }

  Future<void> _onSearchPerson(
    SearchPersonEvent event,
    Emitter<PersonSearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(PersonSearchInitial());
      return;
    }

    emit(PersonSearchLoading());
    final result = await searchPerson(event.query, page: event.page);
    result.fold(
      (failure) => emit(PersonSearchError(failure.message)),
      (persons) => emit(PersonSearchLoaded(persons)),
    );
  }

  Future<void> _onClearPersonSearch(
    ClearPersonSearchEvent event,
    Emitter<PersonSearchState> emit,
  ) async {
    emit(PersonSearchInitial());
  }
}

