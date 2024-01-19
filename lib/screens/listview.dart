import 'package:flutter/material.dart';

class ListViewScreen extends StatelessWidget {
  const ListViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
            itemCount: 10,
            itemBuilder: (BuildContext context, int index) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  tileColor: Colors.cyan,
                  title: Text("hello"),
                  subtitle: Text("gdsc workshop"),
                ),
              );
            }),
      ),
    );
  }
}
