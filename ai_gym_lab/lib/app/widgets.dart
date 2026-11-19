import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../domain/catalog/research.dart';
import '../domain/models.dart';
import 'theme.dart';

class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  const SectionCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color});

  @override
  Widget build(BuildContext context) => Card(
    color: color,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(padding: padding, child: child),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
    child: Row(
      children: [
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        ),
        ?trailing,
      ],
    ),
  );
}

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final Color? color;
  const StatTile({super.key, required this.label, required this.value, this.sub, this.color});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: GymColors.textDim, fontSize: 12)),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color ?? GymColors.text),
      ),
      if (sub != null) Text(sub!, style: const TextStyle(color: GymColors.textDim, fontSize: 12)),
    ],
  );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: GymColors.textDim),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: GymColors.textDim),
            ),
          ],
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    ),
  );
}

/// 큰 숫자 + / - 버튼 (운동 중 한 손 빠른 입력)
class NumberStepper extends StatelessWidget {
  final String label;
  final double? value;
  final double step;
  final double min;
  final double max;
  final int decimals;
  final ValueChanged<double> onChanged;
  final String? placeholder;
  final bool enabled;
  const NumberStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.min = 0,
    this.max = 999,
    this.decimals = 0,
    this.placeholder,
    this.enabled = true,
  });

  String _fmt(double v) {
    if (decimals == 0 || v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(decimals).replaceFirst(RegExp(r'0+$'), '');
  }

  Future<void> _edit(BuildContext context) async {
    // 작은 정수 범위(RIR 등)는 키보드 없이 한 번에 고르는 빠른 선택
    if (decimals == 0 && max - min <= 10) {
      final r = await showModalBottomSheet<double>(
        context: context,
        backgroundColor: GymColors.surface,
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (var v = min.toInt(); v <= max.toInt(); v++)
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(56, 56),
                            backgroundColor: value == v ? GymColors.accent : GymColors.surface2,
                            foregroundColor: value == v ? Colors.black : GymColors.text,
                          ),
                          onPressed: () => Navigator.pop(ctx, v.toDouble()),
                          child: Text('$v', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      if (r != null) onChanged(r);
      return;
    }
    final c = TextEditingController(text: value == null ? '' : _fmt(value!));
    final r = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          onSubmitted: (v) => Navigator.pop(ctx, double.tryParse(v)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(ctx, double.tryParse(c.text)), child: const Text('확인')),
        ],
      ),
    );
    if (r != null) onChanged(r.clamp(min, max).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        // 폭에 따라 버튼 크기 조정: 넓으면 36, 보통 26, 매우 좁으면 버튼 없이 탭하여 선택
        final w = box.maxWidth;
        final btnW = w >= 120 ? 36.0 : (w >= 84 ? 26.0 : 0.0);
        Widget btn(IconData i, double d) => SizedBox(
          width: btnW,
          height: 48,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: enabled
                ? () {
                    HapticFeedback.selectionClick();
                    onChanged(((value ?? 0) + d).clamp(min, max).toDouble());
                  }
                : null,
            icon: Icon(i, size: btnW >= 36 ? 20 : 16),
          ),
        );
        return Container(
          height: 52,
          decoration: BoxDecoration(color: GymColors.surface2, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              if (btnW > 0) btn(Icons.remove, -step),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: enabled ? () => _edit(context) : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(fontSize: 10, color: GymColors.textDim),
                      ),
                      FittedBox(
                        child: Text(
                          value == null ? (placeholder ?? '-') : _fmt(value!),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: value == null ? GymColors.textDim : GymColors.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (btnW > 0) btn(Icons.add, step),
            ],
          ),
        );
      },
    );
  }
}

class EvidenceBadge extends StatelessWidget {
  final EvidenceKind kind;
  const EvidenceBadge(this.kind, {super.key});
  @override
  Widget build(BuildContext context) {
    final c = switch (kind) {
      EvidenceKind.research => GymColors.research,
      EvidenceKind.appDefault => GymColors.warn,
      EvidenceKind.userData => GymColors.accent,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(
        kind.ko,
        style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class RationaleList extends StatelessWidget {
  final List<Rationale> items;
  const RationaleList(this.items, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final r in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EvidenceBadge(r.kind),
              const SizedBox(height: 4),
              Text(r.text, style: const TextStyle(height: 1.4)),
              for (final id in r.referenceIds)
                if (researchById[id] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '· ${researchById[id]!.authors.split(',').first} 외 (${researchById[id]!.year}), ${researchById[id]!.journal}',
                      style: const TextStyle(fontSize: 12, color: GymColors.research),
                    ),
                  ),
            ],
          ),
        ),
    ],
  );
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  const Pill(this.text, {super.key, this.color = GymColors.accent});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
    ),
  );
}

void showSnack(BuildContext context, String msg) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(msg)));

Future<bool> confirm(BuildContext context, String title, String message, {String ok = '확인', bool danger = false}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
        FilledButton(
          style: danger ? FilledButton.styleFrom(backgroundColor: GymColors.danger, foregroundColor: Colors.white) : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(ok),
        ),
      ],
    ),
  );
  return r ?? false;
}
