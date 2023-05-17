import 'package:flutter/material.dart';

import 'package:redditech/modules/profile/components/body_profil.dart';
import 'package:redditech/modules/profile/components/header_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: const [
          HeaderProfile(),
          BodyProfile(),
        ],
      ),
    );
  }
}
