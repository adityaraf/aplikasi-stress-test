import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stress_test_app/main.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String gender;
  final int age;
  final List<String> healthConditions;

  const EditProfilePage({
    super.key,
    required this.name,
    required this.gender,
    required this.age,
    required this.healthConditions,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  late String _gender;
  late List<String> _healthConditions;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];
  final List<String> _healthConditionOptions = [
    'Depresi',
    'Gangguan Kecemasan',
    'Gangguan Tidur',
    'Gangguan Makan',
    'Tidak Ada'
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _ageController.text = widget.age.toString();
    _gender = widget.gender;
    _healthConditions = List<String>.from(widget.healthConditions);
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser!.id;

      await supabase.from('profiles').update({
        'name': _nameController.text.trim(),
        'gender': _gender,
        'age': int.parse(_ageController.text.trim()),
        'health_conditions': _healthConditions,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      if (mounted) {
        context.showSnackBar('Profil berhasil diperbarui');
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Gagal memperbarui profil', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Jenis Kelamin',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
                  value: _gender,
                  items: _genderOptions.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _gender = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Umur',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Umur tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Umur harus berupa angka';
                    }
                    if (int.parse(value) < 1 || int.parse(value) > 120) {
                      return 'Umur tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Kondisi Kesehatan:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                // Tampilan kondisi kesehatan yang lebih baik dengan ListView
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _healthConditionOptions.length,
                  itemBuilder: (context, index) {
                    final condition = _healthConditionOptions[index];
                    return CheckboxListTile(
                      title: Text(condition),
                      value: _healthConditions.contains(condition),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            if (condition == 'Tidak Ada') {
                              _healthConditions.clear();
                              _healthConditions.add('Tidak Ada');
                            } else {
                              _healthConditions.remove('Tidak Ada');
                              if (!_healthConditions.contains(condition)) {
                                _healthConditions.add(condition);
                              }
                            }
                          } else {
                            _healthConditions.remove(condition);
                            if (_healthConditions.isEmpty) {
                              _healthConditions.add('Tidak Ada');
                            }
                          }
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Simpan Perubahan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
