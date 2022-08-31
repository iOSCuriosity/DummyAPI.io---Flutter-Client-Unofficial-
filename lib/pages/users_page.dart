import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:social/common/user_store.dart';
import 'package:social/common/utils.dart';
import 'package:social/pages/home_page.dart';
import '../models/user.dart';
import '../common/loading_list.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  int _page = 0;
  final int _limit = 20;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  List _users = [];

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
      _users = [];
      _isFirstLoadRunning = true;
    });

    fetchUsers(page: _page, limit: _limit).then((list) {
      setState(() {
        _users = list;
        _isFirstLoadRunning = false;
      });
    }, onError: (err) {
      if (kDebugMode) {
        print('Error: $err');
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Failed to fetch users"),
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
        _users.isNotEmpty &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      _page += 1; // Increase _page by 1

      fetchUsers(page: _page, limit: _limit).then((list) {
        if (list.isNotEmpty) {
          setState(() {
            _users.addAll(list);
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
          content: const Text("Failed to fetch new users"),
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

  Widget getUsersListView(data) {
    if (_isFirstLoadRunning) {
      return Flexible(
        fit: FlexFit.loose,
        child: Container(
          alignment: Alignment.center,
          child: const LoadingList(
            type: LoadingSkeletonType.user,
          ),
        ),
      );
    } else {
      return Flexible(
          fit: FlexFit.loose,
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              return getUserView(context, index, data);
            },
            physics: const NeverScrollableScrollPhysics(),
          ));
    }
  }

  Widget getUserView(BuildContext context, int index, data) {
    return GestureDetector(
        onTap: () {
          UserStore.shared.setCurrentUser(data[index]);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        },
        child: Card(
          child: getUserContentView(context, index, data),
          clipBehavior: Clip.hardEdge,
        ));
  }

  Widget getUserContentView(BuildContext context, int index, data) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage('${data[index].picture}'),
            ),
            title: Text(
                '${data[index].title.toString().capitalize()}. ${data[index].firstName} ${data[index].lastName}'),
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Choose Your User',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          centerTitle: false,
          foregroundColor: Colors.black,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        backgroundColor: Colors.white.withAlpha(240),
        body: SafeArea(
          child: RefreshIndicator(
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
                  getUsersListView(_users),
                  if (_isLoadMoreRunning)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
        ));
  }
}
