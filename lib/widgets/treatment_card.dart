import 'package:flutter/material.dart';
import '../screens/registration_screen.dart'; // for SelectedTreatment

class TreatmentCardWidget extends StatelessWidget {
  final SelectedTreatment st;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  const TreatmentCardWidget({
    Key? key,
    required this.st,
    required this.index,
    required this.onRemove,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('$index.', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(width: 8),
          Expanded(child: Text(st.treatment.name ?? 'Unknown', style: TextStyle(fontSize: 15))),
          Text('₹${st.treatment.price.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[700])),
          SizedBox(width: 8),
          IconButton(onPressed: onRemove, icon: Icon(Icons.close, color: Colors.red)),
        ]),
        SizedBox(height: 8),
        Row(children: [
          // your male/female count UI...
          // The exact Containers as before
          Spacer(),
          IconButton(onPressed: onEdit, icon: Icon(Icons.edit, color: Color(0xFF2E7D32))),
        ]),
      ]),
    );
  }
}