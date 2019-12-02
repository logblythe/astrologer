import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CircularImage extends StatefulWidget {
  const CircularImage({Key key}) : super(key: key);

  @override
  _CircularImageState createState() => _CircularImageState();
}

class _CircularImageState extends State<CircularImage> {
  File _image;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: CircleAvatar(
        radius: 56,
        child: _image == null
            ? Icon(Icons.person)
            : Container(
                decoration: new BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                      fit: BoxFit.fill, image: new FileImage(_image)),
                ),
              ),
      ),
      onTap: getImage,
    );
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }
}
