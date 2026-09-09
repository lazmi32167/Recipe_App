import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/account_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final accountService = AccountService();
  bool isLoading = false;
  final imagePicker = ImagePicker();
  Uint8List? selectedImageBytes;
  bool isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('Please enter your full name.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await accountService.updateProfileName(name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      _showMessage(error.message ?? 'Unable to update your profile.');
    } catch (_) {
      _showMessage('Unable to update your profile. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> pickProfileImage() async {
    try {
      final image = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (image == null) return;
      final bytes = await image.readAsBytes();
      setState(() {
        selectedImageBytes = bytes;
        isUploadingImage = true;
      });
      await accountService.uploadProfileImage(bytes);
      _showMessage('Profile image updated.');
    } on FirebaseException catch (error) {
      debugPrint(
        'PROFILE IMAGE FIREBASE ERROR: code=${error.code}, message=${error.message}',
      );
      _showMessage('Profile image upload failed: ${error.code}. Your profile was kept.');
    } catch (error) {
      debugPrint('Profile image upload error: $error');
      _showMessage('Profile image upload failed. Your profile was kept.');
    } finally {
      if (mounted) setState(() => isUploadingImage = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          GestureDetector(
            onTap: isUploadingImage ? null : pickProfileImage,
            child: CircleAvatar(
              radius: 42,
              backgroundImage: selectedImageBytes == null
                  ? (FirebaseAuth.instance.currentUser?.photoURL != null
                      ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                      : null)
                  : MemoryImage(selectedImageBytes!),
              child: isUploadingImage
                  ? const CircularProgressIndicator()
                  : (selectedImageBytes == null &&
                          FirebaseAuth.instance.currentUser?.photoURL == null
                      ? Icon(Icons.person_outline, size: 52, color: Theme.of(context).colorScheme.primary)
                      : null),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            FirebaseAuth.instance.currentUser?.email ?? '',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: isLoading ? null : saveProfile,
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}
