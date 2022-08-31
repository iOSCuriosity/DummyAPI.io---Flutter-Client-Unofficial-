import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:social/common/fullscreen_image_viewer.dart';
import 'package:social/common/loading_list.dart';
import 'package:social/common/utils.dart';
import 'package:social/models/post.dart';
import 'package:flutter/material.dart';
import 'package:social/pages/explore_page.dart';
import 'package:social/provider/bottom_tab_provider.dart';
import 'package:social/provider/tag_provider.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({Key? key, this.tag}) : super(key: key);

  final String? tag;
  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  int _page = 0;
  final int _limit = 10;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  List _posts = [];

  @override
  void initState() {
    super.initState();
    _firstLoad();
    _controller = ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }

  void _firstLoad() async {
    setState(() {
      _posts = [];
      _isFirstLoadRunning = true;
    });

    fetchPosts(page: _page, limit: _limit, tag: widget.tag ?? '').then((list) {
      setState(() {
        _posts = list;
        _isFirstLoadRunning = false;
      });
    }, onError: (err) {
      if (kDebugMode) {
        print('Error: $err');
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Failed to fetch posts"),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            _firstLoad();
          },
        ),
      ));
      setState(() {
        _isFirstLoadRunning = false;
      });
    });
  }

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _posts.isNotEmpty &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      _page += 1; // Increase _page by 1

      fetchPosts(page: _page, limit: _limit, tag: widget.tag ?? '').then((list) {
        if (list.isNotEmpty) {
          setState(() {
            _posts.addAll(list);
            _isLoadMoreRunning = false;
          });
        } else {
          setState(() {
            _hasNextPage = false;
            _isLoadMoreRunning = false;
          });
        }
      }, onError: (err) {
        if (kDebugMode) {
          print('Error: $err');
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Failed to fetch new posts"),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              _loadMore();
            },
          ),
        ));
        setState(() {
          _isLoadMoreRunning = false;
        });
      });
    }
  }

  late ScrollController _controller;

  Widget _buildPostListView(data) {
    if (_isFirstLoadRunning) {
      return Flexible(
        fit: FlexFit.loose,
        child: Container(
          alignment: Alignment.center,
          child: const LoadingList(
            type: LoadingSkeletonType.post,
          ),
        ),
      );
    } else {
    return Flexible(
        fit: FlexFit.loose,
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildPostView(context, index, data);
          },
        ));
    }
  }

  Widget _buildPostView(BuildContext context, int index, data) {
    return GestureDetector(
        onTap: () {},
        child: Card(
          child: _buildPostContentView(context, index, data),
          clipBehavior: Clip.hardEdge,
        ));
  }

  Widget _buildPostContentView(BuildContext context, int index, data) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage('${data[index].owner.picture}'),
            ),
            title: Text(
                '${data[index].owner.title.toString().capitalize()}. ${data[index].owner.firstName} ${data[index].owner.lastName}'),
            subtitle: Text(getTimeAgoFromDate('${data[index].publishDate}')),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FullScreenImageViewer(
                            post: data[index],
                          ),
                      fullscreenDialog: true));
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage('${data[index].image}'),
                        fit: BoxFit.cover),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        Colors.black.withAlpha(00),
                        Colors.black.withAlpha(180)
                      ])),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 16, bottom: 4),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${data[index].text}',
                                style: const TextStyle(color: Colors.white)),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: data[index]
                                        .tags
                                        .map(
                                          (chip) => GestureDetector(
                                            onTap: () {
                                              Provider.of<TagProvider>(context, listen: false).selectedTag = '$chip';
                                              Provider.of<BottomTabProvider>(context, listen: false).selectedTab = BottomTabBarItems.explore;
                                              // Navigator.push(context, MaterialPageRoute(builder: (context) => ExplorePage(tag: '$chip',)));
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
                                      Text(' ${data[index].likes}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12))
                                    ],
                                  ),
                                )
                              ],
                            )
                          ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(const Duration(milliseconds: 1), () {
          _firstLoad();
        });
      },
      child: SingleChildScrollView(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPostListView(_posts),
            if (_isLoadMoreRunning)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}