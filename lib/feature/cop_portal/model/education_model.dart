class EducationHomeResponse {
  final List<Video> videos;
  final List<Guide> guides;

  EducationHomeResponse({required this.videos, required this.guides});

  factory EducationHomeResponse.fromJson(Map<String, dynamic> json) {
    return EducationHomeResponse(
      videos:
          (json['videos'] as List<dynamic>?)
              ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      guides:
          (json['guides'] as List<dynamic>?)
              ?.map((e) => Guide.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Video {
  final int id;
  final String type;
  final String? mediaUrl;
  final String? readTime;
  final String createdAt;
  final String description;
  final String title;
  final String? thumbnailUrl;
  final String? duration;
  final List<Section> sections;

  Video({
    required this.id,
    required this.type,
    this.mediaUrl,
    this.readTime,
    required this.createdAt,
    required this.description,
    required this.title,
    this.thumbnailUrl,
    this.duration,
    required this.sections,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as int,
      type: json['type'] as String,
      mediaUrl: json['media_url'] as String?,
      readTime: json['read_time'] as String?,
      createdAt: json['created_at'] as String,
      description: json['description'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      duration: json['duration'] as String?,
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map((e) => Section.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Guide {
  final int id;
  final String type;
  final String? mediaUrl;
  final String? readTime;
  final String createdAt;
  final String description;
  final String title;
  final String? thumbnailUrl;
  final String? duration;
  final List<Section> sections;

  Guide({
    required this.id,
    required this.type,
    this.mediaUrl,
    this.readTime,
    required this.createdAt,
    required this.description,
    required this.title,
    this.thumbnailUrl,
    this.duration,
    required this.sections,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: json['id'] as int,
      type: json['type'] as String,
      mediaUrl: json['media_url'] as String?,
      readTime: json['read_time'] as String?,
      createdAt: json['created_at'] as String,
      description: json['description'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      duration: json['duration'] as String?,
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map((e) => Section.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Section {
  final String title;
  final String content;

  Section({required this.title, required this.content});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
}
