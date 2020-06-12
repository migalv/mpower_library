import 'package:rxdart/rxdart.dart';

class LoadCategoryBloc {
  final category;
  final String localeLangCode;

  // Streams
  ValueObservable<List> get filteredProducts =>
      _filteredProductsController.stream;
  ValueObservable<bool> get isSearching => _isSearchingController.stream;

  // Controllers
  final _filteredProductsController = BehaviorSubject<List>();
  final _isSearchingController = BehaviorSubject<bool>();

  bool _isDisposed;

  LoadCategoryBloc({this.category, this.localeLangCode}) {
    _isDisposed = false;
    if (!_isDisposed) _filteredProductsController.add(category.products);
  }

  void search(String searchTerm) {
    List filteredProds = category.products
        .where((prod) => prod.name[localeLangCode ?? 'en']
            .toLowerCase()
            .contains(searchTerm.toLowerCase()))
        .toList();
    _filteredProductsController.add(filteredProds);
  }

  void startSearch(bool start) {
    if (!_isDisposed) _isSearchingController.add(start);

    if (!start) _filteredProductsController.add(category.products);
  }

  void dispose() {
    _isDisposed = true;
    _filteredProductsController.close();
    _isSearchingController.close();
  }
}
