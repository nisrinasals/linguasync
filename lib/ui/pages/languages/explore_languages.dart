import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'detail_language_page.dart';
import 'package:linguasync/data/models/language_model.dart';
import 'package:linguasync/logic/bloc/auth/auth_bloc.dart';
import 'package:linguasync/logic/bloc/auth/auth_event.dart';
import '../../../../logic/bloc/language/language_bloc.dart';
import '../../../../logic/bloc/language/language_event.dart';
import '../../../../logic/bloc/language/language_state.dart';
import '../../widgets/language_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../theme/japandi_theme.dart';

class ExploreLanguagePage extends StatefulWidget {
  const ExploreLanguagePage({super.key});

  @override
  State<ExploreLanguagePage> createState() => _ExploreLanguagePageState();
}

class _ExploreLanguagePageState extends State<ExploreLanguagePage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  List<LanguageModel> _languages = [];
  bool _hasReachedMax = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    BlocProvider.of<LanguageBloc>(context).add(const FetchLanguages(isRefresh: true));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_hasReachedMax &&
          BlocProvider.of<LanguageBloc>(context).state is! LanguageLoading) {
        BlocProvider.of<LanguageBloc>(context).add(
          FetchLanguages(
            search: _searchController.text.trim(),
            isRefresh: false,
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    BlocProvider.of<LanguageBloc>(context)
        .add(FetchLanguages(search: query.trim(), isRefresh: true));
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari Akun', style: JT.titleMd),
        content: Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: JT.bodySm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: JC.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eksplorasi Bahasa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Keluar',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: BlocConsumer<LanguageBloc, LanguageState>(
        listener: (context, state) {
          if (state is LanguageFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is LanguageExploreLoaded) {
            _languages = state.languages;
            _hasReachedMax = state.hasReachedMax;
          }

          return Column(
            children: [
              // Search field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: JC.ink, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Cari bahasa pembelajaran...',
                    hintStyle: const TextStyle(color: JC.inkLt, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: JC.inkLt, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: JC.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: JC.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: JC.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: JC.bgCard,
                  ),
                ),
              ),
              Expanded(
                child: _buildBody(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(LanguageState state) {
    if (state is LanguageLoading && _languages.isEmpty) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => const ShimmerLoading(),
      );
    }

    if (_languages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: JC.bgMuted,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.search_off, color: JC.inkLt, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              state is LanguageFailure ? state.error : 'Tidak ada bahasa ditemukan.',
              style: JT.bodySm,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: JC.primary,
      backgroundColor: JC.bgCard,
      onRefresh: () async {
        BlocProvider.of<LanguageBloc>(context).add(
          FetchLanguages(search: _searchController.text.trim(), isRefresh: true),
        );
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 4, bottom: 20),
        itemCount: _hasReachedMax ? _languages.length : _languages.length + 1,
        itemBuilder: (context, index) {
          if (index >= _languages.length) return const ShimmerLoading();

          final language = _languages[index];
          return LanguageCard(
            language: language,
            onTap: () {
              final languageBloc = BlocProvider.of<LanguageBloc>(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailLanguagePage(language: language),
                ),
              ).then((_) {
                languageBloc.add(const FetchLanguages(isRefresh: true));
              });
            },
          );
        },
      ),
    );
  }
}
