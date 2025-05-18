import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'game_break_channel',
        channelName: 'Game Break',
        channelDescription: 'gaming breaks notifications',
        defaultColor: Colors.blue,
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        criticalAlerts: true,
      )
    ],
    debug: true,
  );

  await AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications(
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.CriticalAlert,
        ],
      );
    }
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Break',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: Color(0xFF00FFFF),
            shadows: [
              Shadow(blurRadius: 10, color: Color(0xFF00FFFF)),
              Shadow(blurRadius: 20, color: Colors.blueAccent),
            ],
          ),
          centerTitle: true,
        ),
      ),
      home: BreakTimerPage(),
    );
  }
}

class BreakTimerPage extends StatefulWidget {
  @override
  State<BreakTimerPage> createState() => _BreakTimerPageState();
}

class _BreakTimerPageState extends State<BreakTimerPage> {
  int sessionCount = 0;
  final TextEditingController _minutesController = TextEditingController(text: '60');

  final DocumentReference<Map<String, dynamic>> sessionDoc =
  FirebaseFirestore.instance.collection('users').doc('admin');

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    int localSessions = prefs.getInt('sessions') ?? 0;

    try {
      final snapshot = await sessionDoc.get();
      if (snapshot.exists && snapshot.data() != null) {
        int remoteSessions = snapshot.data()!['sessionCount'] ?? 0;
        sessionCount = remoteSessions;
        await prefs.setInt('sessions', remoteSessions);
      } else {
        sessionCount = localSessions;
      }
    } catch (e) {
      sessionCount = localSessions;
    }

    setState(() {});
  }

  Future<void> _incrementSessions() async {
    final prefs = await SharedPreferences.getInstance();
    sessionCount += 1;

    await prefs.setInt('sessions', sessionCount);

    try {
      await sessionDoc.set({
        'sessionCount': sessionCount,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
    }

    setState(() {});
  }

  void startSession({required int minutes}) {
    final now = DateTime.now();

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: now.millisecondsSinceEpoch.remainder(100000),
        channelKey: 'game_break_channel',
        title: '🎮 Break!',
        body: 'Game off dude! Time to chill!',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar(
        year: now.year,
        month: now.month,
        day: now.day,
        hour: now.add(Duration(minutes: minutes)).hour,
        minute: now.add(Duration(minutes: minutes)).minute,
        second: 0,
        millisecond: 0,
        repeats: false,
      ),
    );

    _incrementSessions();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('gaming sesh started! gaming break in $minutes minutes.')),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neonBlue = Color(0xFF00C2FF);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'gam3boi break',
            style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 30)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'gaming sessions today:',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: neonBlue.withOpacity(0.9),
                  shadows: [
                    Shadow(blurRadius: 8, color: neonBlue),
                  ],
                ),
              ),
              SizedBox(height: 10),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 400),
                child: Text(
                  '$sessionCount',
                  key: ValueKey<int>(sessionCount),
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: neonBlue,
                    shadows: [
                      Shadow(blurRadius: 20, color: neonBlue),
                      Shadow(blurRadius: 40, color: neonBlue),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: _minutesController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: neonBlue,
                  fontSize: 25,
                ),
                decoration: InputDecoration(
                  labelText: 'gaming duration (minutes)',
                  labelStyle: TextStyle(color: neonBlue),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: neonBlue, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: neonBlue, width: 3),
                  ),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.6),
                ),
                cursorColor: neonBlue,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  final minutes = int.tryParse(_minutesController.text) ?? 50;
                  if (minutes <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('enter session duration')),
                    );
                    return;
                  }
                  startSession(minutes: minutes);
                },
                icon: Icon(Icons.play_arrow, size: 28, color: Colors.white),
                label: Text(
                  'start game sesh',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: Colors.transparent,
                  shadowColor: neonBlue.withOpacity(0.6),
                  elevation: 20,
                ).copyWith(
                  overlayColor: WidgetStateProperty.all(neonBlue.withOpacity(0.2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}