import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../utils/color_utils.dart';

import '../enums/meal_time_type.dart';
import '../models/meal_record.dart';
import '../providers/meal_records_provider.dart';
import '../providers/ai_estimation_provider.dart';
import '../utils/validators.dart';
import '../utils/icon_mapper.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/nutrition_editor.dart';
import '../widgets/nutrition_summary_card.dart';
import '../theme/app_theme.dart';

/// Screen for adding or editing a meal record with improved UI
class MealInputScreenNew extends ConsumerStatefulWidget {
  /// The meal record to edit (null for creating a new meal)
  final MealRecord? mealRecord;

  /// Constructor for MealInputScreen
  const MealInputScreenNew({super.key, this.mealRecord});

  @override
  ConsumerState<MealInputScreenNew> createState() => _MealInputScreenNewState();
}

class _MealInputScreenNewState extends ConsumerState<MealInputScreenNew> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _mealNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _fatController;
  late final TextEditingController _carbsController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  
  late MealTimeType _selectedMealType;
  late DateTime _selectedDateTime;
  bool _isEditing = false;
  File? _selectedImageFile;
  
  // Nutrition values
  double _calories = 0;
  double _protein = 0;
  double _fat = 0;
  double _carbs = 0;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.mealRecord != null;
    
    if (_isEditing) {
      // Initialize with existing meal data
      _mealNameController = TextEditingController(text: widget.mealRecord!.mealName);
      _descriptionController = TextEditingController(text: widget.mealRecord!.description);
      _calories = widget.mealRecord!.calories;
      _protein = widget.mealRecord!.protein;
      _fat = widget.mealRecord!.fat;
      _carbs = widget.mealRecord!.carbs;
      _caloriesController = TextEditingController(text: _calories.toString());
      _proteinController = TextEditingController(text: _protein.toString());
      _fatController = TextEditingController(text: _fat.toString());
      _carbsController = TextEditingController(text: _carbs.toString());
      _selectedMealType = widget.mealRecord!.mealTimeType;
      _selectedDateTime = widget.mealRecord!.consumedAt;
    } else {
      // Initialize with default values
      _mealNameController = TextEditingController();
      _descriptionController = TextEditingController();
      _caloriesController = TextEditingController();
      _proteinController = TextEditingController();
      _fatController = TextEditingController();
      _carbsController = TextEditingController();
      _selectedMealType = MealTimeType.lunch;
      _selectedDateTime = DateTime.now();
    }
    
    // Initialize date and time controllers
    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(_selectedDateTime),
    );
    _timeController = TextEditingController(
      text: DateFormat('HH:mm').format(_selectedDateTime),
    );
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  /// Estimate nutrition using AI based on meal description
  void _estimateNutrition(WidgetRef ref) {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a meal description first')),
      );
      return;
    }
    
    // Trigger AI estimation
    ref.read(aiEstimationProvider.notifier).estimateNutrition(description);
  }

  /// Select image and trigger AI analysis
  Future<void> _triggerImageEstimation(ImageSource source, WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 88,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
        
        // Process the image with AI
        ref.read(aiEstimationProvider.notifier).estimateNutritionFromImageFile(_selectedImageFile!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  /// Show date picker and update the selected date
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    
    if (pickedDate != null && mounted) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDateTime);
      });
    }
  }

  /// Show time picker and update the selected time
  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    
    if (pickedTime != null && mounted) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _timeController.text = DateFormat('HH:mm').format(_selectedDateTime);
      });
    }
  }

  /// Save the meal record
  void _saveMeal() {
    if (_formKey.currentState!.validate()) {
      // Get values from controllers if not updated via NutritionEditor
      final parsedCalories = double.tryParse(_caloriesController.text) ?? _calories;
      final parsedProtein = double.tryParse(_proteinController.text) ?? _protein;
      final parsedFat = double.tryParse(_fatController.text) ?? _fat;
      final parsedCarbs = double.tryParse(_carbsController.text) ?? _carbs;
      
      // Create a meal record
      final mealRecord = MealRecord(
        id: _isEditing ? widget.mealRecord!.id : null,
        mealName: _mealNameController.text,
        description: _descriptionController.text,
        calories: parsedCalories,
        protein: parsedProtein,
        fat: parsedFat,
        carbs: parsedCarbs,
        mealTimeType: _selectedMealType,
        consumedAt: _selectedDateTime,
        createdAt: _isEditing ? widget.mealRecord!.createdAt : null,
        updatedAt: DateTime.now(),
      );
      
      // Add or update the meal record
      if (_isEditing) {
        ref.read(mealRecordsProvider.notifier).updateMealRecord(mealRecord);
      } else {
        ref.read(mealRecordsProvider.notifier).addMealRecord(mealRecord);
      }
      
      // Return to previous screen
      context.pop();
    }
  }
  
  /// Update nutrition values
  void _updateNutrition(double calories, double protein, double fat, double carbs) {
    setState(() {
      _calories = calories;
      _protein = protein;
      _fat = fat;
      _carbs = carbs;
      
      // Update controllers to keep them in sync
      _caloriesController.text = calories.toString();
      _proteinController.text = protein.toString();
      _fatController.text = fat.toString();
      _carbsController.text = carbs.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Meal' : 'Add New Meal'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Meal'),
                    content: const Text('Are you sure you want to delete this meal?'),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Delete the meal and return
                          ref.read(mealRecordsProvider.notifier)
                              .deleteMealRecord(widget.mealRecord!.id);
                          context.pop(); // pop the dialog
                          context.pop(); // pop the edit screen
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // Tab bar for different input methods
              TabBar(
                tabs: [
                  Tab(
                    icon: Icon(TontonIcons.food),
                    text: 'Manual Entry',
                  ),
                  Tab(
                    icon: Icon(TontonIcons.ai),
                    text: 'AI Estimation',
                  ),
                ],
              ),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  children: [
                    // Manual entry tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(TontonSpacing.md),
                      child: _buildManualEntryForm(context),
                    ),
                    
                    // AI estimation tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(TontonSpacing.md),
                      child: _buildAiEstimationForm(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 80,
        padding: const EdgeInsets.symmetric(
          horizontal: TontonSpacing.md,
          vertical: TontonSpacing.sm,
        ),
        child: ElevatedButton(
          onPressed: _saveMeal,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: TontonSpacing.md),
            textStyle: theme.textTheme.titleMedium,
          ),
          child: Text(_isEditing ? 'Update Meal' : 'Save Meal'),
        ),
      ),
    );
  }
  
  /// Build the manual entry form tab
  Widget _buildManualEntryForm(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current nutrition summary card
        NutritionSummaryCard(
          calories: _calories,
          protein: _protein,
          fat: _fat,
          carbs: _carbs,
          title: 'Current Nutrition',
          showPercentages: true,
        ),
        
        const SizedBox(height: TontonSpacing.md),
        
        // Nutrition editor
        Text(
          'Adjust Nutrition',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: TontonSpacing.sm),
        
        // Interactive nutrition editor with sliders
        NutritionEditor(
          calories: _calories,
          protein: _protein,
          fat: _fat,
          carbs: _carbs,
          onChanged: _updateNutrition,
        ),
        
        const SizedBox(height: TontonSpacing.lg),
        
        // Meal details section
        Text(
          'Meal Details',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: TontonSpacing.sm),
        
        // Meal type selector
        Text(
          'Meal Type',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: TontonSpacing.xs),
        SegmentedButton<MealTimeType>(
          segments: MealTimeType.values.map((type) => 
            ButtonSegment<MealTimeType>(
              value: type,
              label: Text(type.displayName),
              icon: Icon(TontonIcons.mealTimeIcon(type)),
            )
          ).toList(),
          selected: {_selectedMealType},
          onSelectionChanged: (set) {
            setState(() {
              _selectedMealType = set.first;
            });
          },
        ),
        const SizedBox(height: TontonSpacing.md),
        
        // Date and time pickers side by side
        Row(
          children: [
            Expanded(
              child: LabeledTextField(
                label: 'Date',
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                validator: validateRequired,
                suffixIcon: Icon(TontonIcons.calendar),
              ),
            ),
            const SizedBox(width: TontonSpacing.md),
            Expanded(
              child: LabeledTextField(
                label: 'Time',
                controller: _timeController,
                readOnly: true,
                onTap: _selectTime,
                validator: validateRequired,
                suffixIcon: const Icon(Icons.access_time),
              ),
            ),
          ],
        ),
        const SizedBox(height: TontonSpacing.md),
        
        // Meal name field
        LabeledTextField(
          label: 'Meal Name',
          controller: _mealNameController,
          hintText: 'Enter meal name',
          validator: validateRequired,
          suffixIcon: Icon(TontonIcons.food),
        ),
        
        // Description field (optional)
        LabeledTextField(
          label: 'Description (Optional)',
          controller: _descriptionController,
          hintText: 'Enter meal description',
          isMultiline: true,
        ),
      ],
    );
  }
  
  /// Build the AI estimation form tab
  Widget _buildAiEstimationForm(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image selection section
        Text(
          'Take or Select a Photo',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: TontonSpacing.sm),
        
        // Selected image preview
        if (_selectedImageFile != null)
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: TontonSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TontonRadius.md),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  _selectedImageFile!,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: TontonSpacing.xs,
                  right: TontonSpacing.xs,
                  child: IconButton(
                    icon: const Icon(Icons.clear),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedImageFile = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: TontonSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: (0.3 * 255).round()),
              borderRadius: BorderRadius.circular(TontonRadius.md),
              border: Border.all(
                color: theme.colorScheme.outline
                    .withValues(alpha: (0.5 * 255).round()),
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 48,
                    color: theme.colorScheme.primary
                        .withValues(alpha: (0.7 * 255).round()),
                  ),
                  const SizedBox(height: TontonSpacing.sm),
                  Text(
                    'Take or select a photo of your meal',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Image source buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                onPressed: () => _triggerImageEstimation(ImageSource.gallery, ref),
              ),
            ),
            const SizedBox(width: TontonSpacing.md),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                onPressed: () => _triggerImageEstimation(ImageSource.camera, ref),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: TontonSpacing.lg),
        
        // Text-based estimation
        Text(
          'Describe Your Meal',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: TontonSpacing.sm),
        
        LabeledTextField(
          label: 'Meal Description',
          controller: _descriptionController,
          hintText: 'Describe your meal in detail for better AI estimation',
          isMultiline: true,
          suffixIcon: IconButton(
            icon: Icon(TontonIcons.ai),
            tooltip: 'Estimate nutrition with AI',
            onPressed: () => _estimateNutrition(ref),
          ),
        ),
        
        const SizedBox(height: TontonSpacing.md),
        
        // AI estimation status
        Consumer(
          builder: (context, ref, child) {
            final estimationState = ref.watch(aiEstimationProvider);
            
            return estimationState.when(
              data: (nutrition) {
                if (nutrition != null) {
                  // Auto-fill fields with estimated values
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // Update state variables
                    setState(() {
                      _calories = nutrition.calories;
                      _protein = nutrition.nutrients.protein;
                      _fat = nutrition.nutrients.fat;
                      _carbs = nutrition.nutrients.carbs;
                    });
                    
                    // Update controllers
                    _caloriesController.text = nutrition.calories.toString();
                    _proteinController.text = nutrition.nutrients.protein.toString();
                    _fatController.text = nutrition.nutrients.fat.toString();
                    _carbsController.text = nutrition.nutrients.carbs.toString();
                    
                    // Update meal name if provided
                    if (nutrition.mealName.isNotEmpty && 
                        (_mealNameController.text.isEmpty || _mealNameController.text != nutrition.mealName)) {
                      _mealNameController.text = nutrition.mealName;
                    }
                    
                    // Notify user
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AI estimation applied! You can edit values if needed.')),
                    );
                    
                    // Reset after using the values
                    ref.read(aiEstimationProvider.notifier).reset();
                  });
                  
                  // Show the estimated nutrition
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: TontonSpacing.md),
                    child: NutritionSummaryCard(
                      calories: nutrition.calories,
                      protein: nutrition.nutrients.protein,
                      fat: nutrition.nutrients.fat,
                      carbs: nutrition.nutrients.carbs,
                      title: 'AI Estimated Nutrition',
                      subtitle: 'For: ${nutrition.mealName}',
                      showPercentages: true,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => Padding(
                padding: const EdgeInsets.symmetric(vertical: TontonSpacing.md),
                child: Column(
                  children: [
                    const LinearProgressIndicator(),
                    const SizedBox(height: TontonSpacing.sm),
                    Text(
                      'Analyzing with AI...',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.symmetric(vertical: TontonSpacing.sm),
                child: Text(
                  'Error: Failed to estimate nutrition. Please try again or enter manually.',
                  style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: TontonSpacing.md),
        
        // Help text
        Card(
          color: theme.colorScheme.primaryContainer
              .withValues(alpha: (0.3 * 255).round()),
          child: Padding(
            padding: const EdgeInsets.all(TontonSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: theme.colorScheme.primary),
                    const SizedBox(width: TontonSpacing.sm),
                    Text(
                      'AI Nutrition Tips',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TontonSpacing.sm),
                Text(
                  '• For best results, take clear photos of your meals\n'
                  '• Include detailed descriptions like ingredients and portion sizes\n'
                  '• You can always adjust the AI estimates manually',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}