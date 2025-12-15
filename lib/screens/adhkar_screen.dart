import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../models/adhkar.dart';
import '../widgets/adhkar/adhkar_category_list.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  Future<List<AdhkarCategory>?>? _adhkarFuture;

  @override
  void initState() {
    super.initState();
    _adhkarFuture = ApiService().fetchAdhkar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adhkar'),
      ),
      body: FutureBuilder<List<AdhkarCategory>?>(
        future: _adhkarFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Could not load adhkar.'));
          }
          return AdhkarCategoryList(categories: snapshot.data!);
        },
      ),
    );
  }
}