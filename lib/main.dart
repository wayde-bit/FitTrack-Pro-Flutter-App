// FitTracker Pro - Complete Gym Management App
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(FitTrackerApp());
}

class FitTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTracker Pro',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange.shade600,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
      home: MainNavigationScreen(),
      routes: {
        '/workout-detail': (context) => WorkoutDetailScreen(),
        '/exercise-detail': (context) => ExerciseDetailScreen(),
        '/add-workout': (context) => AddWorkoutScreen(),
        '/progress': (context) => ProgressScreen(),
      },
    );
  }
}

// Data Models
class Exercise {
  final String id;
  final String name;
  final String category;
  final String muscleGroup;
  final String description;
  final String instructions;
  final int defaultSets;
  final int defaultReps;
  final double defaultWeight;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.muscleGroup,
    required this.description,
    required this.instructions,
    this.defaultSets = 3,
    this.defaultReps = 10,
    this.defaultWeight = 0,
  });
}

class WorkoutSet {
  final int reps;
  final double weight;
  final bool completed;
  final DateTime timestamp;

  WorkoutSet({
    required this.reps,
    required this.weight,
    this.completed = false,
    required this.timestamp,
  });

  WorkoutSet copyWith({int? reps, double? weight, bool? completed}) {
    return WorkoutSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      completed: completed ?? this.completed,
      timestamp: this.timestamp,
    );
  }
}

class WorkoutExercise {
  final Exercise exercise;
  final List<WorkoutSet> sets;

  WorkoutExercise({
    required this.exercise,
    required this.sets,
  });
}

class Workout {
  final String id;
  final String name;
  final DateTime date;
  final List<WorkoutExercise> exercises;
  final Duration duration;
  final bool completed;

  Workout({
    required this.id,
    required this.name,
    required this.date,
    required this.exercises,
    required this.duration,
    this.completed = false,
  });
}

class Goal {
  final String id;
  final String name;
  final String description;
  final double target;
  final double current;
  final String unit;
  final DateTime deadline;
  final GoalType type;

  Goal({
    required this.id,
    required this.name,
    required this.description,
    required this.target,
    required this.current,
    required this.unit,
    required this.deadline,
    required this.type,
  });

  double get progress => (current / target * 100).clamp(0, 100);
  bool get isCompleted => current >= target;
}

enum GoalType { weight, strength, endurance, frequency }

// Data Service (Singleton)
class FitnessDataService {
  static final FitnessDataService _instance = FitnessDataService._internal();
  factory FitnessDataService() => _instance;
  FitnessDataService._internal();

  final List<Exercise> _exercises = [
    Exercise(
      id: '1',
      name: 'Bench Press',
      category: 'Strength',
      muscleGroup: 'Chest',
      description: 'Classic chest exercise',
      instructions:
          '1. Lie on bench\n2. Grip bar shoulder-width\n3. Lower to chest\n4. Press up explosively',
      defaultSets: 4,
      defaultReps: 8,
      defaultWeight: 60,
    ),
    Exercise(
      id: '2',
      name: 'Squat',
      category: 'Strength',
      muscleGroup: 'Legs',
      description: 'King of all exercises',
      instructions:
          '1. Feet shoulder-width apart\n2. Lower until thighs parallel\n3. Drive through heels\n4. Keep chest up',
      defaultSets: 4,
      defaultReps: 10,
      defaultWeight: 80,
    ),
    Exercise(
      id: '3',
      name: 'Deadlift',
      category: 'Strength',
      muscleGroup: 'Back',
      description: 'Full body power move',
      instructions:
          '1. Bar over mid-foot\n2. Grip shoulder-width\n3. Keep back straight\n4. Drive hips forward',
      defaultSets: 3,
      defaultReps: 5,
      defaultWeight: 100,
    ),
    Exercise(
      id: '4',
      name: 'Pull-ups',
      category: 'Bodyweight',
      muscleGroup: 'Back',
      description: 'Upper body pulling exercise',
      instructions:
          '1. Hang from bar\n2. Pull chest to bar\n3. Control descent\n4. Full extension',
      defaultSets: 3,
      defaultReps: 8,
      defaultWeight: 0,
    ),
    Exercise(
      id: '5',
      name: 'Running',
      category: 'Cardio',
      muscleGroup: 'Full Body',
      description: 'Cardiovascular endurance',
      instructions:
          '1. Warm up 5 minutes\n2. Maintain steady pace\n3. Focus on breathing\n4. Cool down properly',
      defaultSets: 1,
      defaultReps: 30,
      defaultWeight: 0,
    ),
  ];

  final List<Workout> _workouts = [];
  final List<Goal> _goals = [];

  List<Exercise> get exercises => List.unmodifiable(_exercises);
  List<Workout> get workouts => List.unmodifiable(_workouts);
  List<Goal> get goals => List.unmodifiable(_goals);

  void addWorkout(Workout workout) {
    _workouts.add(workout);
  }

  void addGoal(Goal goal) {
    _goals.add(goal);
  }

  List<Exercise> getExercisesByCategory(String category) {
    return _exercises.where((e) => e.category == category).toList();
  }

  List<Workout> getRecentWorkouts({int limit = 5}) {
    final sorted = List<Workout>.from(_workouts)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  Map<String, int> getWorkoutStats() {
    final now = DateTime.now();
    final thisWeek =
        _workouts.where((w) => now.difference(w.date).inDays <= 7).length;
    final thisMonth =
        _workouts.where((w) => now.difference(w.date).inDays <= 30).length;

    return {
      'total': _workouts.length,
      'thisWeek': thisWeek,
      'thisMonth': thisMonth,
    };
  }
}

// Main Navigation with Bottom Navigation Bar
class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    DashboardScreen(),
    WorkoutsScreen(),
    ExercisesScreen(),
    GoalsScreen(),
    ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: 'Workouts'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Exercises'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Dashboard Screen
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FitnessDataService _dataService = FitnessDataService();

  @override
  Widget build(BuildContext context) {
    final stats = _dataService.getWorkoutStats();
    final recentWorkouts = _dataService.getRecentWorkouts(limit: 3);

    return Scaffold(
      appBar: AppBar(
        title: Text('FitTracker Pro'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ready for your next workout?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add-workout');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange,
                    ),
                    child: Text('Start Workout'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Stats Cards
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Workouts',
                    '${stats['total']}',
                    Icons.fitness_center,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'This Week',
                    '${stats['thisWeek']}',
                    Icons.calendar_today,
                    Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'This Month',
                    '${stats['thisMonth']}',
                    Icons.calendar_month,
                    Colors.purple,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Streak',
                    '7 days',
                    Icons.local_fire_department,
                    Colors.red,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Recent Workouts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Workouts',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to workouts screen
                  },
                  child: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 16),
            recentWorkouts.isEmpty
                ? Container(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.fitness_center,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No workouts yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start your fitness journey today!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: recentWorkouts.length,
                    itemBuilder: (context, index) {
                      final workout = recentWorkouts[index];
                      return _buildWorkoutCard(workout);
                    },
                  ),

            SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildQuickActionCard(
                  'Log Workout',
                  Icons.add_circle,
                  Colors.orange,
                  () => Navigator.pushNamed(context, '/add-workout'),
                ),
                _buildQuickActionCard(
                  'View Progress',
                  Icons.trending_up,
                  Colors.green,
                  () => Navigator.pushNamed(context, '/progress'),
                ),
                _buildQuickActionCard(
                  'Browse Exercises',
                  Icons.list,
                  Colors.blue,
                  () {
                    // Navigate to exercises
                  },
                ),
                _buildQuickActionCard(
                  'Set Goals',
                  Icons.flag,
                  Colors.purple,
                  () {
                    // Navigate to goals
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.fitness_center, color: Colors.white),
        ),
        title: Text(workout.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${workout.exercises.length} exercises'),
            Text('${workout.duration.inMinutes} minutes'),
          ],
        ),
        trailing: workout.completed
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.radio_button_unchecked, color: Colors.grey),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/workout-detail',
            arguments: workout,
          );
        },
      ),
    );
  }

  Widget _buildQuickActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Workouts Screen
class WorkoutsScreen extends StatefulWidget {
  @override
  _WorkoutsScreenState createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final FitnessDataService _dataService = FitnessDataService();

  @override
  Widget build(BuildContext context) {
    final workouts = _dataService.workouts;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Workouts'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add-workout');
            },
          ),
        ],
      ),
      body: workouts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No workouts recorded yet',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to create your first workout',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add-workout');
                    },
                    child: Text('Create Workout'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout =
                    workouts[workouts.length - 1 - index]; // Reverse order
                return _buildWorkoutCard(workout);
              },
            ),
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    workout.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (workout.completed)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Completed',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${workout.date.day}/${workout.date.month}/${workout.date.year}',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(width: 16),
                Icon(Icons.timer, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${workout.duration.inMinutes} min',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.fitness_center, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${workout.exercises.length} exercises',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/workout-detail',
                      arguments: workout,
                    );
                  },
                  child: Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Exercises Screen
class ExercisesScreen extends StatefulWidget {
  @override
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final FitnessDataService _dataService = FitnessDataService();
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final exercises = _selectedCategory == 'All'
        ? _dataService.exercises
        : _dataService.getExercisesByCategory(_selectedCategory);

    final categories = ['All', 'Strength', 'Cardio', 'Bodyweight'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Library'),
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: Colors.orange.shade100,
                    checkmarkColor: Colors.orange,
                  ),
                );
              },
            ),
          ),

          // Exercise List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return _buildExerciseCard(exercise);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(exercise.category),
          child: Icon(
            _getCategoryIcon(exercise.category),
            color: Colors.white,
          ),
        ),
        title: Text(exercise.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.muscleGroup),
            Text(
              exercise.description,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/exercise-detail',
            arguments: exercise,
          );
        },
        isThreeLine: true,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Strength':
        return Colors.orange;
      case 'Cardio':
        return Colors.red;
      case 'Bodyweight':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Strength':
        return Icons.fitness_center;
      case 'Cardio':
        return Icons.directions_run;
      case 'Bodyweight':
        return Icons.accessibility;
      default:
        return Icons.help;
    }
  }
}

// Goals Screen
class GoalsScreen extends StatefulWidget {
  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final FitnessDataService _dataService = FitnessDataService();

  @override
  void initState() {
    super.initState();
    _initializeSampleGoals();
  }

  void _initializeSampleGoals() {
    if (_dataService.goals.isEmpty) {
      _dataService.addGoal(Goal(
        id: '1',
        name: 'Bench Press 100kg',
        description: 'Increase bench press to 100kg',
        target: 100,
        current: 75,
        unit: 'kg',
        deadline: DateTime.now().add(Duration(days: 90)),
        type: GoalType.strength,
      ));

      _dataService.addGoal(Goal(
        id: '2',
        name: 'Workout 4x per week',
        description: 'Maintain consistency',
        target: 16,
        current: 12,
        unit: 'workouts',
        deadline: DateTime.now().add(Duration(days: 30)),
        type: GoalType.frequency,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final goals = _dataService.goals;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Goals'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddGoalDialog,
          ),
        ],
      ),
      body: goals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No goals set yet',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Set your first fitness goal!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return _buildGoalCard(goal);
              },
            ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (goal.isCompleted)
                  Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            SizedBox(height: 8),
            Text(
              goal.description,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 16),

            // Progress bar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${goal.current.toStringAsFixed(0)}/${goal.target.toStringAsFixed(0)} ${goal.unit}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${goal.progress.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: goal.isCompleted
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: goal.progress / 100,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          goal.isCompleted ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deadline: ${goal.deadline.day}/${goal.deadline.month}/${goal.deadline.year}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                TextButton(
                  onPressed: () => _showUpdateProgressDialog(goal),
                  child: Text('Update Progress'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AddGoalDialog(),
    ).then((goal) {
      if (goal != null) {
        setState(() {
          _dataService.addGoal(goal);
        });
      }
    });
  }

  void _showUpdateProgressDialog(Goal goal) {
    final controller = TextEditingController(text: goal.current.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current progress for: ${goal.name}'),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Current ${goal.unit}',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, you'd update the goal here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Progress updated!')),
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}

// Add Goal Dialog
class AddGoalDialog extends StatefulWidget {
  @override
  _AddGoalDialogState createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  final _unitController = TextEditingController();

  GoalType _selectedType = GoalType.strength;
  DateTime _selectedDeadline = DateTime.now().add(Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Goal'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Goal Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _targetController,
                decoration: InputDecoration(
                  labelText: 'Target Value',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: InputDecoration(
                  labelText: 'Unit (kg, reps, workouts, etc.)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final goal = Goal(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                description: _descriptionController.text,
                target: double.parse(_targetController.text),
                current: 0,
                unit: _unitController.text,
                deadline: _selectedDeadline,
                type: _selectedType,
              );
              Navigator.pop(context, goal);
            }
          },
          child: Text('Add Goal'),
        ),
      ],
    );
  }
}

// Profile Screen
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: Colors.orange),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Kiarie Wayde',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Fitness Enthusiast',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Stats Overview
            Row(
              children: [
                Expanded(
                    child:
                        _buildStatCard('Weight', '75kg', Icons.monitor_weight)),
                SizedBox(width: 16),
                Expanded(
                    child: _buildStatCard('Height', '180cm', Icons.height)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('BMI', '23.1', Icons.calculate)),
                SizedBox(width: 16),
                Expanded(child: _buildStatCard('Age', '28', Icons.cake)),
              ],
            ),

            SizedBox(height: 24),

            // Menu Items
            _buildMenuItem(
              'Personal Information',
              Icons.person_outline,
              () {},
            ),
            _buildMenuItem(
              'Workout Preferences',
              Icons.settings,
              () {},
            ),
            _buildMenuItem(
              'Notifications',
              Icons.notifications_outlined,
              () {},
            ),
            _buildMenuItem(
              'Export Data',
              Icons.download,
              () {},
            ),
            _buildMenuItem(
              'Privacy Policy',
              Icons.privacy_tip_outlined,
              () {},
            ),
            _buildMenuItem(
              'About',
              Icons.info_outline,
              () {},
            ),

            SizedBox(height: 24),

            // Sign Out Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showSignOutDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Colors.orange, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle sign out
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// Add Workout Screen
class AddWorkoutScreen extends StatefulWidget {
  @override
  _AddWorkoutScreenState createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final FitnessDataService _dataService = FitnessDataService();
  final _nameController = TextEditingController();
  final List<WorkoutExercise> _selectedExercises = [];
  DateTime _selectedDate = DateTime.now();
  Duration _estimatedDuration = Duration(minutes: 45);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Workout'),
        actions: [
          TextButton(
            onPressed: _selectedExercises.isNotEmpty ? _saveWorkout : null,
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout Details
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workout Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Workout Name',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Push Day, Leg Day',
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Duration',
                              border: OutlineInputBorder(),
                            ),
                            child: Text('${_estimatedDuration.inMinutes} min'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Selected Exercises
            Text(
              'Exercises (${_selectedExercises.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            if (_selectedExercises.isEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No exercises added yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add exercises from the library below',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _selectedExercises.length,
                itemBuilder: (context, index) {
                  final workoutExercise = _selectedExercises[index];
                  return _buildSelectedExerciseCard(workoutExercise, index);
                },
              ),

            SizedBox(height: 24),

            // Exercise Library
            Text(
              'Exercise Library',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _dataService.exercises.length,
              itemBuilder: (context, index) {
                final exercise = _dataService.exercises[index];
                final isSelected = _selectedExercises
                    .any((we) => we.exercise.id == exercise.id);

                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getCategoryColor(exercise.category),
                      child: Icon(
                        _getCategoryIcon(exercise.category),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(exercise.name),
                    subtitle: Text(exercise.muscleGroup),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Icon(Icons.add_circle_outline),
                    onTap: isSelected ? null : () => _addExercise(exercise),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedExerciseCard(
      WorkoutExercise workoutExercise, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    workoutExercise.exercise.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeExercise(index),
                ),
              ],
            ),
            Text(
              workoutExercise.exercise.muscleGroup,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 12),
            Text(
              'Sets: ${workoutExercise.sets.length}',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _addExercise(Exercise exercise) {
    setState(() {
      final sets = List.generate(
        exercise.defaultSets,
        (index) => WorkoutSet(
          reps: exercise.defaultReps,
          weight: exercise.defaultWeight,
          timestamp: DateTime.now(),
        ),
      );

      _selectedExercises.add(WorkoutExercise(
        exercise: exercise,
        sets: sets,
      ));
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
    });
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveWorkout() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a workout name')),
      );
      return;
    }

    final workout = Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      date: _selectedDate,
      exercises: _selectedExercises,
      duration: _estimatedDuration,
      completed: false,
    );

    _dataService.addWorkout(workout);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Workout saved successfully!')),
    );

    Navigator.pop(context);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Strength':
        return Colors.orange;
      case 'Cardio':
        return Colors.red;
      case 'Bodyweight':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Strength':
        return Icons.fitness_center;
      case 'Cardio':
        return Icons.directions_run;
      case 'Bodyweight':
        return Icons.accessibility;
      default:
        return Icons.help;
    }
  }
}

// Exercise Detail Screen
class ExerciseDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Exercise exercise =
        ModalRoute.of(context)!.settings.arguments as Exercise;

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Header
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: _getCategoryColor(exercise.category),
                      child: Icon(
                        _getCategoryIcon(exercise.category),
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            exercise.muscleGroup,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(exercise.category),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              exercise.category,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Description
            _buildSection(
              'Description',
              exercise.description,
              Icons.description,
            ),

            SizedBox(height: 20),

            // Instructions
            _buildSection(
              'Instructions',
              exercise.instructions,
              Icons.list_alt,
            ),

            SizedBox(height: 20),

            // Default Settings
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Recommended Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSettingItem(
                              'Sets', '${exercise.defaultSets}'),
                        ),
                        Expanded(
                          child: _buildSettingItem(
                              'Reps', '${exercise.defaultReps}'),
                        ),
                        if (exercise.defaultWeight > 0)
                          Expanded(
                            child: _buildSettingItem(
                                'Weight', '${exercise.defaultWeight}kg'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Action Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/add-workout');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Add to Workout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Strength':
        return Colors.orange;
      case 'Cardio':
        return Colors.red;
      case 'Bodyweight':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Strength':
        return Icons.fitness_center;
      case 'Cardio':
        return Icons.directions_run;
      case 'Bodyweight':
        return Icons.accessibility;
      default:
        return Icons.help;
    }
  }
}

// Workout Detail Screen
class WorkoutDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Workout workout =
        ModalRoute.of(context)!.settings.arguments as Workout;

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Share workout functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout Summary
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          workout.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (workout.completed)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Completed',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildInfoItem(Icons.calendar_today,
                            '${workout.date.day}/${workout.date.month}/${workout.date.year}'),
                        SizedBox(width: 24),
                        _buildInfoItem(
                            Icons.timer, '${workout.duration.inMinutes} min'),
                        SizedBox(width: 24),
                        _buildInfoItem(Icons.fitness_center,
                            '${workout.exercises.length} exercises'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Exercises
            Text(
              'Exercises',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: workout.exercises.length,
              itemBuilder: (context, index) {
                final workoutExercise = workout.exercises[index];
                return _buildExerciseCard(workoutExercise);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(WorkoutExercise workoutExercise) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workoutExercise.exercise.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              workoutExercise.exercise.muscleGroup,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Sets:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Column(
              children: workoutExercise.sets.asMap().entries.map((entry) {
                final index = entry.key;
                final set = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: set.completed
                        ? Colors.green.shade50
                        : Colors.grey.shade50,
                    border: Border.all(
                      color: set.completed
                          ? Colors.green.shade200
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: set.completed
                              ? Colors.green
                              : Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              '${set.reps} reps',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            if (set.weight > 0) ...[
                              SizedBox(width: 16),
                              Text(
                                '${set.weight}kg',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (set.completed)
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Progress Screen
class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final FitnessDataService _dataService = FitnessDataService();
  String _selectedPeriod = 'Week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'View Progress:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: [
                          ButtonSegment(value: 'Week', label: Text('Week')),
                          ButtonSegment(value: 'Month', label: Text('Month')),
                          ButtonSegment(value: 'Year', label: Text('Year')),
                        ],
                        selected: {_selectedPeriod},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _selectedPeriod = selection.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Workout Frequency Chart
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workout Frequency',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 200,
                      child: _buildWorkoutChart(),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Statistics Overview
            Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                    'Total Workouts',
                    '${_dataService.workouts.length}',
                    Icons.fitness_center,
                    Colors.orange),
                _buildStatCard('This Month', '${_getThisMonthWorkouts()}',
                    Icons.calendar_month, Colors.blue),
                _buildStatCard(
                    'Average/Week',
                    '${_getAveragePerWeek().toStringAsFixed(1)}',
                    Icons.trending_up,
                    Colors.green),
                _buildStatCard('Longest Streak', '7 days',
                    Icons.local_fire_department, Colors.red),
              ],
            ),

            SizedBox(height: 20),

            // Goals Progress
            Text(
              'Goals Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            if (_dataService.goals.isEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.flag, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No goals set yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Set goals to track your progress',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _dataService.goals.length,
                itemBuilder: (context, index) {
                  final goal = _dataService.goals[index];
                  return _buildGoalProgressCard(goal);
                },
              ),

            SizedBox(height: 20),

            // Body Measurements (Placeholder)
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Body Measurements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _buildMeasurementItem(
                                'Weight', '75.0', 'kg', Colors.blue)),
                        SizedBox(width: 16),
                        Expanded(
                            child: _buildMeasurementItem(
                                'BMI', '23.1', '', Colors.green)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _buildMeasurementItem(
                                'Body Fat', '15.2', '%', Colors.orange)),
                        SizedBox(width: 16),
                        Expanded(
                            child: _buildMeasurementItem(
                                'Muscle Mass', '62.5', 'kg', Colors.purple)),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          // Navigate to body measurements
                        },
                        child: Text('Update Measurements'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutChart() {
    // Simple bar chart representation
    final workouts = _dataService.workouts;
    final now = DateTime.now();
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Count workouts for each day of the week
    final workoutCounts = List.filled(7, 0);
    for (final workout in workouts) {
      if (now.difference(workout.date).inDays <= 7) {
        final dayIndex = (workout.date.weekday - 1) % 7;
        workoutCounts[dayIndex]++;
      }
    }

    final maxCount = workoutCounts.reduce((a, b) => a > b ? a : b);
    if (maxCount == 0) {
      return Center(
        child: Text(
          'No workout data available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final count = workoutCounts[index];
        final height = count == 0 ? 10.0 : (count / maxCount) * 150;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 30,
              height: height,
              decoration: BoxDecoration(
                color: count > 0 ? Colors.orange : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 8),
            Text(
              daysOfWeek[index],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgressCard(Goal goal) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${goal.progress.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: goal.isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal.progress / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                goal.isCompleted ? Colors.green : Colors.orange,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${goal.current.toStringAsFixed(0)}/${goal.target.toStringAsFixed(0)} ${goal.unit}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementItem(
      String label, String value, String unit, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$value$unit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  int _getThisMonthWorkouts() {
    final now = DateTime.now();
    return _dataService.workouts
        .where((workout) => now.difference(workout.date).inDays <= 30)
        .length;
  }

  double _getAveragePerWeek() {
    final workouts = _dataService.workouts;
    if (workouts.isEmpty) return 0.0;

    final oldestWorkout = workouts.first.date;
    final daysSinceFirst = DateTime.now().difference(oldestWorkout).inDays;
    final weeksSinceFirst = (daysSinceFirst / 7).ceil();

    return weeksSinceFirst > 0 ? workouts.length / weeksSinceFirst : 0.0;
  }
}
