import 'package:flutter/material.dart';
import 'package:lovehue/models/user_information.dart';
import 'package:provider/provider.dart';

import '../providers/partners_info_state.dart';
import '../providers/user_info_state.dart';
import '../resources/copy_to_clipboard.dart';
import '../resources/unique_link_code_generator.dart';
import '../widgets/header.dart';

/// Screen with link partner form to display when no partner linked.
class LinkPartnerScreen extends StatefulWidget {
  const LinkPartnerScreen({Key? key}) : super(key: key);

  @override
  State<LinkPartnerScreen> createState() => _LinkPartnerScreenState();
}

class _LinkPartnerScreenState extends State<LinkPartnerScreen> {
  @override
  Widget build(BuildContext context) {
    TextStyle linkCodeTextStyle =
        DefaultTextStyle.of(context).style.copyWith(fontSize: 20);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Consumer2<UserInfoState, PartnersInfoState>(
              builder: (context, userInfoState, partnersInfoState, _) {
            return getLinkStatusWidget(userInfoState, partnersInfoState);
          }),
          const SizedBox(height: 64),
          Text(
            'Your link code is:',
            style: linkCodeTextStyle,
            textAlign: TextAlign.center,
          ),
          Consumer<UserInfoState>(
              builder: (BuildContext context, UserInfoState userInfoState, _) {
            String linkCodeText = userInfoState.linkCode ?? 'Loading...';
            return Row(
              children: [
                const Spacer(),
                Expanded(
                  child: SelectableText(
                    linkCodeText,
                    style:
                        linkCodeTextStyle.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => copyToClipboard(linkCodeText, context),
                    ),
                  ),
                ),
              ],
            );
          }),
        ]),
      ),
    );
  }

  // Return widget depending on the linking state.
  Widget getLinkStatusWidget(
      UserInfoState userInfoState, PartnersInfoState partnersInfoState) {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (userInfoState.userPending) {
      return const IncomingLinkRequest();
    }
    if (partnersInfoState.partnerPending) {
      return const LinkRequestSent();
    }
    if (!partnersInfoState.partnerExist) {
      return const LinkPartnerForm();
    }
    if (userInfoState.partnerLinked) {
      return const CircularProgressIndicator();
    }
    return const Center(
      child: Text("Error: You shouldn't see this message."),
    );
  }
}

/// Form displayed when unlinked, to input a link code to link to.
class LinkPartnerForm extends StatefulWidget {
  const LinkPartnerForm({Key? key}) : super(key: key);

  @override
  State<LinkPartnerForm> createState() => _LinkPartnerForm();
}

class _LinkPartnerForm extends State<LinkPartnerForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_LinkPartnerFormState');
  final _controller = TextEditingController();
  String? _errorMsg;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Header(heading: 'Enter partners link code to connect.'),
          ),
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(
                hintText: 'Link code',
                errorText: _errorMsg,
                helperText: 'Codes are case sensitive.'),
            validator: (value) => _linkCodeValidator(value,
                Provider.of<UserInfoState>(context, listen: false).linkCode),
            onEditingComplete: onLinkCodeSubmit,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton.icon(
              onPressed: onLinkCodeSubmit,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Link'),
            ),
          ),
        ],
      ),
    );
  }

  String? _linkCodeValidator(String? value, String? userLinkCode) {
    // Client side validating of link code. Further validation performed when accessing database.
    if (value == null || value.isEmpty) {
      return "Please enter a code.";
    }
    if (value.length < linkCodeLength) {
      return "Code too short. Should be $linkCodeLength characters.";
    }
    if (value.length > linkCodeLength) {
      return "Code too long. Should be $linkCodeLength characters.";
    }
    if (value == userLinkCode) {
      return "You can't be your own partner.";
    }
    return null;
  }

  void onLinkCodeSubmit() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Linking...')),
      );
      String linkCode = _controller.text;
      UserInfoState userInfoState =
          Provider.of<UserInfoState>(context, listen: false);
      UserInformation? userInfo = userInfoState.userInfo;
      if (userInfo != null) {
        await userInfoState.connectTo(linkCode).then((_) {
          setState(() {
            // Update page to reflect changes
          });
        }).catchError((error) {
          setState(() {
            _errorMsg = "Error: $error";
          });
        });
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}

/// Waiting screen when a link request is sent.
class LinkRequestSent extends StatefulWidget {
  const LinkRequestSent({Key? key}) : super(key: key);

  @override
  State<LinkRequestSent> createState() => _LinkRequestSentState();
}

class _LinkRequestSentState extends State<LinkRequestSent> {
  @override
  Widget build(BuildContext context) {
    String code =
        Provider.of<PartnersInfoState>(context, listen: false).linkCode ??
            "[Error: no partner link code]";
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: <Widget>[
            Header(heading: "Link request sent to: $code."),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async => await cancelRequest(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> cancelRequest(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cancelling...')),
    );
    UserInfoState userInfoState =
        Provider.of<UserInfoState>(context, listen: false);
    await userInfoState.unlink().catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error.')),
      );
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}

/// Accept/Reject screen when a link request is received.
class IncomingLinkRequest extends StatefulWidget {
  const IncomingLinkRequest({Key? key}) : super(key: key);

  @override
  State<IncomingLinkRequest> createState() => _IncomingLinkRequestState();
}

class _IncomingLinkRequestState extends State<IncomingLinkRequest> {
  @override
  Widget build(BuildContext context) {
    UserInfoState userInfoState =
        Provider.of<UserInfoState>(context, listen: false);
    PartnersInfoState partnersInfoState =
        Provider.of<PartnersInfoState>(context, listen: false);
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: <
        Widget>[
      const SizedBox(height: 64),
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 25),
            children: <TextSpan>[
              const TextSpan(text: 'Incoming link request from:\n\n'),
              TextSpan(
                  text: Provider.of<PartnersInfoState>(context, listen: true)
                          .linkCode ??
                      "[Error: something went wrong.]",
                  style: const TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
        OutlinedButton(
          onPressed: () async =>
              await acceptRequest(context, userInfoState, partnersInfoState),
          child: const Text('Accept'),
        ),
        OutlinedButton(
          onPressed: () async =>
              await rejectRequest(context, userInfoState, partnersInfoState),
          child: const Text('Reject'),
        )
      ]),
    ]);
  }

  Future<void> acceptRequest(BuildContext context, UserInfoState userInfoState,
      PartnersInfoState partnersInfoState) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Accepting...')),
    );
    await userInfoState.acceptRequest().catchError((error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error.')),
      );
    });
  }

  Future<void> rejectRequest(BuildContext context, UserInfoState userInfoState,
      PartnersInfoState partnersInfoState) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rejecting...')),
    );
    await userInfoState.unlink().catchError((error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error.')),
      );
    });
  }
}
