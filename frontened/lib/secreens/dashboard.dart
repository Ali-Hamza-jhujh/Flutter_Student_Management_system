import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _bg = Color(0xFF07070F);
const _card = Color(0xFF111120);
const _cardBorder = Color(0xFF1E1E35);
const _accent = Color(0xFF6C63FF);
const _teal = Color(0xFF00D4AA);
const _textPrimary = Colors.white;
const _textSub = Color(0xFF7070A0);

// per-type theme
const _typeThemes = {
  'Quiz': _QuizTheme(),
  'Assignment': _AssignTheme(),
  'Lab': _LabTheme(),
};

class _QuizTheme {
  const _QuizTheme();
  Color get color => const Color(0xFF6C63FF);
  Color get color2 => const Color(0xFF9B6DFF);
  IconData get icon => Icons.quiz_rounded;
}

class _AssignTheme {
  const _AssignTheme();
  Color get color => const Color(0xFF00D4AA);
  Color get color2 => const Color(0xFF00FFCC);
  IconData get icon => Icons.assignment_rounded;
}

class _LabTheme {
  const _LabTheme();
  Color get color => const Color(0xFFFF6B6B);
  Color get color2 => const Color(0xFFFFAA6B);
  IconData get icon => Icons.science_rounded;
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  List marks = [];
  Map<String, bool> _expanded = {
    'Quiz': false,
    'Assignment': false,
    'Lab': false,
  };

  late AnimationController _headerAnim;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    fetchMarksData();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  String get baseUrl => dotenv.env['BACKEND_API'] ?? '';

  Future<void> fetchMarksData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      final response = await http.get(
        Uri.parse("http://$baseUrl:3000/marks/student"),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() => marks = data['data']);
        _showSnack('Marks loaded ✓', isSuccess: true);
      } else {
        _showSnack(data['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      _showSnack('Error: $e');
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: isSuccess ? _teal : Colors.redAccent,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg, style: const TextStyle(color: _textPrimary)),
            ),
          ],
        ),
        backgroundColor: _card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isSuccess
                ? _teal.withOpacity(0.4)
                : Colors.redAccent.withOpacity(0.4),
          ),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  List _byType(String type) =>
      marks.where((m) => m['marksType'] == type).toList();

  double _avgPct(String type) {
    final list = _byType(type);
    if (list.isEmpty) return 0;
    return list.fold<double>(
          0,
          (p, m) => p + (m['percentage'] ?? 0).toDouble(),
        ) /
        list.length;
  }

  String _gradeLabel(double pct) {
    if (pct >= 90) return 'A+';
    if (pct >= 80) return 'A';
    if (pct >= 70) return 'B';
    if (pct >= 60) return 'C';
    if (pct >= 50) return 'D';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          FadeTransition(
            opacity: CurvedAnimation(
              parent: _headerAnim,
              curve: Curves.easeOut,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D0B1F), Color(0xFF0A0F1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: const Border(bottom: BorderSide(color: _cardBorder)),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 58, 24, 22),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: _teal,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'ACADEMIC PORTAL',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 3,
                                color: _teal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'My Results',
                          style: TextStyle(
                            fontSize: 32,
                            color: _textPrimary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${marks.length} total assessments',
                          style: const TextStyle(fontSize: 13, color: _textSub),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: fetchMarksData,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _accent.withOpacity(0.25)),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: _accent,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── List ────────────────────────────────────────────
          Expanded(
            child: marks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bar_chart_rounded,
                            color: _accent,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'No marks yet',
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Check back after assessments',
                          style: TextStyle(color: _textSub, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    children: ['Quiz', 'Assignment', 'Lab'].map((type) {
                      final list = _byType(type);
                      if (list.isEmpty) return const SizedBox.shrink();
                      final isOpen = _expanded[type] ?? false;
                      final avg = _avgPct(type);
                      final theme = type == 'Quiz'
                          ? const _QuizTheme()
                          : type == 'Assignment'
                          ? const _AssignTheme()
                          : const _LabTheme();

                      return _SectionCard(
                        type: type,
                        list: list,
                        isOpen: isOpen,
                        avg: avg,
                        theme: theme,
                        gradeLabel: _gradeLabel,
                        onTap: () => setState(() => _expanded[type] = !isOpen),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String type;
  final List list;
  final bool isOpen;
  final double avg;
  final dynamic theme;
  final String Function(double) gradeLabel;
  final VoidCallback onTap;

  const _SectionCard({
    required this.type,
    required this.list,
    required this.isOpen,
    required this.avg,
    required this.theme,
    required this.gradeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color c = theme.color;
    final Color c2 = theme.color2;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isOpen ? c.withOpacity(0.35) : _cardBorder,
          width: 1.5,
        ),
        boxShadow: isOpen
            ? [BoxShadow(color: c.withOpacity(0.12), blurRadius: 24)]
            : [],
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  // Big circular avg indicator
                  _CircleProgress(
                    value: avg / 100,
                    color: c,
                    color2: c2,
                    size: 62,
                    label: gradeLabel(avg),
                    sublabel: '${avg.toStringAsFixed(0)}%',
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: c.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(theme.icon, color: c, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    type,
                                    style: TextStyle(
                                      color: c,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${list.length} assessments',
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Avg ${avg.toStringAsFixed(1)}% · ${gradeLabel(avg)} grade',
                          style: const TextStyle(color: _textSub, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: c,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded items ─────────────────────────────────
          if (isOpen) ...[
            Divider(color: _cardBorder, height: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 8),
            ...list.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              final pct = (m['percentage'] ?? 0).toDouble();
              final grade = m['grade'] ?? '-';
              final obtained = m['obtainedmarks'] ?? 0;
              final total = m['totalmarks'] ?? 0;

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                child: Row(
                  children: [
                    // small circle progress
                    _CircleProgress(
                      value: pct / 100,
                      color: c,
                      color2: c2,
                      size: 50,
                      label: grade,
                      sublabel: '${pct.toStringAsFixed(0)}%',
                      fontSize: 13,
                      subFontSize: 9,
                      strokeWidth: 4,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$type ${i + 1}',
                            style: const TextStyle(
                              color: _textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$obtained out of $total marks',
                            style: const TextStyle(
                              color: _textSub,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (pct / 100).clamp(0.0, 1.0),
                              backgroundColor: _cardBorder,
                              valueColor: AlwaysStoppedAnimation(c),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

// ── Circular Progress Painter ─────────────────────────────────
class _CircleProgress extends StatelessWidget {
  final double value; // 0.0 – 1.0
  final Color color;
  final Color color2;
  final double size;
  final String label;
  final String sublabel;
  final double fontSize;
  final double subFontSize;
  final double strokeWidth;

  const _CircleProgress({
    required this.value,
    required this.color,
    required this.color2,
    required this.size,
    required this.label,
    required this.sublabel,
    this.fontSize = 16,
    this.subFontSize = 10,
    this.strokeWidth = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ArcPainter(
          value: value,
          color: color,
          color2: color2,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: fontSize,
                  height: 1,
                ),
              ),
              Text(
                sublabel,
                style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: subFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color color2;
  final double strokeWidth;

  _ArcPainter({
    required this.value,
    required this.color,
    required this.color2,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * value;

    // background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = _cardBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: [color, color2],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (value > 0) {
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    }

    // glow dot at end
    if (value > 0) {
      final endAngle = startAngle + sweepAngle;
      final dotX = center.dx + radius * math.cos(endAngle);
      final dotY = center.dy + radius * math.sin(endAngle);
      canvas.drawCircle(
        Offset(dotX, dotY),
        strokeWidth / 2,
        Paint()
          ..color = color2
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 0.8),
      );
      canvas.drawCircle(
        Offset(dotX, dotY),
        strokeWidth / 2.5,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.value != value || old.color != color;
}
