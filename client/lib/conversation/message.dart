import 'dart:typed_data';

import 'package:client/utils/colortheme.dart';
import 'package:flutter/material.dart';

abstract class Message {
  int index;
  bool sent;
  String from;

  Message(this.index, this.sent, this.from);

  Widget getWidget(BuildContext context);
}

class TextMessage extends Message {
  final String message;

  TextMessage(super.index, super.sent, super.from, this.message);

  @override
  Widget getWidget(BuildContext context) {
    return Column(
      crossAxisAlignment:
          sent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        sent
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  from,
                  style: const TextStyle(color: ColorTheme.text),
                ),
              ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 150,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: sent ? ColorTheme.theme : ColorTheme.text,
          ),
          padding: const EdgeInsets.all(12),
          child: Text(
            message,
            style: const TextStyle(fontSize: 15),
          ),
        )
      ],
    );
  }
}

class ImageMessage extends Message {
  final double width;
  final double height;
  final Uint8List data;

  ImageMessage(
    super.index,
    super.sent,
    super.from,
    this.width,
    this.height,
    this.data,
  );

  @override
  Widget getWidget(BuildContext context) {
    Image image = Image.memory(data, width: this.width, height: this.height);
    Size size = MediaQuery.of(context).size;
    final width = size.width / 2;
    final height = image.height! * (width / image.width!);
    final img = Image(image: image.image, width: width, height: height);
    return Column(
      crossAxisAlignment:
          sent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        sent
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  from,
                  style: const TextStyle(color: ColorTheme.text),
                ),
              ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: img,
        )
      ],
    );
  }
}

class PlaceholderImageMessage extends Message {
  PlaceholderImageMessage(super.index, super.sent, super.from);

  @override
  Widget getWidget(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width * 0.4;
    return Column(
      crossAxisAlignment:
          sent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        sent
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  from,
                  style: const TextStyle(color: ColorTheme.text),
                ),
              ),
        Container(
          width: width,
          height: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: ColorTheme.background2,
          ),
          child: const Center(
            child: Text(
              "Loading...",
              style: TextStyle(color: ColorTheme.text),
            ),
          ),
        )
      ],
    );
  }
}
