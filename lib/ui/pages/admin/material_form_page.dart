import 'package:flutter/material.dart' hide MaterialState;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/material_model.dart';
import '../../../../logic/bloc/material/material_bloc.dart';
import '../../../../logic/bloc/material/material_event.dart';
import '../../../../logic/bloc/admin_material/admin_material_bloc.dart';
import '../../../../logic/bloc/admin_material/admin_material_event.dart';
import '../../../../logic/bloc/admin_material/admin_material_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../theme/japandi_theme.dart';

class MaterialFormPage extends StatefulWidget {
  final int languageId;
  final MaterialModel? material;

  const MaterialFormPage({super.key, required this.languageId, this.material});

  @override
  State<MaterialFormPage> createState() => _MaterialFormPageState();
}

class _MaterialFormPageState extends State<MaterialFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _orderController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.material?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.material?.content ?? '',
    );
    _orderController = TextEditingController(
      text: widget.material?.order.toString() ?? '1',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final orderVal = int.tryParse(_orderController.text) ?? 1;
      if (widget.material == null) {
        context.read<AdminMaterialBloc>().add(
          CreateMaterialRequested(
            languageId: widget.languageId,
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            order: orderVal,
          ),
        );
      } else {
        context.read<AdminMaterialBloc>().add(
          UpdateMaterialRequested(
            id: widget.material!.id,
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            order: orderVal,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.material == null ? 'Tambah Materi' : 'Edit Materi',
          style: JT.titleLg,
        ),
      ),
      body: BlocListener<AdminMaterialBloc, AdminMaterialState>(
        listener: (context, state) {
          if (state is AdminMaterialOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Refresh list in MaterialBloc
            context.read<MaterialBloc>().add(
              FetchMaterials(languageId: widget.languageId, isRefresh: true),
            );
            Navigator.pop(context);
          } else if (state is AdminMaterialFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: JC.error,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Judul Bab Materi',
                validator: (val) => val == null || val.isEmpty
                    ? 'Judul materi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _orderController,
                label: 'Urutan Tampilan (Angka Index)',
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty
                    ? 'Urutan nomor bab wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _contentController,
                label: 'Isi Konten Pembelajaran Teks',
                maxLines: 12,
                validator: (val) => val == null || val.isEmpty
                    ? 'Isi teks materi tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 32),
              BlocBuilder<AdminMaterialBloc, AdminMaterialState>(
                builder: (context, state) {
                  return CustomButton(
                    onPressed: _submit,
                    text: widget.material == null
                        ? 'Simpan Materi'
                        : 'Perbarui Materi',
                    isLoading: state is AdminMaterialLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
