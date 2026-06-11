import 'package:flutter/material.dart' hide MaterialState;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/material/material_bloc.dart';
import '../../../../logic/bloc/material/material_event.dart';
import '../../../../logic/bloc/material/material_state.dart';
import '../../widgets/shimmer_loading.dart';
import '../../pages/quiz/quiz_play_page.dart';

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
    BlocProvider.of<MaterialBloc>(context).add(FetchMaterialDetail(id: id));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: BlocBuilder<MaterialBloc, MaterialState>(
                  builder: (context, state) {
                    if (state is MaterialLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2C3E50),
                        ),
                      );
                    }
                    if (state is MaterialDetailLoaded) {
                      return SingleChildScrollView(
                        child: Text(
                          state.material.content,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }
                    if (state is MaterialFailure) {
                      return Center(child: Text(state.error));
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      BlocProvider.of<MaterialBloc>(
        context,
      ).add(FetchMaterials(languageId: widget.languageId, isRefresh: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Materi ${widget.languageName}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              icon: const Icon(Icons.quiz, color: Colors.white, size: 18),
              label: const Text('Mulai Kuis', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF6B705C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      body: BlocBuilder<MaterialBloc, MaterialState>(
        builder: (context, state) {
          if (state is MaterialLoading) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => const ShimmerLoading(),
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
              itemCount: state.hasReachedMax
                  ? state.materials.length
                  : state.materials.length + 1,
              itemBuilder: (context, index) {
                if (index >= state.materials.length) {
                  return const ShimmerLoading();
                }

                final material = state.materials[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2C3E50),
                      child: Text(
                        material.order.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      material.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text('Ketuk untuk mulai membaca materi'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () =>
                        _showMaterialContent(material.id, material.title),
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
    );
  }
}
