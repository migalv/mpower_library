import 'package:auto_size_text/auto_size_text.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cons_calc_lib/src/instructions_card.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PanelBatteryCard extends StatelessWidget {
  final List allPanels, allBatteries, products;
  final Map panels, batteries;
  final Color color;
  final Function addProduct,
      isSelected,
      addPanel,
      addBattery,
      removePanel,
      removeBattery;

  PanelBatteryCard({
    @required this.panels,
    @required this.batteries,
    @required this.products,
    @required this.allPanels,
    @required this.allBatteries,
    @required this.color,
    @required this.addProduct,
    @required this.isSelected,
    @required this.addPanel,
    @required this.addBattery,
    @required this.removePanel,
    @required this.removeBattery,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _firstSection(context),
            Divider(height: 1),
            Container(height: 24),
            _secondSection(context),
          ],
        ),
      );

  Widget _firstSection(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 6,
                  child: _bundleProduct(
                    'PANEL${panels.length > 1 ? 'S' : ''}',
                    panels.values.map((unit) => unit.panel).toList(),
                    context,
                    isPanel: true,
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Icon(
                      Icons.add,
                      color: Colors.black38,
                    ),
                  ),
                ),
                Flexible(
                  flex: 6,
                  child: _bundleProduct(
                    'BATTER${batteries.length > 1 ? 'IES' : 'Y'}',
                    batteries.values.map((unit) => unit.battery).toList(),
                    context,
                  ),
                ),
              ],
            ),
            _panelBatteryNames(context),
          ],
        ),
      );

  Widget _bundleProduct(String label, products, BuildContext context,
          {bool isPanel = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.overline,
          ),
          Container(
            height: 12,
          ),
          _productImage(context, isPanel, products),
          Container(
            height: 12,
          ),
          OutlineButton.icon(
            onPressed: () => _showSelectionDialog(context, isPanel),
            icon: Icon(
              products.length > 0 ? MdiIcons.pencil : Icons.add,
              size: 16,
              color: color,
            ),
            label: Text(
              products.length > 0 ? 'EDIT' : 'ADD',
              style: TextStyle(color: color),
            ),
          )
        ],
      );

  Widget _productImage(BuildContext context, bool isPanel, products) => products
              .length >
          1
      ? Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 32, top: 8, bottom: 32, left: 8),
              child: (products[0].imageUrl?.isEmpty ?? true)
                  ? Material(
                      elevation: 6.0,
                      shape: CircleBorder(),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0x0F000000),
                        child: Icon(
                          isPanel ? Icons.grid_on : Icons.battery_full,
                          color: Colors.black54,
                          size: 20,
                        ),
                      ),
                    )
                  : Material(
                      elevation: 6.0,
                      shape: CircleBorder(),
                      child: CircularProfileAvatar(products[0].imageUrl,
                          radius: 28,
                          cacheImage: true,
                          errorWidget: (_, __, ___) => CircleAvatar(
                                radius: 28,
                                backgroundColor: Color(0x0F000000),
                                child: Icon(
                                  isPanel ? Icons.grid_on : Icons.battery_full,
                                  color: Colors.black54,
                                  size: 20,
                                ),
                              )),
                    ),
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(right: 8, top: 28, bottom: 8, left: 28),
              width: 60,
              height: 60,
              child: (products[1].imageUrl?.isEmpty ?? true)
                  ? Material(
                      elevation: 6.0,
                      shape: CircleBorder(),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Color(0x0F000000),
                        child: Icon(
                          isPanel ? Icons.grid_on : Icons.battery_full,
                          color: Colors.black54,
                          size: 20,
                        ),
                      ),
                    )
                  : Material(
                      elevation: 6.0,
                      shape: CircleBorder(),
                      child: CircularProfileAvatar(products[1].imageUrl,
                          radius: 32,
                          cacheImage: true,
                          errorWidget: (_, __, ___) => CircleAvatar(
                                radius: 32,
                                backgroundColor: Color(0x0F000000),
                                child: Icon(
                                  isPanel ? Icons.grid_on : Icons.battery_full,
                                  color: Colors.black54,
                                  size: 20,
                                ),
                              )),
                    ),
              padding: EdgeInsets.all(4.0),
            ),
          ],
        )
      : products.length == 0
          ? GestureDetector(
              onTap: () => _showSelectionDialog(context, isPanel),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Color(0x0B000000),
                child: Container(
                  height: 46.0,
                  width: 46.0,
                  margin: EdgeInsets.only(left: 6.0, top: 6.0),
                  child: Stack(
                    children: <Widget>[
                      Icon(
                        isPanel ? Icons.grid_on : Icons.battery_full,
                        color: Colors.black38,
                        size: 32,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: _buildIconWithBorder(
                            MdiIcons.plusCircle, 32.0, 6.0,
                            borderColor: Color(0xFFF4F4F4),
                            iconColor: Colors.black38),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : (products[0]?.imageUrl ?? "") == ""
              ? Material(
                  elevation: 6.0,
                  shape: CircleBorder(),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Color(0x0F000000),
                    child: Icon(
                      isPanel ? Icons.grid_on : Icons.battery_full,
                      color: Colors.black54,
                      size: 32,
                    ),
                  ),
                )
              : Material(
                  elevation: 6.0,
                  shape: CircleBorder(),
                  child: CircularProfileAvatar(products[0].imageUrl,
                      radius: 48,
                      cacheImage: true,
                      errorWidget: (_, __, ___) => CircleAvatar(
                            radius: 48,
                            backgroundColor: Color(0xFFFDFDFD),
                            child: Icon(
                              isPanel ? Icons.grid_on : Icons.battery_full,
                              color: Colors.black54,
                              size: 32,
                            ),
                          )),
                );

  Widget _panelBatteryNames(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Panel${panels.length > 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.subtitle2,
            ),
            panels.isNotEmpty
                ? Container(
                    margin: EdgeInsets.only(top: 8.0),
                    padding: EdgeInsets.all(4.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                    child: _buildPanelBatteryRows(panels, true, context),
                  )
                : InstructionsCard(
                    instructions: "Select a panel to start calculating",
                  ),
            SizedBox(height: 8.0),
            Text(
              'Batter${batteries.length > 1 ? 'ies' : 'y'}',
              style: Theme.of(context).textTheme.subtitle2,
            ),
            batteries.isNotEmpty
                ? Container(
                    margin: EdgeInsets.only(top: 8.0),
                    padding: EdgeInsets.all(4.0),
                    width: double.infinity,
                    decoration: new BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                    child: _buildPanelBatteryRows(batteries, false, context),
                  )
                : InstructionsCard(
                    instructions: "Select a battery to start calculating",
                  ),
          ],
        ),
      );

  Widget _buildPanelBatteryRows(list, bool isPanel, BuildContext context) =>
      Column(
        children: list
            .map(
              (unit) => ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                dense: true,
                title: Text(
                  '•  ' + (isPanel ? unit.panel.name : unit.battery.name),
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.black87),
                ),
                trailing: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '${unit.units}x',
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
            .toList()
            .cast<Widget>(),
      );

  Widget _secondSection(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Text(
                'Products',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            products.isNotEmpty
                ? Column(
                    children: products
                        .map(
                          (product) => _buildProductTile(product, context),
                        )
                        .toList(),
                  )
                : _buildProductsPlaceholder(context),
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: OutlineButton.icon(
                  onPressed: addProduct,
                  icon: Icon(Icons.add, color: color),
                  label: Text(
                    'ADD PRODUCT',
                    style: TextStyle(color: color),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildProductTile(product, BuildContext context) => ListTile(
        contentPadding: EdgeInsets.only(left: 24.0, right: 12.0),
        leading: (product.imageUrl?.isEmpty ?? true)
            ? CircleAvatar(
                backgroundColor: Colors.black12,
                child: Icon(
                  MdiIcons.tag,
                  color: Colors.black38,
                  size: 20,
                ),
              )
            : CircularProfileAvatar(
                product.imageUrl,
                cacheImage: true,
                errorWidget: (_, __, ___) => CircleAvatar(
                  backgroundColor: Colors.black12,
                  child: Icon(
                    MdiIcons.tag,
                    color: Colors.black38,
                    size: 20,
                  ),
                ),
              ),
        title: Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Wrap(
          children: <Widget>[
            Text('Cons.: '),
            Text(
              (product.powerConsumption * (product.subProducts?.length ?? 1))
                      .toStringAsFixed(0) +
                  'Wh',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _editProductCount(context, product),
        ),
      );

  Widget _buildProductsPlaceholder(BuildContext context) => Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Container(
              height: 80.0,
              width: 80.0,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 20.0,
                    top: 2.0,
                    child: _buildIconWithBorder(
                      MdiIcons.television,
                      48.0,
                      8.0,
                    ),
                  ),
                  Positioned(
                    left: 2.0,
                    top: 20.0,
                    child: _buildIconWithBorder(
                      MdiIcons.fridge,
                      48.0,
                      8.0,
                    ),
                  ),
                  Positioned(
                    left: 20.0,
                    bottom: 2.0,
                    child: _buildIconWithBorder(
                      MdiIcons.lightbulb,
                      48.0,
                      8.0,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: _buildIconWithBorder(
                      MdiIcons.plusCircle,
                      36.0,
                      6.0,
                    ),
                  ),
                ],
              ),
            ),
            AutoSizeText(
              'Add products to start calculating',
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    fontSize: 24.0,
                    color: Color(0x99000000),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget _buildIconWithBorder(IconData icon, double size, double border,
          {Color iconColor, Color borderColor = Colors.white}) =>
      Container(
        height: size,
        width: size,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: size,
              color: borderColor,
            ),
            Icon(
              icon,
              size: size - border,
              color: iconColor ?? color,
            ),
          ],
        ),
      );

  // METHODS
  void _showSelectionDialog(BuildContext context, bool isPanel) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: EdgeInsets.all(0.0),
          title: Text(
            'Add ${isPanel ? 'panels' : 'batteries'}',
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('ACCEPT'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              children: (isPanel ? allPanels : allBatteries)
                  .map(
                    (product) => _buildExpansionTile(
                      context,
                      product,
                      isPanel: isPanel,
                      isSelected: isSelected(product),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      );

  Widget _buildExpansionTile(BuildContext context, product,
          {bool isPanel = false, bool isSelected = false}) =>
      ListTileTheme(
        contentPadding: const EdgeInsets.all(0.0),
        child: ExpansionTile(
          key: GlobalKey(),
          title: Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(product.sku),
          onExpansionChanged: (isExpanding) {
            if (isExpanding)
              isPanel ? addPanel(product) : addBattery(product);
            else
              isPanel ? removePanel(product.id) : removeBattery(product.id);
          },
          initiallyExpanded: isSelected,
          leading: (product.imageURL?.isEmpty ?? true)
              ? CircleAvatar(
                  backgroundColor: Colors.black12,
                  child: Icon(
                    isPanel ? Icons.grid_on : Icons.battery_full,
                    size: 20,
                    color: Colors.black38,
                  ),
                )
              : CircularProfileAvatar(product.imageURL,
                  radius: 20,
                  cacheImage: true,
                  errorWidget: (_, __, ___) => CircleAvatar(
                        backgroundColor: Colors.black12,
                        child: Icon(
                          isPanel ? Icons.grid_on : Icons.battery_full,
                          size: 20,
                          color: Colors.black38,
                        ),
                      )),
          trailing: Container(
            height: 0.0,
            width: 0.0,
          ),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.remove,
                    size: 18,
                  ),
                  onPressed: () => isPanel
                      ? removePanel(product.id, units: 1)
                      : removeBattery(product.id, units: 1),
                ),
                Text(
                  ((isPanel ? panels : batteries) ?? {})[product.id]
                          .units
                          ?.toString() ??
                      '0',
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    size: 18,
                  ),
                  onPressed: () =>
                      isPanel ? addPanel(product) : addBattery(product),
                ),
                Text(
                  'Units',
                  style: Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.center,
                ),
              ],
            )
          ],
        ),
      );

  // METHODS
  void _editProductCount(BuildContext context, product) => showDialog(
        context: context,
        child: AlertDialog(
          title: Text('Select the quantity'),
          // TODO
          // content: StreamBuilder<ConsumptionProduct>(
          //   stream: bloc.products
          //       .transform(SingleWhereStreamTransformer(id: product.id)),
          //   builder: (context, snapshot) {
          //     return Column(
          //       mainAxisSize: MainAxisSize.min,
          //       children: <Widget>[
          //         ListTile(
          //           contentPadding: const EdgeInsets.all(0.0),
          //           leading: (product.imageUrl?.isEmpty ?? true)
          //               ? CircleAvatar(
          //                   backgroundColor: Colors.black12,
          //                   child: Icon(
          //                     MdiIcons.tag,
          //                     color: Colors.black38,
          //                     size: 20,
          //                   ),
          //                 )
          //               : CircularProfileAvatar(product.imageUrl,
          //                   cacheImage: true,
          //                   errorWidget: (_, __, ___) => CircleAvatar(
          //                         backgroundColor: Colors.black12,
          //                         child: Icon(
          //                           MdiIcons.tag,
          //                           color: Colors.black38,
          //                           size: 20,
          //                         ),
          //                       )),
          //           title: Text(
          //             product.name,
          //             maxLines: 2,
          //             overflow: TextOverflow.ellipsis,
          //           ),
          //           subtitle: Text(
          //             '${snapshot.data?.subProducts?.length ?? 1} ' +
          //                 translations.translate(
          //                     'unit${(snapshot.data?.subProducts?.length ?? 1) > 1 ? 's' : ''}'),
          //           ),
          //         ),
          //         Row(
          //           children: <Widget>[
          //             IconButton(
          //               icon: Icon(
          //                 Icons.remove,
          //                 size: 18,
          //               ),
          //               onPressed: () {
          //                 bool noRemaining = bloc.removeLastUnit(product.id);
          //                 if (noRemaining) Navigator.pop(context);
          //               },
          //             ),
          //             Text(
          //               snapshot.data?.subProducts?.length?.toString() ?? '1',
          //             ),
          //             IconButton(
          //               icon: Icon(
          //                 Icons.add,
          //                 size: 18,
          //               ),
          //               onPressed: () =>
          //                   bloc.addProduct(consumptionProduct: product),
          //             ),
          //           ],
          //         )
          //       ],
          //     );
          //   },
          // ),
          actions: <Widget>[
            FlatButton(
              child: Text('ACCEPT'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
}
