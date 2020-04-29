import 'package:cached_network_image/cached_network_image.dart';
import 'package:cons_calc_lib/src/circular_reveal_route.dart';
import 'package:cons_calc_lib/src/load_category_bloc.dart';
import 'package:cons_calc_lib/src/load_category_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cons_calc_lib/cons_calc_lib.dart';

class LoadListPage extends StatefulWidget {
  final Stream _isSearching, _products, _genericCategories;
  final Function _search, _toggleSearch;
  final _cacheManager;

  LoadListPage({
    @required Stream isSearching,
    @required Stream products,
    @required Stream genericCategories,
    @required Function search,
    @required Function toggleSearch,
    @required cacheManager,
  })  : _isSearching = isSearching,
        _toggleSearch = toggleSearch,
        _products = products,
        _genericCategories = genericCategories,
        _cacheManager = cacheManager,
        _search = search;

  @override
  _LoadListPageState createState() => _LoadListPageState();
}

class _LoadListPageState extends State<LoadListPage> {
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _numberFormat = NumberFormat("#.#");
  double _mpowerCardWidth, _mpowerCardHeight, _screenWidth;
  Offset _tapOffset;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _mpowerCardHeight = MediaQuery.of(context).size.height <= 432.0
        ? MediaQuery.of(context).size.height - 160
        : MediaQuery.of(context).size.height / 2.5;
    _mpowerCardWidth = MediaQuery.of(context).size.width / 2;

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (_, value) => [
              _buildAppBar(),
              _buildTabs(),
            ],
            body: _buildLists(),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() => SliverAppBar(
        title: StreamBuilder<bool>(
          initialData: false,
          stream: widget._isSearching,
          builder: (_, snapshot) => snapshot.data
              ? Theme(
                  data: Theme.of(context).copyWith(primaryColor: secondaryMain),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (searchTerm) => widget._search(searchTerm),
                  ),
                )
              : Text('select a product'),
        ),
        centerTitle: true,
        floating: true,
        actions: <Widget>[
          StreamBuilder<bool>(
            initialData: false,
            stream: widget._isSearching,
            builder: (_, snapshot) => IconButton(
              icon: Icon(snapshot.data ? Icons.close : Icons.search),
              onPressed: () {
                _searchController.clear();
                widget._toggleSearch(snapshot.data);
              },
            ),
          ),
        ],
      );

  Widget _buildTabs() => SliverList(
        delegate: SliverChildListDelegate(
          [
            Container(
              height: 64.0,
              color: Colors.white,
              child: TabBar(
                indicatorColor: secondaryMain,
                tabs: <Widget>[
                  Tab(
                    child: Text(
                      'MPower',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Other',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildLists() => TabBarView(
        children: <Widget>[
          _buildMPowerProductList(),
          _buildGenericProductList(),
        ],
      );

  Widget _buildMPowerProductList() => StreamBuilder(
      stream: widget._products,
      builder: (context, snapshot) {
        return snapshot.data != null
            ? snapshot.data.isNotEmpty
                ? GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: (_mpowerCardWidth / _mpowerCardHeight),
                    crossAxisSpacing: _screenWidth <= 320.0 ? 8.0 : 16.0,
                    mainAxisSpacing: _screenWidth <= 320.0 ? 8.0 : 16.0,
                    padding: EdgeInsets.symmetric(
                        horizontal: _screenWidth <= 320.0 ? 8.0 : 16.0,
                        vertical: _screenWidth <= 320.0 ? 8.0 : 16.0),
                    children: snapshot.data
                        .map((prod) => _buildMPowerProductCard(prod))
                        .toList()
                        .cast<Widget>(),
                  )
                : _buildPlaceHolder()
            : Center(child: CircularProgressIndicator());
      });

  Widget _buildMPowerProductCard(product) => Card(
        // margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: InkWell(
          onTap: () => _selectProduct(product: product),
          customBorder:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Column(
            children: <Widget>[
              _buildProductImage(url: product.imageURL),
              Divider(
                height: 1.0,
                color: Colors.black38,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    _screenWidth <= 320.0 ? 8.0 : 16.0,
                    _screenWidth <= 320.0 ? 8.0 : 12.0,
                    _screenWidth <= 320.0 ? 8.0 : 16.0,
                    4.0),
                child: Text(
                  product.name,
                  style: Theme.of(context).textTheme.headline6,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildConsumptionSubtitle(product?.powerConsumption),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      );

  Widget _buildProductImage({@required String url}) => Expanded(
        child: Container(
          width: _mpowerCardWidth,
          child: _isValidURL(url)
              ? CachedNetworkImage(
                  useOldImageOnUrlChange: true,
                  imageUrl: url,
                  cacheManager: widget._cacheManager,
                  placeholder: (_, __) => Icon(
                    MdiIcons.tag,
                    color: Colors.black26,
                    size: 32.0,
                  ),
                )
              : Icon(
                  MdiIcons.tag,
                  color: Colors.black26,
                  size: 32.0,
                ),
        ),
      );

  Widget _buildConsumptionSubtitle(double consumption) => Container(
        width: _mpowerCardWidth - 32.0,
        padding: EdgeInsets.symmetric(
            horizontal: _screenWidth <= 320.0 ? 0.0 : 16.0, vertical: 2.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: <Widget>[
            Text(
              'Consumption',
              style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.center,
            ),
            Text(
              (consumption != null ? _numberFormat.format(consumption) : "?") +
                  "Wh",
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );

  Widget _buildGenericProductList() => StreamBuilder(
      stream: widget._genericCategories,
      builder: (context, snapshot) {
        return snapshot.data != null
            ? snapshot.data.isNotEmpty
                ? GridView.count(
                    crossAxisCount: _screenWidth <= 320.0 ? 2 : 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    children: snapshot.data
                        .map((cat) => _buildCategoryCard(cat))
                        .toList()
                        .cast<Widget>(),
                  )
                : _buildPlaceHolder()
            : Center(child: CircularProgressIndicator());
      });

  Widget _buildCategoryCard(category) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: InkWell(
          onTap: () => _selectGenericProduct(category),
          onTapDown: (details) =>
              setState(() => _tapOffset = details.globalPosition),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Hero(
                    tag: category.id + "icon",
                    child: Icon(
                      category.icon,
                      size: 40.0,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: category.id + "name",
                      child: Text(
                        category.name,
                        style: Theme.of(context).textTheme.headline6,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildPlaceHolder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildFileNotFoundIcon(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Could not find any products. Try something else',
              style: TextStyle(fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );

  Widget _buildFileNotFoundIcon() => Container(
        width: 64.0,
        height: 64.0,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              MdiIcons.file,
              size: 64.0,
              color: black60,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 32.0,
                width: 32.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: background,
                ),
                child: Icon(
                  MdiIcons.help,
                  size: 24.0,
                  color: black60,
                ),
              ),
            ),
          ],
        ),
      );

  void _selectProduct({product}) {
    Map<String, dynamic> productInfo = {};

    if (product != null) {
      productInfo = {
        'id': product.id,
        'name': product.name,
        'imageUrl': product.imageURL,
        'consumption': product?.powerConsumption,
      };
    }

    Navigator.of(context).pop(productInfo);
  }

  Future<void> _selectGenericProduct(category) async {
    dynamic product = await Navigator.push(
      context,
      CircularRevealRoute(
        page: BlocProvider<LoadCategoryBloc>(
          initBloc: (_, bloc) =>
              bloc ??
              LoadCategoryBloc(
                category: category,
                localeLangCode: 'en',
              ),
          onDispose: (_, bloc) => bloc.dispose(),
          child: LoadCategoryPage(),
        ),
        maxRadius: MediaQuery.of(context).size.height,
        centerOffset: _tapOffset,
      ),
    );

    if (product != null) {
      Map<String, dynamic> selectedProduct = {
        'id': product.id,
        'name': product.name['en'],
        'icon': product.category.icon,
        'consumption': product.consumption,
      };
      Navigator.of(context).pop(selectedProduct);
    }
  }
}

bool _isValidURL(String url) {
  bool valid = false;
  var urlPattern =
      r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
  if (url != null) {
    var match = new RegExp(urlPattern, caseSensitive: false).firstMatch(url);
    valid = match != null;
  }

  return valid;
}
