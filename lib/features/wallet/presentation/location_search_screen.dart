import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../data/location_repository.dart';

// ── Riverpod state ─────────────────────────────────────────────────────────

final _searchQueryProvider = StateProvider<String>((ref) => '');

final _predictionsProvider =
    FutureProvider.family<List<PlacePrediction>, String>((ref, query) async {
  if (query.trim().length < 2) return [];
  final repo = ref.watch(locationRepositoryProvider);
  return repo.autocomplete(query);
});

// ── Screen ─────────────────────────────────────────────────────────────────

class LocationSearchScreen extends ConsumerStatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  ConsumerState<LocationSearchScreen> createState() =>
      _LocationSearchScreenState();
}

class _LocationSearchScreenState extends ConsumerState<LocationSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const _recentSearches = [
    _RecentItem('Ikeja City Mall', 'Alausa, Lagos'),
    _RecentItem('Lekki Phase 1', 'Lekki, Lagos'),
    _RecentItem('Balogun Market', 'Lagos Island, Lagos'),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    ref.read(_searchQueryProvider.notifier).state = value;
  }

  void _selectPrediction(PlacePrediction prediction) async {
    // Return the selected prediction to the caller
    Navigator.pop(context, prediction);
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(_searchQueryProvider);
    final predictionsAsync = ref.watch(_predictionsProvider(query));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Search input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: _onQueryChanged,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search destination…',
                          hintStyle: GoogleFonts.manrope(
                            color: Colors.black38,
                            fontSize: 16,
                          ),
                          prefixIcon: const Icon(Icons.search, color: Colors.black45),
                          suffixIcon: query.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _controller.clear();
                                    _onQueryChanged('');
                                  },
                                  child: const Icon(Icons.close,
                                      color: Colors.black38, size: 20),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Use current location pill ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context, 'current_location'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.kekeGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.kekeGreen.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.kekeGreen.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.my_location,
                            color: AppColors.kekeGreen, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use current location',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Tap to use your GPS location',
                            style: AppTypography.label
                                .copyWith(color: Colors.black45),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Body: autocomplete results OR recent searches ───────────────
            Expanded(
              child: query.trim().length < 2
                  ? _buildRecentSearches()
                  : predictionsAsync.when(
                      data: (predictions) => predictions.isEmpty
                          ? _buildEmptyState(query)
                          : _buildPredictionList(predictions),
                      loading: () => _buildLoadingShimmer(),
                      error: (e, _) => _buildErrorState(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Recent Searches',
              style: AppTypography.heading3
                  .copyWith(color: Colors.black87, fontSize: 14)),
        ),
        const SizedBox(height: 8),
        ..._recentSearches
            .map((item) => _buildRecentItem(item))
            ,
      ],
    );
  }

  Widget _buildRecentItem(_RecentItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.history, size: 18, color: Colors.black45),
      ),
      title: Text(
        item.main,
        style: AppTypography.bodySmall
            .copyWith(fontWeight: FontWeight.w700, color: Colors.black87),
      ),
      subtitle: Text(
        item.secondary,
        style: AppTypography.label.copyWith(color: Colors.black45),
      ),
      onTap: () {
        _controller.text = item.main;
        _onQueryChanged(item.main);
      },
    );
  }

  Widget _buildPredictionList(List<PlacePrediction> predictions) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: predictions.length,
      separatorBuilder: (_, __) => Divider(
        color: Colors.black.withOpacity(0.06),
        height: 1,
        indent: 56,
      ),
      itemBuilder: (context, index) {
        final pred = predictions[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.place_outlined,
                size: 18, color: Colors.black54),
          ),
          title: Text(
            pred.mainText,
            style: AppTypography.bodySmall
                .copyWith(fontWeight: FontWeight.w700, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: pred.secondaryText.isNotEmpty
              ? Text(
                  pred.secondaryText,
                  style: AppTypography.label.copyWith(color: Colors.black45),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          onTap: () => _selectPrediction(pred),
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 11,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.black26),
          const SizedBox(height: 12),
          Text('No results for "$query"',
              style: AppTypography.bodySmall.copyWith(color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: Colors.black26),
          const SizedBox(height: 12),
          Text('Could not load results',
              style: AppTypography.bodySmall.copyWith(color: Colors.black45)),
        ],
      ),
    );
  }
}

// ── Helper model ────────────────────────────────────────────────────────────

class _RecentItem {
  final String main;
  final String secondary;
  const _RecentItem(this.main, this.secondary);
}
