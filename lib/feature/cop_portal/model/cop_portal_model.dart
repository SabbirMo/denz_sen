class CopPortalVideoModel {
  final String title;
  final String duration;
  final String videoUrl;

  CopPortalVideoModel({
    required this.title,
    required this.duration,
    required this.videoUrl,
  });

  factory CopPortalVideoModel.fromJson(Map<String, dynamic> json) {
    return CopPortalVideoModel(
      title: json['title'] as String,
      duration: json['duration'] as String,
      videoUrl: json['videoUrl'] as String,
    );
  }
}

final List<CopPortalVideoModel> copPortalData = [
  CopPortalVideoModel(
    title: 'How to investigate a scene?',
    duration: '3:05',
    videoUrl: 'assets/images/video1.png',
  ),
  CopPortalVideoModel(
    title: 'How to investigate a scene?',
    duration: '3:00',
    videoUrl: 'assets/images/video1.png',
  ),
];

class CopPortalGuidesModel {
  final String title;
  final String duration;
  final String imageUrl;

  CopPortalGuidesModel({
    required this.title,
    required this.duration,
    required this.imageUrl,
  });

  factory CopPortalGuidesModel.fromJson(Map<String, dynamic> json) {
    return CopPortalGuidesModel(
      title: json['title'] as String,
      duration: json['duration'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }
}

final List<CopPortalGuidesModel> copPortalGuidesData = [
  CopPortalGuidesModel(
    title: 'Guide for collecting evidence',
    duration: '10 minute read',
    imageUrl: 'assets/images/image1.png',
  ),
  CopPortalGuidesModel(
    title: 'Investigation Guide',
    duration: '20 minute read',
    imageUrl: 'assets/images/image1.png',
  ),
];
