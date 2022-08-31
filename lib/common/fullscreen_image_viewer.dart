import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:social/common/utils.dart';
import 'package:social/models/post.dart';
import 'package:social/provider/bottom_tab_provider.dart';

import '../provider/tag_provider.dart';

class FullScreenImageViewer extends StatelessWidget {
  const FullScreenImageViewer({Key? key, this.post}) : super(key: key);

  final Post? post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
          alignment: Alignment.bottomCenter, 
          children: [
          Center(
            child: PhotoView(
      imageProvider: NetworkImage('${post?.image}'),
      loadingBuilder: (context, _progress) => Center(
        child: SizedBox(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(
            value: _progress == null
                ? null
                : _progress.cumulativeBytesLoaded /
                    (_progress.expectedTotalBytes ?? 1),
          ),
        ),
      ),
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      customSize: MediaQuery.of(context).size,
      minScale: PhotoViewComputedScale.contained * 0.8,
      maxScale: PhotoViewComputedScale.covered * 1.8,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
      Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              Colors.black.withAlpha(00),
              Colors.black.withAlpha(40)
            ])),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 4),
            child: SafeArea(
                          child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      style: ListTileStyle.drawer,
            leading: CircleAvatar(
              backgroundImage: NetworkImage('${post?.owner?.picture}'),
            ),
            title: Text(
                '${post?.owner?.title.toString().capitalize()}. ${post?.owner?.firstName} ${post?.owner?.lastName}',
                        style: const TextStyle(color: Colors.white)),
            subtitle: Text(getTimeAgoFromDate('${post?.publishDate}'),
                        style: const TextStyle(color: Colors.white)),
          ),
                    Text('${post?.text}',
                        style: const TextStyle(color: Colors.white)),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (post?.tags ?? [])
                                .map(
                                  (chip) => GestureDetector(
                                    onTap: () {
                                      Provider.of<TagProvider>(context, listen: false).selectedTag = chip;
                                      Provider.of<BottomTabProvider>(context, listen: false).selectedTab = BottomTabBarItems.explore;
                                      Navigator.pop(context);
                                    },
                                    child: Text('#$chip',
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12)),
                                  ),
                                )
                                .toList()
                                .cast<Widget>(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.thumb_up,
                                color: Colors.white,
                                size: 12,
                              ),
                              Text(' ${post?.likes}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12))
                            ],
                          ),
                        )
                      ],
                    )
                  ]),
            ),
          ),
        ),
      ),
            ],
          )
        ]),
    );
  }
}
