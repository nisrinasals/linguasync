import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/language_model.dart';
import '../../../logic/bloc/admin_language/admin_language_bloc.dart';
import '../../../logic/bloc/admin_language/admin_language_event.dart';
import '../../../logic/bloc/admin_language/admin_language_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../theme/japandi_theme.dart';

class LanguageFormPage extends StatefulWidget {
  final LanguageModel? language;

  const LanguageFormPage({super.key, this.language});

  @override
  State<LanguageFormPage> createState() => _LanguageFormPageState();
}

class _LanguageFormPageState extends State<LanguageFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;

  bool get isEdit => widget.language != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.language?.name ?? '');
    _descController = TextEditingController(
      text: widget.language?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (!isEdit) {
        BlocProvider.of<AdminLanguageBloc>(context).add(
          CreateLanguageRequested(
            name: _nameController.text.trim(),
            description: _descController.text.trim(),
          ),
        );
      } else {
        BlocProvider.of<AdminLanguageBloc>(context).add(
          UpdateLanguageRequested(
            id: widget.language!.id,
            name: _nameController.text.trim(),
            description: _descController.text.trim(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.language == null ? 'Tambah Bahasa' : 'Edit Bahasa'),
      ),
      body: BlocListener<AdminLanguageBloc, AdminLanguageState>(
        listener: (context, state) {
          if (state is AdminLanguageOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          } else if (state is AdminLanguageFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: JC.error));
          }
        },
        child: SingleChildScrollView(
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
                          isEdit ? 'Ubah Informasi Bahasa' : 'Detail Bahasa Baru',
                          style: JT.titleMd,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _nameController,
                          label: 'Nama Bahasa',
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Nama bahasa wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _descController,
                          label: 'Deskripsi',
                          maxLines: 4,
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Deskripsi wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<AdminLanguageBloc, AdminLanguageState>(
                  builder: (context, state) {
                    final isLoading = state is AdminLanguageLoading;
                    return CustomButton(
                      onPressed: _submit,
                      text: isEdit ? 'Perbarui Data' : 'Simpan Data',
                      isLoading: isLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
