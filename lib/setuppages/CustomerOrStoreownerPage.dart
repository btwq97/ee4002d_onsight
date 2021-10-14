import 'package:flutter/material.dart';
import 'package:on_sight/setuppages/Vegetarianism.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/iconcontent.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/components/reuseablecard.dart';
import 'package:on_sight/setuppages/Allergy.dart';

class CustomerOrStoreOwnerPage extends StatefulWidget {
  @override
  _CustomerOrStoreownerPageState createState() => _CustomerOrStoreownerPageState();
}

class _CustomerOrStoreownerPageState extends State<CustomerOrStoreOwnerPage> {

  Color customerCardColour = kInactiveCardColour;
  Color storeownerCardColour = kInactiveCardColour;

  //1 = customer card chosen, 2 = storeowner card chosen
  void updateColour (int chosen){
    if (chosen == 1){
      if (customerCardColour == kInactiveCardColour){
        customerCardColour = kActiveCardColour;
      }else{
        customerCardColour = kInactiveCardColour;
      }
    }
    if (chosen == 2){
      if (storeownerCardColour == kInactiveCardColour){
        storeownerCardColour = kActiveCardColour;
      }else{
        storeownerCardColour = kInactiveCardColour;
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CUSTOMER OR STOREOWNER?'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  updateColour(1);
                });
              },
              child: ReusableCard(
                  colour: customerCardColour,
                  cardChild: IconContent(
                    icon: FontAwesomeIcons.userFriends,
                    label: 'CUSTOMER',
                  )
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  updateColour(2);
                });
              },
              child: ReusableCard(
                  colour: storeownerCardColour,
                  cardChild: IconContent(
                    icon: FontAwesomeIcons.store,
                    label: 'STOREOWNER',
                  )
              ),
            ),
          ),
          /*BottomButton(
            buttonTitle: 'NEXT',
            onTap: () {
              Navigator.pop(context);
            },
          )*/
        ],
      ),
    );
  }
}


/*class CustomerOrStoreownerPage extends StatelessWidget {
  //const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF301934),
        scaffoldBackgroundColor: Color(0xFF301934),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Onsight',
            style: TextStyle(
              fontFamily: 'HKGrotesk',
              color: Color(0xFFFFFF00),
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.black12,
        ),
        backgroundColor: Color(0xFF301934),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                color: Color(0xFF301934),
                margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      'CUSTOMER or STOREOWNER?',
                      style: TextStyle(
                        color: Color(0xFFFFFF00),
                        fontFamily: 'HKGrotesk',
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
                width: 150.0,
                child: Divider(
                  color: Color(0xFF301934),
                ),
              ),
              Card(
                color: Colors.black12,
                margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(
                        Icons.face,
                        color: Color(0xFFFFFF00)
                    ),
                    title: Text(
                      'CUSTOMER',
                      style: TextStyle(
                        color: Color(0xFFFFFF00),
                        fontFamily: 'HKGrotesk',
                        fontSize: 38,
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.black12,
                margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0.0),
                //padding: EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(
                        Icons.storefront,
                        color: Color(0xFFFFFF00)
                    ),
                    title: Text(
                      'STOREOWNER',
                      style: TextStyle(
                        color: Color(0xFFFFFF00),
                        fontFamily: 'HKGrotesk',
                        fontSize: 38.0,
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.black12,
                margin: EdgeInsets.symmetric(vertical: 10.0),
                //padding: EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      'NEXT',
                      style: TextStyle(
                        color: Color(0xFFFFFF00),
                        fontFamily: 'HKGrotesk',
                        fontSize: 38.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/