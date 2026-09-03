import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// A proof photo, fetched with the session's bearer header. Members only on
/// the server, so a plain URL would be refused — and there is no public URL
/// to leak.
///
/// Renders a quiet placeholder while loading or when the bytes cannot be had.
class AuthImage extends ConsumerWidget {
  const AuthImage({
    super.key,
    required this.mediaId,
    this.size = 56,
    this.onTap,
  });

  final String mediaId;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(mediaRepositoryProvider);
    final radius = BorderRadius.circular(DsSpacing.space2);
    Widget placeholder() => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: DsColors.surfaceRitualAction,
            borderRadius: radius,
          ),
          child: const Icon(Icons.photo_outlined, color: DsColors.textOnRitualMuted, size: 20),
        );
    return Semantics(
      image: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: ClipRRect(
          borderRadius: radius,
          child: Image.network(
            media.urlFor(mediaId),
            headers: media.authHeaders,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder(),
            loadingBuilder: (_, child, progress) =>
                progress == null ? child : placeholder(),
          ),
        ),
      ),
    );
  }
}

/// Full-size view of one proof photo, on a plain sheet.
void showProofPhoto(BuildContext context, String mediaId) {
  showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: DsColors.canvasRitual,
      insetPadding: const EdgeInsets.all(DsSpacing.space4),
      child: _FullProof(mediaId: mediaId),
    ),
  );
}

class _FullProof extends ConsumerWidget {
  const _FullProof({required this.mediaId});

  final String mediaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(mediaRepositoryProvider);
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: InteractiveViewer(
        child: Image.network(
          media.urlFor(mediaId),
          headers: media.authHeaders,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Padding(
            padding: EdgeInsets.all(DsSpacing.space8),
            child: Icon(Icons.photo_outlined, color: DsColors.textOnRitualMuted),
          ),
        ),
      ),
    );
  }
}
