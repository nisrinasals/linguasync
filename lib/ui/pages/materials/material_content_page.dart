import 'package:flutter/material.dart' hide MaterialState;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/material/material_bloc.dart';
import '../../../../logic/bloc/material/material_event.dart';
import '../../../../logic/bloc/material/material_state.dart';
import '../../../../data/repositories/material_repository.dart';
import '../../theme/japandi_theme.dart';

class MaterialContentPage extends StatelessWidget {
  final int materialId;
  final String title;

  const MaterialContentPage({
    super.key,
    required this.materialId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MaterialBloc>(
      create: (context) => MaterialBloc(
        materialRepository: RepositoryProvider.of<MaterialRepository>(context),
      )..add(FetchMaterialDetail(id: materialId)),
      child: Scaffold(
        backgroundColor: JC.bg,
        appBar: AppBar(title: const Text('Materi Belajar')),
        body: SafeArea(
          child: BlocBuilder<MaterialBloc, MaterialState>(
            builder: (context, state) {
              if (state is MaterialLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: JC.primary,
                    strokeWidth: 2,
                  ),
                );
              }
              if (state is MaterialDetailLoaded) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: JC.primarySfc,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Materi #${state.material.order}',
                                style: const TextStyle(
                                  color: JC.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.material.title,
                              style: JT.displaySm.copyWith(color: JC.ink),
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: JC.divider),
                            const SizedBox(height: 20),
                            Text(
                              state.material.content,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.8,
                                color: JC.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              if (state is MaterialFailure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      state.error,
                      style: const TextStyle(color: JC.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
