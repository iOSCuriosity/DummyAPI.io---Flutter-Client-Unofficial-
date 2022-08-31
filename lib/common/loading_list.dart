import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

enum LoadingSkeletonType { post, user }

class LoadingList extends StatefulWidget {
  const LoadingList({Key? key, this.itemCount = 3, required this.type})
      : super(key: key);

  final int itemCount;
  final LoadingSkeletonType type;
  @override
  _LoadingListState createState() => _LoadingListState();
}

class _LoadingListState extends State<LoadingList> {
  Widget getSkeleton() {
    if (widget.type == LoadingSkeletonType.post) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Container(
                  width: 40.0,
                  height: 40.0,
                  color: Colors.white,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 12.0,
                        color: Colors.white,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      Container(
                        width: 100.0,
                        height: 10.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    width: 200,
                    height: 200,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
            ),
          ],
        ),
      );
    } else if (widget.type == LoadingSkeletonType.user) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Container(
                  width: 40.0,
                  height: 40.0,
                  color: Colors.white,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 12.0,
                        color: Colors.white,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      Container(
                        width: 100.0,
                        height: 10.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 12.0,
                      color: Colors.white,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                    ),
                    Container(
                      width: 100.0,
                      height: 10.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              )
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            fit: FlexFit.loose,
            child: Shimmer.fromColors(
              baseColor: Colors.grey.withAlpha(155),
              highlightColor: Colors.grey.withAlpha(100),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.itemCount,
                itemBuilder: (_, __) => getSkeleton(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
