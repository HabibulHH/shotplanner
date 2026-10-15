import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/shotkit_widgets.dart';
import '../../data/shotkit_store.dart';
import '../../data/unlock_service.dart';

/// Whether the user may plan. In read-only mode this shows the unlock sheet
/// first, so a purchase made there lets the action carry straight on.
Future<bool> ensureCanEdit(BuildContext context, ShotKitStore store) async {
  if (store.unlock.canEdit) return true;
  await showUnlockSheet(context, store);
  return store.unlock.canEdit;
}

Future<void> showUnlockSheet(BuildContext context, ShotKitStore store) async {
  final unlocked = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _UnlockSheet(unlock: store.unlock),
  );
  if (unlocked == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ShotKit is unlocked for life. Thank you!')),
    );
  }
}

IconData accessIcon(UnlockService unlock) => switch (unlock.level) {
      AccessLevel.trial => Icons.hourglass_bottom_rounded,
      AccessLevel.readOnly => Icons.lock_outline_rounded,
      AccessLevel.lifetime => Icons.verified_outlined,
      AccessLevel.earlySupporter => Icons.favorite_outline_rounded,
    };

String accessTitle(UnlockService unlock) => switch (unlock.level) {
      AccessLevel.trial => 'Free trial · ${_days(unlock.trialDaysLeft)} left',
      AccessLevel.readOnly => 'Trial ended · read-only',
      AccessLevel.lifetime => 'Lifetime unlocked',
      AccessLevel.earlySupporter => 'Early supporter · free for life',
    };

String accessSubtitle(UnlockService unlock) => switch (unlock.level) {
      AccessLevel.trial => unlock.product == null
          ? 'Pay once to keep planning. No subscription.'
          : 'Unlock for life for ${unlock.product!.price}',
      AccessLevel.readOnly =>
        'Unlock to keep planning. Your projects are safe.',
      AccessLevel.lifetime => 'Thank you for supporting ShotKit',
      AccessLevel.earlySupporter => 'Thanks for using ShotKit from the start',
    };

String _days(int count) => '$count ${count == 1 ? 'day' : 'days'}';

/// Trial countdown or read-only notice for the home screen.
class UnlockBanner extends StatelessWidget {
  const UnlockBanner({super.key, required this.store});
  final ShotKitStore store;

  @override
  Widget build(BuildContext context) {
    final unlock = store.unlock;
    final readOnly = unlock.level == AccessLevel.readOnly;
    return Material(
      color: readOnly ? ShotKitColors.tapeSoft : ShotKitColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: readOnly ? ShotKitColors.tape : ShotKitColors.line,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showUnlockSheet(context, store),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            children: [
              Icon(accessIcon(unlock), size: 20, color: ShotKitColors.tape),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accessTitle(unlock),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      accessSubtitle(unlock),
                      style: const TextStyle(
                        color: ShotKitColors.dim,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: ShotKitColors.dim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnlockSheet extends StatefulWidget {
  const _UnlockSheet({required this.unlock});
  final UnlockService unlock;

  @override
  State<_UnlockSheet> createState() => _UnlockSheetState();
}

class _UnlockSheetState extends State<_UnlockSheet> {
  static const _perks = [
    (Icons.all_inclusive_rounded, 'Unlimited projects, scenes and shots'),
    (Icons.tune_rounded, 'Shot builder, templates and framing previews'),
    (Icons.update_rounded, 'Every future update included'),
    (Icons.cloud_off_rounded, 'Still offline, with no account and no ads'),
  ];

  bool _closed = false;

  @override
  void initState() {
    super.initState();
    widget.unlock.addListener(_changed);
    if (widget.unlock.product == null) widget.unlock.connect();
  }

  @override
  void dispose() {
    widget.unlock.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (_closed) return;
    if (widget.unlock.level == AccessLevel.lifetime) {
      // Close once; later notifications during the exit animation must not
      // pop the screen underneath.
      _closed = true;
      Navigator.pop(context, true);
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final unlock = widget.unlock;
    final product = unlock.product;
    final readOnly = unlock.level == AccessLevel.readOnly;

    final Widget buttonChild;
    final VoidCallback? onBuy;
    if (unlock.busy) {
      buttonChild = const SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: ShotKitColors.tapeInk,
        ),
      );
      onBuy = null;
    } else if (product != null) {
      buttonChild = Text('Unlock for ${product.price}');
      onBuy = unlock.pending ? null : unlock.buy;
    } else if (unlock.connecting) {
      buttonChild = const Text('Loading price…');
      onBuy = null;
    } else {
      buttonChild = const Text('Try again');
      onBuy = unlock.connect;
    }

    final String? note;
    final Color noteColor;
    if (unlock.error != null) {
      note = unlock.error;
      noteColor = ShotKitColors.record;
    } else if (unlock.pending) {
      note = 'Payment pending. ShotKit unlocks as soon as Google Play '
          'confirms it.';
      noteColor = ShotKitColors.tape;
    } else if (product == null && !unlock.connecting) {
      note = 'Could not reach Google Play. Check your connection.';
      noteColor = ShotKitColors.dim;
    } else {
      note = null;
      noteColor = ShotKitColors.dim;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            const SizedBox(height: 18),
            Text(
              accessTitle(unlock).toUpperCase(),
              style: ShotKitText.label.copyWith(color: ShotKitColors.tape),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock ShotKit for life',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              readOnly
                  ? 'Your projects are safe. You can still open them, run '
                      'On-set mode and export PDFs. Unlock to keep planning.'
                  : 'Pay once and keep planning every shoot. '
                      'No subscription.',
              style: const TextStyle(color: ShotKitColors.dim, height: 1.4),
            ),
            const SizedBox(height: 18),
            for (final (icon, text) in _perks)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: ShotKitColors.tape),
                    const SizedBox(width: 12),
                    Expanded(child: Text(text)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            if (note != null) ...[
              Text(note, style: TextStyle(color: noteColor, height: 1.4)),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: onBuy, child: buttonChild),
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: unlock.busy ? null : unlock.restore,
                child: const Text('Restore purchase'),
              ),
            ),
            Center(
              child: Text(
                'ONE-TIME PURCHASE · NO SUBSCRIPTION',
                textAlign: TextAlign.center,
                style: ShotKitText.mono(size: 10.5, spacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
