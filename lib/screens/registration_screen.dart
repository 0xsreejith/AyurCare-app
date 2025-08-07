// lib/screens/registration_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:ayur_care_app/data/services/api_service.dart';
import 'package:ayur_care_app/data/models/branch_model.dart';
import 'package:ayur_care_app/data/models/treatment_model.dart';
import 'package:ayur_care_app/providers/register_provider.dart';
import 'package:ayur_care_app/providers/auth_provider.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _totalController = TextEditingController();
  final _discountController = TextEditingController();
  final _advanceController = TextEditingController();
  final _balanceController = TextEditingController();

  // UI state
  String? selectedLocation;
  Branch? selectedBranch;
  String paymentOption = 'Cash';
  DateTime? selectedDate;
  String? selectedHour;
  String? selectedMinute;

  final List<String> locations = [
    'Kochi',
    'Thrissur',
    'Kozhikode',
    'Kannur',
    'Kollam',
    'Thiruvananthapuram'
  ];

  // Local selected treatments with counts
  List<SelectedTreatment> selectedTreatments = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RegisterProvider>(context, listen: false);
    _fetchInitial(provider);
    _setupAmountListeners();
  }

  void _setupAmountListeners() {
    _totalController.addListener(_recomputeBalance);
    _discountController.addListener(_recomputeBalance);
    _advanceController.addListener(_recomputeBalance);
  }

  void _recomputeBalance() {
    final total = double.tryParse(_totalController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final advance = double.tryParse(_advanceController.text) ?? 0.0;
    final balance = (total - discount) - advance;
    _balanceController.text = balance.toStringAsFixed(2);
  }

  Future<void> _fetchInitial(RegisterProvider provider) async {
    setState(() => _isLoading = true);
    try {
      // Ensure we have authentication before making API calls
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        throw Exception('User not authenticated. Please login first.');
      }
      
      await Future.wait([provider.fetchBranches(), provider.fetchTreatments()]);
      
      if (provider.branches.isEmpty) {
        throw Exception('No branches available. Please check your connection.');
      }
      if (provider.treatments.isEmpty) {
        throw Exception('No treatments available. Please check your connection.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load: $e'), 
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _totalController.dispose();
    _discountController.dispose();
    _advanceController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegisterProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Register', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: _isLoading || provider.isLoadingBranches || provider.isLoadingTreatments
          ? Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Name'),
                  _textField(_nameController, hint: 'Enter your full name', validator: (v) => v?.isEmpty == true ? 'Name required' : null),

                  _label('Whatsapp Number'),
                  _textField(_phoneController, hint: 'Enter your Whatsapp number', keyboardType: TextInputType.phone, validator: (v) => v?.isEmpty == true ? 'Phone required' : null),

                  _label('Address'),
                  _textField(_addressController, hint: 'Enter your address', maxLines: 3, validator: (v) => v?.isEmpty == true ? 'Address required' : null),

                  _dropdownField(label: 'Location', hint: 'Choose your location', value: selectedLocation, items: locations, onChanged: (val) => setState(() => selectedLocation = val)),

                  _label('Branch'),
                  DropdownButtonFormField<Branch>(
                    value: selectedBranch,
                    onChanged: (b) {
                      setState(() => selectedBranch = b);
                      if (b != null) provider.setSelectedBranch(b);
                    },
                    decoration: _inputDecoration(hint: 'Select the branch'),
                    items: provider.branches.map((branch) => DropdownMenuItem(value: branch, child: Text(branch.name))).toList(),
                  ),
                  SizedBox(height: 16),

                  _label('Treatments'),
                  SizedBox(height: 8),
                  ...selectedTreatments.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final st = entry.value;
                    return _treatmentCard(st, idx + 1);
                  }).toList(),

                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _showAddTreatmentDialog(provider.treatments),
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE8F5E8), elevation: 0),
                      child: Text('+ Add Treatments', style: TextStyle(color: Color(0xFF2E7D32))),
                    ),
                  ),
                  SizedBox(height: 16),

                  _label('Total Amount'),
                  _textField(_totalController, hint: 'Enter total amount', keyboardType: TextInputType.numberWithOptions(decimal: true), validator: (v) {
                    if (v?.isEmpty == true) return 'Total required';
                    if (double.tryParse(v!) == null) return 'Enter valid number';
                    return null;
                  }),
                  _label('Discount Amount'),
                  _textField(_discountController, hint: 'Enter discount amount', keyboardType: TextInputType.numberWithOptions(decimal: true)),

                  SizedBox(height: 10),
                  _label('Payment Option'),
                  Row(children: [
                    _radioOption('Cash'),
                    SizedBox(width: 12),
                    _radioOption('Card'),
                    SizedBox(width: 12),
                    _radioOption('UPI'),
                  ]),

                  _label('Advance Amount'),
                  _textField(_advanceController, hint: 'Enter advance amount', keyboardType: TextInputType.numberWithOptions(decimal: true)),
                  _label('Balance Amount'),
                  _textField(_balanceController, hint: 'Balance amount', enabled: false),

                  SizedBox(height: 8),
                  _label('Treatment Date'),
                //  _datePickerField(),
                  _label('Treatment Time'),
              //    _timePickers(),

                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: provider.isSubmitting ? null : () => _onSubmit(provider),
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2E7D32)),
                      child: provider.isSubmitting ? CircularProgressIndicator(color: Colors.white) : Text('Save', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  SizedBox(height: 30),
                ]),
              ),
            ),
    );
  }

  Widget _label(String text) => Padding(padding: EdgeInsets.only(bottom: 6), child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)));

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Color(0xFFF5F5F5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _textField(TextEditingController controller, {String? hint, TextInputType? keyboardType, int maxLines = 1, bool enabled = true, String? Function(String?)? validator}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: enabled,
        validator: validator,
        decoration: _inputDecoration(hint: hint),
      ),
    );
  }

  Widget _dropdownField({required String label, required String hint, required String? value, required List<String> items, required Function(String?) onChanged}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: _inputDecoration(hint: hint),
          icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF2E7D32)),
          items: items.map((it) => DropdownMenuItem(value: it, child: Text(it))).toList(),
        ),
        SizedBox(height: 8),
      ]),
    );
  }

  Widget _radioOption(String value) {
    return Row(children: [
      Radio<String>(value: value, groupValue: paymentOption, onChanged: (v) => setState(() => paymentOption = v!)),
      Text(value)
    ]);
  }

  Widget _treatmentCard(SelectedTreatment st, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('$index.', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(width: 8),
          Expanded(child: Text(st.treatment.name ?? 'Unknown', style: TextStyle(fontSize: 15))),
          Text('₹${st.treatment.price.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[700])),
          SizedBox(width: 8),
          IconButton(onPressed: () {
            // remove from local list and from provider
            setState(() {
              selectedTreatments.remove(st);
            });
            final provider = Provider.of<RegisterProvider>(context, listen: false);
            provider.removeTreatmentCompletely(st.treatment);
            _updateTotalFromProvider(provider);
          }, icon: Icon(Icons.close, color: Colors.red)),
        ]),
        SizedBox(height: 8),
        Row(children: [
          Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Color(0xFF2E7D32), borderRadius: BorderRadius.circular(20)), child: Text('Male', style: TextStyle(color: Colors.white))),
          SizedBox(width: 8),
          Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(6)), child: Text('${st.maleCount}')),
          SizedBox(width: 20),
          Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Color(0xFF2E7D32), borderRadius: BorderRadius.circular(20)), child: Text('Female', style: TextStyle(color: Colors.white))),
          SizedBox(width: 8),
          Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(6)), child: Text('${st.femaleCount}')),
          Spacer(),
          IconButton(onPressed: () => _showEditTreatmentDialog(st), icon: Icon(Icons.edit, color: Color(0xFF2E7D32))),
        ]),
      ]),
    );
  }

  void _showAddTreatmentDialog(List<Treatment> available) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AddTreatmentDialog(
          availableTreatments: available,
          onAddTreatment: (sel) {
            setState(() {
              final idx = selectedTreatments.indexWhere((e) => e.treatment.id == sel.treatment.id);
              if (idx != -1) {
                selectedTreatments[idx].maleCount += sel.maleCount;
                selectedTreatments[idx].femaleCount += sel.femaleCount;
              } else {
                selectedTreatments.add(sel);
              }
            });

            // update provider: add repeated treatment entries for counts
            final provider = Provider.of<RegisterProvider>(context, listen: false);
            provider.updateTreatmentCounts(sel.treatment, sel.maleCount, sel.femaleCount);

            // update total on screen from provider computed total
            _updateTotalFromProvider(provider);
          },
        );
      },
    );
  }

  void _showEditTreatmentDialog(SelectedTreatment existing) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AddTreatmentDialog(
          availableTreatments: [existing.treatment],
          editTreatment: existing,
          onAddTreatment: (updated) {
            setState(() {
              final idx = selectedTreatments.indexWhere((e) => e.treatment.id == existing.treatment.id);
              if (idx != -1) selectedTreatments[idx] = updated;
            });

            final provider = Provider.of<RegisterProvider>(context, listen: false);
            provider.updateTreatmentCounts(updated.treatment, updated.maleCount, updated.femaleCount);

            _updateTotalFromProvider(provider);
          },
        );
      },
    );
  }

  void _updateTotalFromProvider(RegisterProvider provider) {
    final total = provider.totalAmount;
    _totalController.text = total.toStringAsFixed(2);
    // ensure discount/advance recalculated
    _recomputeBalance();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: selectedDate ?? now, firstDate: now, lastDate: now.add(Duration(days: 365)));
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _onSubmit(RegisterProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedBranch == null) {
      _showError('Please select branch');
      return;
    }
    if (selectedTreatments.isEmpty) {
      _showError('Please add at least one treatment');
      return;
    }
    if (selectedDate == null || selectedHour == null || selectedMinute == null) {
      _showError('Please select date and time');
      return;
    }

    setState(() => _isLoading = true);

    // date/time string for API: dd/MM/yyyy-hh:mm AM/PM
    final dateTimeString = _formatDateTimeForApi();

    // provider already updated while adding treatments; set branch in provider
    provider.setSelectedBranch(selectedBranch!);

    // set discount and advance on provider so balance calculation matches
    provider.setDiscount(double.tryParse(_discountController.text) ?? 0.0);
    provider.setAdvance(double.tryParse(_advanceController.text) ?? 0.0);

    final success = await provider.registerPatient(
      name: _nameController.text.trim(),
      executive: 'Default Executive',
      payment: paymentOption,
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      dateAndTime: dateTimeString,
    );

    if (!success) {
      _showError('Registration failed. Check logs for details.');
      setState(() => _isLoading = false);
      return;
    }

    // Generate PDF and share
    try {
      final bytes = await _generatePdf();
      await Printing.sharePdf(bytes: bytes, filename: 'registration_${DateTime.now().millisecondsSinceEpoch}.pdf');
      _showSuccess('Patient registered and PDF generated');
      // clear provider selections
      provider.clearSelections();
      Navigator.of(context).pop();
    } catch (e) {
      _showError('Registered but failed to generate PDF: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDateTimeForApi() {
    if (selectedDate == null || selectedHour == null || selectedMinute == null) return '';
    final day = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final hourInt = int.parse(selectedHour!);
    final minuteInt = int.parse(selectedMinute!);
    // treat hour dropdown as 12-hour with AM by default
    final dt = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, hourInt % 12, minuteInt);
    final timeStr = DateFormat('hh:mm a').format(dt);
    return '$day-$timeStr';
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context ctx) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(16),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('Noviindus Technologies', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text('Name: ${_nameController.text}'),
              pw.Text('Phone: ${_phoneController.text}'),
              pw.Text('Address: ${_addressController.text}'),
              pw.Text('Location: ${selectedLocation ?? ''}'),
              pw.Text('Branch: ${selectedBranch?.name ?? ''}'),
              pw.SizedBox(height: 8),
              pw.Text('Treatments:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Column(children: selectedTreatments.map((st) {
                return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Text(st.treatment.name ?? ''),
                  pw.Text('M:${st.maleCount} F:${st.femaleCount}'),
                ]);
              }).toList()),
              pw.SizedBox(height: 12),
              pw.Text('Payment: $paymentOption'),
              pw.Text('Total: ${_totalController.text}'),
              pw.Text('Discount: ${_discountController.text}'),
              pw.Text('Advance: ${_advanceController.text}'),
              pw.Text('Balance: ${_balanceController.text}'),
              pw.SizedBox(height: 8),
              pw.Text('Date & Time: ${_formatDateTimeForApi()}'),
            ]),
          );
        },
      ),
    );
    return pdf.save();
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
}

/// SelectedTreatment model used by this screen
class SelectedTreatment {
  final Treatment treatment;
  int maleCount;
  int femaleCount;
  SelectedTreatment({required this.treatment, this.maleCount = 0, this.femaleCount = 0});
}

/// AddTreatmentDialog (same dialog used previously)
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
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.editTreatment != null ? 'Edit Treatment' : 'Choose Treatment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 12),
          DropdownButtonFormField<Treatment>(
            value: selectedTreatment,
            onChanged: (t) => setState(() => selectedTreatment = t),
            decoration: InputDecoration(
              hintText: 'Choose preferred treatment',
              filled: true,
              fillColor: Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF2E7D32)),
            items: widget.availableTreatments.map((t) {
              final title = t.name ?? 'Unknown';
              final subtitle = ' - ₹${t.price.toStringAsFixed(0)}';
              return DropdownMenuItem<Treatment>(value: t, child: Text('$title$subtitle'));
            }).toList(),
          ),
          SizedBox(height: 16),
          Text('Add Patients', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          Row(children: [
            Expanded(child: Text('Male')),
            _counterWidget(maleCount, _incMale, _decMale),
          ]),
          SizedBox(height: 12),
          Row(children: [
            Expanded(child: Text('Female')),
            _counterWidget(femaleCount, _incFemale, _decFemale),
          ]),
          SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            SizedBox(width: 8),
            ElevatedButton(
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
              child: Text(widget.editTreatment != null ? 'Update' : 'Add'),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _counterWidget(int value, VoidCallback inc, VoidCallback dec) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey[300]!)),
      child: Row(children: [
        IconButton(icon: Icon(Icons.remove, size: 18), onPressed: dec),
        Text(value.toString(), style: TextStyle(fontSize: 16)),
        IconButton(icon: Icon(Icons.add, size: 18), onPressed: inc),
      ]),
    );
  }
}
