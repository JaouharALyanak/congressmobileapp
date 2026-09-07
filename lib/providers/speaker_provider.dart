import 'dart:async';
import 'package:flutter/material.dart';
import '../models/speaker_model.dart';
import '../services/speaker_service.dart';
import '../services/storage_service.dart'; // ✅ NEW

class SpeakerProvider extends ChangeNotifier {
  final SpeakerService _service = SpeakerService();

  // --- DATA ---
  List<Speaker> _allSpeakers = [];
  List<Speaker> _randomSpeakers = [];

  // --- CACHE PAR RECHERCHE (in-memory) ---
  final Map<String, List<Speaker>> _cache = {};

  // --- PAGINATION ---
  int _currentPage = 1;
  bool _hasNext = true;

  // --- SEARCH ---
  String _searchQuery = "";
  Timer? _debounce;

  // --- STATES ---
  bool isLoading = false;
  bool isFetchingMore = false;
  String? errorMessage;

  // --- GETTERS ---
  List<Speaker> get speakers => _allSpeakers;
  List<Speaker> get randomSpeakers => _randomSpeakers;
  bool get hasNext => _hasNext;

  // ==============================
  // 🎲 RANDOM SPEAKERS
  // ==============================
  Future<void> loadRandomSpeakers() async {
    if (isLoading && _randomSpeakers.isEmpty) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _randomSpeakers = await _service.fetchRandomSpeakers();
    } catch (e) {
      // ✅ Fallback: load from persistent cache
      final cached = await StorageService.getCachedSpeakers();
      if (cached != null && cached.isNotEmpty) {
        _randomSpeakers = cached
            .map((e) => Speaker.fromJson(e))
            .take(5) // same random-ish subset
            .toList();
      } else {
        errorMessage = "Impossible de charger les speakers aléatoires";
      }
      debugPrint("❌ Erreur loadRandomSpeakers : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==============================
  // 🔍 SEARCH (DEBOUNCE)
  // ==============================
  void setSearchQuery(String query) {
    final trimmed = query.trim();
    if (_searchQuery == trimmed) return;
    _searchQuery = trimmed;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), loadInitial);
  }

  void clearSearch() {
    _searchQuery = "";
    _allSpeakers = [];
    _currentPage = 1;
    _hasNext = true;
    loadInitial();
  }

  // ==============================
  // 🚀 LOAD INITIAL
  // ==============================
  Future<void> loadInitial() async {
    _currentPage = 1;
    _hasNext = true;
    errorMessage = null;

    // ✅ In-memory cache check (same session)
    if (_cache.containsKey(_searchQuery)) {
      _allSpeakers = _cache[_searchQuery]!;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final result = await _service.fetchSpeakers(_currentPage, _searchQuery);
      _allSpeakers = result['speakers'];
      _hasNext = result['hasNext'];

      // ✅ Save in-memory cache
      _cache[_searchQuery] = List.from(_allSpeakers);

      // ✅ Save persistent cache (only for empty search = full list)
      if (_searchQuery.isEmpty) {
        await StorageService.cacheSpeakers(
          _allSpeakers.map((s) => s.toJson()).toList(),
        );
      }
    } catch (e) {
      // ✅ Fallback: load from persistent cache (only for empty search)
      if (_searchQuery.isEmpty) {
        final cached = await StorageService.getCachedSpeakers();
        if (cached != null) {
          _allSpeakers = cached.map((e) => Speaker.fromJson(e)).toList();
          _hasNext = false; // no pagination on cache
        } else {
          errorMessage = "Impossible de charger les données";
        }
      } else {
        final cached = await StorageService.getCachedSpeakers();
        if (cached != null) {
          final query = _searchQuery.toLowerCase();
          _allSpeakers = cached
              .map((e) => Speaker.fromJson(e))
              .where((s) =>
                  s.firstName.toLowerCase().contains(query) ||
                  s.lastName.toLowerCase().contains(query) ||
                  s.title.toLowerCase().contains(query))
              .toList();
          _hasNext = false;
        } else {
          errorMessage = "Impossible de charger les données";
        }
      }
      debugPrint("❌ Erreur loadInitial : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==============================
  // 🔄 LOAD MORE (INFINITE SCROLL)
  // ==============================
  Future<void> loadMore() async {
    if (isFetchingMore || isLoading || !_hasNext) return;
    isFetchingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final result = await _service.fetchSpeakers(_currentPage, _searchQuery);
      _allSpeakers.addAll(result['speakers']);
      _hasNext = result['hasNext'];

      // 🔁 Update both caches
      _cache[_searchQuery] = List.from(_allSpeakers);
      if (_searchQuery.isEmpty) {
        await StorageService.cacheSpeakers(
          _allSpeakers.map((s) => s.toJson()).toList(),
        );
      }
    } catch (e) {
      _currentPage--; // rollback
      debugPrint("❌ Erreur loadMore : $e");
    } finally {
      isFetchingMore = false;
      notifyListeners();
    }
  }

  // ==============================
  // 🧹 DISPOSE
  // ==============================
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
