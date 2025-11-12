import 'dart:convert';
import 'dart:io';

/// Auto-fix duplicate question IDs by prefixing with file identifier
void main() async {
  print('🔧 JSON ID Fix Tool - Auto-fixing duplicate question IDs');
  print('=' * 60);
  print('');

  final manifestFile = File('assets/data/manifest.json');
  final manifestContent = await manifestFile.readAsString();
  final manifest = json.decode(manifestContent);
  final List<String> files = List<String>.from(manifest['dataFiles'] ?? []);

  int filesFixed = 0;
  int questionsFixed = 0;

  for (final fileName in files) {
    final filePath = 'assets/data/$fileName';
    final file = File(filePath);

    if (!await file.exists()) {
      print('⚠️  $fileName - FILE NOT FOUND, skipping');
      continue;
    }

    try {
      final content = await file.readAsString();
      final dynamic decoded = json.decode(content);

      if (decoded is! Map<String, dynamic>) {
        print('ℹ️  $fileName - Skipping (not object format)');
        continue;
      }

      final data = decoded;
      
      if (!data.containsKey('questions')) {
        print('ℹ️  $fileName - No questions found');
        continue;
      }

      // Generate unique prefix from filename
      final prefix = _generatePrefix(fileName);
      print('📝 Processing $fileName (prefix: $prefix)');

      int renamedInFile = 0;

      // Fix subcategory IDs
      if (data.containsKey('subcategories')) {
        final subcategories = data['subcategories'] as List;
        for (var i = 0; i < subcategories.length; i++) {
          if (subcategories[i] is! Map<String, dynamic>) continue;
          
          final subcategory = subcategories[i] as Map<String, dynamic>;
          final oldId = subcategory['id'] as String?;
          
          if (oldId != null && !oldId.startsWith(prefix)) {
            final newId = '${prefix}_$oldId';
            subcategory['id'] = newId;
            renamedInFile++;
            
            // Update references in learning units
            if (data.containsKey('learningUnits')) {
              final units = data['learningUnits'] as List;
              for (var unit in units) {
                if (unit is Map<String, dynamic> && unit['subCategoryId'] == oldId) {
                  unit['subCategoryId'] = newId;
                }
              }
            }
          }
        }
      }

      // Fix learning unit IDs
      if (data.containsKey('learningUnits')) {
        final learningUnits = data['learningUnits'] as List;
        for (var i = 0; i < learningUnits.length; i++) {
          if (learningUnits[i] is! Map<String, dynamic>) continue;
          
          final unit = learningUnits[i] as Map<String, dynamic>;
          final oldId = unit['id'] as String?;
          
          if (oldId != null && !oldId.startsWith(prefix)) {
            final newId = '${prefix}_$oldId';
            unit['id'] = newId;
            renamedInFile++;
            
            // Update references in questions
            if (data.containsKey('questions')) {
              final questions = data['questions'] as List;
              for (var question in questions) {
                if (question is Map<String, dynamic> && question['learningUnitId'] == oldId) {
                  question['learningUnitId'] = newId;
                }
              }
            }
          }
        }
      }

      // Fix question IDs
      if (data.containsKey('questions')) {
        final questions = data['questions'] as List;
        for (var i = 0; i < questions.length; i++) {
          if (questions[i] is! Map<String, dynamic>) continue;
          
          final question = questions[i] as Map<String, dynamic>;
          final oldId = question['id'] as String?;
          
          if (oldId != null && !oldId.startsWith(prefix)) {
            // Rename the ID with prefix
            final newId = '${prefix}_$oldId';
            question['id'] = newId;
            renamedInFile++;
            questionsFixed++;
          }
        }
      }

      if (renamedInFile > 0) {
        // Save the file with pretty formatting
        final encoder = JsonEncoder.withIndent('  ');
        final prettyJson = encoder.convert(data);
        await file.writeAsString(prettyJson);
        
        print('   ✅ Fixed $renamedInFile question IDs');
        filesFixed++;
      } else {
        print('   ✓ Already has unique IDs');
      }

    } catch (e) {
      print('❌ Error processing $fileName: $e');
    }
  }

  print('');
  print('=' * 60);
  print('📊 FIX SUMMARY');
  print('=' * 60);
  print('Files processed: ${files.length}');
  print('Files fixed: $filesFixed');
  print('Questions renamed: $questionsFixed');
  print('');
  
  if (filesFixed > 0) {
    print('✅ SUCCESS! Please review the changes and run:');
    print('   dart run tools/validate_json.dart');
    print('   to verify all issues are fixed.');
  } else {
    print('ℹ️  No changes needed - all IDs are already unique!');
  }
}

/// Generate a unique prefix from filename
String _generatePrefix(String fileName) {
  // Remove .json extension
  final name = fileName.replaceAll('.json', '').replaceAll('_', '');
  
  // Create a unique abbreviated prefix
  // Use first letter of each word + last few chars for uniqueness
  if (name.length <= 8) {
    return name;
  }
  
  // For longer names, create abbreviation
  // Examples:
  // "ansible_advanced_questions" -> "ansadv"
  // "kubernetes_orchestration_full" -> "kuborch"
  // "version_control_collab_fundamentals" -> "verconfund"
  
  final parts = fileName.replaceAll('.json', '').split('_');
  final buffer = StringBuffer();
  
  for (var i = 0; i < parts.length && buffer.length < 10; i++) {
    final part = parts[i];
    if (part.isEmpty) continue;
    
    if (i == 0) {
      // First part: use first 3 chars
      buffer.write(part.substring(0, part.length > 3 ? 3 : part.length));
    } else {
      // Subsequent parts: use first 2-3 chars
      final take = part.length > 3 ? 3 : part.length;
      buffer.write(part.substring(0, take));
    }
  }
  
  return buffer.toString().toLowerCase();
}

