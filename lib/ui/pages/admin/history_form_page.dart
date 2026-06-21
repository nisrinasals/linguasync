import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/history_model.dart';
import '../../../data/models/auth_model.dart';
import '../../../data/models/language_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/language_repository.dart';
import '../../../logic/bloc/admin_history/admin_history_bloc.dart';
import '../../../logic/bloc/admin_history/admin_history_event.dart';
import '../../../logic/bloc/admin_history/admin_history_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../theme/japandi_theme.dart';

class HistoryFormPage extends StatefulWidget {
  final HistoryModel? history;

  const HistoryFormPage({super.key, this.history});

  @override
  State<HistoryFormPage> createState() => _HistoryFormPageState();
}

class _HistoryFormPageState extends State<HistoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _scoreController = TextEditingController();

  List<UserModel> _users = [];
  List<LanguageModel> _languages = [];
  
  int? _selectedUserId;
  int? _selectedLanguageId;
  
  bool _isLoadingDropdownData = true;
  String? _dropdownError;

  bool get isEdit => widget.history != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _scoreController.text = widget.history!.score.toStringAsFixed(0);
      _selectedUserId = widget.history!.userId;
      _selectedLanguageId = widget.history!.languageId;
    }
    _loadDropdownData();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    try {
      final userRepo = context.read<UserRepository>();
      final langRepo = context.read<LanguageRepository>();

      // Fetch first page of users and languages with high limits
      final usersResult = await userRepo.getUsers(page: 1, limit: 100);
      final langsResult = await langRepo.exploreLanguages(1, limit: 100);

      setState(() {
        _users = usersResult['data'] as List<UserModel>;
        _languages = langsResult['data'] as List<LanguageModel>;
        _isLoadingDropdownData = false;
      });
    } catch (e) {
      setState(() {
        _dropdownError = e.toString().replaceAll('Exception: ', '');
        _isLoadingDropdownData = false;
      });
    }
  }

  void _saveHistory() {
    if (_formKey.currentState!.validate()) {
      if (_selectedUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih siswa.'), backgroundColor: JC.error),
        );
        return;
      }
      if (_selectedLanguageId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih bahasa.'), backgroundColor: JC.error),
        );
        return;
      }

      final scoreVal = double.tryParse(_scoreController.text) ?? 0.0;

      if (isEdit) {
        context.read<AdminHistoryBloc>().add(
              UpdateAdminHistory(
                id: widget.history!.id,
                userId: _selectedUserId!,
                languageId: _selectedLanguageId!,
                score: scoreVal,
              ),
            );
      } else {
        context.read<AdminHistoryBloc>().add(
              CreateAdminHistory(
                userId: _selectedUserId!,
                languageId: _selectedLanguageId!,
                score: scoreVal,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Riwayat Kuis' : 'Tambah Riwayat Kuis'),
      ),
      body: BlocConsumer<AdminHistoryBloc, AdminHistoryState>(
        listener: (context, state) {
          if (state is AdminHistoryOperationSuccess) {
            Navigator.pop(context);
          } else if (state is AdminHistoryFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: JC.error),
            );
          }
        },
        builder: (context, state) {
          final isSaving = state is AdminHistoryLoading;

          if (_isLoadingDropdownData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_dropdownError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Gagal memuat data pilihan dropdown:\n$_dropdownError',
                        textAlign: TextAlign.center, style: JT.body),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoadingDropdownData = true;
                          _dropdownError = null;
                        });
                        _loadDropdownData();
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit ? 'Ubah Riwayat Kuis' : 'Catat Riwayat Kuis Baru',
                            style: JT.titleMd,
                          ),
                          const SizedBox(height: 20),

                          // Student Dropdown Selector
                          DropdownButtonFormField<int>(
                            value: _selectedUserId,
                            decoration: const InputDecoration(
                              labelText: 'Siswa / Pengguna',
                            ),
                            items: _users.map((user) {
                              return DropdownMenuItem<int>(
                                value: user.id,
                                child: Text('${user.name} (${user.email})'),
                              );
                            }).toList(),
                            onChanged: isEdit
                                ? null // Disable changing user in edit mode to preserve consistency
                                : (value) {
                                    setState(() {
                                      _selectedUserId = value;
                                    });
                                  },
                            validator: (value) {
                              if (value == null) {
                                return 'Pilihan siswa wajib diisi.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Language Dropdown Selector
                          DropdownButtonFormField<int>(
                            value: _selectedLanguageId,
                            decoration: const InputDecoration(
                              labelText: 'Bahasa',
                            ),
                            items: _languages.map((lang) {
                              return DropdownMenuItem<int>(
                                value: lang.id,
                                child: Text(lang.name),
                              );
                            }).toList(),
                            onChanged: isEdit
                                ? null // Disable changing language in edit mode
                                : (value) {
                                    setState(() {
                                      _selectedLanguageId = value;
                                    });
                                  },
                            validator: (value) {
                              if (value == null) {
                                return 'Pilihan bahasa wajib diisi.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Score Input Field
                          CustomTextField(
                            controller: _scoreController,
                            label: 'Skor Kuis (0 - 100)',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Skor wajib diisi.';
                              }
                              final val = double.tryParse(value);
                              if (val == null) {
                                return 'Format skor harus berupa angka.';
                              }
                              if (val < 0 || val > 100) {
                                return 'Skor harus bernilai di antara 0 dan 100.';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: isEdit ? 'Simpan Perubahan' : 'Catat Riwayat',
                    isLoading: isSaving,
                    onPressed: _saveHistory,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
