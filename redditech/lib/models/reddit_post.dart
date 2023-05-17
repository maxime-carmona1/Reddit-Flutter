import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:redditech/constants/app_path.dart';
import 'package:redditech/constants/app_theme.dart';
import 'package:redditech/constants/reddit_info.dart';
import 'package:redditech/models/video_widget.dart';

class RedditPost extends StatelessWidget {
  const RedditPost(
      {Key? key,
      required this.subreddit,
      required this.author,
      required this.title,
      required this.media,
      required this.thumbnail,
      required this.score,
      required this.numComments,
      required this.createdUtc})
      : super(key: key);

  final String subreddit;
  final String author;
  final String title;
  final Map<String, dynamic> media;
  final String thumbnail;
  final String score;
  final String numComments;
  final String createdUtc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            AppTheme.boxShadow,
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: CachedNetworkImage(
                  imageUrl: thumbnail,
                  errorWidget: (context, error, stackTrace) =>
                      CachedNetworkImage(
                          imageUrl: RedditInfo.urlRedditCharacter),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header(
                      subreddit: subreddit,
                      author: author,
                      title: title,
                      createdUtc: createdUtc,
                    ),
                    const SizedBox(height: 8),
                    Body(media: media),
                    const SizedBox(height: 8),
                    Footer(score: score, numComments: numComments),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({
    Key? key,
    required this.subreddit,
    required this.author,
    required this.title,
    required this.createdUtc,
  }) : super(key: key);

  final String subreddit;
  final String author;
  final String title;
  final String createdUtc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            var name = subreddit.split('/');
            if (name[0] == 'r') {
              Modular.to.pushNamed('${AppPath.subredditScreenPath}/${name[1]}');
            }
          },
          child: Text(
            subreddit,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          'posted-by-ago'.i18n([author, createdUtc]),
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class Body extends StatelessWidget {
  const Body({Key? key, required this.media}) : super(key: key);

  final Map<String, dynamic> media;

  @override
  Widget build(BuildContext context) {
    switch (media['type']) {
      case 'image':
        return ClipRect(
          child: CachedNetworkImage(
            imageUrl: media['body'],
            fit: BoxFit.cover,
            width: double.infinity,
            errorWidget: (context, error, stackTrace) => const SizedBox(),
          ),
        );
      case 'video':
        return VideoWidget(url: media['body']);
      default:
        return SelfText(body: media['body']);
    }
  }
}

class Footer extends StatelessWidget {
  const Footer({Key? key, required this.score, required this.numComments})
      : super(key: key);

  final String score;
  final String numComments;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.thumb_up,
          size: 13,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 5),
        Text(
          score,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 10),
        Icon(
          Icons.comment,
          size: 13,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 5),
        Text(
          '$numComments ${'comments'.i18n()}${numComments.length == 1 && (numComments[0] == '1' || numComments[0] == '0') ? '' : 's'}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class SelfText extends StatefulWidget {
  const SelfText({Key? key, required this.body}) : super(key: key);

  final String body;

  @override
  State<SelfText> createState() => _SelfTextState();
}

class _SelfTextState extends State<SelfText> {
  bool _isExpanded = false;
  List<String> _textList = [];
  List<Widget> _widgetList = [];

  @override
  void initState() {
    super.initState();
    _textList = splitSelfTextByUrl(widget.body);
    _widgetList = _textList.map((text) {
      if (text.startsWith('https://preview.redd.it/')) {
        return ClipRect(
          child: CachedNetworkImage(
            imageUrl: text,
            fit: BoxFit.cover,
            height: 200,
            width: double.infinity,
            errorWidget: (context, error, stackTrace) => const SizedBox(),
          ),
        );
      } else {
        return Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textColor,
          ),
        );
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              _widgetList.length > 3 && !_isExpanded ? 3 : _widgetList.length,
          itemBuilder: (context, index) {
            return _widgetList[index];
          },
        ),
        if (_widgetList.length > 3) const SizedBox(height: 8),
        if (_widgetList.length > 3)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'show-less'.i18n() : 'show-more'.i18n(),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

List<String> splitSelfTextByUrl(String text) {
  var textList = text.replaceAll('amp;', '').split('\n');
  final regExp = RegExp(
    r'((http|https):\/\/)?[a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)',
    caseSensitive: false,
    multiLine: false,
  );

  var list = <String>[];
  for (var i = 0; i < textList.length; i++) {
    if (textList[i].contains('https://preview.redd.it/')) {
      RegExpMatch? match = regExp.firstMatch(textList[i]);
      list.add(match?.group(0) ?? '');
    } else {
      list.add(textList[i]);
    }
  }
  return list;
}
