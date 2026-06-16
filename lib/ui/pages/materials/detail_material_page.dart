import 'package:flutter/material.dart' hide MaterialState;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/material/material_bloc.dart';
import '../../../../logic/bloc/material/material_event.dart';
import '../../../../logic/bloc/material/material_state.dart';
import '../../widgets/shimmer_loading.dart';
import '../../pages/quiz/quiz_play_page.dart';
import '../../theme/japandi_theme.dart';
import 'material_content_page.dart';

class DetailMaterialPage extends StatefulWidget {
  final int languageId;
  final String languageName;

  const DetailMaterialPage({
    super.key,
    required this.languageId,
    required this.languageName,
  });

  @override
  State<DetailMaterialPage> createState() => _DetailMaterialPageState();
}

class _DetailMaterialPageState extends State<DetailMaterialPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    BlocProvider.of<MaterialBloc>(
      context,
    ).add(FetchMaterials(languageId: widget.languageId, isRefresh: true));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = BlocProvider.of<MaterialBloc>(context).state;
      if (state is MaterialListLoaded && !state.hasReachedMax) {
        BlocProvider.of<MaterialBloc>(
          context,
        ).add(FetchMaterials(languageId: widget.languageId, isRefresh: false));
      }
    }
  }

  void _showMaterialContent(int id, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaterialContentPage(materialId: id, title: title),
      ),
    ).then((_) {
      if (!mounted) return;
      BlocProvider.of<MaterialBloc>(
        context,
      ).add(FetchMaterials(languageId: widget.languageId, isRefresh: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.languageName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              icon: const Icon(Icons.quiz_outlined, size: 16),
              label: const Text('Mulai Kuis'),
              style: FilledButton.styleFrom(
                backgroundColor: JC.clay,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 0,
                ),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPlayPage(
                      languageId: widget.languageId,
                      languageName: widget.languageName,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<MaterialBloc, MaterialState>(
          builder: (context, state) {
            if (state is MaterialLoading) {
              return ListView.builder(
                itemCount: 5,
                itemBuilder: (_, __) => const ShimmerLoading(),
              );
            }

            if (state is MaterialListLoaded) {
              if (state.materials.isEmpty) {
                return const Center(
                  child: Text('Belum ada konten materi untuk bahasa ini.'),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                itemCount: state.hasReachedMax
                    ? state.materials.length
                    : state.materials.length + 1,
                itemBuilder: (context, index) {
                  if (index >= state.materials.length) {
                    return const ShimmerLoading();
                  }

                  final material = state.materials[index];
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () =>
                          _showMaterialContent(material.id, material.title),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: JC.primarySfc,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                material.order.toString(),
                                style: const TextStyle(
                                  color: JC.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(material.title, style: JT.titleMd),
                                  const SizedBox(height: 3),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: JC.inkLt,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            if (state is MaterialFailure) {
              return Center(child: Text(state.error));
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
