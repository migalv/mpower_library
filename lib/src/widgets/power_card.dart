import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class PowerCard extends StatefulWidget {
  final bool isPinned;
  final double lateralPadding;
  final Stream powerSectionPanel,
      powerSectionBattery,
      isBatterySupported,
      isPanelSupported;

  const PowerCard({
    Key key,
    @required this.isPinned,
    @required this.lateralPadding,
    @required this.powerSectionPanel,
    @required this.powerSectionBattery,
    @required this.isBatterySupported,
    @required this.isPanelSupported,
  }) : super(key: key);

  @override
  _PowerCardState createState() => _PowerCardState();
}

class _PowerCardState extends State<PowerCard> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.all(0.0),
        child: Container(
          child: Column(
            children: <Widget>[
              _buildStatusBarBackground(),
              _buildTile(true),
              _buildTile(false),
              _buildWarningMessage(),
            ],
          ),
        ),
      );

  Widget _buildStatusBarBackground() => AnimatedContainer(
        height: widget.isPinned ? 24.0 : 0.0,
        width: double.infinity,
        duration: Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(4.0),
            bottomRight: Radius.circular(4.0),
          ),
          color: Colors.white,
        ),
        padding: const EdgeInsets.only(top: 3.0),
        child: Text(''),
      );

  Widget _buildTile(bool isPanel) => StreamBuilder(
        stream: isPanel ? widget.powerSectionPanel : widget.powerSectionBattery,
        builder: (context, snapshot) => snapshot.data == null
            ? Container()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    leading: Container(
                      height: 48.0,
                      width: 48.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32.0),
                        border: Border.all(
                          width: 2.0,
                          color: _getColor(snapshot.data.percentage.toInt()),
                        ),
                      ),
                      child: Icon(
                        isPanel ? Icons.grid_on : Icons.battery_full,
                        color: _getColor(snapshot.data.percentage.toInt()),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      snapshot.data.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Wrap(
                      children: <Widget>[
                        Text(isPanel ? 'Production: ' : 'Daily capacity: '),
                        Text(
                          isPanel
                              ? '${(snapshot.data.production * 2.5).toInt()}Wh'
                              : '${snapshot.data.capacity.toInt()}W',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    trailing: Container(
                      width: 48.0,
                      child: AutoSizeText(
                        '${snapshot.data.percentage.toStringAsFixed(0)}%',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    decoration: BoxDecoration(
                      color: _getColor(snapshot.data.percentage.toInt()),
                    ),
                    duration: Duration(milliseconds: 300),
                    curve: Curves.fastOutSlowIn,
                    child: AnimatedSize(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.fastOutSlowIn,
                      vsync: this,
                      child: Container(
                        height: 4,
                        width: _getWidth(snapshot.data.percentage),
                      ),
                    ),
                  ),
                ],
              ),
      );

  Widget _buildWarningMessage() => StreamBuilder<bool>(
        stream: widget.isBatterySupported,
        initialData: true,
        builder: (context, batterySnapshot) => StreamBuilder<bool>(
          stream: widget.isPanelSupported,
          initialData: true,
          builder: (context, panelSnapshot) {
            bool isBatterySupported = batterySnapshot.data ?? true;
            bool isPanelSupported = panelSnapshot.data ?? true;
            return AnimatedContainer(
              height: !isPanelSupported || !isBatterySupported ? 24.0 : 0.0,
              width: double.infinity,
              duration: Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4.0),
                  bottomRight: Radius.circular(4.0),
                ),
                color: Colors.red,
              ),
              padding: const EdgeInsets.only(top: 3.0),
              child: Text(
                'The ${!isBatterySupported ? "battery" : "panel"} does not support the load',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Colors.white,
                      fontSize: 13.0,
                    ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      );

//  METHODS
  Color _getColor(int value) => value >= 100
      ? Colors.red
      : value < 100 && value >= 80
          ? Colors.orange
          : value < 80 && value >= 60 ? Colors.yellow : Colors.green;

  double _getWidth(double percentage) =>
      (MediaQuery.of(context).size.width -
          (widget.isPinned ? 0.0 : widget.lateralPadding * 2)) *
      percentage /
      100;
}
