import 'package:flutter/material.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontent.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/components/reuseablecard.dart';
import 'package:on_sight/setuppages/Cuisine.dart';

enum SpicePreference {
  None,
  Mild,
  Full,
}

class SpiceLevelPage extends StatefulWidget {
  @override
  _SpiceLevelPageState createState() => _SpiceLevelPageState();
}

class _SpiceLevelPageState extends State<SpiceLevelPage> {

  SpicePreference? level;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SPICE LEVEL?', style: TextStyle(fontSize: 40),),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ReusableCard(
                onPress: (){
                  setState(() {
                    level = SpicePreference.None;
                  });
                },
                colour: level == SpicePreference.None ? kActiveCardColour : kInactiveCardColour,
                cardChild: IconContent(
                  icon: Icons.highlight_off,
                  label: 'NONE',
                )
            ),
          ),
          Expanded(
            child: ReusableCard(
                onPress: (){
                  setState(() {
                    level = SpicePreference.Mild;
                  });
                },
                colour: level == SpicePreference.Mild ? kActiveCardColour : kInactiveCardColour,
                cardChild: IconContent(
                  icon: FontAwesomeIcons.pepperHot,
                  label: 'MILD',
                )
            ),
          ),
          Expanded(
            child: ReusableCard(
                onPress: (){
                  setState(() {
                    level = SpicePreference.Full;
                  });
                },
                colour: level == SpicePreference.Full ? kActiveCardColour : kInactiveCardColour,
                cardChild: IconContent(
                  icon: FontAwesomeIcons.hotjar,
                  label: 'FULL',
                )
            ),
          ),
          GestureDetector(
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CuisinePage()));
            },
            child: Container(
              child: Center(
                child: Text (
                  'NEXT',
                  style: kBottomButtonTextStyle,
                ),
              ),
              color: kBottomContainerColour,
              margin: EdgeInsets.only(top: 10.0),
              padding: EdgeInsets.only(bottom: 20.0),
              width: double.infinity,
              height: kBottomContainerHeight,
            ),
          ),
        ],
      ),
    );
  }
}







// class SpicinessPage extends StatefulWidget {
//   @override
//   _SpicinessPageState createState() => _SpicinessPageState();
// }
//
// class _SpicinessPageState extends State<SpicinessPage> {
//
//   Color eggCardColour = kInactiveCardColour;
//   Color nutsCardColour = kInactiveCardColour;
//   Color milkCardColour = kInactiveCardColour;
//   Color soyCardColour = kInactiveCardColour;
//
//   //1 = egg, 2 = nuts, 3 = milk, 4 = soy
//   void updateColour (int chosen){
//     if (chosen == 1){
//       if (eggCardColour == kInactiveCardColour){
//         eggCardColour = kActiveCardColour;
//       }else{
//         eggCardColour = kInactiveCardColour;
//       }
//     }
//     if (chosen == 2){
//       if (nutsCardColour == kInactiveCardColour){
//         nutsCardColour = kActiveCardColour;
//       }else{
//         nutsCardColour = kInactiveCardColour;
//       }
//     }
//     if (chosen == 3){
//       if (milkCardColour == kInactiveCardColour){
//         milkCardColour = kActiveCardColour;
//       }else{
//         milkCardColour = kInactiveCardColour;
//       }
//     }
//     if (chosen == 4){
//       if (soyCardColour == kInactiveCardColour){
//         soyCardColour = kActiveCardColour;
//       }else{
//         soyCardColour = kInactiveCardColour;
//       }
//     }
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('LIST YOUR SPICE TOLERANCE'),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: <Widget>[
//           Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   updateColour(1);
//                 });
//               },
//               child: ReusableCard(
//                   colour: eggCardColour,
//                   cardChild: IconContent(
//                     icon: FontAwesomeIcons.egg,
//                     label: 'EGGS',
//                   )
//               ),
//             ),
//           ),
//           Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   updateColour(2);
//                 });
//               },
//               child: ReusableCard(
//                   colour: nutsCardColour,
//                   cardChild: IconContent(
//                     icon: FontAwesomeIcons.nutritionix,
//                     label: 'NUTS',
//                   )
//               ),
//             ),
//           ),
//           Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   updateColour(3);
//                 });
//               },
//               child: ReusableCard(
//                   colour: milkCardColour,
//                   cardChild: IconContent(
//                     icon: FontAwesomeIcons.hatCowboy,
//                     label: 'MILK',
//                   )
//               ),
//             ),
//           ),
//           Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   updateColour(4);
//                 });
//               },
//               child: ReusableCard(
//                   colour: soyCardColour,
//                   cardChild: IconContent(
//                     icon: FontAwesomeIcons.bandcamp,
//                     label: 'SOY',
//                   )
//               ),
//             ),
//           ),
//           /*BottomButton(
//             buttonTitle: 'NEXT',
//             onTap: () {
//               Navigator.pop(context);
//             },
//           )*/
//         ],
//       ),
//     );
//   }
// }







/*class Spiciness extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LIST YOUR SPICE TOLERANCE'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ReusableCard(
                cardChild: IconContent(
                  icon: FontAwesomeIcons.fireExtinguisher,
                  label: 'NO SPICE',
                )
            ),
          ),
          Expanded(
            child: ReusableCard(
                cardChild: IconContent(
                  icon: FontAwesomeIcons.pepperHot,
                  label: 'MILD SPICE',
                )
            ),
          ),
          Expanded(
            child: ReusableCard(
                cardChild: IconContent(
                  icon: FontAwesomeIcons.dragon,
                  label: 'VERY SPICY',
                )
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
}*/