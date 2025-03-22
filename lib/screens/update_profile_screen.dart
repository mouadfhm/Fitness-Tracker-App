import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'profile_screen.dart';

class UpdateProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const UpdateProfileScreen({super.key, required this.profileData});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedGender = 'male';
  String _selectedActivity = 'Moderate';
  String _selectedGoal = 'weight_loss';

  final _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Validate profile data before assigning to avoid assertion error
    _ageController.text = widget.profileData['age']?.toString() ?? '';
    _weightController.text = widget.profileData['weight']?.toString() ?? '';
    _heightController.text = widget.profileData['height']?.toString() ?? '';

    List<String> validGenders = ['male', 'female'];
    List<String> validActivities = ['sedentary', 'light', 'Moderate', 'active', 'very_active'];
    List<String> validGoals = ['weight_loss', 'muscle_gain', 'maintenance'];

    String? gender = widget.profileData['gender'];
    String? activity = widget.profileData['activity_level'];
    String? goal = widget.profileData['fitness_goal'];

    _selectedGender = validGenders.contains(gender) ? gender! : 'male';
    _selectedActivity = validActivities.contains(activity) ? activity! : 'Moderate';
    _selectedGoal = validGoals.contains(goal) ? goal! : 'weight_loss';
  }

  void _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _apiService.updateProfile({
        'age': int.tryParse(_ageController.text.trim()),
        'weight': double.tryParse(_weightController.text.trim()),
        'height': double.tryParse(_heightController.text.trim()),
        'gender': _selectedGender,
        'activity_level': _selectedActivity,
        'fitness_goal': _selectedGoal,
      });

      // Show success message via Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['message'] ?? 'Profile updated successfully.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      _goToProfile();
    } catch (error) {
      // Show error feedback as a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Profile update failed. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $labelText';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Text Fields
            _buildTextField(
              controller: _ageController,
              labelText: 'Age',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter age';
                }
                final age = int.tryParse(value);
                if (age == null || age < 0 || age > 120) {
                  return 'Please enter a valid age';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _weightController,
              labelText: 'Weight (kg)',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter weight';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight < 0 || weight > 500) {
                  return 'Please enter a valid weight';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _heightController,
              labelText: 'Height (cm)',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter height';
                }
                final height = double.tryParse(value);
                if (height == null || height < 0 || height > 300) {
                  return 'Please enter a valid height';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Gender Dropdown
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ['male', 'female']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a gender';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Activity Level Dropdown
            DropdownButtonFormField<String>(
              value: _selectedActivity,
              decoration: InputDecoration(
                labelText: 'Activity Level',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ['sedentary', 'light', 'Moderate', 'active', 'very_active']
                  .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedActivity = value!;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an activity level';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Fitness Goal Dropdown
            DropdownButtonFormField<String>(
              value: _selectedGoal,
              decoration: InputDecoration(
                labelText: 'Fitness Goal',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ['weight_loss', 'muscle_gain', 'maintenance']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGoal = value!;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a fitness goal';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Update Button
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
