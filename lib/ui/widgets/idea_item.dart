import 'package:astrologer/core/data_model/idea_model.dart';
import 'package:flutter/material.dart';

class IdeaItem extends StatelessWidget {
  const IdeaItem(this.entry, {this.onTap});

  final IdeaModel entry;

  final Function(String) onTap;

  Widget _buildTiles(IdeaModel idea, BuildContext context) {
    if (idea.children.isEmpty) return ListTile(title: Text(idea.title));
    return ExpansionTile(
      key: PageStorageKey<IdeaModel>(idea),
      title: Text(idea.title),
      children: idea.children.map((str) => _buildString(str, context)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry, context);
  }

  Widget _buildString(String str, BuildContext context) {
    return Container(
      /* decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).disabledColor)
          )),*/
      padding: EdgeInsets.all(2),
      child: ListTile(
        title: Text(str),
        trailing: IconButton(
          icon: Icon(
            Icons.send,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            onTap(str);
          },
        ),
      ),
    );
  }
}
