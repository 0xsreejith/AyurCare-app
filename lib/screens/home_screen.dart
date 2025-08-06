import 'package:ayur_care_app/providers/patient_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient List"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          )
        ],
      ),
      body: Consumer<PatientProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchPatients();
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search for treatments",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                // Sort dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text("Sort by: "),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: 'Date',
                        items: const [
                          DropdownMenuItem(value: 'Date', child: Text("Date")),
                          DropdownMenuItem(value: 'Name', child: Text("Name")),
                        ],
                        onChanged: (val) {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Show content
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.patients.isEmpty
                          ? const Center(
                              child: Text("No bookings found"),
                            )
                          : ListView.builder(
                              itemCount: provider.patients.length,
                              itemBuilder: (context, index) {
                                final patient = provider.patients[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${index + 1}. ${patient.name}",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.green),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today, size: 16, color: Colors.orange),
                                            const SizedBox(width: 4),
                                           // Text(patient.date),
                                            const SizedBox(width: 16),
                                            const Icon(Icons.person, size: 16, color: Colors.red),
                                            const SizedBox(width: 4),
                                           // Text(patient.bookedBy),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {
                                              // View booking details
                                            },
                                            child: const Text("View Booking details"),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
