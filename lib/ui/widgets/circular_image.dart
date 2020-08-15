import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

class CircularImage extends StatefulWidget {
  final Function(File image) onImageCaptured;
  final String imageUrl;
  final bool busy;

  const CircularImage({Key key, this.onImageCaptured, this.imageUrl, this.busy})
      : super(key: key);

  @override
  _CircularImageState createState() => _CircularImageState();
}

class _CircularImageState extends State<CircularImage> {
  File _image;
  String _imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        InkResponse(
          child: CircleAvatar(
            backgroundColor: Colors.red,
            radius: 56,
            child: _imageUrl != null
                ? Container(
                    width: 190.0,
                    height: 190.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill, image: NetworkImage(_imageUrl)),
                    ),
                  )
                : _image == null
                    ? Icon(Icons.person_outline)
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
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
        ),
        Positioned(
          top: 38,
          left: 38,
          child: widget.busy
              ? CircularProgressIndicator(
                  strokeWidth: 4,
                  backgroundColor: Colors.white54,
                )
              : Container(),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.imageUrl;
  }

  @override
  void didUpdateWidget(CircularImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      setState(() {
        _imageUrl = widget.imageUrl;
      });
    }
  }


  Future getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _image = image;
        _imageUrl = null;
      });
      widget.onImageCaptured(image);
    }
  }
}
