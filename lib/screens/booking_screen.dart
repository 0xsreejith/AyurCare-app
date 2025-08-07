// lib/ui/bookings_page.dart
import 'package:ayur_care_app/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ayur_care_app/data/services/api_service.dart';
import 'package:ayur_care_app/data/models/patient_model.dart';
import 'package:ayur_care_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class BookingsPage extends StatefulWidget {
  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final ApiService apiService = ApiService();

  List<Patient> allPatients = [];
  List<Patient> filteredPatients = [];

  final TextEditingController searchController = TextEditingController();
  String selectedSortBy = 'Treatment';
  final List<String> sortOptions = ['Date', 'Name', 'Treatment'];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    initAndFetch();
    searchController.addListener(() {
      applyFilters();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(() {});
    searchController.dispose();
    super.dispose();
  }

  Future<void> initAndFetch() async {
    setState(() => isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.token != null) {
        apiService.setToken(authProvider.token!);
        await fetchPatients();
      } else {
        throw Exception('User not authenticated. Please login again.');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> fetchPatients() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final patients = await apiService.getPatientList();
      setState(() {
        allPatients = patients;
      });
      applyFilters();
    } catch (e) {
      setState(() {
        isLoading = false;
        allPatients = [];
        filteredPatients = [];
        errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching patients: ${e.toString()}')),
        );
      }
    }
  }

  void applyFilters() {
    final query = (searchController.text ?? '').trim().toLowerCase();
    List<Patient> list = List.from(allPatients);

    // Search by name or treatment
    if (query.isNotEmpty) {
      list = list.where((p) {
        final name = (p.name ?? '').toLowerCase();
        final treatments = (p.patientDetails ?? [])
            .map((d) => (d.treatmentName ?? '').toLowerCase())
            .join(',');
        return name.contains(query) || treatments.contains(query);
      }).toList();
    }

    // Sorting
    list.sort((a, b) {
      switch (selectedSortBy) {
        case 'Name':
          return (a.name ?? '').toLowerCase().compareTo(
            (b.name ?? '').toLowerCase(),
          );
        case 'Treatment':
          final ta = (a.patientDetails != null && a.patientDetails!.isNotEmpty)
              ? (a.patientDetails![0].treatmentName ?? '')
              : '';
          final tb = (b.patientDetails != null && b.patientDetails!.isNotEmpty)
              ? (b.patientDetails![0].treatmentName ?? '')
              : '';
          return ta.toLowerCase().compareTo(tb.toLowerCase());
        case 'Date':
        default:
          final da = (a.dateAndTime ?? '');
          final db = (b.dateAndTime ?? '');
          final parsedA = DateTime.tryParse(da);
          final parsedB = DateTime.tryParse(db);
          if (parsedA != null && parsedB != null)
            return parsedA.compareTo(parsedB);
          if (da.isEmpty && db.isEmpty)
            return (a.name ?? '').compareTo(b.name ?? '');
          if (da.isEmpty) return 1;
          if (db.isEmpty) return -1;
          return da.compareTo(db);
      }
    });

    setState(() {
      filteredPatients = list;
      isLoading = false;
    });
  }

  // Styling helpers using Poppins
  TextStyle headingStyle(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color ?? Colors.black87,
    );
  }

  TextStyle bodyStyle(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color ?? Colors.black54,
    );
  }

  Widget buildSearchAndSortArea() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => applyFilters(),
                    style: bodyStyle(14),
                    decoration: InputDecoration(
                      hintText: 'Search for treatments',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Color(0xFF0E6B3A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: applyFilters,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: Text(
                          'Search',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Sort row
          Row(
            children: [
              Text(
                'Sort by :',
                style: headingStyle(16, weight: FontWeight.w500),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.white,
                ),
                child: DropdownButton<String>(
                  value: selectedSortBy,
                  underline: SizedBox(),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                  items: sortOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => selectedSortBy = v);
                    applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRegisterNowButton() {
    // Bottom positioned button with shadow
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: SafeArea(
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: navigate to register screen
                Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0E6B3A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Register Now',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPatientCard(BuildContext context, int index, Patient patient) {
    final treatment =
        (patient.patientDetails != null && patient.patientDetails!.isNotEmpty)
        ? (patient.patientDetails![0].treatmentName ?? 'N/A')
        : 'N/A';
    final executive = (patient.user ?? '').isNotEmpty ? patient.user! : 'N/A';
    final date = patient.dateAndTime ?? 'N/A';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Index
                Text('${index + 1}.', style: headingStyle(16)),
                SizedBox(width: 8),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient.name ?? 'Unknown', style: headingStyle(16)),
                      SizedBox(height: 6),
                      Text(
                        treatment,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.orange[600],
                          ),
                          SizedBox(width: 6),
                          Text(
                            date,
                            style: bodyStyle(
                              12,
                              color: Colors.orange[600],
                              weight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 14),
                          Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.orange[600],
                          ),
                          SizedBox(width: 6),
                          Text(
                            executive,
                            style: bodyStyle(
                              12,
                              color: Colors.orange[600],
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Colors.grey[300]),
          ),

          // View details
          InkWell(
            onTap: () {
              // TODO: navigate to booking details page
              // Navigator.pushNamed(context, '/bookingDetails', arguments: patient);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'View Booking details',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right, color: Color(0xFF2E7D32)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.black),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              buildSearchAndSortArea(),
              SizedBox(height: 8),

              // List with bottom padding to avoid button overlap
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: fetchPatients,
                        child: errorMessage != null
                            ? ListView(
                                children: [
                                  SizedBox(height: 60),
                                  Center(
                                    child: Text(
                                      'Error: $errorMessage',
                                      style: bodyStyle(14, color: Colors.red),
                                    ),
                                  ),
                                ],
                              )
                            : filteredPatients.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(height: 60),
                                  Center(
                                    child: Text(
                                      'No patients found',
                                      style: bodyStyle(14),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  100,
                                ), // Added bottom padding for button space
                                itemCount: filteredPatients.length,
                                itemBuilder: (context, idx) {
                                  final patient = filteredPatients[idx];
                                  return buildPatientCard(
                                    context,
                                    idx,
                                    patient,
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),

          // Bottom positioned Register button
          buildRegisterNowButton(),
        ],
      ),
    );
  }
}
