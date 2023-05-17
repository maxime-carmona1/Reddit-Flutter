import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_modular/flutter_modular.dart';
import 'package:redditech/constants/reddit_info.dart';
import 'package:redditech/models/subreddit_suggestion.dart';
import 'package:redditech/utils/format_date.dart';
import 'package:redditech/services/repositories/user_repository.dart';
import 'package:redditech/utils/format_number.dart';

abstract class RedditAPI {
  static Future<Map<String, dynamic>> fetchRedditUserInfo() async {
    final token = await Modular.get<UserRepository>().getToken();
    final url = Uri.parse('https://oauth.reddit.com/api/v1/me');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.userAgentHeader: RedditInfo.userAgent,
    };

    http.Response response = await http.get(
      url,
      headers: headers,
    );
    checkResponseStatusCode(response);

    final jsonBody = jsonDecode(response.body);
    Map<String, dynamic> res = {
      'username': jsonBody['name'],
      'description': jsonBody['subreddit']['public_description'],
      'avatarUrl': jsonBody['snoovatar_img'],
      "subscribers": jsonBody['subreddit']['subscribers'],
      'totalKarma': jsonBody['total_karma'],
      'preferences': jsonBody['pref'],
      'friends': jsonBody['subreddit_friends'],
    };
    return res;
  }

  static Future<List<Map<String, dynamic>>> fetchUserPostSubmitted(
      {username}) async {
    final token = await Modular.get<UserRepository>().getToken();
    username ??= await Modular.get<UserRepository>().getUsername();
    final url =
        Uri.parse('https://oauth.reddit.com/user/$username/submitted?limit=25');
    final headers = {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.userAgentHeader: RedditInfo.userAgent,
    };

    http.Response response = await http.get(
      url,
      headers: headers,
    );
    checkResponseStatusCode(response);

    final jsonBody = jsonDecode(response.body);
    final List<Map<String, dynamic>> posts = [];
    final data = jsonBody['data']['children'];
    for (var i = 0; i < jsonBody['data']['dist']; i++) {
      var date = FormatDate.toDateTime(data[i]['data']['created_utc']);
      var media = getMedia(data[i]);
      Map<String, dynamic> post = {
        'subreddit': data[i]['data']['subreddit_name_prefixed'],
        'author': 'u/${data[i]['data']['author']}',
        'title': data[i]['data']['title'],
        'thumbnail': data[i]['data']['thumbnail'],
        'media': media,
        'score': FormatNumber.formatNumber(data[i]['data']['score']),
        'numComments':
            FormatNumber.formatNumber(data[i]['data']['num_comments']),
        'createdUtc': date,
      };
      posts.add(post);
    }

    return posts;
  }

  static Future<Map<String, dynamic>> fetchUserPreferences() async {
    final token = await Modular.get<UserRepository>().getToken();
    final url = Uri.parse('https://oauth.reddit.com/api/v1/me/prefs');
    final headers = {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.userAgentHeader: RedditInfo.userAgent,
    };

    http.Response response = await http.get(
      url,
      headers: headers,
    );
    checkResponseStatusCode(response);

    final jsonBody = jsonDecode(response.body);
    Map<String, dynamic> res = {
      'lang': jsonBody['lang'],
      'over_18': jsonBody['over_18'],
      'allow_clicktracking': jsonBody['allow_clicktracking'],
      'show_location_based_recommendations':
          jsonBody['show_location_based_recommendations'],
    };

    return res;
  }

  static Future<bool> updateRedditPreferences(
      Map<String, dynamic> prefs) async {
    final token = await Modular.get<UserRepository>().getToken();
    final url = Uri.parse('https://oauth.reddit.com/api/v1/me/prefs');
    final headers = {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.userAgentHeader: RedditInfo.userAgent,
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    http.Response response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode(prefs),
    );
    checkResponseStatusCode(response);

    return true;
  }

  static Future<List<Map<String, dynamic>>> fetchPostsSubreddit(
      {required String type, String? subreddit}) async {
    final token = await Modular.get<UserRepository>().getToken();
    Uri url;
    if (subreddit != null) {
      url = Uri.parse('https://oauth.reddit.com/r/$subreddit/$type?limit=25');
    } else {
      url = Uri.parse('https://oauth.reddit.com/$type?limit=25');
    }
    final headers = {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.userAgentHeader: RedditInfo.userAgent,
    };
    http.Response response = await http.get(
      url,
      headers: headers,
    );
    checkResponseStatusCode(response);

    final jsonBody = jsonDecode(response.body);
    final List<Map<String, dynamic>> posts = [];
    var data = jsonBody['data']['children'];
    for (var i = 0; i < jsonBody['data']['dist']; i++) {
      var date = FormatDate.toDateTime(data[i]['data']['created_utc']);
      var media = getMedia(data[i]);

      Map<String, dynamic> post = {
        'subreddit': data[i]['data']['subreddit_name_prefixed'],
        'author': 'u/${data[i]['data']['author']}',
        'title': data[i]['data']['title'],
        'thumbnail': data[i]['data']['thumbnail'],
        'media': media,
        'score': FormatNumber.formatNumber(data[i]['data']['score']),
        'numComments':
            FormatNumber.formatNumber(data[i]['data']['num_comments']),
        'createdUtc': date,
      };
      posts.add(post);
    }
    return posts;
  }

  static Future<Map<String, dynamic>> fetchInfoSubreddit(
      {required String subredditName}) async {
    final token = await Modular.get<UserRepository>().getToken();
    final url = Uri.parse('https://oauth.reddit.com/r/$subredditName/about');
    final headers = {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.userAgentHeader: RedditInfo.userAgent,
    };

    http.Response response = await http.get(
      url,
      headers: headers,
    );
    checkResponseStatusCode(response);

    final jsonBody = jsonDecode(response.body);
    String dataIcon;
    if (jsonBody['data']['icon_img'] == '') {
      dataIcon = 'community_icon';
    } else {
      dataIcon = 'icon_img';
    }
    Map<String, dynamic> res = {
      'display_name_prefixed': jsonBody['data']['display_name_prefixed'],
      'subscribers': FormatNumber.formatNumber(jsonBody['data']['subscribers']),
      'public_description': jsonBody['data']['public_description'],
      'created_utc': FormatDate.exactDate(jsonBody['data']['created_utc']),
      'user_is_subscriber': jsonBody['data']['user_is_subscriber'],
      'icon_img': jsonBody['data'][dataIcon].replaceAll('amp;', ''),
      'banner_background_image':
          jsonBody['data']['banner_background_image'].replaceAll('amp;', ''),
    };
    return res;
  }

  static Future<bool> changeSubbed(bool userIsSubscriber, String name) async {
    final token = await Modular.get<UserRepository>().getToken();
    final url = Uri.parse('https://oauth.reddit.com/api/subscribe');
    String sub = userIsSubscriber ? 'unsub' : 'sub';
    final headers = {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.userAgentHeader: RedditInfo.userAgent,
    };
    final body = {
      'action': sub,
      'sr_name': name,
    };

    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    checkResponseStatusCode(response);

    return !userIsSubscriber;
  }

  static Future<List<SubredditSuggestion>> fetchSubredditSuggestions(
      String subreddit) async {
    final token = await Modular.get<UserRepository>().getToken();
    final url = Uri.parse(
        'https://oauth.reddit.com/api/subreddit_autocomplete?query=$subreddit');
    final headers = {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.userAgentHeader: RedditInfo.userAgent,
    };
    http.Response response = await http.get(
      url,
      headers: headers,
    );
    checkResponseStatusCode(response);

    final subreddits = jsonDecode(response.body);
    final listResult = List<SubredditSuggestion>.from(
        subreddits["subreddits"].map((subreddit) {
      return SubredditSuggestion.fromJson(subreddit);
    }).toList());

    return listResult;
  }
}

Map<String, dynamic> getMedia(Map<String, dynamic> data) {
  var media = <String, dynamic>{};
  if (data['data']['secure_media'] != null &&
      data['data']['secure_media']['reddit_video'] != null) {
    media = {
      'type': 'video',
      'body': data['data']['secure_media']['reddit_video']['fallback_url']
          .replaceAll('amp;', '')
    };
  } else if (data['data']['preview'] != null &&
      data['data']['selftext'] == '') {
    media = {
      'type': 'image',
      'body': data['data']['preview']['images'][0]['source']['url']
          .replaceAll('amp;', '')
    };
  } else {
    media = {'type': 'text', 'body': data['data']['selftext']};
  }

  return media;
}

void checkResponseStatusCode(http.Response response) {
  if (response.statusCode == 401) {
    throw Exception('Unauthorized - Invalid token');
  } else if (response.statusCode != 200) {
    throw Exception('Failed to load information');
  }
}
