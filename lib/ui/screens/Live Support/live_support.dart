import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tawkto/flutter_tawk.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/extensions.dart';

void main() => runApp(const LiveSupport());

class LiveSupport extends StatefulWidget {
  const LiveSupport({Key? key}) : super(key: key);

  @override
  State<LiveSupport> createState() => _LiveSupportState();
}

class _LiveSupportState extends State<LiveSupport> {
  late String _userName = context.tr('guest')!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          "Live Support",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeights.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: BlocBuilder<UserDetailsCubit, UserDetailsState>(
        bloc: context.read<UserDetailsCubit>(),
        builder: (context, state) {
          if (state is UserDetailsFetchSuccess) {
            final desc = context.read<AuthCubit>().getAuthProvider() ==
                    AuthProviders.mobile
                ? state.userProfile.mobileNumber!
                : state.userProfile.email!;
            return Tawk(
                directChatLink:
                    'https://tawk.to/chat/6659745e981b6c564776ad50/1hv6mt53e',
                visitor: TawkVisitor(
                  name: state.userProfile.name,
                  email: state.userProfile.email,
                ),
                onLoad: () {
                  print('Hello Tawk!');
                },
                onLinkTap: (String url) {
                  print(url);
                },
                placeholder: Center(child: CircularProgressContainer()));
          }
          return Tawk(
              directChatLink:
                  'https://tawk.to/chat/6659745e981b6c564776ad50/1hv6mt53e',
              visitor: TawkVisitor(
                name: 'Guest',
                email: 'guest@gmail.com',
              ),
              onLoad: () {
                print('Hello Tawk!');
              },
              onLinkTap: (String url) {
                print(url);
              },
              placeholder: Center(child: CircularProgressContainer()));
          ;
        },
      ),
    );
  }
}
