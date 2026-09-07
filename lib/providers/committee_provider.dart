import 'package:flutter/material.dart';
import '../models/committee_member_model.dart';
import '../services/committee_service.dart';
import '../services/storage_service.dart'; // ✅ NEW

class CommitteeProvider extends ChangeNotifier {
  final CommitteeService _service = CommitteeService();

  List<CommitteeCategory> _allCategories = [];
  List<CommitteeCategory> categories = [];
  bool isLoading = false;
  bool _loaded = false;
  String? errorMessage;
  String _searchQuery = '';
  int? _selectedCategoryId;

  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;

  Future<void> load() async {
    if (_loaded || isLoading) return;
    isLoading = true;
    notifyListeners();

    try {
      final results = await _service.fetchCommittee();
      _allCategories = results;
      _applyFilters();
      _loaded = true;

      // ✅ Save to persistent cache
      await StorageService.cacheCommittee(
        _allCategories.map((c) => c.toJson()).toList(),
      );
    } catch (e) {
      // ✅ Fallback to persistent cache
      final cached = await StorageService.getCachedCommittee();
      if (cached != null) {
        _allCategories = cached
            .map((e) => CommitteeCategory.fromJson(e))
            .toList();
        _applyFilters();
        _loaded = true;
      } else {
        errorMessage = e.toString();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
    notifyListeners();
  }

  void setCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _applyFilters();
    notifyListeners();
  }

  bool get hasActiveFilter =>
      _searchQuery.isNotEmpty || _selectedCategoryId != null;

  void _applyFilters() {
    var filtered = _allCategories;

    if (_selectedCategoryId != null) {
      filtered = filtered
          .where((cat) => cat.categoryId == _selectedCategoryId)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .map((cat) {
            final filteredMembers = cat.members.where((m) {
              return m.fullName.toLowerCase().contains(_searchQuery);
            }).toList();
            return CommitteeCategory(
              categoryId: cat.categoryId,
              categoryName: cat.categoryName,
              categorySort: cat.categorySort,
              members: filteredMembers,
            );
          })
          .where((cat) => cat.members.isNotEmpty)
          .toList();
    }

    categories = filtered;
  }

  List<CommitteeCategory> get allCategories => _allCategories;

  /// Tous les membres à plat (filtrés par recherche), dans l'ordre API
  List<CommitteeMember> get flatMembers {
    if (_searchQuery.isEmpty) {
      return _allCategories.expand((c) => c.members).toList();
    }
    return _allCategories
        .expand((c) => c.members)
        .where((m) => m.fullName.toLowerCase().contains(_searchQuery))
        .toList();
  }

  void reset() {
    _loaded = false;
    _allCategories = [];
    categories = [];
    _searchQuery = '';
    _selectedCategoryId = null;
    errorMessage = null;
    notifyListeners();
  }
}
