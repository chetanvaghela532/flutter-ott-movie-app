import 'package:equatable/equatable.dart';

abstract class PersonDetailsEvent extends Equatable {
  const PersonDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadPersonDetails extends PersonDetailsEvent {
  final int personId;
  const LoadPersonDetails(this.personId);

  @override
  List<Object> get props => [personId];
}

class LoadAllPersonDetails extends PersonDetailsEvent {
  final int personId;
  const LoadAllPersonDetails(this.personId);

  @override
  List<Object> get props => [personId];
}

