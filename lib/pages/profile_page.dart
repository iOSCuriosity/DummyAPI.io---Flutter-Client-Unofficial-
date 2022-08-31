import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:social/common/user_store.dart';
import 'package:social/common/utils.dart';
import 'package:social/models/post.dart';
import 'package:social/models/user.dart';
import 'package:social/pages/splash_page.dart';

import '../common/fullscreen_image_viewer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? usr;
  int _page = 0;
  final int _limit = 10;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  List _posts = [];
  String _totalPostsCount = '';

  @override
  void initState() {
    super.initState();
    usr = UserStore.shared.currentUser;
    if (usr != null && usr!.id != null) {
      fetchUserById(id: usr!.id!).then((userResponse) {
        if (userResponse.id != null) {
          setState(() {
            usr = userResponse;
            UserStore.shared.setCurrentUser(usr);
          });
        }
      });

      _firstLoad();

      fetchTotalPostsCountByUserId(id: usr!.id!).then((count) {
        if (count > 0) {
          setState(() {
            _totalPostsCount = count.toString();
          });
        }
      });
    }
    _controller = ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }

  void _firstLoad() async {
    if (usr == null || usr!.id == null) {
      return;
    }
    setState(() {
      _posts = [];
      _isFirstLoadRunning = true;
    });

    fetchPosts(userId: usr!.id!, page: _page, limit: _limit).then((list) {
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
    if (usr == null || usr!.id == null) {
      return;
    }

    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _posts.isNotEmpty &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      _page += 1; // Increase _page by 1

      fetchPosts(userId: usr!.id!, page: _page, limit: _limit).then((list) {
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

  Widget _buildUserDetailsView(data) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CircleAvatar(
              backgroundImage: NetworkImage('${data.picture}'),
              radius: 50,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${data.title.toString().capitalize()}. ${data.firstName} ${data.lastName}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
          ),
          Text(
            getFormattedAddressFromLocation(data.location),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
          ),
        ]);
  }

  Widget _buildChangeUserButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          onPressed: () {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                content: const Text('Are you sure you want to Log Out?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ).then((action) {
              if (action == 'OK') {
                UserStore.shared.eraseCurrentUser().then((success) {
                  if (success) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SplashPage(
                                  message: "Cleaning up...",
                                )));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Something went wrong, Please try later."),
                    ));
                  }
                });
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildUsersPostGrid(user, data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [Text('$_totalPostsCount Posts '), const Icon(Icons.grid_on)],
        ),
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
                image: NetworkImage('${data[index].image}'), 
                fit: BoxFit.cover
                ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: _controller,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildChangeUserButton(),
              _buildUserDetailsView(usr),
              _buildUsersPostGrid(usr, _posts),
              if (_isLoadMoreRunning)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
          ),
            ]),
      ),
    );
  }
}
