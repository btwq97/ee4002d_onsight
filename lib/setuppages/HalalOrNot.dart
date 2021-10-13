import 'package:flutter/material.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/iconcontent.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/components/reuseablecard.dart';
import 'package:on_sight/setuppages/Allergy.dart';

class HalalOrNot extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DO YOU NEED HALAL OPTIONS?'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ReusableCard(
                cardChild: IconContent(
                  icon: FontAwesomeIcons.thumbsUp,
                  label: 'YES',
                )
            ),
          ),
          Expanded(
            child: ReusableCard(
                cardChild: IconContent(
                  icon: FontAwesomeIcons.thumbsDown,
                  label: 'NO',
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
}