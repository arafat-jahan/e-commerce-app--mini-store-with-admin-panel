import 'package:flutter/foundation.dart';

import '../../data/product_repository.dart';
import '../../domain/entities/product.dart';

class ProductsProvider extends ChangeNotifier {
  ProductsProvider({ProductRepository? repo})
      : _repo = repo ?? ProductRepository() {
    _load();
  }

  final ProductRepository _repo;

  List<Product> _products = [];
  List<Product> get products => List.unmodifiable(_products);

  String _search = '';
  String _category = 'All';

  String get search => _search;
  String get category => _category;

  List<Product> get filtered {
    return _products.where((p) {
      if (!p.isActive) return false;
      final matchesSearch =
          _search.isEmpty || p.name.toLowerCase().contains(_search.toLowerCase());
      final matchesCategory =
          _category == 'All' || p.category == _category;
      return matchesSearch && matchesCategory;
    }).toList(growable: false);
  }

  Future<void> _load() async {
    _products = await _repo.fetchOnce();
    notifyListeners();
    _repo.watchProducts().listen((list) {
      _products = list;
      notifyListeners();
    });
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setCategory(String value) {
    _category = value;
    notifyListeners();
  }
}

