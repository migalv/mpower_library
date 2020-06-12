import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cons_calc_lib/cons_calc_lib.dart';

BuildContext _context;

class ConsumptionCard extends StatelessWidget {
  final Stream _products;
  final Function _toggleSubProducts, _changeProductName, _onSliderChange;

  const ConsumptionCard({
    @required Stream products,
    @required Function toggleSubProducts,
    @required Function changeProductName,
    @required Function onSliderChange,
  })  : _products = products,
        _toggleSubProducts = toggleSubProducts,
        _changeProductName = changeProductName,
        _onSliderChange = onSliderChange;

  @override
  Widget build(BuildContext context) {
    _context = context;

    return Card(
      child: StreamBuilder(
        stream: _products,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<Widget> tiles = [];
          int i = 0;

          (snapshot.data ?? []).forEach(
            (product) {
              tiles.add(_consumptionTile(product));
              if (i != snapshot.data.length - 1)
                tiles.add(Divider(height: 2.0, thickness: 1.0));
              i++;
            },
          );

          return Column(children: tiles);
        },
      ),
    );
  }

  Widget _consumptionTile(product) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Container(
              constraints:
                  BoxConstraints(maxWidth: MediaQuery.of(_context).size.width),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      child: Icon(
                        MdiIcons.lightbulbOn,
                        color: Colors.white,
                      ),
                      backgroundColor: secondaryMain,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      product.name,
                      style: Theme.of(_context).textTheme.bodyText2,
                    ),
                  ),
                  _buildTrailing(product.subProducts?.length ?? 1),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 56.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    flex: 3,
                    child: Text(
                      'Consumption: ',
                      style: Theme.of(_context)
                          .textTheme
                          .subtitle2
                          .copyWith(fontSize: 16.0),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Text(
                      '${((product.day + product.night) * product.powerConsumption).toInt()}Wh',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: black60,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 56.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: AutoSizeText(
                      'Day: ',
                      style: Theme.of(_context)
                          .textTheme
                          .subtitle2
                          .copyWith(fontSize: 16.0),
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      '${(product.day * product.powerConsumption).toInt()}Wh',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: black60,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: AutoSizeText(
                      ' | Night: ',
                      style: Theme.of(_context)
                          .textTheme
                          .subtitle2
                          .copyWith(fontSize: 16.0),
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      '${(product.night * product.powerConsumption).toInt()}Wh',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: black60,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            (product.subProducts?.isNotEmpty ?? false)
                ? ExpansionButton(
                    onPressed: () {
                      _toggleSubProducts(product.id);
                    },
                    label: Text(
                      '${product.expanded ? 'Collapse' : 'Expand'} products',
                    ),
                  )
                : Container(),
            !product.expanded || (product.subProducts?.isEmpty ?? true)
                ? _buildSliders(product)
                : Container(),
            product.expanded ? _buildSubProducts(product) : Container(),
          ],
        ),
      );

  Widget _buildTrailing(int units) => units == 1
      ? Container()
      : Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 8.0, right: 8.0),
              child: Text(
                '$units unit${units > 1 ? 's' : ''}',
                style: Theme.of(_context).textTheme.caption,
              ),
            ),
          ],
        );

  Widget _buildSliders(product) => Column(
        children: <Widget>[
          _buildSlider(
            product,
            product.day?.toDouble() ?? 0,
          ),
          _buildSlider(
            product,
            product.night?.toDouble() ?? 0,
            isNight: true,
          ),
        ],
      );

  Widget _buildSlider(product, double value, {bool isNight = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(
              isNight ? Icons.brightness_2 : MdiIcons.whiteBalanceSunny,
              color: black60,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                inactiveTickMarkColor: Colors.transparent,
                activeTickMarkColor: Colors.transparent,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
              ),
              child: Slider(
                min: 0.0,
                max: isNight
                    ? product.night > 16 ? product.night : 16
                    : product.day > 8 ? product.day : 8,
                activeColor: secondaryMain,
                inactiveColor: secondaryMain.withOpacity(0.5),
                value: value,
                onChanged: (value) {
                  _onSliderChange(
                    isNight: isNight,
                    id: product.id,
                    newValue: value,
                  );
                },
              ),
            ),
          ),
          Container(
            width: 32.0,
            child: Text(
              value.toStringAsFixed(0) + "h",
              style: Theme.of(_context)
                  .textTheme
                  .subtitle2
                  .copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );

  Widget _buildSubProducts(product) => Column(
        children: product.subProducts
                ?.map(
                  (subProduct) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      EditableText(
                        controller:
                            TextEditingController(text: subProduct.name),
                        focusNode: FocusNode(),
                        style: Theme.of(_context).textTheme.bodyText2,
                        cursorColor: secondaryMain,
                        backgroundCursorColor: secondaryMain,
                        onSubmitted: (String value) {
                          _changeProductName(product.id, subProduct.id, value);
                        },
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'Consumption: ',
                            style: Theme.of(_context).textTheme.subtitle2,
                          ),
                          Text(
                            ((subProduct.day + subProduct.night) *
                                        product.powerConsumption)
                                    .toStringAsFixed(0) +
                                'Wh',
                            style:
                                Theme.of(_context).textTheme.subtitle2.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: black60,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'Day: ',
                            style: Theme.of(_context).textTheme.subtitle2,
                          ),
                          Text(
                            '${(subProduct.day * product.powerConsumption).toInt()}Wh',
                            style:
                                Theme.of(_context).textTheme.subtitle2.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: black60,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(' | Night: ',
                              style: Theme.of(_context).textTheme.subtitle2),
                          Text(
                            '${(subProduct.night * product.powerConsumption).toInt()}Wh',
                            style:
                                Theme.of(_context).textTheme.subtitle2.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: black60,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      _buildSliders(subProduct),
                      Container(
                        height: 12,
                      ),
                    ],
                  ),
                )
                ?.toList()
                ?.cast<Widget>() ??
            [],
      );
}

class ExpansionButton extends StatefulWidget {
  final Function onPressed;
  final Widget label;

  const ExpansionButton({Key key, this.onPressed, this.label})
      : super(key: key);

  @override
  _ExpansionButtonState createState() => _ExpansionButtonState();
}

class _ExpansionButtonState extends State<ExpansionButton>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final Animatable<double> _sizeTween = Tween<double>(begin: 0.0, end: 1.0),
      _rotationTween = Tween<double>(begin: 0.0, end: 0.5);
  Animation<double> _sizeAnimation, _rotateAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _sizeAnimation = _sizeTween.animate(
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    _rotateAnimation = _rotationTween.animate(
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    super.initState();
  }

  @override
  Widget build(BuildContext context) => FlatButton.icon(
        onPressed: () {
          _toggleExpand();
          widget.onPressed();
        },
        icon: RotationTransition(
          turns: _rotateAnimation,
          child: Icon(
            Icons.keyboard_arrow_down,
          ),
        ),
        label: widget.label,
      );

  // METHODS
  _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);

    switch (_sizeAnimation.status) {
      case AnimationStatus.completed:
        _controller.reverse();
        break;
      case AnimationStatus.dismissed:
        _controller.forward();
        break;
      case AnimationStatus.reverse:
      case AnimationStatus.forward:
        break;
    }
  }
}
