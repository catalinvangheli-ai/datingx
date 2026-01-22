import 'package:flutter/material.dart';

class ProfileProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProfileProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (currentStep / totalSteps * 100).toInt();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pasul $currentStep din $totalSteps', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: currentStep / totalSteps, backgroundColor: Colors.grey[300], minHeight: 8),
        const SizedBox(height: 4),
        Text('$percentage% completat', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
