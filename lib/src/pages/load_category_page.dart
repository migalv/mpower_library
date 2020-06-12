import 'package:auto_size_text/auto_size_text.dart';
import 'package:cons_calc_lib/src/blocs/load_category_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cons_calc_lib/cons_calc_lib.dart';

class LoadCategoryPage extends StatefulWidget {
  LoadCategoryPage({Key key}) : super(key: key);

  @override
  _LoadCategoryPageState createState() => _LoadCategoryPageState();
}

class _LoadCategoryPageState extends State<LoadCategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController;
  bool _isScrolled = false;
  LoadCategoryBloc _loadCategoryBloc;
  NumberFormat numberFormat = NumberFormat("#.#");

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_listenToScrollChange);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _loadCategoryBloc = Provider.of<LoadCategoryBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Material(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              _buildAppBar(),
              _buildList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() => SliverAppBar(
        expandedHeight: 144.0,
        pinned: true,
        actions: <Widget>[
          StreamBuilder<bool>(
            initialData: false,
            stream: _loadCategoryBloc.isSearching,
            builder: (_, snapshot) => IconButton(
              icon: Icon(snapshot.data ? Icons.close : Icons.search),
              onPressed: () {
                _searchController.clear();
                _loadCategoryBloc.startSearch(!snapshot.data);
              },
            ),
          ),
          // AnimatedContainer(
          //   duration: Duration(milliseconds: 300),
          //   curve: Curves.ease,
          //   width: _isScrolled ? 48.0 : 0.0,
          //   height: _isScrolled ? 48.0 : 0.0,
          //   child: IconButton(
          //     icon: Icon(MdiIcons.filter),
          //     onPressed: () => _showFiltersDialog(),
          //   ),
          // ),
        ],
        forceElevated: true,
        centerTitle: true,
        title: StreamBuilder<bool>(
            stream: _loadCategoryBloc.isSearching,
            initialData: false,
            builder: (context, snapshot) {
              return snapshot.data
                  ? Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: secondaryMain),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: (searchTerm) =>
                            _loadCategoryBloc.search(searchTerm),
                      ),
                    )
                  : AnimatedOpacity(
                      duration: Duration(milliseconds: 300),
                      opacity: _isScrolled ? 1.0 : 0.0,
                      curve: Curves.ease,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            _loadCategoryBloc.category.icon,
                            size: 32.0,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            _loadCategoryBloc.category.name,
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(fontSize: 20.0),
                          ),
                        ],
                      ),
                    );
            }),
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(bottom: 8.0),
          centerTitle: true,
          collapseMode: CollapseMode.parallax,
          background: Padding(
            padding: const EdgeInsets.only(top: 48.0, bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Hero(
                    tag: _loadCategoryBloc.category.id + "icon",
                    child: Icon(
                      _loadCategoryBloc.category.icon,
                      size: 88.0,
                      color: black60,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 80.0),
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Hero(
                      tag: _loadCategoryBloc.category.id + "name",
                      child: AutoSizeText(
                        _loadCategoryBloc.category.name,
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(fontSize: 32.0),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        maxFontSize: 32.0,
                      ),
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(right: 16.0),
                //   child: FlatButton.icon(
                //     label: Text(
                //       "Filters",
                //       style: TextStyle(color: black70),
                //     ),
                //     icon: Icon(
                //       MdiIcons.filter,
                //       color: black70,
                //     ),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8.0),
                //     ),
                //     onPressed: () => _showFiltersDialog(),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      );

  Widget _buildList() {
    int count = 0;

    return StreamBuilder<List>(
        stream: _loadCategoryBloc.filteredProducts,
        builder: (context, snapshot) {
          return snapshot.data != null && snapshot.data.isNotEmpty
              ? SliverList(
                  delegate: SliverChildListDelegate(
                    snapshot.data.map((load) {
                      List<Widget> listTile = [_buildListTile(load)];
                      if (count != snapshot.data.length - 1) {
                        listTile.add(Divider(
                          height: 3.0,
                          thickness: 1.0,
                          indent: 64.0,
                        ));
                      }
                      count++;
                      return Column(
                        children: listTile,
                      );
                    }).toList(),
                  ),
                )
              : SliverFillRemaining(
                  child: _buildPlaceHolder(),
                );
        });
  }

  Widget _buildListTile(product) => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        leading: CircleAvatar(
          radius: 24.0,
          backgroundColor: Colors.black45,
          child: Icon(
            _loadCategoryBloc.category.icon,
            size: 24.0,
            color: Colors.white70,
          ),
        ),
        title: Text(
          product.name['en'],
          style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 20.0),
        ),
        subtitle: Row(
          children: <Widget>[
            Text(
              'Estimated consumption: ',
              style: Theme.of(context).textTheme.subtitle2,
            ),
            Text(
              "${numberFormat.format(product.consumption)}Wh",
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        onTap: () => _selectProduct(product),
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
              _loadCategoryBloc.category.icon,
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

  // METHODS
  void _listenToScrollChange() {
    if (_scrollController.offset >= 48.0) {
      setState(() {
        _isScrolled = true;
      });
    } else {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  void _selectProduct(product) => Navigator.of(context).pop(product);
}
