import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const _bg = Color(0xFF0A0A14);
const _surface = Color(0xFF12121F);
const _card = Color(0xFF1A1A2E);
const _cardBorder = Color(0xFF2A2A45);
const _accent = Color(0xFF6C63FF);
const _accentGlow = Color(0x336C63FF);
const _gold = Color(0xFFFFD700);
const _teal = Color(0xFF00D4AA);
const _textPrimary = Colors.white;
const _textSub = Color(0xFF9090B0);

const _avatarColors = [
  Color(0xFF6C63FF),
  Color(0xFF00D4AA),
  Color(0xFFFF6B6B),
  Color(0xFFFFAA00),
  Color(0xFF00AAFF),
  Color(0xFFFF63C4),
];

class Students extends StatefulWidget {
  const Students({super.key});
  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> with TickerProviderStateMixin {
  bool isLoading = false;
  List users = [];
  String get baseUrl => dotenv.env['BACKEND_API'] ?? '';

  late AnimationController _headerAnim;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    fetchStudents();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  Future<void> fetchStudents() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse('http://$baseUrl:3000/users/all'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() => users = data['allUsers']);
        _showSnack('All students loaded ✓', isSuccess: true);
      } else {
        _showSnack(data['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      setState(() => isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          FadeTransition(
            opacity: _headerFade,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D0D22), Color(0xFF141430)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(
                  bottom: BorderSide(color: _cardBorder, width: 1),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
              child: Row(
                children: [
                  // left text
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
                            Text(
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
                          'Students',
                          style: TextStyle(
                            fontSize: 30,
                            color: _textPrimary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${users.length} enrolled',
                          style: const TextStyle(fontSize: 13, color: _textSub),
                        ),
                      ],
                    ),
                  ),
                  // refresh button
                  GestureDetector(
                    onTap: fetchStudents,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _accent.withOpacity(0.3)),
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

          // ── Search bar ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _cardBorder),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 14),
                  Icon(Icons.search_rounded, color: _textSub, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Search students…',
                    style: TextStyle(color: _textSub, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // ── List ────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? _buildShimmer()
                : users.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return _StudentCard(
                        user: users[index],
                        index: index,
                        onTap: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, a, __) =>
                                StudentMarks(studentId: users[index]['_id']),
                            transitionsBuilder: (_, anim, __, child) =>
                                FadeTransition(opacity: anim, child: child),
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 80,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              color: _accent,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No students found',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pull to refresh',
            style: TextStyle(color: _textSub, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Student Card ─────────────────────────────────────────────
class _StudentCard extends StatefulWidget {
  final Map user;
  final int index;
  final VoidCallback onTap;
  const _StudentCard({
    required this.user,
    required this.index,
    required this.onTap,
  });

  @override
  State<_StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<_StudentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _anim.forward();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fname = widget.user['fname'] ?? '';
    final lname = widget.user['lname'] ?? '';
    final email = widget.user['email'] ?? '';
    final initials =
        '${fname.isNotEmpty ? fname[0] : ''}${lname.isNotEmpty ? lname[0] : ''}'
            .toUpperCase();
    final avatarColor = _avatarColors[widget.index % _avatarColors.length];

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: avatarColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: avatarColor.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: avatarColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$fname $lname',
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          email,
                          style: const TextStyle(color: _textSub, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: _accent,
                      size: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  STUDENT MARKS
// ═══════════════════════════════════════════════════════════════
class StudentMarks extends StatefulWidget {
  final String studentId;
  const StudentMarks({super.key, required this.studentId});
  @override
  State<StudentMarks> createState() => _StudentMarksState();
}

class _StudentMarksState extends State<StudentMarks>
    with TickerProviderStateMixin {
  bool isLoading = false;
  String selectedType = 'Quiz';
  final TextEditingController totalmarks = TextEditingController();
  final TextEditingController obtainedmarks = TextEditingController();
  String get baseUrl => dotenv.env['BACKEND_API'] ?? '';

  late AnimationController _formAnim;

  @override
  void initState() {
    super.initState();
    _formAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    totalmarks.dispose();
    obtainedmarks.dispose();
    _formAnim.dispose();
    super.dispose();
  }

  Future<void> setMarks() async {
    if (totalmarks.text.isEmpty || obtainedmarks.text.isEmpty) {
      _showSnack('Please fill all fields');
      return;
    }
    final total = int.tryParse(totalmarks.text) ?? 0;
    final obtained = int.tryParse(obtainedmarks.text) ?? 0;
    if (obtained > total) {
      _showSnack('Obtained cannot exceed total marks');
      return;
    }
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.post(
        Uri.parse('http://$baseUrl:3000/marks/student'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'totalmarks': total,
          'obtainedmarks': obtained,
          'marksType': selectedType,
          'studentId': widget.studentId,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        _showSnack('Marks saved successfully ✓', isSuccess: true);
        totalmarks.clear();
        obtainedmarks.clear();
        setState(() => selectedType = 'Quiz');
      } else {
        _showSnack(data['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      setState(() => isLoading = false);
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

  double get _percentage {
    final t = int.tryParse(totalmarks.text) ?? 0;
    final o = int.tryParse(obtainedmarks.text) ?? 0;
    if (t == 0) return 0;
    return (o / t).clamp(0.0, 1.0);
  }

  String get _grade {
    final p = _percentage * 100;
    if (p >= 90) return 'A+';
    if (p >= 80) return 'A';
    if (p >= 70) return 'B';
    if (p >= 60) return 'C';
    if (p >= 50) return 'D';
    return 'F';
  }

  Color get _gradeColor {
    final p = _percentage * 100;
    if (p >= 80) return _teal;
    if (p >= 60) return _gold;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D0D22), Color(0xFF141430)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(bottom: BorderSide(color: _cardBorder)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _textPrimary,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACADEMIC PORTAL',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 3,
                        color: _accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Add Marks',
                      style: TextStyle(
                        fontSize: 22,
                        color: _textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Form ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Live grade preview card
                  _buildGradePreview(),
                  const SizedBox(height: 20),

                  // Total marks
                  _buildInputCard(
                    label: 'TOTAL MARKS',
                    icon: Icons.bar_chart_rounded,
                    iconColor: _accent,
                    controller: totalmarks,
                    hint: 'e.g. 100',
                  ),
                  const SizedBox(height: 14),

                  // Obtained marks
                  _buildInputCard(
                    label: 'OBTAINED MARKS',
                    icon: Icons.edit_rounded,
                    iconColor: _teal,
                    controller: obtainedmarks,
                    hint: 'e.g. 85',
                  ),
                  const SizedBox(height: 14),

                  // Assessment type
                  _buildTypeSelector(),
                  const SizedBox(height: 28),

                  // Submit
                  _buildSubmitButton(),
                  const SizedBox(height: 12),
                  const Text(
                    'Grade & percentage auto-calculated',
                    style: TextStyle(fontSize: 11, color: _textSub),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradePreview() {
    return AnimatedBuilder(
      animation: _formAnim,
      builder: (_, child) => child!,
      child: StatefulBuilder(
        builder: (context, setInner) {
          totalmarks.addListener(() {
            if (mounted) setInner(() {});
          });
          obtainedmarks.addListener(() {
            if (mounted) setInner(() {});
          });
          final pct = _percentage;
          final hasData =
              totalmarks.text.isNotEmpty && obtainedmarks.text.isNotEmpty;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_card, _surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasData ? _gradeColor.withOpacity(0.3) : _cardBorder,
              ),
              boxShadow: hasData
                  ? [
                      BoxShadow(
                        color: _gradeColor.withOpacity(0.1),
                        blurRadius: 20,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // Progress ring placeholder
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        value: hasData ? pct : 0,
                        strokeWidth: 5,
                        backgroundColor: _cardBorder,
                        valueColor: AlwaysStoppedAnimation(
                          hasData ? _gradeColor : _cardBorder,
                        ),
                      ),
                    ),
                    Text(
                      hasData ? _grade : '—',
                      style: TextStyle(
                        color: hasData ? _gradeColor : _textSub,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasData
                            ? '${(pct * 100).toStringAsFixed(1)}%'
                            : 'Fill in marks',
                        style: TextStyle(
                          color: hasData ? _textPrimary : _textSub,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasData
                            ? '${obtainedmarks.text} out of ${totalmarks.text} · $selectedType'
                            : 'Live grade preview',
                        style: const TextStyle(color: _textSub, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputCard({
    required String label,
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: _textSub,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: _textSub,
                fontSize: 22,
                fontWeight: FontWeight.w300,
              ),
              filled: true,
              fillColor: _surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: iconColor.withOpacity(0.6),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    const types = [
      {'label': 'Quiz', 'icon': Icons.quiz_rounded, 'color': _accent},
      {'label': 'Assignment', 'icon': Icons.assignment_rounded, 'color': _teal},
      {'label': 'Lab', 'icon': Icons.science_rounded, 'color': _gold},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.label_rounded, color: _textSub, size: 16),
              SizedBox(width: 8),
              Text(
                'ASSESSMENT TYPE',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: _textSub,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: types.map((t) {
              final label = t['label'] as String;
              final icon = t['icon'] as IconData;
              final color = t['color'] as Color;
              final isActive = selectedType == label;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedType = label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isActive ? color.withOpacity(0.15) : _surface,
                      border: Border.all(
                        color: isActive ? color.withOpacity(0.6) : _cardBorder,
                        width: isActive ? 1.5 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.2),
                                blurRadius: 12,
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          icon,
                          color: isActive ? color : _textSub,
                          size: 20,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive ? color : _textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: isLoading ? null : setMarks,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [_accent.withOpacity(0.5), _accent.withOpacity(0.4)]
                : [const Color(0xFF6C63FF), const Color(0xFF4F46E5)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(isLoading ? 0.1 : 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Submit Marks',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
