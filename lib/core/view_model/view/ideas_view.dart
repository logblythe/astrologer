import 'package:astrologer/core/constants/what_to_ask.dart' show ideas;
import 'package:astrologer/core/view_model/view/idea_view_model.dart';
import 'package:astrologer/ui/base_widget.dart';
import 'package:astrologer/ui/widgets/idea_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IdeasView extends StatelessWidget {
  final Function onTap;

  const IdeasView({Key key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseWidget<IdeaViewModel>(
      model: IdeaViewModel(homeService: Provider.of(context)),
      builder: (context, model, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: _buildIdeas(context, model),
        );
      },
    );
  }

  _buildHeader() {
    return Text(
        'There are some question samples to inspire you with ideas what type and kind of questions you may ask. Of course, there are imaginary questins, our customer data is strictly confidential.');
  }

  Widget _buildIdeas(BuildContext context, IdeaViewModel model) {
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (_, index) => IdeaItem(
              ideas[index],
              onTap: (idea) {
                model.addMessageToSink(idea);
                onTap();
              },
            ),
        separatorBuilder: (_, int) => Divider(),
        itemCount: ideas.length);
  }
}
