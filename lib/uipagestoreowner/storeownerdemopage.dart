import 'package:flutter/material.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/uipagestoreowner/models/storeowner_menu.dart';
import 'package:on_sight/uipagestoreowner/storeowner_menu_dialog.dart';

class StoreownerMainPage extends StatefulWidget {
  StoreownerMainPage({
    Key? key,
    required this.onSight,
  }) : super(key: key);

  final OnSight onSight;

  @override
  _StoreownerMainPageState createState() => _StoreownerMainPageState(
        onSight: onSight,
      );
}

class _StoreownerMainPageState extends State<StoreownerMainPage> {
  _StoreownerMainPageState({
    required this.onSight,
  });

  final OnSight onSight;

  List<StoreownerMenu> menuList = [];

  @override
  Widget build(BuildContext context) {
    void addMenuData(StoreownerMenu menu) {
      setState(() {
        menuList.add(menu);
      });
    }

    void showMenuDialog() {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: AddStoreownerMenuDialog(addMenuData),
          );
        },
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Hungry Burger (Halal, Non Veg)',
            style: TextStyle(fontSize: 15),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: showMenuDialog,
          child: Icon(Icons.add),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          child: ListView.builder(
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.all(4),
                elevation: 8,
                child: ListTile(
                  title: Text(menuList[index].menuname),
                  subtitle: Text(menuList[index].preferences),
                  trailing: Text(menuList[index].price),
                ),
              );
            },
            itemCount: menuList.length,
          ),
        ));
  }
}
