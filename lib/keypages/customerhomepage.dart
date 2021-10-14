import 'package:flutter/material.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontent.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/components/reuseablecard.dart';
import 'package:on_sight/setuppages/SpiceLevel.dart';


class CustomerHomePage extends StatefulWidget {
  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HOME PAGE'),
      ),
      body: SafeArea(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
      CircleAvatar(
      radius: 50.0,
      backgroundImage: AssetImage('images/imtiaz.jpg'),
      ),
      Text(
      'Imtiaz Bin Yazdany',
      style: TextStyle(
      fontFamily: 'Pacifico',
      fontSize: 40.0,
      color: Colors.white,
      fontWeight: FontWeight.bold
      ),
      ),
      Text(
      'STUDENT',
      style: TextStyle(
      fontFamily: 'SourceSansPro',
      fontSize: 20.0,
      color: Colors.lightBlue.shade50,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.5,
    ),
    ),
    SizedBox(
    height: 20.0,
    width: 150.0,
    child: Divider(
    color: Colors.lightBlue.shade100
    ),
    ),
    Card(
    color: Colors.black12,
    margin: EdgeInsets.symmetric (vertical: 10.0, horizontal: 25.0),
    child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: ListTile(
    leading:Icon(
    Icons.phone_iphone_rounded,
    color: Colors.lightBlue.shade50
    ),
    title: Text(
    '(+65) 8228 0284',
    style: TextStyle(
    color: Colors.lightBlue.shade50,
    fontFamily: 'SourceSansPro',
    fontSize: 18.0,
    ),
    ),
    ),
    ),
    ),
    Card(
    color: Colors.black12,
    margin: EdgeInsets.symmetric (vertical: 10.0, horizontal: 25.0),
    //padding: EdgeInsets.all(10.0),
    child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: ListTile(
    leading:Icon(
    Icons.email_outlined,
    color: Colors.lightBlue.shade50
    ),
    title: Text(
    'yazdanyimtiaz23@hotmail.com',
    style: TextStyle(
    color: Colors.lightBlue.shade50,
    fontFamily: 'SourceSansPro',
    fontSize: 18.0,
    ),
    ),
    ),
    ),
    ),
    ],
    ),
    ));
  }
}