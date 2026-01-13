import 'package:denz_sen/core/theme/app_style.dart';
import 'package:flutter/material.dart';

class EditInformationPage extends StatelessWidget {
  const EditInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Edit Information', style: AppStyle.semiBook20),centerTitle: false,
      ),
      body: const Center(
        child: Text('Edit Information Page Content'),
      ),
    );
  }
}