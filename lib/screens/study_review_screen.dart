import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../models/learning_unit.dart';
import '../services/hive_service.dart';
import '../services/user_service.dart';
import '../widgets/common_sticky_header.dart';

class StudyReviewScreen extends StatefulWidget {
  final String learningUnitId;

  const StudyReviewScreen({
    super.key,
    required this.learningUnitId,
  });

  @override
  State<StudyReviewScreen> createState() => _StudyReviewScreenState();
}

class _StudyReviewScreenState extends State<StudyReviewScreen> {
  List<Question> questions = [];
  LearningUnit? learningUnit;
  int currentQuestionIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _checkForSavedState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Save current position when leaving
    _saveStudyState();
    super.dispose();
  }
  
  Future<void> _checkForSavedState() async {
    final user = UserService.getCurrentUser();
    if (user == null) {
      _loadQuestions();
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final stateKey = 'study_state_${user.id}_${widget.learningUnitId}';
    final savedIndex = prefs.getInt('${stateKey}_index');
    final savedTimestamp = prefs.getInt('${stateKey}_timestamp');
    
    if (savedIndex != null && savedTimestamp != null) {
      final saveTime = DateTime.fromMillisecondsSinceEpoch(savedTimestamp);
      final difference = DateTime.now().difference(saveTime);
      
      if (difference.inHours < 24 && mounted) {
        final shouldResume = await _showResumeDialog(savedIndex);
        if (shouldResume == true) {
          _loadQuestions(resumeFromIndex: savedIndex);
          return;
        } else {
          await _clearSavedState();
        }
      } else {
        await _clearSavedState();
      }
    }
    
    _loadQuestions();
  }
  
  Future<bool?> _showResumeDialog(int savedIndex) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Resume Study?'),
        content: Text(
          'You were at question ${savedIndex + 1}.\n\nWould you like to continue where you left off?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Start From Beginning'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _saveStudyState() async {
    final user = UserService.getCurrentUser();
    if (user == null || currentQuestionIndex == 0) return;
    
    final prefs = await SharedPreferences.getInstance();
    final stateKey = 'study_state_${user.id}_${widget.learningUnitId}';
    
    await prefs.setInt('${stateKey}_index', currentQuestionIndex);
    await prefs.setInt('${stateKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
    
    debugPrint('💾 Study state saved: Q${currentQuestionIndex + 1}');
  }
  
  Future<void> _clearSavedState() async {
    final user = UserService.getCurrentUser();
    if (user == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final stateKey = 'study_state_${user.id}_${widget.learningUnitId}';
    
    await prefs.remove('${stateKey}_index');
    await prefs.remove('${stateKey}_timestamp');
    
    debugPrint('🗑️ Study state cleared');
  }

  void _loadQuestions({int? resumeFromIndex}) {
    final loadedQuestions = HiveService.getQuestionsByLearningUnit(widget.learningUnitId);
    final loadedUnit = HiveService.getLearningUnit(widget.learningUnitId);
    
    setState(() {
      questions = loadedQuestions;
      learningUnit = loadedUnit;
      if (resumeFromIndex != null) {
        currentQuestionIndex = resumeFromIndex;
        // Jump to the saved page after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(currentQuestionIndex);
          }
        });
        debugPrint('🔄 Resuming study from Q${currentQuestionIndex + 1}');
      }
    });
  }

  void _goToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      _pageController.animateToPage(
        currentQuestionIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // Save state after navigation
      _saveStudyState();
    }
  }

  void _goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
      _pageController.animateToPage(
        currentQuestionIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // Save state after navigation
      _saveStudyState();
    }
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return Colors.green;
      case Difficulty.intermediate:
        return Colors.orange;
      case Difficulty.advanced:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverStickyHeader(
            header: const CommonStickyHeader(currentScreen: 'study'),
            sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No study material available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverStickyHeader(
            header: const CommonStickyHeader(currentScreen: 'study'),
            sliver: SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = MediaQuery.of(context).size.height;
                  final isSmallScreen = screenHeight < 600;
                  
                  return Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 4.0 : 8.0), // More compact padding
                    child: Column(
                      children: [
                        // Header with progress
                        _buildHeader(isSmallScreen),
                        SizedBox(height: isSmallScreen ? 4 : 8), // More compact spacing
                        
                        // PageView for questions
                        SizedBox(
                          height: isSmallScreen 
                              ? screenHeight - 130  // More compact for small screens
                              : screenHeight - 180, // More compact for larger screens
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                currentQuestionIndex = index;
                              });
                            },
                            itemCount: questions.length,
                            itemBuilder: (context, index) {
                              return SingleChildScrollView(
                                child: _buildQuestionContent(questions[index], isSmallScreen),
                              );
                            },
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 4 : 8), // More compact spacing
                        
                        // Navigation controls
                        _buildNavigationControls(isSmallScreen),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Card(
      margin: EdgeInsets.zero, // Remove card margin
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0), // More compact padding
        child: Row(
          children: [
            Icon(
              Icons.auto_stories,
              size: isSmallScreen ? 18 : 22, // Smaller icon
              color: Colors.teal,
            ),
            SizedBox(width: isSmallScreen ? 6 : 8), // Compact spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Study Mode',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: isSmallScreen ? 13 : 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (learningUnit != null) ...[
                    SizedBox(height: 1), // Minimal spacing
                    Text(
                      learningUnit!.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: isSmallScreen ? 9 : 11, // Smaller text
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 6 : 8, 
                vertical: isSmallScreen ? 2 : 3,
              ), // More compact padding
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.teal),
              ),
              child: Text(
                '${currentQuestionIndex + 1} / ${questions.length}',
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 10 : 11, // Smaller text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent(Question question, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question Card
        Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: isSmallScreen ? 4 : 6), // Compact margin
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 10.0), // More compact padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: Colors.blue,
                      size: isSmallScreen ? 16 : 20, // Smaller icon
                    ),
                    SizedBox(width: isSmallScreen ? 5 : 6), // Compact spacing
                    Text(
                      'Question',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: isSmallScreen ? 11 : 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 5 : 6, 
                        vertical: isSmallScreen ? 2 : 3,
                      ), // More compact padding
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(question.difficulty).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        question.difficulty.name.toUpperCase(),
                        style: TextStyle(
                          color: _getDifficultyColor(question.difficulty),
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 7 : 9, // Smaller text
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 6 : 8), // Compact spacing
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: isSmallScreen ? 13 : 15,
                    height: 1.3,
                  ),
                ),
                if (question.tags.isNotEmpty) ...[
                  SizedBox(height: isSmallScreen ? 6 : 8), // Compact spacing
                  Wrap(
                    spacing: isSmallScreen ? 3 : 4, // Compact spacing
                    runSpacing: isSmallScreen ? 3 : 4, // Compact spacing
                    children: question.tags.map((tag) => Chip(
                      label: Text(
                        tag,
                        style: TextStyle(fontSize: isSmallScreen ? 8 : 9), // Smaller text
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 2 : 3, 
                        vertical: 0,
                      ), // More compact padding
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact, // Make chip more compact
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        // Answer Card
        Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: isSmallScreen ? 4 : 6), // Compact margin
          color: Colors.green.withValues(alpha: 0.05),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 10.0), // More compact padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: isSmallScreen ? 16 : 20, // Smaller icon
                    ),
                    SizedBox(width: isSmallScreen ? 5 : 6), // Compact spacing
                    Text(
                      'Answer',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: isSmallScreen ? 11 : 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 6 : 8), // Compact spacing
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10), // More compact padding
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    question.correctAnswer,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.green[900],
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Explanation Card
        if (question.explanation != null) ...[
          Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: isSmallScreen ? 4 : 6), // Compact margin
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8.0 : 10.0), // More compact padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber[700],
                        size: isSmallScreen ? 16 : 20, // Smaller icon
                      ),
                      SizedBox(width: isSmallScreen ? 5 : 6), // Compact spacing
                      Text(
                        'Explanation',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: isSmallScreen ? 11 : 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8), // Compact spacing
                  Text(
                    question.explanation!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.4,
                      fontSize: isSmallScreen ? 11 : 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        
        // Hint Card
        if (question.hint != null) ...[
          Card(
            elevation: 2,
            margin: EdgeInsets.zero, // No bottom margin on last card
            color: Colors.purple.withValues(alpha: 0.05),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8.0 : 10.0), // More compact padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: Colors.purple,
                        size: isSmallScreen ? 16 : 20, // Smaller icon
                      ),
                      SizedBox(width: isSmallScreen ? 5 : 6), // Compact spacing
                      Text(
                        'Hint',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: isSmallScreen ? 11 : 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8), // Compact spacing
                  Text(
                    question.hint!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                      fontSize: isSmallScreen ? 11 : 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNavigationControls(bool isSmallScreen) {
    return Card(
      margin: EdgeInsets.zero, // Remove card margin
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0), // More compact padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous Button
            ElevatedButton.icon(
              onPressed: currentQuestionIndex > 0 ? _goToPreviousQuestion : null,
              icon: Icon(Icons.arrow_back, size: isSmallScreen ? 14 : 16), // Smaller icon
              label: Text('Previous', style: TextStyle(fontSize: isSmallScreen ? 10 : 12)), // Smaller text
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 6 : 8, 
                  vertical: isSmallScreen ? 6 : 8,
                ), // More compact padding
              ),
            ),
            
            // Progress Indicator
            Text(
              '${currentQuestionIndex + 1} / ${questions.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            
            // Next Button
            ElevatedButton.icon(
              onPressed: currentQuestionIndex < questions.length - 1 
                  ? _goToNextQuestion 
                  : null,
              icon: Icon(Icons.arrow_forward, size: isSmallScreen ? 14 : 16), // Smaller icon
              label: Text('Next', style: TextStyle(fontSize: isSmallScreen ? 10 : 12)), // Smaller text
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 6 : 8, 
                  vertical: isSmallScreen ? 6 : 8,
                ), // More compact padding
              ),
            ),
          ],
        ),
      ),
    );
  }
}

