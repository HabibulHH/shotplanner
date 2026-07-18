import 'package:flutter/material.dart';

import '../../data/shotkit_store.dart';
import '../theme/app_theme.dart';

Future<void> showProUpsell(
  BuildContext context,
  ShotKitStore store, {
  String reason = 'Unlock unlimited productions and scenes.',
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                color: ShotKitColors.tape,
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.all_inclusive_rounded,
                color: ShotKitColors.tapeInk),
          ),
          const SizedBox(height: 16),
          Text('ShotKit Pro', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 7),
          Text(reason,
              textAlign: TextAlign.center,
              style: const TextStyle(color: ShotKitColors.dim)),
          const SizedBox(height: 16),
          const Text(
            'Unlimited projects · Unlimited scenes · All templates · No PDF watermark',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: store.entitlement.product == null
                  ? null
                  : () async {
                      await store.entitlement.buy();
                      if (context.mounted) Navigator.pop(context);
                    },
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: Text(
                store.entitlement.product == null
                    ? 'PLAY STORE UNAVAILABLE'
                    : 'UNLOCK · ${store.entitlement.product!.price}',
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await store.entitlement.restore();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('RESTORE PURCHASE'),
          ),
        ],
      ),
    ),
  );
}
