import 'package:flutter/material.dart';

import '../../../../core/widgets/clinics_loader.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/clinic_repository.dart';
import '../../domain/clinic_detail.dart';

final _myReviewProvider = FutureProvider.autoDispose.family<Review?, String>(
  (ref, clinicId) => ref.watch(clinicRepositoryProvider).getMyReview(clinicId),
);

class ReviewsTab extends ConsumerWidget {
  final String clinicId;

  const ReviewsTab({super.key, required this.clinicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(clinicReviewsProvider(clinicId));
    final loggedIn = ref.watch(authProvider).value != null;
    final mine = loggedIn ? ref.watch(_myReviewProvider(clinicId)).value : null;

    return reviews.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(
        error: e,
        onRetry: () => ref.invalidate(clinicReviewsProvider(clinicId)),
      ),
      data: (page) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.rate_review_outlined, size: 18),
            label: Text(
              mine == null ? 'Avaliar esta clínica' : 'Editar minha avaliação',
            ),
            onPressed: () async {
              if (!loggedIn) {
                context.push('/login');
                return;
              }
              final saved = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                builder: (_) => _ReviewForm(clinicId: clinicId, current: mine),
              );
              if (saved == true) {
                ref.invalidate(clinicReviewsProvider(clinicId));
                ref.invalidate(clinicDetailProvider(clinicId));
                ref.invalidate(_myReviewProvider(clinicId));
              }
            },
          ),
          const SizedBox(height: 12),
          if (page.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Ainda não há avaliações.')),
            ),
          for (final r in page.items) _ReviewCard(review: r),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = review.createdAt.toLocal();
    final date =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.authorName ?? 'Paciente',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                date,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  i <= review.rating ? Icons.star : Icons.star_border,
                  size: 16,
                  color: Colors.amber,
                ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.comment!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.slateDeep,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewForm extends ConsumerStatefulWidget {
  final String clinicId;
  final Review? current;

  const _ReviewForm({required this.clinicId, this.current});

  @override
  ConsumerState<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends ConsumerState<_ReviewForm> {
  late int _rating = widget.current?.rating ?? 0;
  late final _comment = TextEditingController(text: widget.current?.comment);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_rating == 0) {
      setState(() => _error = 'Escolha uma nota de 1 a 5.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(clinicRepositoryProvider)
          .saveMyReview(widget.clinicId, _rating, _comment.text);
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Sua avaliação', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  iconSize: 36,
                  color: Colors.amber,
                  icon: Icon(i <= _rating ? Icons.star : Icons.star_border),
                  onPressed: () => setState(() => _rating = i),
                ),
            ],
          ),
          TextField(
            controller: _comment,
            maxLines: 3,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: 'Conte como foi o atendimento (opcional)',
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryDeep,
                    ),
                  )
                : const Text('Salvar avaliação'),
          ),
        ],
      ),
    );
  }
}
