import 'package:admin_panel/navigation/getX_navigation.dart';
import 'package:admin_panel/provider/report_provider/report_provider.dart';
import 'package:admin_panel/report/report_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class ReportScreen extends StatefulWidget {
  static String routeName = "/report-screen";
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  void _fetchReports() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportProvider = Provider.of<ReportProvider>(
        context,
        listen: false,
      );
      reportProvider.getReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header with Title and Refresh Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Reports",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [ 
                    IconButton(
                      onPressed: () {
                        final reportProvider = Provider.of<ReportProvider>(
                          context,
                          listen: false,
                        );
                        reportProvider.getReports();
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh Reports',
                    ),
                    // Download Excel Button
                    Consumer<ReportProvider>(
                      builder: (context, provider, child) {
                        return provider.isDownloading
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.green,
                                  ),
                                ),
                              )
                            : IconButton(
                                onPressed: () async {
                                  final reportProvider =
                                      Provider.of<ReportProvider>(
                                        context,
                                        listen: false,
                                      );

                                  // Use the selected filter for the API call
                                  bool success = await reportProvider
                                      .downloadReportsExcel(_selectedFilter);

                                  if (success) {
                                    toastification.show(
                                      context: context,
                                      type: ToastificationType.success,
                                      style: ToastificationStyle.flatColored,
                                      title: const Text('Excel Downloaded'),
                                      description: const Text(
                                        'Reports exported successfully.',
                                      ),
                                      autoCloseDuration: const Duration(
                                        seconds: 3,
                                      ),
                                      alignment: Alignment.topRight,
                                    );
                                  } else {
                                    toastification.show(
                                      context: context,
                                      type: ToastificationType.error,
                                      style: ToastificationStyle.flatColored,
                                      title: const Text('Download Failed'),
                                      description: const Text(
                                        'Failed to export reports.',
                                      ),
                                      autoCloseDuration: const Duration(
                                        seconds: 3,
                                      ),
                                      alignment: Alignment.topRight,
                                    );
                                  }
                                },
                                icon: const Icon(Icons.download),
                                tooltip: 'Download Excel',
                                color: Colors.green,
                              );
                      },
                    ),
                  ],
                ),
                ],
            ),
            const SizedBox(height: 16),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("All"),
                  const SizedBox(width: 8),
                  _buildFilterChip("Pending"),
                  const SizedBox(width: 8),
                  _buildFilterChip("Resolve"),
                  const SizedBox(width: 8),
                  _buildFilterChip("Decline"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Report List
            Expanded(
              child: Consumer<ReportProvider>(
                builder: (context, reportProvider, child) {
                  if (reportProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Apply Filtering
                  final allReports = reportProvider.reports;
                  final filteredReports = _selectedFilter == 'All'
                      ? allReports
                      : allReports
                            .where(
                              (report) =>
                                  report.status.toLowerCase() ==
                                  _selectedFilter.toLowerCase(),
                            )
                            .toList();

                  if (filteredReports.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.filter_list_off,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ${_selectedFilter == "All" ? "" : _selectedFilter.toLowerCase()} reports found.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      // Determine status color for the card indicator
                      Color statusColor;
                      switch (report.status.toLowerCase()) {
                        case 'resolve':
                          statusColor = Colors.green;
                          break;
                        case 'decline':
                          statusColor = Colors.red;
                          break;
                        case 'pending':
                        default:
                          statusColor = Colors.orange;
                      }

                      return InkWell(
                        onTap: () {
                          GetxNavigation.next(
                            ReportDetailsScreen.routeName,
                            arguments: report.id,
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                // Colored Strip Indicator
                                Container(
                                  width: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Container(
                                            height: 80,
                                            width: 80,
                                            color: Colors.grey[100],
                                            child: Image.network(
                                              'https://api.bhavnika.shop${report.image}',
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    report.modelName
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  _buildStatusChip(
                                                    report.status,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Reported by: ${report.userName}",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[800],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                report.userEmail,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      selectedColor: Colors.blue[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue[900] : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    String label;
    switch (status?.toLowerCase()) {
      case 'resolve':
        color = Colors.green;
        label = 'Resolved';
        break;
      case 'decline':
        color = Colors.red;
        label = 'Declined';
        break;
      case 'pending':
      default:
        color = Colors.orange;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2), // Increased opacity as requested
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.8)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withOpacity(
            1.0,
          ), // Ensure text is fully opaque and readable
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
