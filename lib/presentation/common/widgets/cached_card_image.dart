import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// 네트워크 타로 카드 이미지 (디스크·메모리 캐시 적용)
class CachedCardImage extends StatelessWidget {
  const CachedCardImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 12,
    this.loadingHeight = 200,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final double loadingHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        // 메모리 캐시 크기 힌트 — 리스트/상세에서 동일 URL 재사용 시 디코딩 비용 절감
        memCacheWidth: width != null && width!.isFinite
            ? (width! * MediaQuery.devicePixelRatioOf(context)).round()
            : null,
        progressIndicatorBuilder: (context, url, progress) {
          return SizedBox(
            height: loadingHeight,
            width: width,
            child: Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.secondary,
                value: progress.progress,
              ),
            ),
          );
        },
        errorWidget: (context, url, error) => const SizedBox.shrink(),
      ),
    );
  }
}
