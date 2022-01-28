import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relationship_bars/models/link_code_firestore_collection_model.dart';
import 'package:relationship_bars/providers/partners_info_state.dart';
import 'package:relationship_bars/providers/user_info_state.dart';
import 'package:relationship_bars/resources/unique_link_code_generator.dart';
import 'header.dart';

class LinkPartnerScreen extends StatefulWidget {
  final PartnersInfoState partnersInfoState;
  const LinkPartnerScreen({Key? key, required this.partnersInfoState}) : super(key: key);

  @override
  State<LinkPartnerScreen> createState() => _LinkPartnerScreenState();
}

class _LinkPartnerScreenState extends State<LinkPartnerScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: SizedBox(
            width: double.infinity,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Consumer<UserInfoState>(
                  builder: (context, userInfoState, _) => getLinkStatusWidget(userInfoState, widget.partnersInfoState)),
              const SizedBox(height: 64),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 64),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style.copyWith(fontSize: 20),
                    children: <TextSpan>[
                      const TextSpan(text: 'Your link code is:\n'),
                      TextSpan(
                          text: '${UserInfoState.instance.linkCode}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ])));
  }

  getLinkStatusWidget(UserInfoState userInfoState, PartnersInfoState partnersInfoState) {
    if (userInfoState.userPending) {
      return const IncomingLinkRequest();
    }
    if (partnersInfoState.partnerPending) {
      return const LinkRequestSent();
    }
    if (!partnersInfoState.partnerExist) {
      return const LinkPartnerForm();
    }
    return const Center(
      child: Text("Error: You shouldn't see this message"),
    );
  }
}

class LinkPartnerForm extends StatefulWidget {
  const LinkPartnerForm({Key? key}) : super(key: key);

  @override
  _LinkPartnerForm createState() => _LinkPartnerForm();
}

/* TODO: FIX NEXT BUTTON GOING OFFSCREEN WHEN KEYBOARD POPS UP */
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
          const SizedBox(height: 64),
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Header(heading: 'Enter partners link code to connect.'),
          ),
          TextFormField(
            controller: _controller,
            decoration:
                InputDecoration(hintText: 'Link code', errorText: _errorMsg, helperText: 'Codes are case sensitive.'),
            validator: (value) => _linkCodeValidator(value),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Linking...')),
                  );
                  String linkCode = _controller.text;
                  await LinkCode.connectLinkCode(linkCode).then((_) {
                    setState(() {});
                  }).catchError((error) {
                    setState(() {
                      print(error);
                      _errorMsg = "Error: $error";
                    });
                  });
                }
                ScaffoldMessenger.of(context).clearSnackBars();
              },
              child: const Text('Link'),
            ),
          ),
        ],
      ),
    );
  }

  String? _linkCodeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a code.";
    }
    if (value.length < linkCodeLength) {
      return "Code too short. Should be $linkCodeLength characters.";
    }
    if (value.length > linkCodeLength) {
      return "Code too long. Should be $linkCodeLength characters.";
    }
    if (value == UserInfoState.instance.linkCode) {
      return "You can't be your own partner.";
    }
    return null;
  }
}

class LinkRequestSent extends StatelessWidget {
  const LinkRequestSent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String code = PartnersInfoState.instance.linkCode ?? "[Error: no partner link code]";
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
          ]
        )
      ),
    );
  }

  Future<void> cancelRequest(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cancelling...')),
    );
    await LinkCode.rejectLinkCode().catchError((error) {
      print(error);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}

class IncomingLinkRequest extends StatelessWidget {
  const IncomingLinkRequest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      const SizedBox(height: 64),
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 25),
            children: <TextSpan>[
              const TextSpan(text: 'Incoming link request from:\n\n'),
              TextSpan(
                  text: Provider.of<PartnersInfoState>(context, listen: true).linkCode ?? "[Error: something went wrong.]",
                  style: const TextStyle(fontWeight: FontWeight.bold)
              )
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
        OutlinedButton(
          onPressed: () async => await acceptRequest(context),
          child: const Text('Accept'),
        ),
        OutlinedButton(
          onPressed: () async => await rejectRequest(context),
          child: const Text('Reject'),
        )
      ]),
    ]);
  }

  Future<void> acceptRequest(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Accepting...')),
    );
    await LinkCode.acceptLinkCode().catchError((error) {
      print(error);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  Future<void> rejectRequest(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rejecting...')),
    );
    await LinkCode.rejectLinkCode().catchError((error) {
      print(error);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}
