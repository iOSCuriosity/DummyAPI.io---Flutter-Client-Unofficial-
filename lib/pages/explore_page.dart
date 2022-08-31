import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/common/user_store.dart';
import 'package:social/models/post.dart';
import 'package:social/models/tag.dart';
import 'package:social/provider/tag_provider.dart';

import '../common/fullscreen_image_viewer.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  int _page = 0;
  final int _limit = 20;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  List _posts = [];
  List _tags = [];
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _loadTags();
    _firstLoad();
    _controller = ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }

  void _onTagChange() {
    if (mounted) {
      _selectedTag = context.read<TagProvider>().selectedTag;
      if (kDebugMode) {
        print('_onTagChange: $_selectedTag');
      }
      _firstLoad();
    }
  }

  void _firstLoad() async {
    _page = 0;
    _hasNextPage = true;
    _isLoadMoreRunning = false;
    setState(() {
      _posts = [];
      _isFirstLoadRunning = true;
    });

    fetchPosts(page: _page, limit: _limit, tag: _selectedTag ?? '', fromExplore: true).then(
        (list) {
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

      fetchPosts(page: _page, limit: _limit, tag: _selectedTag ?? '', fromExplore: true).then(
          (list) {
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

  void _loadTags() async {
    setState(() {
      _tags = UserStore.shared.tags;
    });

    if (_tags.isEmpty) {
      fetchTags().then((list) {
        UserStore.shared.tags = list;
        _loadTags();
      }, onError: (err) {
        if (kDebugMode) {
          print('Error: $err');
        }
      });
    }
  }

  Widget _buildUsersPostGrid(data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
            fit: FlexFit.loose,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2),
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildPostView(context, index, data);
              },
            )),
            if (!_isFirstLoadRunning && _posts.isEmpty && (_selectedTag?.isNotEmpty ?? false))
              Center(child: Text("No Posts found for '$_selectedTag'", style: TextStyle(color: Colors.grey.shade600),),)
      ],
    );
  }

  Widget _buildPostView(BuildContext context, int index, data) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FullScreenImageViewer(
                            post: data[index],
                          ),
                      fullscreenDialog: true));
        },
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.width * 0.3,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            image: DecorationImage(
                image: NetworkImage('${data[index].image}'), fit: BoxFit.cover),
          ),
        ));
  }

  Widget _buildTagListView(data) {
    return SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildTagView(context, index, data);
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(
            width: 4,
          );
        },
      ),
    );
  }

  Widget _buildTagView(BuildContext context, int index, data) {
    return ChoiceChip(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      label: Text(
        '${data[index]}', 
        style: TextStyle(
          color: (_selectedTag == '${data[index]}') ? Colors.white : Colors.black),),
      selectedColor: Colors.black,
      selected: _selectedTag == '${data[index]}',
      onSelected: (bool selected) {
        if (_selectedTag != '${data[index]}') {
          Provider.of<TagProvider>(context, listen: false).selectedTag = '${data[index]}';
          // setState(() {
          //   _selectedTag = '${data[index]}';
          //   _firstLoad();
          // });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('explore_page: build');
    }
    context.watch<TagProvider>().removeListener(_onTagChange);
    context.watch<TagProvider>().addListener(_onTagChange);

    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(const Duration(milliseconds: 1), () {
          _loadTags();
        });
      },
      child: SingleChildScrollView(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTagListView(_tags),
            _buildUsersPostGrid(_posts),
            if (_isLoadMoreRunning || _isFirstLoadRunning)
              const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
