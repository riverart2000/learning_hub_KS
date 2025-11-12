# ChatGPT Prompt for Generating Learning Hub Content

Copy and paste this prompt to ChatGPT, replacing `[CATEGORY_NAME]` with your desired topic:

---

## Prompt:

```
I need you to generate a JSON file for a learning app with questions and answers for the category: [CATEGORY_NAME]

Please follow this exact structure:

1. Create 1 category with:
   - Unique id (e.g., "cat_mathematics")
   - Name (e.g., "Mathematics")
   - Description (brief, one sentence)
   - Icon (use: "school", "science", "history_edu", "calculate", "auto_stories", "psychology", or "language")

2. Create 5 subcategories under this category with:
   - Unique ids (e.g., "subcat_algebra", "subcat_geometry")
   - Names that are specific topics within the main category
   - Descriptions (one sentence each)

3. Create 5 learning units (one per subcategory) with:
   - Unique ids matching the subcategory names (e.g., "unit_algebra")
   - type: ALWAYS "mixed"
   - difficulty: use "beginner", "intermediate", or "advanced"
   - Relevant tags

4. Create 50 questions PER subcategory with:
   - Sequential ids (q1, q2, q3, ... q100)
   - Each question linked to the appropriate learning unit
   - Clear, concise questions
   - Accurate correct answers
   - Helpful hints (optional but recommended)
   - Detailed explanations of the correct answer
   - Appropriate difficulty level ("beginner", "intermediate", "advanced")
   - Relevant tags
   - Time limit in seconds (30-60 seconds recommended)

Please use this exact JSON structure:

{
  "categories": [
    {
      "id": "cat_TOPIC",
      "name": "Topic Name",
      "description": "Description here",
      "icon": "school"
    }
  ],
  "subcategories": [
    {
      "id": "subcat_NAME1",
      "categoryId": "cat_TOPIC",
      "name": "Subtopic 1",
      "description": "Description"
    }
    // ... 4 more subcategories
  ],
  "learningUnits": [
    {
      "id": "unit_NAME1",
      "subCategoryId": "subcat_NAME1",
      "type": "mixed",
      "title": "Subtopic 1",
      "content": {},
      "difficulty": "beginner",
      "tags": ["tag1", "tag2"],
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
    // ... 4 more learning units
  ],
  "questions": [
    {
      "id": "q1",
      "learningUnitId": "unit_NAME1",
      "question": "Question text?",
      "correctAnswer": "The answer",
      "hint": "A helpful hint",
      "explanation": "Why this is correct",
      "difficulty": "beginner",
      "tags": ["tag1"],
      "timeLimit": 30
    }
    // ... 99 more questions (20 per subcategory)
  ]
}

Requirements:
- Make questions educational and accurate
- Vary difficulty levels appropriately
- Include helpful explanations
- Keep questions clear and concise
- Ensure correctAnswer is factually accurate
- Add relevant tags for each question
- Distribute 50 questions per subcategory evenly
```

---

## Example Categories You Can Request:

- **Mathematics** (Algebra, Geometry, Calculus, Statistics, Trigonometry)
- **Biology** (Cell Biology, Genetics, Evolution, Ecology, Human Anatomy)
- **Chemistry** (Organic Chemistry, Inorganic Chemistry, Physical Chemistry, Biochemistry, Analytical Chemistry)
- **Computer Science** (Programming, Data Structures, Algorithms, Databases, Networks)
- **History** (Ancient History, Medieval History, Modern History, World Wars, Renaissance)
- **Geography** (Physical Geography, Human Geography, World Capitals, Countries, Landmarks)
- **Literature** (Poetry, Novels, Drama, Literary Devices, Famous Authors)
- **Languages** (Spanish, French, German, Japanese, Mandarin)
- **Psychology** (Cognitive Psychology, Social Psychology, Developmental Psychology, Abnormal Psychology, Neuroscience)
- **Economics** (Microeconomics, Macroeconomics, International Trade, Finance, Economic Theory)
- **Philosophy** (Ethics, Logic, Metaphysics, Epistemology, Political Philosophy)
- **Art History** (Renaissance Art, Modern Art, Impressionism, Sculpture, Architecture)
- **Music Theory** (Scales, Harmony, Rhythm, Composition, Musical Notation)

---

## After ChatGPT Generates the File:

1. Copy the JSON output
2. Save it as `{topic}_unified.json` in `/Users/riverart/flutter/learning_hub/assets/data/`
3. Add the filename to `/Users/riverart/flutter/learning_hub/assets/data/manifest.json`:
   ```json
   {
     "dataFiles": [
       "physics_unified.json",
       "YOUR_NEW_FILE.json"
     ]
   }
   ```
4. Run the app - your new category will appear automatically!

---

## Tips:

- Be specific with your category request (e.g., "Advanced Mathematics for High School" vs just "Mathematics")
- You can request multiple difficulty levels
- Ask for real-world examples in questions
- Request specific time periods, regions, or focuses for history/geography
- Specify the education level (high school, college, professional)















