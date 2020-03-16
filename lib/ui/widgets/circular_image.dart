import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CircularImage extends StatefulWidget {
  final Function(File image) onImageCaptured;
  final String imageUrl;

  const CircularImage({Key key, this.onImageCaptured, this.imageUrl})
      : super(key: key);

  @override
  _CircularImageState createState() => _CircularImageState();
}

class _CircularImageState extends State<CircularImage> {
  File _image;
  String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        InkResponse(
          child: CircleAvatar(
            backgroundColor: Colors.red,
            radius: 56,
            child: imageUrl != null
                ? Container(
                    width: 190.0,
                    height: 190.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(widget.imageUrl))))
                : _image == null
                    ? Icon(Icons.person_outline,)
                    : Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.red),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.fill, image: FileImage(_image)),
                        ),
                      ),
          ),
          onTap: () => getImage(ImageSource.camera),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: Theme.of(context).accentColor),
            child: InkWell(
              child: Icon(
                Icons.file_upload,
                size: 18,
                color: Theme.of(context).backgroundColor,
              ),
              onTap: () => getImage(ImageSource.gallery),
            ),
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    imageUrl = widget.imageUrl;
  }

  @override
  void didUpdateWidget(CircularImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      setState(() {
        imageUrl = widget.imageUrl;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _image = image;
        imageUrl = null;
      });
      widget.onImageCaptured(image);
    }
  }
}
