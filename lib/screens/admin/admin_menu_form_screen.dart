import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/menu_model.dart';
import '../../providers/menu_provider.dart';

class AdminMenuFormScreen extends StatefulWidget {
  const AdminMenuFormScreen({super.key});

  @override
  State<AdminMenuFormScreen> createState() => _AdminMenuFormScreenState();
}

class _AdminMenuFormScreenState extends State<AdminMenuFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _hargaController = TextEditingController();
  final _gambarUrlController = TextEditingController();
  
  String? _kategori;
  bool _statusAktif = true;
  MenuModel? _editingMenu;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is MenuModel) {
        _editingMenu = args;
        _namaController.text = _editingMenu!.nama;
        _deskripsiController.text = _editingMenu!.deskripsi;
        _hargaController.text = _editingMenu!.harga.toString();
        _gambarUrlController.text = _editingMenu!.gambarUrl;
        _kategori = _editingMenu!.kategori;
        _statusAktif = _editingMenu!.statusAktif;
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _hargaController.dispose();
    _gambarUrlController.dispose();
    super.dispose();
  }

  void _simpanMenu() async {
    if (_formKey.currentState!.validate()) {
      if (_kategori == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kategori')));
        return;
      }

      final isEdit = _editingMenu != null;
      final newMenu = MenuModel(
        id: isEdit ? _editingMenu!.id : '',
        nama: _namaController.text,
        deskripsi: _deskripsiController.text,
        harga: int.tryParse(_hargaController.text) ?? 0,
        kategori: _kategori!,
        gambarUrl: _gambarUrlController.text,
        statusAktif: _statusAktif,
      );

      final provider = context.read<MenuProvider>();
      final success = isEdit ? await provider.updateMenu(newMenu) : await provider.addMenu(newMenu);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Menu berhasil diperbarui' : 'Menu berhasil ditambahkan')));
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MenuProvider>();
    final isEdit = _editingMenu != null;
    
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        
        title: Text(isEdit ? 'Edit Menu' : 'Tambah Menu Baru', style: const TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('URL Gambar (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _gambarUrlController,
                decoration: const InputDecoration(hintText: 'https://example.com/image.jpg', prefixIcon: Icon(Icons.link)),
              ),
              const SizedBox(height: 24),
              
              const Text('Nama Menu', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(hintText: 'Misal: Pizza Margherita'),
                validator: (value) => value == null || value.isEmpty ? 'Nama menu wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              const Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _kategori,
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem(value: 'Makanan Utama', child: Text('Makanan Utama')),
                  DropdownMenuItem(value: 'Cemilan', child: Text('Cemilan')),
                  DropdownMenuItem(value: 'Minuman', child: Text('Minuman')),
                  DropdownMenuItem(value: 'Coffee', child: Text('Coffee')),
                ],
                onChanged: (value) {
                  setState(() {
                    _kategori = value;
                  });
                },
                hint: const Text('Pilih Kategori'),
              ),
              const SizedBox(height: 16),
              
              const Text('Harga (Rp)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '0'),
                validator: (value) => value == null || value.isEmpty ? 'Harga wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Deskripsi menu...'),
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Status Aktif', style: TextStyle(fontWeight: FontWeight.bold)),
                  Switch(
                    value: _statusAktif,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _statusAktif = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _simpanMenu,
                  child: provider.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                      : Text(isEdit ? 'Simpan Perubahan' : 'Simpan Menu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
