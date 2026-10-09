import '../../data/models/notice_model.dart';
import '../repositories/academic_repository.dart';

/// Caso de uso: avisos
class GetNoticesUseCase {
  final AcademicRepository _repository;
  GetNoticesUseCase(this._repository);

  Stream<List<NoticeModel>> call() => _repository.watchNotices();
}
