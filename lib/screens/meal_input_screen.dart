import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // For Image Picker
import '../utils/color_utils.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../enums/meal_time_type.dart';
import '../models/meal_record.dart';
import '../providers/meal_records_provider.dart';
import '../providers/ai_estimation_provider.dart';
import '../utils/validators.dart';
import '../widgets/labeled_text_field.dart';

/// Screen for adding or editing a meal record
class MealInputScreen extends ConsumerStatefulWidget {
  /// The meal record to edit (null for creating a new meal)
  final MealRecord? mealRecord;

  /// Constructor for MealInputScreen
  const MealInputScreen({super.key, this.mealRecord});

  @override
  ConsumerState<MealInputScreen> createState() => _MealInputScreenState();
}

class _MealInputScreenState extends ConsumerState<MealInputScreen> {
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
  File? _selectedImageFile; // To store the selected image file
  // bool _isEstimatingFromImage = false; // To manage UI state during image processing if needed beyond provider state

  @override
  void initState() {
    super.initState();
    _isEditing = widget.mealRecord != null;
    
    if (_isEditing) {
      // Initialize controllers with existing meal data
      _mealNameController = TextEditingController(text: widget.mealRecord!.mealName);
      _descriptionController = TextEditingController(text: widget.mealRecord!.description);
      _caloriesController = TextEditingController(text: widget.mealRecord!.calories.toString());
      _proteinController = TextEditingController(text: widget.mealRecord!.protein.toString());
      _fatController = TextEditingController(text: widget.mealRecord!.fat.toString());
      _carbsController = TextEditingController(text: widget.mealRecord!.carbs.toString());
      _selectedMealType = widget.mealRecord!.mealTimeType;
      _selectedDateTime = widget.mealRecord!.consumedAt;
    } else {
      // Initialize with default values for new meal
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

  /// Show date picker and update the selected date
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    
    if (pickedDate != null) {
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
    
    if (pickedTime != null) {
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

  /// Trigger image selection and then AI estimation from the image
  Future<void> _triggerImageEstimation(ImageSource source, WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1800, // Optional: constrain image size
        maxHeight: 1800,
        imageQuality: 88, // Optional: compress image
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
        
        // Call the provider method to handle upload and estimation
        // UserId is no longer passed here as the new service method doesn't require it directly.
        ref.read(aiEstimationProvider.notifier).estimateNutritionFromImageFile(_selectedImageFile!);

      } else {
        // User cancelled the picker
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected.')),
          );
        }
      }
    } catch (e) {
      // Handle any errors during image picking
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  /// Save the meal record
  void _saveMeal() {
    if (_formKey.currentState!.validate()) {
      // Create a meal record from form values
      final mealRecord = MealRecord(
        id: _isEditing ? widget.mealRecord!.id : null,
        mealName: _mealNameController.text,
        description: _descriptionController.text,
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        fat: double.parse(_fatController.text),
        carbs: double.parse(_carbsController.text),
        mealTimeType: _selectedMealType,
        consumedAt: _selectedDateTime,
        createdAt: _isEditing ? widget.mealRecord!.createdAt : null,
        updatedAt: DateTime.now(),
      );
      
      // Add or update the meal record using the provider
      if (_isEditing) {
        ref.read(mealRecordsProvider.notifier).updateMealRecord(mealRecord);
      } else {
        ref.read(mealRecordsProvider.notifier).addMealRecord(mealRecord);
      }
      
      // Return to previous screen
      context.pop();
    }
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
                          // Delete the meal and return to previous screen
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal type selector
              Text(
                'Meal Type',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<MealTimeType>(
                segments: MealTimeType.values.map((type) => 
                  ButtonSegment<MealTimeType>(
                    value: type,
                    label: Text(type.displayName),
                  )
                ).toList(),
                selected: {_selectedMealType},
                onSelectionChanged: (set) {
                  setState(() {
                    _selectedMealType = set.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              
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
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: LabeledTextField(
                      label: 'Time',
                      controller: _timeController,
                      readOnly: true,
                      onTap: _selectTime,
                      validator: validateRequired,
                    ),
                  ),
                ],
              ),
              
              // Meal name field
              LabeledTextField(
                label: 'Meal Name',
                controller: _mealNameController,
                hintText: 'Enter meal name',
                validator: validateRequired,
              ),
              
              // Description field (optional) with AI button
              LabeledTextField(
                label: 'Description (Optional)',
                controller: _descriptionController,
                hintText: 'Enter meal description',
                isMultiline: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.auto_awesome), // Magic wand for text AI
                  tooltip: 'Estimate nutrition with AI (from text)',
                  onPressed: () => _estimateNutrition(ref),
                ),
              ),
              const SizedBox(height: 16),

              // Section for AI Estimation from Image
              Text(
                'AI Estimation from Image',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_selectedImageFile != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Center(
                    child: Column(
                      children: [
                        Image.file(
                          _selectedImageFile!,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 4),
                        TextButton.icon(
                          icon: const Icon(Icons.clear, size: 18),
                          label: const Text('Clear Image'),
                          onPressed: () {
                            setState(() {
                              _selectedImageFile = null;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('From Gallery'),
                      onPressed: () => _triggerImageEstimation(ImageSource.gallery, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        foregroundColor: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('From Camera'),
                      onPressed: () => _triggerImageEstimation(ImageSource.camera, ref),
                       style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        foregroundColor: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // AI Estimation Status (this Consumer will now also reflect image AI status)
              Consumer(
                builder: (context, ref, child) {
                  final estimationState = ref.watch(aiEstimationProvider);
                  
                  return estimationState.when(
                    data: (nutrition) {
                      if (nutrition != null) {
                        // Auto-fill fields with estimated values
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // Update controllers with the estimated values
                          _caloriesController.text = nutrition.calories.toString();
                          _proteinController.text = nutrition.nutrients.protein.toString();
                          _fatController.text = nutrition.nutrients.fat.toString();
                          _carbsController.text = nutrition.nutrients.carbs.toString();
                          
                          // Update meal name if AI provided a name and it's empty or different
                          if (nutrition.mealName.isNotEmpty && 
                              (_mealNameController.text.isEmpty || _mealNameController.text != nutrition.mealName)) {
                            _mealNameController.text = nutrition.mealName;
                          }

                          // Update description if AI provided one and it's empty or different
                          if (nutrition.description.isNotEmpty &&
                              (_descriptionController.text.isEmpty || _descriptionController.text != nutrition.description)) {
                            _descriptionController.text = nutrition.description;
                          }
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('AI estimation applied! You can edit values if needed.')),
                          );
                          
                          // Reset after using the values
                          ref.read(aiEstimationProvider.notifier).reset();
                        });
                      }
                      return const SizedBox.shrink(); // No visible UI when not loading
                    },
                    loading: () => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          const LinearProgressIndicator(),
                          const SizedBox(height: 8),
                          Text(
                            'Analyzing with AI...',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    error: (error, stack) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Error: Failed to estimate nutrition. Please try again or enter manually.',
                        style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
              
              // Nutrition fields
              Text(
                'Nutrition Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Calories
              LabeledTextField(
                label: 'Calories (kcal)',
                controller: _caloriesController,
                hintText: 'Enter calories',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
                validator: validatePositiveNumber,
              ),
              
              // Macronutrients side by side
              Row(
                children: [
                  // Protein
                  Expanded(
                    child: LabeledTextField(
                      label: 'Protein (g)',
                      controller: _proteinController,
                      hintText: 'Enter protein',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      ],
                      validator: validatePositiveNumber,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Fat
                  Expanded(
                    child: LabeledTextField(
                      label: 'Fat (g)',
                      controller: _fatController,
                      hintText: 'Enter fat',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      ],
                      validator: validatePositiveNumber,
                    ),
                  ),
                ],
              ),
              
              // Carbs
              LabeledTextField(
                label: 'Carbs (g)',
                controller: _carbsController,
                hintText: 'Enter carbohydrates',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
                validator: validatePositiveNumber,
              ),
              
              // AI Feature Help Box
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16), // Adjusted margin
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer
                      .withValues(alpha: (0.3 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: theme.colorScheme.primary
                          .withValues(alpha: (0.5 * 255).round())),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                    Text(
                      'AI Nutrition Estimation',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Text-based: Describe your meal and tap the ✨ icon.\n2. Image-based: Select or take a photo using the buttons above. The AI will attempt to analyze the image.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMeal,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: Text(_isEditing ? 'Update Meal' : 'Save Meal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
