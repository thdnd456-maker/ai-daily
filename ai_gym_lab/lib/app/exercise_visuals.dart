// 운동 사진·썸네일·기구 아이콘 공통 위젯
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../domain/catalog/exercise_photos.dart';
import '../domain/models.dart';
import 'theme.dart';

IconData equipmentIcon(Equipment e) => switch (e) {
  Equipment.barbell || Equipment.ezBar || Equipment.smith => Icons.fitness_center,
  Equipment.dumbbell || Equipment.kettlebell => Icons.sports_gymnastics,
  Equipment.machine || Equipment.legPress || Equipment.hackSquat || Equipment.specialtyMachine => Icons.precision_manufacturing,
  Equipment.cable => Icons.cable,
  Equipment.band => Icons.linear_scale,
  Equipment.bench => Icons.weekend_outlined,
  Equipment.pullupBar || Equipment.dipStation => Icons.horizontal_rule,
  Equipment.bodyweight => Icons.accessibility_new,
};

/// "가슴 · 바벨" 같은 짧은 부제
String exerciseSubtitle(Exercise e) {
  final eq = e.equipment.where((q) => q != Equipment.bench || e.equipment.length == 1).map((q) => q.ko).join('+');
  return '${e.primary.map((m) => m.ko).join('·')} · $eq';
}

/// 운동 사진. [animate]=true면 시작/끝 자세를 번갈아 보여줘 동작을 보여줍니다.
/// 사진이 없는 운동은 기구 아이콘 카드로 대체합니다.
class ExercisePhoto extends StatefulWidget {
  final Exercise exercise;
  final double? width;
  final double? height;
  final double radius;
  final bool animate;
  final bool showApproxBadge;
  const ExercisePhoto({super.key, required this.exercise, this.width, this.height, this.radius = 14, this.animate = false, this.showApproxBadge = false});

  @override
  State<ExercisePhoto> createState() => _ExercisePhotoState();
}

class _ExercisePhotoState extends State<ExercisePhoto> {
  int _frame = 0;
  Timer? _t;

  ExercisePhotoInfo? get _info => exercisePhotos[widget.exercise.id];

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void didUpdateWidget(covariant ExercisePhoto old) {
    super.didUpdateWidget(old);
    if (old.exercise.id != widget.exercise.id || old.animate != widget.animate) {
      _frame = 0;
      _setup();
    }
  }

  void _setup() {
    _t?.cancel();
    if (widget.animate && (_info?.count ?? 0) > 1) {
      _t = Timer.periodic(const Duration(milliseconds: 1100), (_) {
        if (mounted) setState(() => _frame = 1 - _frame);
      });
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    final child = info == null
        ? _Fallback(exercise: widget.exercise, compact: (widget.height ?? 100) < 90)
        : Stack(
            fit: StackFit.expand,
            children: [
              // 두 장을 겹쳐 두고 투명도만 바꿔 깜빡임 없이 전환
              for (var f = 0; f < info.count; f++)
                AnimatedOpacity(
                  opacity: f == _frame ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Image.asset(
                    exercisePhotoAsset(widget.exercise.id, f),
                    fit: BoxFit.cover,
                    cacheWidth: 480,
                    gaplessPlayback: true,
                    errorBuilder: (_, _, _) => _Fallback(exercise: widget.exercise, compact: true),
                  ),
                ),
              if (widget.showApproxBadge && info.approx)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(8)),
                    child: const Text('유사 동작 사진', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ),
            ],
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: SizedBox(width: widget.width, height: widget.height, child: child),
    );
  }
}

class _Fallback extends StatelessWidget {
  final Exercise exercise;
  final bool compact;
  const _Fallback({required this.exercise, required this.compact});
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [GymColors.surface2, Color(0xFF2B3240)]),
    ),
    alignment: Alignment.center,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(equipmentIcon(exercise.primaryEquipment), color: GymColors.accent, size: compact ? 26 : 44),
        if (!compact) ...[const SizedBox(height: 8), Text(exercise.primaryEquipment.ko, style: const TextStyle(color: GymColors.textDim, fontSize: 13))],
      ],
    ),
  );
}

/// 사진 썸네일 + 이름 + 부제 + 오른쪽 정보 (모든 운동 목록에서 공통 사용)
class ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double thumb;
  const ExerciseTile({super.key, required this.exercise, this.subtitle, this.trailing, this.onTap, this.thumb = 56});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ExercisePhoto(exercise: exercise, width: thumb, height: thumb, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.nameKo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle ?? exerciseSubtitle(exercise),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: GymColors.textDim, fontSize: 12.5),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    ),
  );
}

/// 크게 보기 (탭하면 전체 화면으로 동작 사진)
void showExercisePhotoViewer(BuildContext context, Exercise e) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: GymColors.surface,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ExercisePhoto(exercise: e, animate: true, showApproxBadge: true, radius: 14),
            ),
            const SizedBox(height: 12),
            Text(e.nameKo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(exerciseSubtitle(e), style: const TextStyle(color: GymColors.textDim)),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('닫기')),
          ],
        ),
      ),
    ),
  );
}
