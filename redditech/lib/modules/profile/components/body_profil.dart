import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';

import 'package:redditech/constants/app_theme.dart';
import 'package:redditech/models/reddit_post.dart';
import 'package:redditech/services/api/reddit_api.dart';
import 'package:redditech/services/bloc/localization/localization_bloc.dart';
import 'package:redditech/utils/error_catch.dart';

class BodyProfile extends StatefulWidget {
  const BodyProfile({Key? key}) : super(key: key);

  @override
  State<BodyProfile> createState() => _BodyProfileState();
}

class _BodyProfileState extends State<BodyProfile> {
  int _tabController = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _tabController == 0
                          ? Colors.grey.shade300
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      fixedSize: const Size(double.infinity, 60),
                    ),
                    onPressed: () {
                      setState(() {
                        _tabController = 0;
                      });
                    },
                    child: Text(
                      'posts'.i18n(),
                      style: TextStyle(
                          color: _tabController == 0
                              ? AppTheme.primary
                              : AppTheme.textColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _tabController == 1
                          ? Colors.grey.shade300
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      fixedSize: const Size(double.infinity, 60),
                    ),
                    onPressed: () {
                      setState(() {
                        _tabController = 1;
                      });
                    },
                    child: Text(
                      'settings'.i18n(),
                      style: TextStyle(
                          color: _tabController == 1
                              ? AppTheme.primary
                              : AppTheme.textColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        IndexedStack(
          index: _tabController,
          children: const [
            ListUserPost(),
            Settings(),
          ],
        ),
      ],
    );
  }
}

class ListUserPost extends StatelessWidget {
  const ListUserPost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: RedditAPI.fetchUserPostSubmitted(),
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.secondary,
                  ),
                ),
              );
            default:
              if (snapshot.hasError) {
                ErrorCatch.catchError(snapshot, context);
                return const SizedBox.shrink();
              }

              if (snapshot.data!.isEmpty) {
                return SizedBox(
                  height: 300,
                  child: Center(
                    child: Text(
                      'no-posts-found'.i18n(),
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true, // to limit height
                primary: false, // to disable the scroll
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return RedditPost(
                    subreddit: snapshot.data![index]["subreddit"],
                    author: snapshot.data![index]["author"],
                    title: snapshot.data![index]["title"],
                    media: snapshot.data![index]["media"],
                    thumbnail: snapshot.data![index]["thumbnail"],
                    score: snapshot.data![index]["score"],
                    numComments: snapshot.data![index]["numComments"],
                    createdUtc: snapshot.data![index]["createdUtc"],
                  );
                },
              );
          }
        });
  }
}

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late String _lang;
  late bool _over18;
  late bool _allowClicktracking;
  late bool _showLocationBasedRecommendations;

  late bool _isUpdating;

  @override
  void initState() {
    super.initState();
    _isUpdating = false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: RedditAPI.fetchUserPreferences(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.secondary,
                  ),
                ),
              );
            default:
              if (snapshot.hasError) {
                ErrorCatch.catchError(snapshot, context);
                return const SizedBox.shrink();
              }

              if (!_isUpdating) {
                (snapshot.data!['lang'] == 'en-US')
                    ? _lang = 'en'
                    : _lang = snapshot.data!['lang'];
                _over18 = snapshot.data!['over_18'];
                _allowClicktracking = snapshot.data!['allow_clicktracking'];
                _showLocationBasedRecommendations =
                    snapshot.data!['show_location_based_recommendations'];
              }

              return BlocBuilder<LocalizationBloc, LocalizationState>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Center(
                      child: SizedBox(
                        width: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 270,
                              child: DropdownButtonFormField(
                                value: _lang,
                                items: [
                                  DropdownMenuItem(
                                    value: 'en',
                                    child: Text('english'.i18n()),
                                  ),
                                  DropdownMenuItem(
                                    value: 'fr',
                                    child: Text('french'.i18n()),
                                  ),
                                ],
                                onChanged: (value) {
                                  RedditAPI.updateRedditPreferences(
                                      {'lang': value}).then((future) {
                                    if (value != _lang && value == 'en') {
                                      BlocProvider.of<LocalizationBloc>(context)
                                          .add(const LocalizationChangedEvent(
                                              locale: Locale('en', 'US')));
                                    }
                                    if (value != _lang && value == 'fr') {
                                      BlocProvider.of<LocalizationBloc>(context)
                                          .add(const LocalizationChangedEvent(
                                              locale: Locale('fr', 'FR')));
                                    }
                                  });
                                },
                              ),
                            ),
                            SwitchListTile(
                              title: Text('over-18'.i18n()),
                              activeColor: AppTheme.secondary,
                              value: _over18,
                              onChanged: (value) {
                                RedditAPI.updateRedditPreferences(
                                    {'over_18': value}).then((future) {
                                  setState(() {
                                    _over18 = value;
                                  });
                                });
                              },
                            ),
                            SwitchListTile(
                              title: Text('allow-clicktracking'.i18n()),
                              activeColor: AppTheme.secondary,
                              value: _allowClicktracking,
                              onChanged: (value) {
                                RedditAPI.updateRedditPreferences(
                                        {'allow_clicktracking': value})
                                    .then((future) {
                                  setState(() {
                                    _allowClicktracking = value;
                                  });
                                });
                              },
                            ),
                            SwitchListTile(
                              title: Text(
                                  'show-location-based-recommendations'.i18n()),
                              activeColor: AppTheme.secondary,
                              value: _showLocationBasedRecommendations,
                              onChanged: (value) {
                                RedditAPI.updateRedditPreferences({
                                  'show_location_based_recommendations': value
                                }).then((future) {
                                  setState(() {
                                    _showLocationBasedRecommendations = value;
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
          }
        });
  }
}
