import 'package:admin_panel/feature_request/model/feature_request_data_list_model.dart';
import 'package:admin_panel/feature_request/provider/feature_request_provider.dart';
import 'package:admin_panel/network_connection/apis.dart';
import 'package:admin_panel/utils/toast_message/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class FeatureRequestScreen extends StatefulWidget {
  static const String routeName = '/feature-request';

  const FeatureRequestScreen({super.key});

  @override
  State<FeatureRequestScreen> createState() => _FeatureRequestScreenState();
}

class _FeatureRequestScreenState extends State<FeatureRequestScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to ensure this runs after the current build cycle
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    await Provider.of<FeatureRequestProvider>(
      context,
      listen: false,
    ).getAllFeatureRequest();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Calculate number of columns based on screen width
  int _calculateCrossAxisCount(double width) {
    if (width > 1200) {
      return 4; // Large desktop screens
    } else if (width > 900) {
      return 3; // Standard desktop screens
    } else if (width > 600) {
      return 2; // Tablets and small desktops
    } else {
      return 1; // Mobile phones
    }
  }

  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feature Requests')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer<FeatureRequestProvider>(
          builder: (ctx, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${provider.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Filter logic
            final filteredRequests = _selectedFilter == 'All'
                ? provider.featureRequests
                : provider.featureRequests
                      .where(
                        (request) =>
                            request.status.toLowerCase() ==
                            _selectedFilter.toLowerCase(),
                      )
                      .toList();

            return Column(
              children: [
                _buildFilterButtons(),
                Expanded(
                  child: filteredRequests.isEmpty
                      ? const Center(child: Text('No feature requests found'))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = _calculateCrossAxisCount(
                              constraints.maxWidth,
                            );

                            return GridView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: crossAxisCount == 1
                                        ? 1.2
                                        : 1.0,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    mainAxisExtent:
                                        250, // Fixed height for each card
                                  ),
                              itemCount: filteredRequests.length,
                              itemBuilder: (context, index) {
                                final request = filteredRequests[index];
                                return FeatureRequestCard(request: request);
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    final filters = ['All', 'Pending', 'Accepted', 'Declined'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      color: Colors.transparent, // Removed white background
      child: Center(
        // Center the filters
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: filters.map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6F61EF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6F61EF)
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF6F61EF).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class FeatureRequestCard extends StatefulWidget {
  final FeatureRequestData request;

  const FeatureRequestCard({Key? key, required this.request}) : super(key: key);

  @override
  State<FeatureRequestCard> createState() => _FeatureRequestCardState();
}

class _FeatureRequestCardState extends State<FeatureRequestCard> {
  void _showNoteDialog(String action) {
    final TextEditingController _noteController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('${action.capitalize()} Feature Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add a note for future reference:'),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add your reason for ${action.toLowerCase()}ing',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_noteController.text.trim().isEmpty) {
                ToastMessage.error("Error", "Please add a note");
                return;
              }
              FeatureRequestProvider provider =
                  Provider.of<FeatureRequestProvider>(context, listen: false);
              provider.updateFeatureRequestStatus(
                featureRequestId: widget.request.id,
                featureStatus: action,
                featureRequestStatusMessage: _noteController.text.trim(),
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: action == FeatureRequestStatus.accepted.name
                  ? Colors.green
                  : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final formattedDate = dateFormat.format(widget.request.createdAt);

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            if (widget.request.status != FeatureRequestStatus.pending.name)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        widget.request.status ==
                            FeatureRequestStatus.accepted.name
                        ? Colors.green
                        : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.request.status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    widget.request.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                widget.request.description,
                style: const TextStyle(fontSize: 16),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Note section if note exists
            if (widget.request.statusMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Note:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      widget.request.statusMessage,
                      style: TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

            const Divider(),
            Row(
              children: [
                Expanded(child: UserInfoRow(user: widget.request.userId)),

                // Action buttons
                if (widget.request.status == FeatureRequestStatus.pending.name)
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            _showNoteDialog(FeatureRequestStatus.accepted.name),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          minimumSize: Size(0, 36),
                        ),
                        child: Text('Accept'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () =>
                            _showNoteDialog(FeatureRequestStatus.declined.name),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          minimumSize: Size(0, 36),
                        ),
                        child: Text('Decline'),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class UserInfoRow extends StatelessWidget {
  final UserData user;

  const UserInfoRow({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.blueGrey,
          radius: 20,
          child: user.profileImage.isEmpty
              ? Text(
                  '${user.firstName[0]}${user.lastName[0]}',
                  style: const TextStyle(color: Colors.white),
                )
              : ClipOval(
                  child: Image.network(
                    "${Apis.BASE_URL_IMAGE}${user.profileImage}",
                    fit: BoxFit.cover,
                    width: 40, // Double the radius for diameter
                    height: 40, // Double the radius for diameter
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        '${user.firstName[0]}${user.lastName[0]}',
                        style: const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user.firstName} ${user.middleName} ${user.lastName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                user.email,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
