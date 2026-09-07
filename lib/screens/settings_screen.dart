import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Account Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _InfoTile(label: 'Name', value: user?.displayName?.isNotEmpty == true ? user!.displayName! : 'Recipe Lover'),
          _InfoTile(label: 'Email', value: user?.email ?? 'Unavailable'),
          _InfoTile(label: 'User ID', value: _shortId(user?.uid)),
          const SizedBox(height: 24),
          const Text('App Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const _InfoTile(label: 'App name', value: 'Recipe App'),
          const _InfoTile(label: 'Version', value: '1.0.0'),
        ],
      ),
    );
  }

  String _shortId(String? uid) {
    if (uid == null || uid.isEmpty) return 'Unavailable';
    return uid.length <= 12 ? uid : '${uid.substring(0, 12)}...';
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
    );
  }
}
