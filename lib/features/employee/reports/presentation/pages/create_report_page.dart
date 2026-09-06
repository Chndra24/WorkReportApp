import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../widgets/image_upload_widget.dart';
import '../providers/report_provider.dart';

class CreateReportPage extends ConsumerStatefulWidget {
  const CreateReportPage({super.key});

  @override
  ConsumerState<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends ConsumerState<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Silakan unggah foto hasil kerja terlebih dahulu")),
        );
        return;
      }

      ref.read(reportProvider.notifier).submitReport(
            date: _selectedDate,
            title: _titleController.text.trim(),
            location: _locationController.text.trim(),
            description: _descriptionController.text.trim(),
            imageFile: _selectedImage!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportProvider);

    // Menangani feedback sukses/error
    ref.listen(reportProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Laporan berhasil dikirim ke Admin!")),
        );
        // Reset form
        _titleController.clear();
        _locationController.clear();
        _descriptionController.clear();
        setState(() => _selectedImage = null);
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${next.error}")),
        );
      }
    });

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "INPUT LAPORAN PEKERJAAN HASIL KERJA",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                
                // Tanggal
                TextFormField(
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: InputDecoration(
                    labelText: "Tanggal Pekerjaan",
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  controller: TextEditingController(
                    text: DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
                  ),
                ),
                const SizedBox(height: 16),

                // Judul
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Judul Pekerjaan",
                    hintText: "Masukkan judul pekerjaan",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? "Judul wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                // Lokasi
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: "Lokasi",
                    hintText: "Masukkan lokasi kerja",
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? "Lokasi wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                // Deskripsi
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Deskripsi Kerja",
                    hintText: "Jelaskan rincian pekerjaan yang dilakukan...",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? "Deskripsi wajib diisi" : null,
                ),
                const SizedBox(height: 24),

                // Upload Widget
                ImageUploadWidget(
                  selectedImage: _selectedImage,
                  onImageSelected: (file) => setState(() => _selectedImage = file),
                ),
                
                const SizedBox(height: 32),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: reportState.isLoading ? null : _submit,
                    icon: const Icon(Icons.send),
                    label: const Text("KIRIM LAPORAN KE ADMIN", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        
        // Loading Overlay
        if (reportState.isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Sedang mengunggah laporan...", style: TextStyle(fontWeight: FontWeight.w500)),
                      Text("Harap tunggu sebentar", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
