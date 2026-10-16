import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/calendar_info_model.dart';
import '../../data/models/event_model.dart';
import '../../data/models/map_info_model.dart';
import '../../data/models/notice_model.dart';
import 'app_providers.dart';

/// Providers académicos

// Avisos
final noticesStreamProvider = StreamProvider.autoDispose<List<NoticeModel>>((ref) {
  return ref.watch(getNoticesUseCaseProvider).call();
});

/// Aviso por id
final noticeByIdProvider = FutureProvider.autoDispose.family<NoticeModel, String>((ref, id) {
  return ref.watch(academicRepositoryProvider).getNoticeById(id);
});

// Eventos
final eventsStreamProvider = StreamProvider.autoDispose<List<EventModel>>((ref) {
  return ref.watch(getEventsUseCaseProvider).call();
});

/// Evento por id
final eventByIdProvider = FutureProvider.autoDispose.family<EventModel, String>((ref, id) {
  return ref.watch(academicRepositoryProvider).getEventById(id);
});

// Mapa
final mapInfoStreamProvider = StreamProvider.autoDispose<MapInfoModel>((ref) {
  return ref.watch(academicRepositoryProvider).watchMapInfo();
});

// Calendario
final calendarInfoStreamProvider = StreamProvider.autoDispose<CalendarInfoModel>((ref) {
  return ref.watch(academicRepositoryProvider).watchCalendarInfo();
});

// Guardados del usuario actual (ids de eventos)
final savedEventIdsProvider = StreamProvider.autoDispose<Set<String>>((ref) {
  final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
  if (uid == null) return Stream.value(<String>{});
  return ref.watch(academicRepositoryProvider).watchSavedEventIds(uid);
});
