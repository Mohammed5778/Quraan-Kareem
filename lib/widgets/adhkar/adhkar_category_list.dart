import 'package:flutter/material.dart';
import '../../models/adhkar.dart';
import 'adhkar_detail_screen.dart';

class AdhkarCategoryList extends StatelessWidget {
  final List<AdhkarCategory> categories;

  const AdhkarCategoryList({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          title: Text(category.name),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdhkarDetailScreen(category: category),
              ),
            );
          },
        );
      },
    );
  }
}