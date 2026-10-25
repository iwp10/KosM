import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

/// Standard placeholder page displaying an [EmptyState] for uncompleted features.
class PlaceholderPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(icon: icon, title: title, description: description),
    );
  }
}
