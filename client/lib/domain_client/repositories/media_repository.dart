import 'dart:typed_data';

import '../api_client.dart';

/// What the server hands back for one uploaded proof photo.
class MediaUpload {
  const MediaUpload({required this.id, required this.url});

  factory MediaUpload.fromJson(Map<String, dynamic> json) => MediaUpload(
        id: json['id'] as String,
        url: json['url'] as String? ?? '/v1/media/${json['id']}',
      );

  final String id;

  /// Server-relative, `/v1/media/{id}`; readable by members only.
  final String url;
}

class MediaRepository {
  MediaRepository(this._api);

  final ApiClient _api;

  /// `POST /v1/dynamics/{id}/media`, field `file`. JPEG only from this client:
  /// the picker re-encodes whatever the camera or gallery produced.
  Future<MediaUpload> upload(String dynamicId, Uint8List jpeg) async =>
      MediaUpload.fromJson(await _api.postFile(
        '/v1/dynamics/$dynamicId/media',
        bytes: jpeg,
        filename: 'proof.jpg',
      ));

  /// Where the bytes for one media id live, absolute, for an image widget.
  String urlFor(String mediaId) => _api.resolve('/v1/media/$mediaId');

  Map<String, String> get authHeaders => _api.authHeaders;
}
