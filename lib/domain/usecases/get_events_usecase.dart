import '../../data/models/event_model.dart';
import '../repositories/academic_repository.dart';

/// Caso de uso: eventos
class GetEventsUseCase {
  final AcademicRepository _repository;
  GetEventsUseCase(this._repository);

  Stream<List<EventModel>> call() => _repository.watchEvents();
}
