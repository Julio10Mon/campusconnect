import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/notice_model.dart';
import 'adaptive_image.dart';

class NoticeCard extends StatelessWidget {
  final NoticeModel notice;
  final VoidCallback onTap;

  const NoticeCard({super.key, required this.notice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final fecha = DateFormat('d MMM, HH:mm', 'es_MX').format(notice.fecha);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notice.fotoBase64 != null)
              Stack(
                children: [
                  AdaptiveImage(
                    base64Image: notice.fotoBase64!,
                    maxHeight: 220,
                    borderRadius: BorderRadius.zero,
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: _DateChip(text: fecha),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                        child: Icon(Icons.campaign_rounded, color: colors.primary, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(notice.titulo, style: text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notice.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  if (notice.fotoBase64 == null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 13, color: colors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(fecha, style: text.labelMedium),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String text;
  const _DateChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
    );
  }
}
