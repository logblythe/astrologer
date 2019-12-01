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
          child: Column(
            children: <Widget>[
              _buildHeader(context),
              Expanded(child: _buildIdeas(context, model)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'There are some question samples to inspire you with ideas what type and kind of questions you may ask. Of course, there are imaginary questins, our customer data is strictly confidential.',
        style: Theme.of(context).textTheme.subhead,
      ),
    );
  }

  Widget _buildIdeas(BuildContext context, IdeaViewModel model) {
    return model.busy
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            shrinkWrap: true,
            itemCount: model.ideas.length,
            itemBuilder: (_, index) => IdeaItem(
              model.ideas[index],
              onTap: (idea) {
                model.addMessageToSink(idea);
                onTap();
              },
            ),
          );
  }
}
