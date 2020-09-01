import 'package:campus_mobile_experimental/core/data_providers/parking_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/spot_types_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/HexColor.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SpotTypesView extends StatelessWidget {
  ParkingDataProvider spotTypesDataProvider;
  @override
  Widget build(BuildContext context) {
    spotTypesDataProvider = Provider.of<ParkingDataProvider>(context);
    return ContainerView(
      child: createListWidget(context),
    );
  }

  Widget createListWidget(BuildContext context) {
    return ListView(children: createList(context));
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = List<Widget>();
    for (Spot data in spotTypesDataProvider.spotTypeModel.spots) {
      Color iconColor = HexColor(data.color);
      Color textColor = HexColor(data.textColor);
      list.add(ListTile(
        key: Key(data.spotKey.toString()),
        leading: Container(
            width: 35,
            height: 35,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor,
            ),
            child: Align(
                alignment: Alignment.center,
                child: data.text.contains("&#x267f;")
                    ? FaIcon(FontAwesomeIcons.accessibleIcon)
                    : Text(
                        data.text,
                        style: TextStyle(color: textColor),
                      ))),
        title: Text(data.name),
        trailing: Switch(
          value: Provider.of<ParkingDataProvider>(context)
              .spotTypesState[data.spotKey],
          onChanged: (_) {
            spotTypesDataProvider.toggleSpotSelection(data.spotKey);
          },
          activeColor: ColorPrimary,
        ),
      ));
    }
    return list;
  }
}
