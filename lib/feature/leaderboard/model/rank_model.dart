class RankModel {
  final String id;
  final String name;
  final String iconPath;
  final int requiredTasks;
  final bool isUnlocked;

  RankModel({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.requiredTasks,
    this.isUnlocked = false,
  });
}
