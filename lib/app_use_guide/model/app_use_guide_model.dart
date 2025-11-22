// "_id": "691542508d2a14c9f8c17ee8",
// "title": "gd",
// "description": "dfg",
// "videoName": "/public/videos/app-guide/IMG_8070_1763000912563.mp4",
// "videoSize": 4823490,
// "videoExtension": "mp4",
// "createdAt": "2025-11-13T02:28:32.573Z",
// "updatedAt": "2025-11-13T02:28:32.573Z",
// "__v": 0
class AppUseGuideModel {
  final String id;
  String title;
  String description;
  String videoName;
  int videoSize;
  String videoExtension;
  String createdAt;
  String updatedAt;
  bool visibility; // new field to represent visibility of the video

  AppUseGuideModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoName,
    required this.videoSize,
    required this.videoExtension,
    required this.createdAt,
    required this.updatedAt,
    this.visibility = true,
  });

  factory AppUseGuideModel.fromJson(Map<String, dynamic> json) {
    return AppUseGuideModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoName: json['videoName'] ?? '',
      videoSize: json['videoSize'] ?? 0,
      videoExtension: json['videoExtension'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      visibility: json.containsKey('visibility')
          ? (json['visibility'] == null ? true : (json['visibility'] is bool ? json['visibility'] : (json['visibility'].toString().toLowerCase() == 'true')))
          : true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'videoName': videoName,
      'videoSize': videoSize,
      'videoExtension': videoExtension,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'visibility': visibility,
    };
  }
}