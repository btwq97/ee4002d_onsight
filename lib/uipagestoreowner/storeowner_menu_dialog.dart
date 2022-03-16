import 'package:flutter/material.dart';
import 'package:on_sight/services/onsight.dart';

import 'models/storeowner_menu.dart';

class AddStoreownerMenuDialog extends StatefulWidget {
  //const AddStoreownerMenuDialog({Key? key}) : super(key: key);

  final Function(StoreownerMenu) addMenu;

  AddStoreownerMenuDialog(this.addMenu);

  @override
  _AddStoreownerMenuDialogState createState() =>
      _AddStoreownerMenuDialogState();
}

class _AddStoreownerMenuDialogState extends State<AddStoreownerMenuDialog> {
  @override
  Widget build(BuildContext context) {
    Widget buildMenuField(String hint, TextEditingController controller) {
      return Container(
        margin: EdgeInsets.all(4),
        child: TextField(
          decoration: InputDecoration(
            labelText: hint,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black38,
              ),
            ),
          ),
          controller: controller,
        ),
      );
    }

    var menuNameController = TextEditingController();
    // var vegetarianController = TextEditingController();
    // var allergyController = TextEditingController();
    // var spicinessController = TextEditingController();
    var preferenceController = TextEditingController();
    var priceController = TextEditingController();

    return Container(
      padding: EdgeInsets.all(8),
      height: 450,
      width: 400,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text('Add Menu',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: Color(0xFFFFFF00))),
            buildMenuField('Name?', menuNameController),
            buildMenuField('Vegetarian, Allergy, Spiciness?', preferenceController),
            // buildMenuField('Any Allergens?', allergyController),
            // buildMenuField('Spiciness Level?', spicinessController),
            buildMenuField('Price?', priceController),
            ElevatedButton(
              onPressed: () {
                final menu = StoreownerMenu(
                    menuNameController.text,
                    preferenceController.text,
                    priceController.text);
                widget.addMenu(menu);
                Navigator.of(context).pop();
              },
              child: Text('Add Menu'),
            )
          ],
        ),
      ),
    );
  }
}
