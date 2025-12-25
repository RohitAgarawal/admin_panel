import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/access_code_model/access_code_model.dart';
import '../navigation/getX_navigation.dart';
import '../provider/access_code_provider/access_code_provider.dart';
import '../user/user_details_screen.dart';

class AccessCode extends StatefulWidget {
  const AccessCode({super.key});

  @override
  State<AccessCode> createState() => _AccessCodeState();
}

class _AccessCodeState extends State<AccessCode> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccessCodeProvider>(context, listen: false).getAccessCode();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void showUserDialog(BuildContext context, List<dynamic> users) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor:
            Colors.transparent, // Transparent to handle custom container
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Pin Users",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey[200]),
              const SizedBox(height: 16),
              users.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_off_rounded,
                                size: 48,
                                color: Colors.orange[400],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No Users Found",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "This PIN hasn't been used by anyone yet.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: users.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final fName = user['fName']?.isNotEmpty == true
                              ? user['fName'][0]
                              : '';
                          final lName = user['lName']?.isNotEmpty == true
                              ? user['lName'][0]
                              : '';
                          final fullName = "$fName $lName".trim();
                          final email = user['email'] ?? 'No Email';
                          final phone = user['phone']?.isNotEmpty == true
                              ? user['phone'][0]
                              : 'N/A';

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                GetxNavigation.next(
                                  UserDetailsScreen.routeName,
                                  arguments: user['_id'],
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              hoverColor:
                                  Colors.grey[50], // Subtle hover effect
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        fName.isNotEmpty
                                            ? fName[0].toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          color: Colors.blue[800],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fullName.isEmpty
                                                ? 'Unknown User'
                                                : fullName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            email,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          phone,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: Colors.grey[400],
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Softer background color
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Header & Search ---
            Row(
              children: [
                const Text(
                  "Access Codes",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 380,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30), // Pill shape
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search access codes...",
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 12),
                        child: Icon(
                          Icons.search_rounded,
                          color: Colors.grey[400],
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- Content ---
            Expanded(
              child: Consumer<AccessCodeProvider>(
                builder: (context, accessCodeProvider, child) {
                  if (accessCodeProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 🔽 Sort and filter
                  List<AccessCodeModel> sortedCodes = List.from(
                    accessCodeProvider.accessCodes,
                  );
                  // Sort by usage (most used first)
                  sortedCodes.sort((a, b) => b.useCount.compareTo(a.useCount));

                  if (searchQuery.isNotEmpty) {
                    sortedCodes = sortedCodes
                        .where(
                          (code) => code.code.toLowerCase().contains(
                            searchQuery.toLowerCase(),
                          ),
                        )
                        .toList();
                  }

                  if (sortedCodes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "No Access Codes Found",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final double gridWidth = constraints.maxWidth;
                      const double maxCrossAxisExtent = 500;
                      const double mainAxisSpacing = 24;
                      const double crossAxisSpacing = 24;

                      // Calculate columns
                      final int crossAxisCount =
                          (gridWidth / maxCrossAxisExtent).ceil();

                      // Calculate actual width of each card
                      final double availableWidth =
                          gridWidth - ((crossAxisCount - 1) * crossAxisSpacing);
                      final double itemWidth = availableWidth / crossAxisCount;

                      // Desired height ~240px to fit content comfortably without overflow
                      // Ratio = Width / Height
                      final double childAspectRatio = itemWidth / 240;

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: mainAxisSpacing,
                          crossAxisSpacing: crossAxisSpacing,
                          childAspectRatio: childAspectRatio,
                        ),
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: sortedCodes.length,
                        itemBuilder: (context, index) {
                          final code = sortedCodes[index];
                          final remaining = code.maxUseCount - code.useCount;
                          final isDepleted = remaining <= 0;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE0E0E0,
                                  ).withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Material(
                                color: Colors.transparent,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white,
                                              Color(0xFFFAFAFA),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        code.code,
                                                        style: const TextStyle(
                                                          fontSize:
                                                              22, // Slightly larger than 18 for better read
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          letterSpacing: 0.5,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: isDepleted
                                                          ? Colors.red
                                                                .withOpacity(
                                                                  0.08,
                                                                )
                                                          : Colors.green
                                                                .withOpacity(
                                                                  0.08,
                                                                ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      isDepleted
                                                          ? "Fully Used"
                                                          : "Active",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: isDepleted
                                                            ? Colors.red[700]
                                                            : Colors.green[700],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "${index + 1}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[500],
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const Spacer(),

                                          // Usage Stats
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF5F7FA),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                _buildStatItem(
                                                  "Used",
                                                  "${code.useCount}",
                                                  Colors.black87,
                                                ),
                                                Container(
                                                  width: 1,
                                                  height: 20,
                                                  color: Colors.grey[300],
                                                ),
                                                _buildStatItem(
                                                  "Max",
                                                  "${code.maxUseCount}",
                                                  Colors.black87,
                                                ),
                                                Container(
                                                  width: 1,
                                                  height: 20,
                                                  color: Colors.grey[300],
                                                ),
                                                _buildStatItem(
                                                  "Left",
                                                  "$remaining",
                                                  isDepleted
                                                      ? Colors.red
                                                      : Colors.green,
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 16),

                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                final accessCodeProv =
                                                    Provider.of<
                                                      AccessCodeProvider
                                                    >(context, listen: false);
                                                final users =
                                                    await accessCodeProv
                                                        .getUserByAccessCode(
                                                          code.code,
                                                        );

                                                if (!context.mounted) return;
                                                showUserDialog(
                                                  context,
                                                  users ?? [],
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                              ),
                                              icon: const Icon(
                                                Icons.people_outline_rounded,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                "View Users",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
