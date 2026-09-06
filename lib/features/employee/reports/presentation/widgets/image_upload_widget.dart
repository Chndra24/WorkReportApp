import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadWidget extends StatelessWidget {
  final File? selectedImage;
  final Function(File?) onImageSelected;

  const ImageUploadWidget({
    super.key,
    required this.selectedImage,
    required this.onImageSelected,
  });

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 70, // Kompresi gambar agar tidak terlalu berat
      maxWidth: 1000,
    );

    if (pickedFile != null) {
      onImageSelected(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "UPLOAD FOTO HASIL KERJA",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        const Text(
          "Upload Foto Hasil Kerja (Maks. 5MB)",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        
        // Upload Card
        InkWell(
          onTap: () => _showPickerOptions(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.indigo.shade200, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
              color: Colors.indigo.withOpacity(0.05),
            ),
            child: Column(
              children: [
                const Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.indigo),
                const SizedBox(height: 8),
                Text(
                  selectedImage == null ? "Pilih Foto / Upload" : "Ganti Foto",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                if (selectedImage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    selectedImage!.path.split('/').last,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Preview Area
        if (selectedImage != null) ...[
          const Text("Preview Foto Kerja:", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.file(
                  selectedImage!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                PositionBagged(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    onPressed: () => onImageSelected(null),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    style: IconButton.styleFrom(backgroundColor: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ] else
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text("Belum ada foto terpilih", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
      ],
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Helper untuk Stack position yang aman
class PositionBagged extends StatelessWidget {
  final double? right;
  final double? top;
  final Widget child;
  const PositionBagged({super.key, this.right, this.top, required this.child});
  @override
  Widget build(BuildContext context) {
    return Positioned(right: right, top: top, child: child);
  }
}
