import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:relationship_bars/models/link_code_firestore_collection_model.dart';
import 'package:relationship_bars/providers/application_state.dart';
import 'package:relationship_bars/resources/database_and_table_names.dart';
import 'package:relationship_bars/resources/unique_link_code_generator.dart';

import 'header.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 64),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Header('Enter partners link code to connect.'),
                  ),
                  TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Link code',
                      errorText: _errorMsg,
                    ),
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
                          await LinkCode.connectLinkCode(linkCode).
                          then((_) { setState(() {}); })
                              .catchError((error) {
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
                  const SizedBox(height: 64),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64),
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context)
                            .style
                            .copyWith(fontSize: 20),
                        children: <TextSpan>[
                          const TextSpan(text: 'Your link code is:\n'),
                          TextSpan(
                              text:
                                  '${ApplicationState.instance.linkCode}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
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
    if (value == ApplicationState.instance.linkCode) {
      return "You can't be your own partner.";
    }
    return null;
  }
}
