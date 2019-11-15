import 'package:astrologer/core/enum/gender.dart';
import 'package:astrologer/ui/widgets/gender_tile.dart';
import 'package:flutter/material.dart';

class GenderSelection extends StatefulWidget {
  final Function(Gender gender) updateGender;
  final Gender selectedGender;

  const GenderSelection({Key key, this.updateGender, this.selectedGender})
      : super(key: key);

  @override
  _GenderSelectionState createState() => _GenderSelectionState();
}

class _GenderSelectionState extends State<GenderSelection> {
  Gender selectedGender;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedGender = widget.selectedGender;
    print('inside $selectedGender');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: GenderTile(
            isSelected: selectedGender == Gender.female,
            genderText: "Female",
            genderIcon: Icons.accessibility_new,
            character: Gender.female,
            onTap: () {
              setState(() {
                selectedGender = Gender.female;
                widget.updateGender(selectedGender);
              });
            },
          ),
        ),
        Expanded(
          child: GenderTile(
            isSelected: selectedGender == Gender.male,
            genderText: "Male",
            genderIcon: Icons.person,
            character: Gender.male,
            onTap: () {
              setState(() {
                selectedGender = Gender.male;
                widget.updateGender(selectedGender);
              });
            },
          ),
        )
      ],
    );
  }
}
