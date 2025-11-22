import 'dart:typed_data';

class VideoMetadataModel {
  final String? videoName;
  final String? videoExtension;
  final int? videoSize;
  final Uint8List? videoBytes;
  final String? videoBase64;

  VideoMetadataModel({
     this.videoName,
     this.videoExtension,
     this.videoSize,
     this.videoBase64,
     this.videoBytes,
  });

  factory VideoMetadataModel.fromJson(Map<String, dynamic> json) {
    return VideoMetadataModel(
      videoName: json['name'],
      videoExtension: json['extension'],
      videoSize: json['size'],
      videoBase64: json['base64'],
      videoBytes: json['bytes'] != null ? Uint8List.fromList(List<int>.from(json['bytes'])) : null,

    );
  }

  Map<String, dynamic> toPrintJson() {
    return {
      'name': videoName,
      'extension': videoExtension,
      'size': videoSize,
      // 'base64': videoBase64,
      // 'bytes': videoBytes,
    };
  }
  Map<String, dynamic> toJson() {
    return {
      'videoName':videoName?.split('.').first,
      'videoExtension': videoExtension,
      'videoSize': videoSize,
      'videoData': videoBase64,
      // 'bytes': videoBytes,
    };
  }
}