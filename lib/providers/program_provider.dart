import 'package:dio/dio.dart' show Options;
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/program_model.dart';
import '../core/api_client.dart';
import '../config/app_config.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class ProgramProvider extends ChangeNotifier {
  List<ProgramDay> _days = [];
  int _selectedDayIndex = 0;
  String _searchQuery = '';
  bool _isLoading = false;

  final Set<int> _selectedSpeakerIds = {};
  final Set<String> _selectedRooms = {};

  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // item.id → day.date lookup
  final Map<int, String> _itemDateMap = {};
  Map<int, String> get itemDateMap => _itemDateMap;

  // <--- NEW: Agenda related properties and methods
  Set<int> _agendaItemIds = {}; // Store IDs of items in the agenda
  Set<int> get agendaItemIds => _agendaItemIds;

  /// Délai de notification choisi par l'utilisateur pour chaque session (itemId → minutes).
  Map<int, int> _notificationDelays = {};
  int notificationDelayFor(int itemId) => _notificationDelays[itemId] ?? 10;

  ProgramProvider() {
    _loadAgendaFromStorage(); // Load agenda when provider is created
  }

  Future<void> _loadAgendaFromStorage() async {
    final cachedAgenda = await StorageService.getCachedAgenda();
    if (cachedAgenda != null) {
      _agendaItemIds = cachedAgenda.toSet();
    }
    _notificationDelays = await StorageService.getCachedNotificationDelays();
    notifyListeners();
  }

  // Method to toggle an item's agenda status
  /// [delayMinutes] : délai avant la session (10, 15, 30…). Ignoré si l'item
  /// est retiré de l'agenda. Défaut = 10 minutes.
  Future<void> toggleAgendaItem(ProgramItem item, {int delayMinutes = 10}) async {
    if (_agendaItemIds.contains(item.id)) {
      _agendaItemIds.remove(item.id);
      _notificationDelays.remove(item.id);
      await NotificationService.cancelNotification(item.id);
      debugPrint(
        'Removed item ${item.id} from agenda and canceled notification.',
      );
    } else {
      _agendaItemIds.add(item.id);
      _notificationDelays[item.id] = delayMinutes;
      // Schedule notification
      final itemDateString = _itemDateMap[item.id];
      if (itemDateString != null) {
        final startTimeParts = item.startTime.split(':');
        final itemDate = DateTime.parse(itemDateString);
        final scheduledDateTime = DateTime(
          itemDate.year,
          itemDate.month,
          itemDate.day,
          int.parse(startTimeParts[0]),
          int.parse(startTimeParts[1]),
        );

        await NotificationService.scheduleNotification(
          id: item.id,
          title: item.displayTitle,
          body: 'Commence dans $delayMinutes min à ${item.startTime}.',
          scheduledDate: scheduledDateTime,
          beforeEvent: Duration(minutes: delayMinutes),
        );
      }
      debugPrint('Added item ${item.id} to agenda and scheduled notification ($delayMinutes min avant).');
    }
    await StorageService.cacheAgenda(_agendaItemIds.toList());
    await StorageService.cacheNotificationDelays(_notificationDelays);
    notifyListeners();
  }

  bool isItemInAgenda(int itemId) {
    return _agendaItemIds.contains(itemId);
  }

  /// Returns agenda items grouped by day (checks root items and their children)
  List<({ProgramDay day, List<ProgramItem> items})> get agendaByDay {
    final result = <({ProgramDay day, List<ProgramItem> items})>[];
    for (final day in _days) {
      final items = <ProgramItem>[];
      for (final root in day.items) {
        if (_agendaItemIds.contains(root.id)) items.add(root);
        for (final child in root.children) {
          if (_agendaItemIds.contains(child.id)) items.add(child);
        }
      }
      if (items.isNotEmpty) result.add((day: day, items: items));
    }
    return result;
  }

  int get agendaCount => _agendaItemIds.length;
  // NEW: Agenda related properties and methods ^^^

  List<ProgramDay> get days => _days;
  int get selectedDayIndex => _selectedDayIndex;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  Set<int> get selectedSpeakerIds => _selectedSpeakerIds;
  Set<String> get selectedRooms => _selectedRooms;
  DateTime? get rangeStart => _rangeStart;
  DateTime? get rangeEnd => _rangeEnd;

  String dateForItem(int itemId) {
    return _itemDateMap[itemId] ??
        DateTime.now().toIso8601String().substring(0, 10);
  }

  List<DateTime> get eventDates =>
      _days.map((d) => DateTime.parse(d.date)).toList();

  List<ProgramItem> get currentDayItems {
    if (_days.isEmpty || _selectedDayIndex >= _days.length) return [];
    return _days[_selectedDayIndex].items;
  }

  bool _itemMatchesFilters(ProgramItem item) {
    final query = _searchQuery.toLowerCase();

    bool matchesQuery = true;
    if (query.isNotEmpty) {
      final titleMatch = item.displayTitle.toLowerCase().contains(query);
      final speakersMatch = item.isSession
          ? item.session!.allParticipants
                .any((p) => p.fullName.toLowerCase().contains(query))
          : false;
      matchesQuery = titleMatch || speakersMatch;
    }

    bool matchesSpeakers = true;
    if (_selectedSpeakerIds.isNotEmpty) {
      matchesSpeakers =
          item.isSession &&
          item.session!.allParticipants
              .any((p) => _selectedSpeakerIds.contains(p.id));
    }

    bool matchesRooms = true;
    if (_selectedRooms.isNotEmpty) {
      matchesRooms =
          item.isSession &&
          item.session?.room != null &&
          _selectedRooms.contains(item.session!.room);
    }

    return matchesQuery && matchesSpeakers && matchesRooms;
  }

  bool get _hasActiveContentFilters =>
      _searchQuery.isNotEmpty ||
      _selectedSpeakerIds.isNotEmpty ||
      _selectedRooms.isNotEmpty;

  List<ProgramItem> get allFilteredItems {
    List<ProgramItem> sourceItems = [];

    if (_rangeStart != null) {
      final DateTime effectiveEnd = _rangeEnd ?? _rangeStart!;
      for (var day in _days) {
        final dayDate = DateTime.parse(day.date);
        final bool isInRange =
            (dayDate.isAfter(_rangeStart!) ||
                isSameDay(dayDate, _rangeStart!)) &&
            (dayDate.isBefore(effectiveEnd) ||
                isSameDay(dayDate, effectiveEnd));
        if (isInRange) sourceItems.addAll(day.items);
      }
    } else {
      sourceItems = currentDayItems;
    }

    return sourceItems.where((item) {
      if (item.isGroup) {
        // Groups: show always when no content filter active,
        // otherwise show only if at least one child matches
        if (!_hasActiveContentFilters) return true;
        return item.children.any(_itemMatchesFilters);
      }
      return _itemMatchesFilters(item);
    }).toList();
  }

  void setRange(DateTime? start, DateTime? end) {
    _rangeStart = start;
    _rangeEnd = end;
    notifyListeners();
  }

  void toggleSpeaker(int id) {
    _selectedSpeakerIds.contains(id)
        ? _selectedSpeakerIds.remove(id)
        : _selectedSpeakerIds.add(id);
    notifyListeners();
  }

  void toggleRoom(String room) {
    _selectedRooms.contains(room)
        ? _selectedRooms.remove(room)
        : _selectedRooms.add(room);
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectDay(int index) {
    _selectedDayIndex = index;
    _rangeStart = null;
    _rangeEnd = null;
    notifyListeners();
  }

  void clearFilters() {
    _rangeStart = null;
    _rangeEnd = null;
    _selectedSpeakerIds.clear();
    _selectedRooms.clear();
    _searchQuery = '';
    notifyListeners();
  }

  bool get hasActiveFilters =>
      _selectedSpeakerIds.isNotEmpty ||
      _selectedRooms.isNotEmpty ||
      _rangeStart != null ||
      _searchQuery.isNotEmpty;

  List<ProgramPerson> get allAvailableSpeakers {
    final Map<int, ProgramPerson> speakers = {};
    for (var day in _days) {
      for (var item in day.items) {
        if (item.isSession && item.session != null) {
          for (var p in item.session!.allParticipants) {
            speakers[p.id] = p;
          }
        }
        for (var child in item.children) {
          if (child.isSession && child.session != null) {
            for (var p in child.session!.allParticipants) {
              speakers[p.id] = p;
            }
          }
        }
      }
    }
    return speakers.values.toList()
      ..sort((a, b) => a.lastName.compareTo(b.lastName));
  }

  List<String> get allAvailableRooms {
    final Set<String> rooms = {};
    for (var day in _days) {
      for (var item in day.items) {
        if (item.isSession &&
            item.session?.room != null &&
            item.session!.room!.isNotEmpty) {
          rooms.add(item.session!.room!);
        }
        for (var child in item.children) {
          if (child.isSession &&
              child.session?.room != null &&
              child.session!.room!.isNotEmpty) {
            rooms.add(child.session!.room!);
          }
        }
      }
    }
    return rooms.toList()..sort();
  }

  void _buildItemDateMap() {
    _itemDateMap.clear();
    for (final day in _days) {
      for (final item in day.items) {
        _itemDateMap[item.id] = day.date;
        for (final child in item.children) {
          _itemDateMap[child.id] = day.date;
        }
      }
    }
  }

  // ── API ──────────────────────────────────────────────────────────────────

  /// [forceRefresh] — pass true to bypass both client and server-side caches.
  /// Appends a `_t` timestamp to the URL so even CDN/reverse-proxy caches
  /// cannot serve a stale response.
  Future<void> loadProgram({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();

    // Build the path: add _t=timestamp when forceRefresh to bust server cache.
    final basePath = '/${AppConfig.eventSlug}/program';
    final path = forceRefresh
        ? '$basePath?_t=${DateTime.now().millisecondsSinceEpoch}'
        : basePath;

    try {
      final response = await ApiClient.dio.get(
        path,
        options: forceRefresh
            ? Options(
                headers: {
                  'Cache-Control': 'no-cache, no-store, must-revalidate',
                  'Pragma': 'no-cache',
                },
              )
            : null,
      );

      if (response.data['success'] == true) {
        final List data = response.data['data'];
        _days = data.map((d) => ProgramDay.fromJson(d)).toList();
        _buildItemDateMap();

        // Overwrite cache with the freshly fetched data
        await StorageService.cacheProgram(
          _days.map((d) => d.toJson()).toList(),
        );

        // <--- NEW: Sync agenda notifications after loading new program data
        _syncAgendaNotifications();
      }
    } catch (e) {
      // No connection — fall back to last known cache
      final cached = await StorageService.getCachedProgram();
      if (cached != null) {
        _days = cached.map((d) => ProgramDay.fromJson(d)).toList();
        _buildItemDateMap();
        _syncAgendaNotifications();
      }
      debugPrint('Erreur chargement programme : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // <--- NEW: Helper to re-schedule/cancel notifications based on current agenda
  Future<void> _syncAgendaNotifications() async {
    // REMOVED THE STRAY LINE HERE:
    // final int? itemId = int.tryParse(p.payload?.split('_').last ?? '');

    final List<ProgramItem> allProgramItems = _days
        .expand((day) => day.items)
        .expand((item) => [item, ...item.children])
        .toList();
    final Map<int, ProgramItem> allItemsMap = {
      for (var item in allProgramItems) item.id: item,
    };

    // Get a copy of _agendaItemIds to iterate safely while modifying
    final currentAgendaItems = _agendaItemIds.toList();

    // Cancel notifications for items no longer in the program or agenda
    final pending = await NotificationService.getPendingNotifications();
    for (var p in pending) {
      final int? itemId = int.tryParse(p.payload?.split('_').last ?? '');
      if (itemId == null ||
          !_agendaItemIds.contains(itemId) ||
          !allItemsMap.containsKey(itemId)) {
        await NotificationService.cancelNotification(p.id);
        if (_agendaItemIds.remove(itemId)) {
          // Also remove from agenda if notification was for a non-existent item
          debugPrint(
            'Removed item $itemId from agenda as it no longer exists or should not have a notification.',
          );
        }
      }
    }

    // Schedule/reschedule notifications for items currently in agenda
    for (int agendaId in currentAgendaItems) {
      // Iterate over the copy
      final item = allItemsMap[agendaId];
      final itemDateString = _itemDateMap[agendaId];
      if (item != null && itemDateString != null) {
        final startTimeParts = item.startTime.split(':');
        final itemDate = DateTime.parse(itemDateString);
        final scheduledDateTime = DateTime(
          itemDate.year,
          itemDate.month,
          itemDate.day,
          int.parse(startTimeParts[0]),
          int.parse(startTimeParts[1]),
        );
        // Cancel the old notification first (in case the session time was updated
        // on the backend — scheduleNotification silently skips past dates without
        // cancelling the previously-scheduled alarm).
        final delay = _notificationDelays[agendaId] ?? 10;
        await NotificationService.cancelNotification(item.id);
        await NotificationService.scheduleNotification(
          id: item.id,
          title: item.displayTitle,
          body: 'Commence dans $delay min à ${item.startTime}.',
          scheduledDate: scheduledDateTime,
          beforeEvent: Duration(minutes: delay),
        );
      } else {
        // Item in agenda but not found in program data (e.g., deleted from backend)
        _agendaItemIds.remove(agendaId); // Remove from agenda
        await NotificationService.cancelNotification(
          agendaId,
        ); // Cancel any pending notification
        debugPrint(
          'Item $agendaId was in agenda but not found in program data. Removing.',
        );
      }
    }
    // After modifying agendaItemIds, persist the changes
    await StorageService.cacheAgenda(_agendaItemIds.toList());
    notifyListeners(); // Notify listeners after agenda changes from sync
  }

  // NEW: Helper to re-schedule/cancel notifications based on current agenda ^^^
}
