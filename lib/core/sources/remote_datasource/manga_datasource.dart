import 'package:flutter_manga_reader/core/sources/remote_datasource/mangabox.dart';
import 'package:flutter_manga_reader/core/sources/remote_datasource/mangadex.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader_core/manga_reader_core.dart';

final scopedMangaDatasourceProvider = Provider.autoDispose<MangaDatasource>((ref) {
  // Thay vì throw lỗi ngay lập tức, chúng ta thử lấy source đầu tiên làm mặc định
  // hoặc báo lỗi nhẹ nhàng hơn để không trắng màn hình.
  try {
    // Logic mặc định: cố gắng lấy source từ danh sách có sẵn nếu không được override
    final allSources = ref.watch(mangaDatasourcesProvider);
    if (allSources.isNotEmpty) {
      return allSources.values.first;
    }
  } catch (_) {}

  throw UnimplementedError('No datasource set in this scope.');
});

final fetchChapterPagesProvider = FutureProvider.autoDispose
    .family<Result<List<ChapterPage>, HttpError>, SourceChapter>((
      Ref ref,
      SourceChapter sourceChapter,
    ) {
      return ref
          .watch(scopedMangaDatasourceProvider)
          .fetchChapterPages(sourceChapter);
    });

final mangaDatasourcesProvider = Provider.autoDispose((ref) {
  final mangadex = ref.watch(mangadexProvider);
  final mangabox = ref.watch(mangaboxProvider);

  return {for (final e in mangadex) e.id: e, for (final e in mangabox) e.id: e};
});

final findSourceFromIdProvider = Provider.autoDispose
    .family<MangaDatasource?, String>((ref, sourceId) {
      final sources = ref.watch(mangaDatasourcesProvider);
      return sources[sourceId];
    });

final getSourceFromIdProvider = Provider.autoDispose
    .family<MangaDatasource, String>((ref, sourceId) {
      final source = ref.watch(findSourceFromIdProvider(sourceId));
      if (source == null) {
        throw ArgumentError.value(sourceId, 'sourceId', 'Unknown source');
      }
      return source;
    });
