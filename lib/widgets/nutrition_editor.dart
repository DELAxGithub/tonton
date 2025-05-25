import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// A widget for displaying and editing nutrition information.
class NutritionEditor extends StatefulWidget {
  /// Current calorie value
  final double calories;
  
  /// Current protein value (in grams)
  final double protein;
  
  /// Current fat value (in grams)
  final double fat;
  
  /// Current carbs value (in grams)
  final double carbs;
  
  /// Callback when nutrition values change
  final void Function(double calories, double protein, double fat, double carbs) onChanged;
  
  /// Optional max values to display in the sliders
  final double? maxCalories;
  final double? maxProtein;
  final double? maxFat;
  final double? maxCarbs;
  
  const NutritionEditor({
    super.key,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.onChanged,
    this.maxCalories,
    this.maxProtein,
    this.maxFat,
    this.maxCarbs,
  });

  @override
  State<NutritionEditor> createState() => _NutritionEditorState();
}

class _NutritionEditorState extends State<NutritionEditor> {
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _fatController;
  late final TextEditingController _carbsController;
  
  double _calories = 0;
  double _protein = 0;
  double _fat = 0;
  double _carbs = 0;
  
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    _calories = widget.calories;
    _protein = widget.protein;
    _fat = widget.fat;
    _carbs = widget.carbs;
    
    _caloriesController = TextEditingController(text: _calories.toString());
    _proteinController = TextEditingController(text: _protein.toString());
    _fatController = TextEditingController(text: _fat.toString());
    _carbsController = TextEditingController(text: _carbs.toString());
  }
  
  @override
  void didUpdateWidget(NutritionEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.calories != widget.calories) {
      _calories = widget.calories;
      _caloriesController.text = _calories.toString();
    }
    if (oldWidget.protein != widget.protein) {
      _protein = widget.protein;
      _proteinController.text = _protein.toString();
    }
    if (oldWidget.fat != widget.fat) {
      _fat = widget.fat;
      _fatController.text = _fat.toString();
    }
    if (oldWidget.carbs != widget.carbs) {
      _carbs = widget.carbs;
      _carbsController.text = _carbs.toString();
    }
  }
  
  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }
  
  void _submitChanges() {
    if (_formKey.currentState!.validate()) {
      widget.onChanged(_calories, _protein, _fat, _carbs);
    }
  }
  
  void _updateCalories(double value) {
    setState(() {
      _calories = value;
      _caloriesController.text = value.toStringAsFixed(0);
    });
    _submitChanges();
  }
  
  void _updateProtein(double value) {
    setState(() {
      _protein = value;
      _proteinController.text = value.toStringAsFixed(1);
    });
    _submitChanges();
  }
  
  void _updateFat(double value) {
    setState(() {
      _fat = value;
      _fatController.text = value.toStringAsFixed(1);
    });
    _submitChanges();
  }
  
  void _updateCarbs(double value) {
    setState(() {
      _carbs = value;
      _carbsController.text = value.toStringAsFixed(1);
    });
    _submitChanges();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxCalories = widget.maxCalories ?? 2000;
    final maxProtein = widget.maxProtein ?? 100;
    final maxFat = widget.maxFat ?? 100;
    final maxCarbs = widget.maxCarbs ?? 300;
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calories
          _buildNutrientRow(
            context: context,
            label: 'Calories',
            unit: 'kcal',
            value: _calories,
            maxValue: maxCalories,
            controller: _caloriesController,
            color: theme.colorScheme.primary,
            onChanged: (value) {
              if (value != null) {
                _updateCalories(value);
              }
            },
            onSliderChanged: _updateCalories,
          ),
          
          const SizedBox(height: TontonSpacing.sm),
          
          // Protein
          _buildNutrientRow(
            context: context,
            label: 'Protein',
            unit: 'g',
            value: _protein,
            maxValue: maxProtein,
            controller: _proteinController,
            color: Colors.red.shade700,
            onChanged: (value) {
              if (value != null) {
                _updateProtein(value);
              }
            },
            onSliderChanged: _updateProtein,
          ),
          
          const SizedBox(height: TontonSpacing.sm),
          
          // Fat
          _buildNutrientRow(
            context: context,
            label: 'Fat',
            unit: 'g',
            value: _fat,
            maxValue: maxFat,
            controller: _fatController,
            color: Colors.amber.shade700,
            onChanged: (value) {
              if (value != null) {
                _updateFat(value);
              }
            },
            onSliderChanged: _updateFat,
          ),
          
          const SizedBox(height: TontonSpacing.sm),
          
          // Carbs
          _buildNutrientRow(
            context: context,
            label: 'Carbs',
            unit: 'g',
            value: _carbs,
            maxValue: maxCarbs,
            controller: _carbsController,
            color: Colors.blue.shade700,
            onChanged: (value) {
              if (value != null) {
                _updateCarbs(value);
              }
            },
            onSliderChanged: _updateCarbs,
          ),
        ],
      ),
    );
  }
  
  Widget _buildNutrientRow({
    required BuildContext context,
    required String label,
    required String unit,
    required double value,
    required double maxValue,
    required TextEditingController controller,
    required Color color,
    required void Function(double? value) onChanged,
    required void Function(double value) onSliderChanged,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Slider
        Expanded(
          flex: 3,
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor:
                  color.withOpacity(0.2),
              thumbColor: color,
            ),
            child: Slider(
              min: 0,
              max: maxValue,
              value: value.clamp(0, maxValue),
              onChanged: onSliderChanged,
            ),
          ),
        ),
        
        // Value text field
        SizedBox(
          width: 70,
          height: 40,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: TontonSpacing.sm,
                vertical: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TontonRadius.md),
              ),
              suffixText: unit,
              suffixStyle: theme.textTheme.bodySmall,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              final number = double.tryParse(value);
              if (number == null || number < 0) {
                return 'Invalid';
              }
              return null;
            },
            onChanged: (value) {
              final number = double.tryParse(value);
              onChanged(number);
            },
          ),
        ),
      ],
    );
  }
}