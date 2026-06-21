import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/bloc/admin_history/admin_history_bloc.dart';
import '../../../logic/bloc/admin_history/admin_history_event.dart';
import '../../../logic/bloc/admin_history/admin_history_state.dart';
import '../../widgets/shimmer_loading.dart';
import '../../theme/japandi_theme.dart';
import 'history_form_page.dart';
import '../../../data/models/language_model.dart';
import '../../../data/repositories/language_repository.dart';

class AdminManageHistoryPage extends StatefulWidget {
  const AdminManageHistoryPage({super.key});

  @override
  State<AdminManageHistoryPage> createState() => _AdminManageHistoryPageState();
}

class _AdminManageHistoryPageState extends State<AdminManageHistoryPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  List<LanguageModel> _languages = [];
  int? _selectedLanguageId;
  bool _isLoadingLanguages = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadLanguages();
    BlocProvider.of<AdminHistoryBloc>(context).add(
      const FetchAdminHistory(isRefresh: true),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLanguages() async {
    setState(() {
      _isLoadingLanguages = true;
    });
    try {
      final repo = context.read<LanguageRepository>();
      final result = await repo.exploreLanguages(1, limit: 100);
      setState(() {
        _languages = result['data'] as List<LanguageModel>;
        _isLoadingLanguages = false;
      });
    } catch (_) {
      setState(() {
        _isLoadingLanguages = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = BlocProvider.of<AdminHistoryBloc>(context).state;
      if (state is AdminHistoryLoaded && !state.hasReachedMax) {
        BlocProvider.of<AdminHistoryBloc>(context).add(
          FetchAdminHistory(
            search: _searchController.text.trim(),
            isRefresh: false,
            languageId: _selectedLanguageId,
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    BlocProvider.of<AdminHistoryBloc>(context).add(
      FetchAdminHistory(
        search: query.trim(),
        isRefresh: true,
        languageId: _selectedLanguageId,
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Riwayat Kuis', style: JT.titleMd),
        content: const Text(
          'Apakah Anda yakin ingin menghapus data riwayat kuis ini?',
          style: JT.bodySm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: JC.error),
            onPressed: () {
              BlocProvider.of<AdminHistoryBloc>(context).add(
                DeleteAdminHistory(id: id),
              );
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Riwayat Kuis (Admin)'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: JC.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistoryFormPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocListener<AdminHistoryBloc, AdminHistoryState>(
        listener: (context, state) {
          if (state is AdminHistoryOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            BlocProvider.of<AdminHistoryBloc>(context).add(
              FetchAdminHistory(
                search: _searchController.text.trim(),
                isRefresh: true,
                languageId: _selectedLanguageId,
              ),
            );
          } else if (state is AdminHistoryFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: JC.error),
            );
          }
        },
        child: Column(
          children: [
            // Dropdown Filter Bahasa
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: DropdownButtonFormField<int?>(
                value: _selectedLanguageId,
                dropdownColor: JC.bgCard,
                style: JT.body.copyWith(fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  labelText: 'Filter Bahasa',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Semua Bahasa'),
                  ),
                  ..._languages.map((lang) {
                    return DropdownMenuItem<int?>(
                      value: lang.id,
                      child: Text(lang.name),
                    );
                  }),
                ],
                onChanged: _isLoadingLanguages
                    ? null
                    : (val) {
                        setState(() {
                          _selectedLanguageId = val;
                        });
                        BlocProvider.of<AdminHistoryBloc>(context).add(
                          FetchAdminHistory(
                            search: _searchController.text.trim(),
                            isRefresh: true,
                            languageId: val,
                          ),
                        );
                      },
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: JC.ink, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari nama siswa/bahasa...',
                  hintStyle: const TextStyle(color: JC.inkLt, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: JC.inkLt, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: JC.bgCard,
                ),
              ),
            ),

            // History List
            Expanded(
              child: BlocBuilder<AdminHistoryBloc, AdminHistoryState>(
                builder: (context, state) {
                  if (state is AdminHistoryLoading) {
                    return ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) => const ShimmerLoading(),
                    );
                  }

                  if (state is AdminHistoryLoaded) {
                    if (state.histories.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada riwayat kuis ditemukan.',
                          style: JT.body,
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: state.hasReachedMax
                          ? state.histories.length
                          : state.histories.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.histories.length) {
                          return const ShimmerLoading();
                        }

                        final history = state.histories[index];
                        // format date simple
                        String dateStr = '';
                        try {
                          final parsedDate = DateTime.parse(history.createdAt);
                          dateStr = '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
                        } catch (_) {
                          dateStr = history.createdAt;
                        }

                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    history.userName ?? 'N/A',
                                    style: JT.titleMd,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: JC.primarySfc,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Skor: ${history.score.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: JC.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Bahasa: ${history.languageName ?? 'N/A'}',
                                      style: JT.bodySm,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    dateStr,
                                    style: JT.caption,
                                  ),
                                ],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HistoryFormPage(history: history),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: JC.error),
                                  onPressed: () => _confirmDelete(history.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
