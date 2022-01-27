import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relationship_bars/database/local_database_handler.dart';
import 'package:relationship_bars/database/secure_storage_handler.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';
import 'package:relationship_bars/main.dart';
import 'package:relationship_bars/providers/application_state.dart';
import 'package:relationship_bars/providers/partners_info_state.dart';
import 'package:relationship_bars/resources/database_and_table_names.dart';
import 'package:relationship_bars/widgets/bar_builders.dart';
import 'package:relationship_bars/widgets/link_partner_form.dart';
import 'package:sqflite/sqflite.dart';

class PartnersBars extends StatefulWidget {
  const PartnersBars({Key? key}) : super(key: key);

  @override
  _PartnersBarsState createState() => _PartnersBarsState();
}

class _PartnersBarsState extends State<PartnersBars> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PartnersInfoState>(
        builder: (context, partnersInfoState, _) {
      String title = partnersInfoState.partnersInfo?.displayName ?? "Partner";
      return Scaffold(
        appBar: AppBar(
          title: Text('$title\'s Bars'),
        ),
        body: (partnersInfoState.partnersID != null)
            ? barStreamBuilder(
                partnersInfoState.partnersID!, nonInteractableBarBuilder)
            : const LinkPartnerForm(),
      );
    });
  }
}
