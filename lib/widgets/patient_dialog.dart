

import 'package:ayur_care_app/data/models/treatment_model.dart';
import 'package:ayur_care_app/screens/registration_screen.dart';
import 'package:flutter/material.dart';

class AddTreatmentDialog extends StatefulWidget {
  final List<Treatment> availableTreatments;
  final Function(SelectedTreatment) onAddTreatment;
  final SelectedTreatment? editTreatment;

  AddTreatmentDialog({
    required this.availableTreatments,
    required this.onAddTreatment,
    this.editTreatment,
  });

  @override
  _AddTreatmentDialogState createState() => _AddTreatmentDialogState();
}

class _AddTreatmentDialogState extends State<AddTreatmentDialog> {
  Treatment? selectedTreatment;
  int maleCount = 0;
  int femaleCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.editTreatment != null) {
      selectedTreatment = widget.editTreatment!.treatment;
      maleCount = widget.editTreatment!.maleCount;
      femaleCount = widget.editTreatment!.femaleCount;
    }
  }

  void _incMale() => setState(() => maleCount++);
  void _decMale() => setState(() => maleCount = (maleCount - 1).clamp(0, 999));
  void _incFemale() => setState(() => femaleCount++);
  void _decFemale() => setState(() => femaleCount = (femaleCount - 1).clamp(0, 999));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Choose Treatment', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
          ),
          SizedBox(height: 16),
          
          // Treatment Dropdown
          DropdownButtonFormField<Treatment>(
            value: selectedTreatment,
            onChanged: (t) => setState(() => selectedTreatment = t),
            decoration: InputDecoration(
              hintText: 'Choose preferred treatment',
              hintStyle: TextStyle(color: Colors.grey[500]),
              filled: true,
              fillColor: Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF2E7D32)),
            items: widget.availableTreatments.map((t) {
              final title = t.name ?? 'Unknown';
              return DropdownMenuItem<Treatment>(value: t, child: Text(title));
            }).toList(),
          ),
          
          SizedBox(height: 20),
          Text('Add Patients', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          SizedBox(height: 16),
          
          // Male Counter
          _patientCounterRow('Male', maleCount, _incMale, _decMale),
          SizedBox(height: 16),
          
          // Female Counter  
          _patientCounterRow('Female', femaleCount, _incFemale, _decFemale),
          SizedBox(height: 24),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (selectedTreatment == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a treatment'), backgroundColor: Colors.red));
                  return;
                }
                if (maleCount == 0 && femaleCount == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Add at least one patient'), backgroundColor: Colors.red));
                  return;
                }
                final sel = SelectedTreatment(treatment: selectedTreatment!, maleCount: maleCount, femaleCount: femaleCount);
                widget.onAddTreatment(sel);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text('Save', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _patientCounterRow(String label, int count, VoidCallback increment, VoidCallback decrement) {
    return Row(
      children: [
        // Label
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        
        Spacer(),
        
        // Counter Controls
        Row(
          children: [
            // Decrement Button
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: decrement,
                icon: Icon(Icons.remove, color: Colors.white, size: 18),
                padding: EdgeInsets.zero,
              ),
            ),
            
            SizedBox(width: 12),
            
            // Count Display
            Container(
              width: 40,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            
            SizedBox(width: 12),
            
            // Increment Button
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: increment,
                icon: Icon(Icons.add, color: Colors.white, size: 18),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }
}