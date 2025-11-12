import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz.dart';
import '../models/learning_unit.dart';
import '../models/user_progress.dart';
import '../services/hive_service.dart';
import '../services/user_service.dart';
import '../services/sound_service.dart';
import '../services/firebase_service.dart';
import '../services/progress_tracking_service.dart';
import '../widgets/common_sticky_header.dart';

class QuizGameScreen extends StatefulWidget {
  final String learningUnitId;

  const QuizGameScreen({
    super.key,
    required this.learningUnitId,
  });

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  List<Quiz> quizzes = [];
  List<Quiz> allQuizzes = [];
  LearningUnit? learningUnit;
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  bool isGameCompleted = false;
  List<Map<String, dynamic>> gameQuestions = [];
  int? selectedAnswerIndex;
  bool showingResult = false;
  String? feedbackMessage;
  Timer? _countdownTimer;
  int _remainingTime = 0;
  final SoundService _soundService = SoundService();
  
  // Confetti controllers
  late ConfettiController _confettiControllerSmall;
  late ConfettiController _confettiControllerMedium;
  late ConfettiController _confettiControllerBig;

  @override
  void initState() {
    super.initState();
    _soundService.init();
    
    // Initialize confetti controllers
    _confettiControllerSmall = ConfettiController(duration: const Duration(seconds: 2));
    _confettiControllerMedium = ConfettiController(duration: const Duration(seconds: 3));
    _confettiControllerBig = ConfettiController(duration: const Duration(seconds: 5));
    
    _checkForSavedState();
  }
  
  Future<void> _checkForSavedState() async {
    final user = UserService.getCurrentUser();
    if (user == null) {
      _loadQuizzes();
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final stateKey = 'quiz_state_${user.id}_${widget.learningUnitId}';
    final savedIndex = prefs.getInt('${stateKey}_index');
    final savedCorrect = prefs.getInt('${stateKey}_correct');
    final savedTimestamp = prefs.getInt('${stateKey}_timestamp');
    
    if (savedIndex != null && savedCorrect != null && savedTimestamp != null) {
      // Check if state is recent (less than 24 hours old)
      final saveTime = DateTime.fromMillisecondsSinceEpoch(savedTimestamp);
      final difference = DateTime.now().difference(saveTime);
      
      if (difference.inHours < 24 && mounted) {
        // Ask user if they want to resume
        final shouldResume = await _showResumeDialog(savedIndex, savedCorrect);
        if (shouldResume == true) {
          _loadQuizzes(resumeFromIndex: savedIndex, resumeCorrectCount: savedCorrect);
          return;
        } else {
          // Clear saved state if they choose to start fresh
          await _clearSavedState();
        }
      } else {
        // State too old, clear it
        await _clearSavedState();
      }
    }
    
    _loadQuizzes();
  }
  
  Future<bool?> _showResumeDialog(int savedIndex, int savedCorrect) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Resume Quiz?'),
        content: Text(
          'You have an incomplete quiz. You were at question ${savedIndex + 1} with $savedCorrect correct answers.\n\nWould you like to continue where you left off?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Start Fresh'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _saveQuizState() async {
    if (isGameCompleted) return; // Don't save if quiz is completed
    
    final user = UserService.getCurrentUser();
    if (user == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final stateKey = 'quiz_state_${user.id}_${widget.learningUnitId}';
    
    await prefs.setInt('${stateKey}_index', currentQuestionIndex);
    await prefs.setInt('${stateKey}_correct', correctAnswers);
    await prefs.setInt('${stateKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
    
    debugPrint('💾 Quiz state saved: Q${currentQuestionIndex + 1}, $correctAnswers correct');
  }
  
  Future<void> _clearSavedState() async {
    final user = UserService.getCurrentUser();
    if (user == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final stateKey = 'quiz_state_${user.id}_${widget.learningUnitId}';
    
    await prefs.remove('${stateKey}_index');
    await prefs.remove('${stateKey}_correct');
    await prefs.remove('${stateKey}_timestamp');
    
    debugPrint('🗑️ Quiz state cleared');
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _confettiControllerSmall.dispose();
    _confettiControllerMedium.dispose();
    _confettiControllerBig.dispose();
    
    // Save quiz state when exiting (if not completed)
    if (!isGameCompleted && currentQuestionIndex > 0) {
      _saveQuizState();
    }
    
    // Only save score on exit if quiz was NOT completed normally
    // (If completed, score was already saved in _completeGame)
    if (!isGameCompleted && currentQuestionIndex > 0 && correctAnswers > 0) {
      debugPrint('⚠️ Quiz exited early - saving partial progress...');
      _saveFinalScoreOnExit();
    } else if (isGameCompleted) {
      debugPrint('✓ Quiz was completed normally - skipping dispose save');
    }
    
    super.dispose();
  }
  
  void _saveFinalScoreOnExit() async {
    final user = UserService.getCurrentUser();
    if (user == null || gameQuestions.isEmpty) return;
    
    // Calculate score based on current progress
    final percentageScore = (correctAnswers / gameQuestions.length) * 100;
    final finalScore = UserService.calculateScore(
      correctAnswers: correctAnswers,
      totalQuestions: gameQuestions.length,
      difficulty: learningUnit?.difficulty ?? Difficulty.beginner,
    );
    
    // Save to Firebase
    try {
      debugPrint('💾 Saving score on exit...');
      debugPrint('   Correct Answers: $correctAnswers');
      debugPrint('   Total Questions: ${gameQuestions.length}');
      debugPrint('   Current Question Index: $currentQuestionIndex');
      debugPrint('   Percentage: $percentageScore%');
      debugPrint('   Calculated Score: $finalScore');
      debugPrint('   Difficulty: ${learningUnit?.difficulty.name}');
      
      final firebaseService = FirebaseService();
      await firebaseService.saveScore(
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        score: finalScore,
        category: learningUnit?.subCategoryId ?? 'unknown',
        difficulty: learningUnit?.difficulty.name ?? 'beginner',
      );
      debugPrint('✅ Score saved on exit!');
    } catch (e) {
      debugPrint('❌ Could not save score on exit: $e');
    }
    
    // Track progress for categories and subcategories (even for partial progress)
    try {
      await ProgressTrackingService.recordQuizCompletion(
        userId: user.id,
        learningUnitId: widget.learningUnitId,
        questionsAttempted: currentQuestionIndex, // Only count questions actually attempted
        correctAnswers: correctAnswers,
      );
      debugPrint('✅ Progress tracking updated for partial quiz (exit early)');
    } catch (e) {
      debugPrint('⚠️ Could not update progress tracking on exit: $e');
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    final currentQuestion = gameQuestions[currentQuestionIndex];
    _remainingTime = currentQuestion['timeLimit'] ?? 30;
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        if (!showingResult) {
          _onTimeExpired();
        }
      }
    });
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
  }

  void _onTimeExpired() async {
    final currentQuestion = gameQuestions[currentQuestionIndex];
    
    // Play incorrect sound when time runs out
    _soundService.playIncorrectSound();
    
    setState(() {
      selectedAnswerIndex = null; // No answer selected
      showingResult = true;
      
      final correctAnswer = currentQuestion['options'][currentQuestion['correctIndex']];
      feedbackMessage = 'Time\'s up! The correct answer is: $correctAnswer';
    });
    
    // Save progress (counts as incorrect since correctAnswers not incremented)
    await _saveCurrentProgress();
  }

  void _loadQuizzes({int? resumeFromIndex, int? resumeCorrectCount}) {
    quizzes = HiveService.getQuizzesByLearningUnit(widget.learningUnitId);
    allQuizzes = HiveService.getAllQuizzes();
    learningUnit = HiveService.getLearningUnit(widget.learningUnitId);
    
    if (quizzes.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    _prepareGameQuestions(resumeFromIndex: resumeFromIndex, resumeCorrectCount: resumeCorrectCount);
  }

  void _prepareGameQuestions({int? resumeFromIndex, int? resumeCorrectCount}) {
    gameQuestions.clear();
    final usedQuestions = <String>{};
    
    for (final quiz in quizzes) {
      // Skip duplicate questions (same question text)
      if (usedQuestions.contains(quiz.question)) {
        continue;
      }
      usedQuestions.add(quiz.question);
      
      gameQuestions.add({
        'question': quiz.question,
        'options': quiz.options,
        'correctIndex': quiz.correctAnswerIndex,
        'explanation': quiz.explanation,
        'timeLimit': quiz.timeLimit ?? 30,
        'originalQuiz': quiz,
      });
    }
    
    // Randomize question order
    gameQuestions.shuffle();
    
    // Resume from saved state if provided
    if (resumeFromIndex != null && resumeCorrectCount != null) {
      currentQuestionIndex = resumeFromIndex;
      correctAnswers = resumeCorrectCount;
      debugPrint('🔄 Resuming quiz from Q${currentQuestionIndex + 1} with $correctAnswers correct');
    }
    
    // Start timer for first/current question
    if (gameQuestions.isNotEmpty) {
      _startTimer();
    }
  }

  void _onAnswerSelected(int selectedIndex) async {
    if (showingResult) return; // Prevent multiple taps
    
    // Stop the timer when answer is selected
    _stopTimer();
    
    final currentQuestion = gameQuestions[currentQuestionIndex];
    final isCorrect = selectedIndex == currentQuestion['correctIndex'];
    
    // Play sound effect
    if (isCorrect) {
      _soundService.playCorrectSound();
    } else {
      _soundService.playIncorrectSound();
    }
    
    setState(() {
      selectedAnswerIndex = selectedIndex;
      showingResult = true;
      
      if (isCorrect) {
        correctAnswers++;
        feedbackMessage = currentQuestion['explanation'] ?? 'Correct!';
        
        // Trigger confetti based on milestones
        _checkConfettiMilestone();
      } else {
        final correctAnswer = currentQuestion['options'][currentQuestion['correctIndex']];
        feedbackMessage = currentQuestion['explanation'] ?? 'The correct answer is: $correctAnswer';
      }
    });
    
    // Save progress immediately after each question
    await _saveCurrentProgress();
  }
  
  void _checkConfettiMilestone() {
    // Small confetti every 5 correct answers
    if (correctAnswers % 5 == 0 && correctAnswers < 20) {
      _confettiControllerSmall.play();
    }
    // Medium confetti at 20 correct answers
    else if (correctAnswers == 20) {
      _confettiControllerMedium.play();
    }
  }
  
  void _onContinue() {
    if (!showingResult) return;
    _nextQuestion();
  }

  void _nextQuestion() {
    if (currentQuestionIndex < gameQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        showingResult = false;
        feedbackMessage = null;
      });
      // Save quiz state after moving to next question
      _saveQuizState();
      // Start timer for next question
      _startTimer();
    } else {
      _completeGame();
    }
  }

  Future<void> _saveCurrentProgress() async {
    // Calculate PARTIAL score based on total quiz length, not just answered questions
    // This ensures we don't show 100% after just 2 correct answers
    final totalQuestions = gameQuestions.length;
    
    // Apply learning unit difficulty multiplier
    final currentScore = UserService.calculateScore(
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      difficulty: learningUnit?.difficulty ?? Difficulty.beginner,
    );

    // Record progress as in-progress (not completed yet)
    final user = UserService.getCurrentUser();
    if (user != null) {
      await UserService.recordProgress(
        userId: user.id,
        learningUnitId: widget.learningUnitId,
        score: currentScore,
        status: ProgressStatus.inProgress, // Always in-progress until complete
      );
    }
  }

  void _completeGame() async {
    // Stop the timer when game completes
    _stopTimer();
    
    // Clear saved quiz state since quiz is completed
    await _clearSavedState();
    
    // Big confetti at the end
    _confettiControllerBig.play();
    
    setState(() {
      isGameCompleted = true;
    });

    // Calculate final score
    final percentageScore = (correctAnswers / gameQuestions.length) * 100;
    
    // Apply learning unit difficulty multiplier
    final finalScore = UserService.calculateScore(
      correctAnswers: correctAnswers,
      totalQuestions: gameQuestions.length,
      difficulty: learningUnit?.difficulty ?? Difficulty.beginner,
    );

    // Record progress locally
    final user = UserService.getCurrentUser();
    if (user != null) {
      await UserService.recordProgress(
        userId: user.id,
        learningUnitId: widget.learningUnitId,
        score: finalScore,
        status: UserService.getProgressStatus(percentageScore),
      );
      
      // Save score to Firebase (leaderboard)
      try {
        debugPrint('💾 [COMPLETE] Attempting to save score to Firebase...');
        debugPrint('   User: ${user.name} (${user.email})');
        debugPrint('   Correct Answers: $correctAnswers');
        debugPrint('   Total Questions: ${gameQuestions.length}');
        debugPrint('   Percentage: $percentageScore%');
        debugPrint('   Calculated Score: $finalScore');
        debugPrint('   Category: ${learningUnit?.subCategoryId ?? 'unknown'}');
        debugPrint('   Difficulty: ${learningUnit?.difficulty.name ?? 'beginner'}');
        
        final firebaseService = FirebaseService();
        await firebaseService.saveScore(
          userId: user.id,
          userName: user.name,
          userEmail: user.email,
          score: finalScore,
          category: learningUnit?.subCategoryId ?? 'unknown',
          difficulty: learningUnit?.difficulty.name ?? 'beginner',
        );
        debugPrint('✅ [COMPLETE] Score saved to Firebase successfully!');
      } catch (e) {
        debugPrint('❌ Could not save score to Firebase: $e');
        // Continue anyway - local score is saved
      }
    }

    // Track progress for categories and subcategories
    try {
      final currentUser = UserService.getCurrentUser();
      if (currentUser != null) {
        await ProgressTrackingService.recordQuizCompletion(
          userId: currentUser.id,
          learningUnitId: widget.learningUnitId,
          questionsAttempted: gameQuestions.length,
          correctAnswers: correctAnswers,
        );
        debugPrint('✅ Progress tracking updated for quiz completion');
      }
    } catch (e) {
      debugPrint('⚠️ Could not update progress tracking: $e');
      // Continue anyway - quiz results still shown
    }

    _showResultsDialog(finalScore, percentageScore);
  }

  void _showResultsDialog(double finalScore, double percentageScore) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              percentageScore >= 80 ? Icons.star : Icons.thumb_up,
              size: 64,
              color: percentageScore >= 80 
                ? Colors.amber 
                : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Score: ${finalScore.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Accuracy: ${percentageScore.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Correct: $correctAnswers/${gameQuestions.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Difficulty: ${learningUnit?.difficulty.name ?? 'Unknown'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _restartGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      currentQuestionIndex = 0;
      correctAnswers = 0;
      isGameCompleted = false;
      selectedAnswerIndex = null;
      showingResult = false;
      feedbackMessage = null;
    });
    _prepareGameQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (gameQuestions.isEmpty) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverStickyHeader(
              header: const CommonStickyHeader(currentScreen: 'quiz'),
              sliver: SliverFillRemaining(
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final currentQuestion = gameQuestions[currentQuestionIndex];

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverStickyHeader(
                header: CommonStickyHeader(
                  currentScreen: 'quiz',
                  key: ValueKey('quiz_$currentQuestionIndex'),
                ),
                sliver: SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: showingResult ? _onContinue : null,
                    behavior: HitTestBehavior.opaque,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Make height responsive to screen size
                        final screenHeight = MediaQuery.of(context).size.height;
                        final availableHeight = screenHeight < 600 
                            ? screenHeight - 150  // More compact for small screens
                            : screenHeight - 200; // Standard for larger screens
                        
                        return SizedBox(
                          height: availableHeight,
                          child: Padding(
                            padding: EdgeInsets.all(screenHeight < 600 ? 8.0 : 16.0), // Responsive padding
                            child: Column(
                              children: [
                                // Progress indicator
                                LinearProgressIndicator(
                                  value: (currentQuestionIndex + 1) / gameQuestions.length,
                                  backgroundColor: Colors.grey[300],
                                ),
                                SizedBox(height: screenHeight < 600 ? 4 : 8), // Responsive spacing
                                
                                // Question counter
                                Text(
                                  'Question ${currentQuestionIndex + 1} of ${gameQuestions.length}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith( // Smaller text
                                    fontSize: screenHeight < 600 ? 12 : 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: screenHeight < 600 ? 8 : 16), // Responsive spacing
                            
                                // Score display
                                Container(
                                  padding: EdgeInsets.all(screenHeight < 600 ? 8 : 12), // Responsive padding
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Score
                                      Text(
                                        'Score: $correctAnswers/${currentQuestionIndex + 1}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith( // Smaller text
                                          fontSize: screenHeight < 600 ? 12 : 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Topic
                                      Expanded(
                                        child: Text(
                                          learningUnit?.title ?? '',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith( // Smaller text
                                            fontSize: screenHeight < 600 ? 12 : 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Timer
                                      if (currentQuestion['timeLimit'] != null)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.timer,
                                              size: screenHeight < 600 ? 14 : 16, // Smaller icon
                                              color: Theme.of(context).textTheme.bodyMedium?.color,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${_remainingTime}s',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith( // Smaller text
                                                fontSize: screenHeight < 600 ? 12 : 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: screenHeight < 600 ? 6 : 12), // Reduced spacing
                            
                                // Question and options
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Question Card
                                      Card(
                                        key: ValueKey(currentQuestionIndex),
                                        child: Padding(
                                          padding: EdgeInsets.all(screenHeight < 600 ? 12.0 : 16.0), // Responsive padding
                                          child: Text(
                                            currentQuestion['question'],
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith( // Smaller text
                                              fontSize: screenHeight < 600 ? 14 : 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  
                                      // Options
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: currentQuestion['options'].length,
                                          itemBuilder: (context, index) {
                                            final option = currentQuestion['options'][index];
                                            final correctIndex = currentQuestion['correctIndex'];
                                            final isSelected = selectedAnswerIndex == index;
                                            final isCorrect = index == correctIndex;
                                            
                                            // Determine button color
                                            Color? buttonColor;
                                            if (showingResult && isSelected) {
                                              buttonColor = isCorrect ? Colors.green : Colors.red;
                                            } else if (showingResult && isCorrect) {
                                              buttonColor = Colors.green.withValues(alpha: 0.3);
                                            }
                                            
                                            return Padding(
                                              padding: EdgeInsets.symmetric(vertical: screenHeight < 600 ? 2.0 : 4.0), // Responsive padding
                                              child: ElevatedButton(
                                                onPressed: showingResult ? null : () => _onAnswerSelected(index),
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.all(screenHeight < 600 ? 12 : 16), // Responsive padding
                                                  alignment: Alignment.centerLeft,
                                                  backgroundColor: buttonColor,
                                                  disabledBackgroundColor: buttonColor,
                                                ),
                                                child: Text(
                                                  '${String.fromCharCode(65 + index)}. $option',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith( // Smaller text
                                                    fontSize: screenHeight < 600 ? 12 : 14,
                                                    color: showingResult && (isSelected || isCorrect) 
                                                        ? Colors.white 
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  
                                      // Feedback message
                                      if (feedbackMessage != null) ...[
                                        SizedBox(height: screenHeight < 600 ? 8 : 16), // Responsive spacing
                                        Container(
                                          padding: EdgeInsets.all(screenHeight < 600 ? 12 : 16), // Responsive padding
                                          decoration: BoxDecoration(
                                            color: selectedAnswerIndex == currentQuestion['correctIndex']
                                                ? Colors.green.withValues(alpha: 0.1)
                                                : Colors.red.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: selectedAnswerIndex == currentQuestion['correctIndex']
                                                  ? Colors.green
                                                  : Colors.red,
                                              width: 2,
                                            ),
                                          ),
                                          child: AnimatedTextKit(
                                            animatedTexts: [
                                              TypewriterAnimatedText(
                                                feedbackMessage!,
                                                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith( // Smaller text
                                                  fontSize: screenHeight < 600 ? 12 : 14,
                                                ) ?? const TextStyle(fontSize: 12),
                                                textAlign: TextAlign.center,
                                                speed: const Duration(milliseconds: 50),
                                              ),
                                            ],
                                            totalRepeatCount: 1,
                                            displayFullTextOnTap: true,
                                          ),
                                        ),
                                      ],
                                      
                                      // Continue prompt
                                      if (feedbackMessage != null) ...[
                                        SizedBox(height: screenHeight < 600 ? 8 : 16), // Responsive spacing
                                        Text(
                                          'Tap anywhere to continue',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                            fontSize: screenHeight < 600 ? 11 : 12, // Smaller text
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Confetti widgets
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiControllerSmall,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 15,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiControllerMedium,
              blastDirection: pi / 2,
              maxBlastForce: 10,
              minBlastForce: 5,
              emissionFrequency: 0.03,
              numberOfParticles: 30,
              gravity: 0.25,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple, Colors.yellow],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiControllerBig,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 20,
              minBlastForce: 10,
              emissionFrequency: 0.02,
              numberOfParticles: 50,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple, Colors.yellow, Colors.red],
            ),
          ),
        ],
      ),
    );
  }
}
