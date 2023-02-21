import 'dart:typed_data';

import 'package:client/conversation/conversation.dart';
import 'package:client/eventbus.dart';
import 'package:client/utils/bytebuffer.dart';
import 'package:client/utils/colortheme.dart';
import 'package:client/utils/navigatortool.dart';
import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';

class ImagePicker extends StatefulWidget {
  const ImagePicker(this._eventBus, this._conversation, {super.key});

  final MainEventBus _eventBus;
  final Conversation _conversation;

  @override
  State<ImagePicker> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<ImagePicker> {
  String? selected;
  int? index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.background,
      appBar: AppBar(
        backgroundColor: ColorTheme.banner,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              NavigatorTool.pop();
            },
            icon: const Icon(Icons.close)),
        title: const Text(
          "Gallery",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: FutureBuilder(
        future: _albumRowFuture(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!;
          } else {
            return const Center(
              child: Text(
                "Loading...",
                style: TextStyle(color: ColorTheme.title, fontSize: 24),
              ),
            );
          }
        },
      ),
    );
  }

  Future<Widget> _albumRowFuture() async {
    final albums = await PhotoGallery.listAlbums(mediumType: MediumType.image);
    final List<Widget> achildren = [const SizedBox(width: 10)];
    for (var i = 0; i < albums.length; i++) {
      selected ??= albums[i].name;
      index ??= i;
      achildren.add(_albumButton(i, albums[i].name!));
      achildren.add(const SizedBox(width: 10));
    }
    final List<Widget> pchildren = [];
    final pictures = (await albums[index!].listMedia()).items;
    final columnCount = (pictures.length / 3).floor();
    for (var i = 0; i < columnCount; i++) {
      final j = i * 3;
      pchildren.add(Row(
        children: [
          await _iconize(pictures[j]),
          await _iconize(pictures[j + 1]),
          await _iconize(pictures[j + 2]),
        ],
      ));
    }
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: achildren,
            ),
          ),
        ),
        Column(
          children: pchildren,
        )
      ],
    );
  }

  Widget _albumButton(int i, String title) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          index = i;
          selected = title;
        });
      },
      style: ButtonStyle(
        backgroundColor: _btnize(ColorTheme.background3),
        fixedSize: _btnize(const Size(128, 36)),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Future<Widget> _iconize(Medium medium) async {
    final image = Image.file(
      await medium.getFile(),
      width: 100,
      height: 100,
    );
    return Padding(
      padding: const EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          NavigatorTool.pop();
          _handleImage(medium);
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: ColorTheme.background3,
            borderRadius: BorderRadius.circular(5),
          ),
          child: image,
        ),
      ),
    );
  }

  Future<void> _handleImage(Medium medium) async {
    Uint8List image = await (await medium.getFile()).readAsBytes();
    final uiImage = await decodeImageFromList(image);

    ByteBuf buf = ByteBuf.write();
    buf.writeDouble(uiImage.width.toDouble());
    buf.writeDouble(uiImage.height.toDouble());
    buf.writeBytes(image);

    widget._eventBus.sendMessage(
      widget._conversation.name,
      1,
      buf.toByteArray(),
    );
  }

  MaterialStateProperty<T> _btnize<T>(T value) {
    return MaterialStateProperty.all(value);
  }
}
