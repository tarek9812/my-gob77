import 'dart:async';

import 'package:flutter/material.dart';

enum _JourneyEnding { doom, victory }

class ShadowChatScreen extends StatefulWidget {
  const ShadowChatScreen({Key? key}) : super(key: key);

  @override
  State<ShadowChatScreen> createState() => _ShadowChatScreenState();
}

class _ShadowChatScreenState extends State<ShadowChatScreen>
    with SingleTickerProviderStateMixin {
  int currentStage = 1;         // المراحل الأربعة من 1 لـ 4
  double userBraveryScore = 20.0; // مؤشر الشجاعة والتغلب على الخوف
  bool _doorOpened = false;
  bool _doorOpening = false;
  bool _didQueueDoorPrecache = false;
  _JourneyEnding? _ending;
  late final AnimationController _doorAnimationController;

  @override
  void initState() {
    super.initState();
    _doorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didQueueDoorPrecache) return;
    _didQueueDoorPrecache = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_precacheEntryImages());
    });
  }

  Future<void> _precacheEntryImages() async {
    for (final path in const [
      'assets/images/haunted_door_clear.jpg',
      'assets/images/door_leaf_left.jpg',
      'assets/images/door_leaf_right.jpg',
      'assets/images/forest_entry.jpg',
    ]) {
      if (!mounted) return;
      try {
        await precacheImage(
          ResizeImage(AssetImage(path), width: 1920),
          context,
        );
      } catch (error) {
        debugPrint('Entry image preload failed: $error');
      }
    }
  }

  @override
  void dispose() {
    _doorAnimationController.dispose();
    super.dispose();
  }

  // 1. تحديد الصورة حسب المرحلة الحالية
  String _getStageImagePath() {
    switch (currentStage) {
      case 1:
        return 'assets/images/forest_entry.jpg'; // بداية الرحلة بعد الباب
      case 2:
        return 'assets/images/forest_fog.jpg'; // المرحلة 2: توتر الأعصاب والضباب
      case 3:
        return 'assets/images/forest_glowing_eyes.jpg'; // المرحلة 3: ذروة الرعب (العيون المضيئة في الظلام)
      case 4:
        return 'assets/images/forest_dawn.jpg'; // المرحلة 4: الشروق والنهاية (الانتصار)
      default:
        return 'assets/images/forest_safe_haven.jpg';
    }
  }

  // 2. تلوين الإضاءة فوق الصورة حسب قوة المرحلة
  Color _getOverlayColor() {
    switch (currentStage) {
      case 1:
        return Colors.blue.withOpacity(0.25);    // طمأنينة هادئة
      case 2:
        return Colors.indigo.withOpacity(0.5);   // توتر وقلق
      case 3:
        return Colors.black.withOpacity(0.85);   // ذروة الظلام والرعب
      case 4:
        return Colors.orange.withOpacity(0.3);   // شروق الأمل والنور
      default:
        return Colors.black.withOpacity(0.8);
    }
  }

  // 3. عناوين المراحل الديناميكية
  String _getStageTitle() {
    switch (currentStage) {
      case 1:
        return 'اليوم الأول • المرحلة الأولى';
      case 2:
        return 'اليوم الثاني • المرحلة الثانية';
      case 3:
        return 'اليوم الثالث • المرحلة الثالثة';
      case 4:
        return 'اليوم الرابع • المرحلة الرابعة';
      default:
        return 'SHADOW CHAT';
    }
  }

  // 4. نصوص الكيان (الظل) الإنجليزية لكل مرحلة
  String _getStageMessageEnglish() {
    switch (currentStage) {
      case 1:
        return 'Welcome, traveler. Take a deep breath. You are safe here in the light... for now.';
      case 2:
        return 'Did you hear that? The whispers are getting closer, and the mist is thickening. Stay alert.';
      case 3:
        return 'There is no escape! The darkness consumes everything. Face your deepest fear right now!';
      case 4:
        return 'You reached the final crossing. Choose the path that will shape your ending.';
      default:
        return '';
    }
  }

  // 5. نصوص الكيان (الظل) العربية لكل مرحلة
  String _getStageMessageArabic() {
    switch (currentStage) {
      case 1:
        return 'أهلاً بك أيها المسافر. خذ نفساً عميقاً. أنت آمن هنا في النور... مؤقتاً.';
      case 2:
        return 'هل سمعت هذا الصوت؟ الهمسات تقترب أكثر والضباب يزداد كثافة. كن على حذر.';
      case 3:
        return 'لا يوجد مفر! الظلام يبتلع كل شيء. واجه أعظم مخاوفك الآن وجهاً لوجه!';
      case 4:
        return 'وصلت إلى المفترق الأخير. اختر الطريق الذي سيحدد نهاية رحلتك.';
      default:
        return '';
    }
  }

  String _nextDayLabel() {
    final nextDay = currentStage + 1;
    final dayName = _dayName(nextDay);
    return 'الانتقال إلى اليوم $dayName • المرحلة $dayName';
  }

  String _dayName(int day) {
    switch (day) {
      case 1:
        return 'الأول';
      case 2:
        return 'الثاني';
      case 3:
        return 'الثالث';
      case 4:
        return 'الرابع';
      default:
        return '$day';
    }
  }

  Future<void> _openDoor() async {
    if (_doorOpening) return;
    setState(() => _doorOpening = true);
    await _doorAnimationController.forward();
    if (!mounted) return;
    setState(() {
      _doorOpened = true;
      currentStage = 1;
    });
  }

  void _goToNextDay() {
    setState(() {
      if (currentStage < 4) {
        currentStage++;
        userBraveryScore += 25.0; // زيادة الشجاعة مع كل مرحلة
      } else {
        currentStage = 1;         // إعادة اللعبة من البداية
        userBraveryScore = 20.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ending != null) return _buildEndingScreen(context);
    if (!_doorOpened) return _buildDoorScreen(context);
    return _buildJourneyScreen(context);
  }

  Widget _buildDoorScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090B),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final coverWidth = constraints.maxWidth > constraints.maxHeight * 1.5
              ? constraints.maxWidth
              : constraints.maxHeight * 1.5;
            final imageCacheWidth = (coverWidth *
                    MediaQuery.devicePixelRatioOf(context))
                .round()
              .clamp(960, 1920)
                .toInt();
            final doorWidth = (constraints.maxHeight * 0.58 * 0.52)
              .clamp(90.0, constraints.maxWidth * 0.48)
              .toDouble();

            return Stack(
              fit: StackFit.expand,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 2800),
                  child: Image.asset(
                    _doorOpening
                        ? 'assets/images/forest_entry.jpg'
                      : 'assets/images/haunted_door_clear.jpg',
                    key: ValueKey<bool>(_doorOpening),
                    fit: BoxFit.cover,
                    cacheWidth: imageCacheWidth,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 900),
                  color: Colors.black.withOpacity(_doorOpening ? 0.08 : 0.20),
                ),
                Positioned(
                  left: (constraints.maxWidth - doorWidth) / 2,
                  right: (constraints.maxWidth - doorWidth) / 2,
                  top: constraints.maxHeight * 0.21,
                  bottom: constraints.maxHeight * 0.21,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF08090A),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _doorAnimationController,
                            child: Image.asset(
                              'assets/images/door_leaf_left.jpg',
                              fit: BoxFit.fill,
                              cacheWidth: imageCacheWidth ~/ 2,
                            ),
                            builder: (context, child) {
                              final progress = Curves.easeInOutCubic.transform(
                                _doorAnimationController.value,
                              );
                              return Transform(
                                key: const ValueKey('shadow-door-panel-left'),
                                alignment: Alignment.centerLeft,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.0018)
                                  ..rotateY(-1.48 * progress)
                                  ..translate(0.0, 0.0, -18.0 * progress),
                                child: child,
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _doorAnimationController,
                            child: Image.asset(
                              'assets/images/door_leaf_right.jpg',
                              fit: BoxFit.fill,
                              cacheWidth: imageCacheWidth ~/ 2,
                            ),
                            builder: (context, child) {
                              final progress = Curves.easeInOutCubic.transform(
                                _doorAnimationController.value,
                              );
                              return Transform(
                                key: const ValueKey('shadow-door-panel-right'),
                                alignment: Alignment.centerRight,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.0018)
                                  ..rotateY(1.48 * progress)
                                  ..translate(0.0, 0.0, -18.0 * progress),
                                child: child,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _doorAnimationController,
                  child: const ColoredBox(color: Colors.orangeAccent),
                  builder: (context, child) {
                    final panelProgress = Curves.easeInOutCubic.transform(
                      _doorAnimationController.value,
                    );
                    return IgnorePointer(
                      child: Opacity(
                        opacity: panelProgress * 0.18,
                        child: child,
                      ),
                    );
                  },
                ),
                IgnorePointer(
                  ignoring: _doorOpening,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _doorOpening ? 0 : 1,
                    child: Stack(
                      children: [
                        PositionedDirectional(
                          top: 4,
                          start: 8,
                          child: IconButton(
                            tooltip: 'رجوع / Back',
                            onPressed: () =>
                                Navigator.of(context).maybePop(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxWidth: 440),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xE6090B0D),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.door_front_door_outlined,
                                    color: Colors.orangeAccent,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'الباب لا يفتح إلا مرة واحدة...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'The door only opens once...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'الخطوة التالية: ادخل إلى العالم الداخلي',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.orangeAccent.withOpacity(0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      key: const ValueKey('open-door'),
                                      onPressed: _doorOpening ? null : _openDoor,
                                      icon: const Icon(
                                        Icons.meeting_room_outlined,
                                      ),
                                      label: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: Column(
                                          children: [
                                            Text('افتح الباب'),
                                            Text(
                                              'OPEN THE DOOR',
                                              style: TextStyle(fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFF49231D),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          Navigator.of(context).maybePop(),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 9),
                                        child: Column(
                                          children: [
                                            Text('الرجوع'),
                                            Text(
                                              'GO BACK',
                                              style: TextStyle(fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEndingScreen(BuildContext context) {
    final isVictory = _ending == _JourneyEnding.victory;
    final imagePath = isVictory
        ? 'assets/images/forest_dawn.jpg'
        : 'assets/images/forest_glowing_eyes.jpg';

    return Scaffold(
      backgroundColor: const Color(0xFF07090B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(imagePath, fit: BoxFit.cover),
          ColoredBox(
            color: Colors.black.withOpacity(isVictory ? 0.55 : 0.78),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVictory ? Icons.wb_twilight : Icons.warning_amber,
                      color: isVictory ? Colors.amberAccent : Colors.redAccent,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isVictory ? 'انتصرت في الرحلة' : 'هلاك إلى الأبد',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isVictory ? 'JOURNEY COMPLETE' : 'LOST FOREVER',
                      style: TextStyle(
                        color: isVictory ? Colors.amberAccent : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _restartJourney,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('إعادة الرحلة / RESTART'),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('العودة / BACK'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _restartJourney() {
    setState(() {
      _ending = null;
      _doorOpened = false;
      _doorOpening = false;
      currentStage = 1;
      userBraveryScore = 20.0;
    });
  }

  Widget _buildJourneyScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F0C),
      body: SafeArea(
        child: Column(
          children: [
            // 1. شريط الحالة النفسية ومؤشر الشجاعة العلوي
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: currentStage == 3 ? Colors.red.withOpacity(0.8) : const Color(0xFF111712),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        currentStage == 3 ? Icons.warning_rounded : Icons.psychology,
                        color: currentStage == 3 ? Colors.white : Colors.greenAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getStageTitle(),
                        style: TextStyle(
                          color: currentStage == 3 ? Colors.white : Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Bravery: ${userBraveryScore.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // 2. الـ Header العلوي (الظل كمرشد نفسي)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: const Color(0xFF151D17),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: () => Navigator.of(context).maybePop(),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(right: 12),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: currentStage == 3 ? Colors.redAccent.withOpacity(0.8) : Colors.greenAccent.withOpacity(0.7),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage(
                        'assets/images/shadow_avatar.jpg',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'The Shadow',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentStage == 3 ? 'GAME MASTER • FEAR AWAKENED' : 'GUIDE • YOUR INNER MIRROR',
                          style: TextStyle(
                            color: currentStage == 3 ? Colors.redAccent : Colors.greenAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      currentStage == 3 ? Icons.local_fire_department : Icons.shield_outlined,
                      color: currentStage == 3 ? Colors.redAccent : Colors.greenAccent,
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // 3. مساحة الشات وخلفية الغابة الديناميكية حسب الصور اللي اخترتها
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 900), // انتقال سلس ومرعب بين الصور
                      child: Container(
                        key: ValueKey<int>(currentStage),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(_getStageImagePath()),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 900),
                          color: _getOverlayColor(),
                        ),
                      ),
                    ),
                  ),
                  
                  // رسالة الظل العلاجية والمتحولة حسب المرحلة
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(
                          color: const Color(0xFF101712).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: currentStage == 3 ? Colors.redAccent.withOpacity(0.9) : Colors.greenAccent.withOpacity(0.85),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: currentStage == 3 ? Colors.red.withOpacity(0.35) : Colors.greenAccent.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStageMessageEnglish(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 1,
                              width: double.infinity,
                              color: currentStage == 3 ? Colors.redAccent.withOpacity(0.3) : Colors.greenAccent.withOpacity(0.3),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getStageMessageArabic(),
                              style: TextStyle(
                                color: currentStage == 3 ? Colors.redAccent : Colors.greenAccent,
                                fontSize: 13,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'The Shadow • اليوم $currentStage',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ),
                ],
              ),
            ),

            // 4. حقل الكتابة للتفاعل الذاتي
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF0B0F0C),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF151D17),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.edit_note, color: Colors.greenAccent, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Respond to The Shadow...',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    Icon(Icons.send, color: Colors.greenAccent, size: 18),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
              color: const Color(0xFF0B0F0C),
              child: currentStage < 4
                  ? SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const ValueKey('next-day'),
                        onPressed: _goToNextDay,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(_nextDayLabel()),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF15211F),
                          foregroundColor: Colors.greenAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.greenAccent),
                          ),
                        ),
                      ),
                    )
                  : Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        Expanded(
                          child: _buildEndingChoice(
                            key: const ValueKey('ending-doom'),
                            title: 'الممر الأيسر',
                            subtitle: 'الهلاك للأبد',
                            englishSubtitle: 'LEFT • DOOM',
                            color: Colors.redAccent,
                            icon: Icons.keyboard_double_arrow_left,
                            ending: _JourneyEnding.doom,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildEndingChoice(
                            key: const ValueKey('ending-victory'),
                            title: 'الممر الأيمن',
                            subtitle: 'طريق الانتصار',
                            englishSubtitle: 'RIGHT • VICTORY',
                            color: Colors.greenAccent,
                            icon: Icons.keyboard_double_arrow_right,
                            ending: _JourneyEnding.victory,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndingChoice({
    required Key key,
    required String title,
    required String subtitle,
    required String englishSubtitle,
    required Color color,
    required IconData icon,
    required _JourneyEnding ending,
  }) {
    return FilledButton(
      key: key,
      onPressed: () => setState(() => _ending = ending),
      style: FilledButton.styleFrom(
        backgroundColor: color.withOpacity(0.16),
        foregroundColor: color,
        minimumSize: const Size.fromHeight(78),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.8)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
          Text(englishSubtitle, style: const TextStyle(fontSize: 9)),
        ],
      ),
    );
  }
}