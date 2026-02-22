import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class AvatarUploadField extends StatelessWidget {
  const AvatarUploadField({
    super.key,
    required this.onImageSelected,
    this.imagePath,
    this.imageUrl,
    this.enabled = true,
    this.radius = 48,
    this.label = 'Ajouter une photo de profil',
  });

  final String? imagePath;
  final String? imageUrl;
  final bool enabled;
  final double radius;
  final String label;
  final ValueChanged<String?> onImageSelected;

  Future<void> _openPicker(BuildContext context) async {
    final action = await showModalBottomSheet<_AvatarSourceAction>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.of(context).pop(_AvatarSourceAction.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.of(context).pop(_AvatarSourceAction.camera);
                },
              ),
            ],
          ),
        );
      },
    );

    if (action == null) return;

    final source = action == _AvatarSourceAction.camera
        ? ImageSource.camera
        : ImageSource.gallery;

    final picker = ImagePicker();
    try {
      final file = await picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1400,
      );

      if (file != null) {
        onImageSelected(file.path);
      }
    } on PlatformException catch (e) {
      if (!context.mounted) return;
      final message =
          e.message ?? 'Accès refusé ou fonctionnalité non disponible.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'ouvrir le sélecteur: $message')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'ouverture de la photo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocalImage = imagePath != null && imagePath!.trim().isNotEmpty;
    final hasRemoteImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    ImageProvider? imageProvider;
    if (hasLocalImage) {
      imageProvider = FileImage(File(imagePath!));
    } else if (hasRemoteImage) {
      imageProvider = NetworkImage(imageUrl!);
    }

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(radius + 8),
          onTap: enabled ? () => _openPicker(context) : null,
          child: Stack(
            children: [
              CircleAvatar(
                radius: radius,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.1),
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? Icon(
                        Icons.person,
                        size: radius,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: enabled ? () => _openPicker(context) : null,
          icon: const Icon(Icons.upload_outlined, size: 18),
          label: Text(label),
        ),
      ],
    );
  }
}

enum _AvatarSourceAction { gallery, camera }
