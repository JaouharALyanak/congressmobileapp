import 'dart:async';
import 'package:flutter/material.dart';
import '../models/abstract_model.dart';
import '../services/abstract_service.dart';
import '../services/storage_service.dart';

class AbstractProvider extends ChangeNotifier {
  final AbstractService _service = AbstractService();

  List<AbstractModel> _fullList = [];
  List<AbstractModel> _filtered = [];

  int _currentPage = 1;
  bool _hasNext = true;

  String _searchQuery = "";
  Timer? _debounce;

  bool isLoading = false;
  bool isFetchingMore = false;
  String? errorMessage;

  List<AbstractModel> get abstracts => _filtered;
  bool get hasNext => _hasNext && _searchQuery.isEmpty;

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filtered = List.from(_fullList);
    } else {
      final q = _searchQuery.toLowerCase();
      _filtered = _fullList.where((a) =>
        a.firstName.toLowerCase().contains(q) ||
        a.lastName.toLowerCase().contains(q) ||
        (a.title?.toLowerCase().contains(q) ?? false) ||
        a.specialityList.any((s) => s.toLowerCase().contains(q)) ||
        a.cityName.toLowerCase().contains(q) ||
        a.countryName.toLowerCase().contains(q)
      ).toList();
    }
  }

  void setSearchQuery(String query) {
    final trimmed = query.trim();
    if (_searchQuery == trimmed) return;
    _searchQuery = trimmed;
    _debounce?.cancel();
    if (_fullList.isNotEmpty) {
      _debounce = Timer(const Duration(milliseconds: 400), () {
        _applyFilter();
        notifyListeners();
      });
    } else {
      _debounce = Timer(const Duration(milliseconds: 400), loadInitial);
    }
  }

  Future<void> loadInitial() async {
    _currentPage = 1;
    _hasNext = true;
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final result = await _service.fetchAbstracts(_currentPage, '');
      _fullList = result['abstracts'];
      _hasNext = result['hasNext'];

      await StorageService.cacheAbstracts(
        _fullList.map((a) => a.toJson()).toList(),
      );

      _applyFilter();
    } catch (e) {
      final cached = await StorageService.getCachedAbstracts();
      if (cached != null) {
        _fullList = cached.map((e) => AbstractModel.fromJson(e)).toList();
        _hasNext = false;
        _applyFilter();
      } else {
        errorMessage = "Impossible de charger les abstracts";
      }
      debugPrint("❌ loadInitial abstracts: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (isFetchingMore || isLoading || !_hasNext || _searchQuery.isNotEmpty) return;
    isFetchingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final result = await _service.fetchAbstracts(_currentPage, '');
      _fullList.addAll(result['abstracts']);
      _hasNext = result['hasNext'];

      await StorageService.cacheAbstracts(
        _fullList.map((a) => a.toJson()).toList(),
      );

      _applyFilter();
    } catch (e) {
      _currentPage--;
      debugPrint("❌ loadMore abstracts: $e");
    } finally {
      isFetchingMore = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
