import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';
import '../models/learning_unit.dart';
import '../models/user_progress.dart';
import '../services/hive_service.dart';
import '../services/user_service.dart';
import '../services/sound_service.dart';
import '../services/firebase_service.dart';
import '../services/progress_tracking_service.dart';
import '../widgets/common_sticky_header.dart';

class FlashcardGameScreen extends StatefulWidget {
  final String learningUnitId;

  const FlashcardGameScreen({
    super.key,
    required this.learningUnitId,
  });

  @override
  State<FlashcardGameScreen> createState() => _FlashcardGameScreenState();
}

class _FlashcardGameScreenState extends State<FlashcardGameScreen> {
  List<Flashcard> flashcards = [];
  LearningUnit? learningUnit;
  int currentIndex = 0;
  int correctAnswers = 0;
  bool isGameCompleted = false;
  bool isFlipped = false;
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
      _loadFlashcards();
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final stateKey = 'flashcard_state_${user.id}_${widget.learningUnitId}';
    final savedIndex = prefs.getInt('${stateKey}_index');
    final savedCorrect = prefs.getInt('${stateKey}_correct');
    final savedTimestamp = prefs.getInt('${stateKey}_timestamp');
    
    if (savedIndex != null && savedCorrect != null && savedTimestamp != null) {
      final saveTime = DateTime.fromMillisecondsSinceEpoch(savedTimestamp);
      final difference = DateTime.now().difference(saveTime);
      
      if (difference.inHours < 24 && mounted) {
        final shouldResume = await _showResumeDialog(savedIndex, savedCorrect);
        if (shouldResume == true) {
          _loadFlashcards(resumeFromIndex: savedIndex, resumeCorrectCount: savedCorrect);
          return;
        } else {
          await _clearSavedState();
        }
      } else {
        await _clearSavedState();
      }
    }
    
    _loadFlashcards();
  }
  
  Future<bool?> _showResumeDialog(int savedIndex, int savedCorrect) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Resume Flashcards?'),
        content: Text(
          'You have an incomplete flashcard session. You were at card ${savedIndex + 1} with $savedCorrect correct.\n\nWould you like to continue where you left off?',
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
  
  Future<void> _saveFlashcardState() async {
    if (isGameCompleted) return;
    
    final user = UserService.getCurrentUser();
    if (user == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final stateKey = 'flashcard_state_${user.id}_${widget.learningUnitId}';
    
    await prefs.setInt('${stateKey}_index', currentIndex);
    await prefs.setInt('${stateKey}_correct', correctAnswers);
    await prefs.setInt('${stateKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
    
    debugPrint('💾 Flashcard state saved: Card ${currentIndex + 1}, $correctAnswers correct');
  }
  
  Future<void> _clearSavedState() async {
    final user = UserService.getCurrentUser();
    if (user == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final stateKey = 'flashcard_state_${user.id}_${widget.learningUnitId}';
    
    await prefs.remove('${stateKey}_index');
    await prefs.remove('${stateKey}_correct');
    await prefs.remove('${stateKey}_timestamp');
    
    debugPrint('🗑️ Flashcard state cleared');
  }
  
  @override
  void dispose() {
    _confettiControllerSmall.dispose();
    _confettiControllerMedium.dispose();
    _confettiControllerBig.dispose();
    
    // Save flashcard state when exiting (if not completed)
    if (!isGameCompleted && currentIndex > 0) {
      _saveFlashcardState();
    }
    
    // Only save score on exit if flashcards were NOT completed normally
    // (If completed, score was already saved in _completeGame)
    if (!isGameCompleted && currentIndex > 0) {
      debugPrint('⚠️ Flashcards exited early - saving partial progress...');
      _saveFinalScoreOnExit();
    } else if (isGameCompleted) {
      debugPrint('✓ Flashcards completed normally - skipping dispose save');
    }
    
    super.dispose();
  }
  
  void _saveFinalScoreOnExit() async {
    final user = UserService.getCurrentUser();
    if (user == null || flashcards.isEmpty) return;
    
    // Calculate score based on cards reviewed
    final finalScore = UserService.calculateScore(
      correctAnswers: correctAnswers,
      totalQuestions: flashcards.length,
      difficulty: learningUnit?.difficulty ?? Difficulty.beginner,
    );
    
    // Save to Firebase
    try {
      debugPrint('💾 Saving flashcard score on exit...');
      debugPrint('   Progress: $currentIndex/${flashcards.length} cards');
      debugPrint('   Score: $finalScore');
      
      final firebaseService = FirebaseService();
      await firebaseService.saveScore(
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        score: finalScore,
        category: learningUnit?.subCategoryId ?? 'unknown',
        difficulty: learningUnit?.difficulty.name ?? 'beginner',
      );
      debugPrint('✅ Flashcard score saved on exit!');
    } catch (e) {
      debugPrint('❌ Could not save flashcard score on exit: $e');
    }
    
    // Track progress for categories and subcategories (even for partial progress)
    try {
      await ProgressTrackingService.recordQuizCompletion(
        userId: user.id,
        learningUnitId: widget.learningUnitId,
        questionsAttempted: currentIndex, // Cards actually viewed
        correctAnswers: correctAnswers,
      );
      debugPrint('✅ Progress tracking updated for partial flashcard session (exit early)');
    } catch (e) {
      debugPrint('⚠️ Could not update progress tracking on exit: $e');
    }
  }

  void _loadFlashcards({int? resumeFromIndex, int? resumeCorrectCount}) {
    debugPrint('🃏 _loadFlashcards called for learningUnitId: ${widget.learningUnitId}');
    final allFlashcards = HiveService.getFlashcardsByLearningUnit(widget.learningUnitId);
    learningUnit = HiveService.getLearningUnit(widget.learningUnitId);
    
    debugPrint('🃏 Found ${allFlashcards.length} flashcards from HiveService');
    
    // Remove duplicates based on front text (question)
    final seenQuestions = <String>{};
    flashcards = allFlashcards.where((card) {
      if (seenQuestions.contains(card.front)) {
        return false;
      }
      seenQuestions.add(card.front);
      return true;
    }).toList();
    
    debugPrint('🃏 After deduplication: ${flashcards.length} flashcards');
    
    // Shuffle for random order
    flashcards.shuffle();
    
    // Resume from saved state if provided
    if (resumeFromIndex != null && resumeCorrectCount != null) {
      setState(() {
        currentIndex = resumeFromIndex;
        correctAnswers = resumeCorrectCount;
      });
      debugPrint('🔄 Resuming flashcards from card ${currentIndex + 1} with $correctAnswers correct');
    } else {
      // Always call setState to trigger UI rebuild after loading flashcards
      setState(() {
        // This will trigger a rebuild with the loaded flashcards
      });
    }
    
    if (flashcards.isEmpty) {
      // Show error or navigate back
      Navigator.of(context).pop();
    }
  }

  void _onCardAnswered() async {
    // Count this card as reviewed
    correctAnswers++;
    
    // Trigger confetti based on milestones
    _checkConfettiMilestone();

    // Save progress immediately after each card
    await _saveCurrentProgress();

    if (currentIndex < flashcards.length - 1) {
      setState(() {
        currentIndex++;
        isFlipped = false; // Reset flip state for next card
      });
      // Save flashcard state after moving to next card
      _saveFlashcardState();
    } else {
      _completeGame();
    }
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

  Future<void> _saveCurrentProgress() async {
    // Calculate PARTIAL score based on cards reviewed
    final totalCards = flashcards.length;

    // Apply learning unit difficulty multiplier
    final currentScore = UserService.calculateScore(
      correctAnswers: correctAnswers,
      totalQuestions: totalCards,
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
    // Clear saved flashcard state since session is completed
    await _clearSavedState();
    
    // Big confetti at the end
    _confettiControllerBig.play();
    
    setState(() {
      isGameCompleted = true;
    });

    // Calculate final score - all cards reviewed get full credit
    final percentageScore = 100.0; // All cards were reviewed

    // Apply learning unit difficulty multiplier
    final finalScore = UserService.calculateScore(
      correctAnswers: flashcards.length,
      totalQuestions: flashcards.length,
      difficulty: learningUnit?.difficulty ?? Difficulty.beginner,
    );

    // Record progress
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
        debugPrint('💾 Attempting to save flashcard score to Firebase...');
        debugPrint('   User: ${user.name} (${user.email})');
        debugPrint('   Score: $finalScore');
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
        debugPrint('✅ Flashcard score saved to Firebase successfully!');
      } catch (e) {
        debugPrint('❌ Could not save flashcard score to Firebase: $e');
        // Continue anyway - local score is saved
      }
      
      // Track progress for categories and subcategories
      try {
        await ProgressTrackingService.recordQuizCompletion(
          userId: user.id,
          learningUnitId: widget.learningUnitId,
          questionsAttempted: flashcards.length,
          correctAnswers: correctAnswers,
        );
        debugPrint('✅ Progress tracking updated for flashcard session');
      } catch (e) {
        debugPrint('⚠️ Could not update progress tracking: $e');
        // Continue anyway - session results still shown
      }
    }

    _showResultsDialog(finalScore, percentageScore);
  }

  void _showResultsDialog(double finalScore, double percentageScore) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Flashcard Session Complete!'),
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
              'Cards reviewed: ${flashcards.length}',
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
      currentIndex = 0;
      correctAnswers = 0;
      isGameCompleted = false;
      isFlipped = false;
    });
  }

  Widget _buildFrontCard() {
    return Card(
      key: ValueKey('front_$currentIndex'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              flashcards[currentIndex].front,
              style: Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap to reveal answer',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return Card(
      key: ValueKey('back_$currentIndex'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lightbulb,
              size: 48,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            Text(
              flashcards[currentIndex].back,
              style: Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            if (flashcards[currentIndex].hint != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.help_outline, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hint: ${flashcards[currentIndex].hint}',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (flashcards.isEmpty) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverStickyHeader(
              header: const CommonStickyHeader(currentScreen: 'flashcard'),
              sliver: SliverFillRemaining(
                child: const Center(
                  child: Text('No flashcards available'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverStickyHeader(
                header: CommonStickyHeader(
                  currentScreen: 'flashcard',
                  key: ValueKey('flashcard_$currentIndex'),
                ),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Progress indicator
                        LinearProgressIndicator(
                          value: (currentIndex + 1) / flashcards.length,
                          backgroundColor: Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        
                        // Card counter
                        Text(
                          'Card ${currentIndex + 1} of ${flashcards.length}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        // Flashcard
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isFlipped = !isFlipped;
                              });
                            },
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 600),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: isFlipped 
                                ? _buildBackCard() 
                                : _buildFrontCard(),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Next card button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _onCardAnswered,
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(
                              currentIndex < flashcards.length - 1 
                                ? 'Next Card' 
                                : 'Finish',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 18),
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
