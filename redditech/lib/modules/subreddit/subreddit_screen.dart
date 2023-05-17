import 'package:flutter/material.dart';
import 'package:redditech/modules/subreddit/components/body_subreddit.dart';
import 'package:redditech/modules/subreddit/components/header_subreddit.dart';

class SubredditScreen extends StatelessWidget {
  const SubredditScreen({Key? key, this.subredditName}) : super(key: key);

  final String? subredditName;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          HeaderSubreddit(subredditName: subredditName),
          BodySubreddit(
            subredditName: subredditName,
          ),
        ],
      ),
    );
  }
}
