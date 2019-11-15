import 'package:astrologer/core/data_model/astrologer_model.dart';
import 'package:astrologer/core/view_model/view/astrologer_view_model.dart';
import 'package:astrologer/ui/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AstrologersView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseWidget<AstrologerViewModel>(
      model: AstrologerViewModel(homeService: Provider.of(context)),
      onModelReady: (model) => model.fetchAstrologers(),
      builder: (context, model, child) {
        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              )),
          child: model.busy
              ? const Center(child: const CircularProgressIndicator())
              : (model.astrologers == null || model.astrologers.isEmpty)
                  ? const Center(
                      child: const Text('No astrologer found at the moment'))
                  : ListView(children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Our astrologers are genuine professionals trained to treat astrology like a sacred science. In their own lives in Nepal, they are known to combine simple, honest living with high thinking',
                          style: Theme.of(context).textTheme.title,
                        ),
                      ),
                      Divider(),
                      ListTile(
                          title: Text(
                            'Why astrologers?',
                            style: Theme.of(context).textTheme.body1,
                          ),
                          leading: Icon(Icons.people)),
                      Divider(),
                      _buildListView(model),
                    ]),
        );
      },
    );
  }

  ListView _buildListView(AstrologerViewModel model) {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: model.astrologers.length,
        itemBuilder: (context, index) {
          AstrologerModel _astrologer = model.astrologers[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 24.0,
              backgroundImage: NetworkImage(_astrologer.profileImageUrl ??
                  'https://via.placeholder.com/150'),
              backgroundColor: Colors.transparent,
            ),
            title: Text("${_astrologer.firstName} ${_astrologer.lastName}"),
          );
        });
  }
}
