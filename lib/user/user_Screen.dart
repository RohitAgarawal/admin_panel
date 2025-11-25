import 'package:admin_panel/model/user_model/user_model.dart';
import 'package:admin_panel/navigation/getX_navigation.dart';
import 'package:admin_panel/provider/access_code_provider/access_code_provider.dart';
import 'package:admin_panel/user/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/user_model/user_tab_model.dart';
import '../provider/user_provider/user_provider.dart';

class UserScreen extends StatefulWidget {
  static const routeName = "/user-screen";

  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  DateTimeRange? _selectedDateRange;
  Set<String> _loadingUserIds = {};

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    AccessCodeProvider accessCodeProvider = Provider.of<AccessCodeProvider>(
      context,
      listen: false,
    );
    accessCodeProvider.getAccessCode();
    userProvider.getUserCategory().then((_) {
      List<String> categories = userProvider.userCategories
          .map((e) => e.category)
          .toList();
      if (userProvider.userCategories.isNotEmpty) {
        int initialIndex = 0;
        if (userProvider.getSelectedCategory == "A" &&
            categories.contains("A")) {
          initialIndex = 1;
        } else if (userProvider.getSelectedCategory == "B" &&
            categories.contains("B")) {
          initialIndex = 2;
        } else if (userProvider.getSelectedCategory == "α" &&
            categories.contains("α")) {
          initialIndex = 3;
        } else if (userProvider.getSelectedCategory == "β" &&
            categories.contains("β")) {
          initialIndex = 4;
        } else {
          initialIndex = 0;
        }
        userProvider.getUser();
        // Create tab controller
        if (mounted) {
          setState(() {
            _tabController = TabController(
              length: userProvider.userCategories.length,
              vsync: this,
              initialIndex: initialIndex,
            );
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    DateTime? tempStart = _selectedDateRange?.start;
    DateTime? tempEnd = _selectedDateRange?.end;

    TextEditingController startController = TextEditingController(
      text: tempStart != null
          ? DateFormat('dd/MM/yyyy').format(tempStart!)
          : '',
    );
    TextEditingController endController = TextEditingController(
      text: tempEnd != null ? DateFormat('dd/MM/yyyy').format(tempEnd!) : '',
    );

    // Calculate total months from 2020 to now
    DateTime startDate = DateTime(2020, 1);
    DateTime now = DateTime.now();
    int totalMonths =
        (now.year - startDate.year) * 12 + now.month - startDate.month + 1;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: 450, // Increased width
                height: 550, // Increased height
                child: Column(
                  children: [
                    // Header with Inputs
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Start Date",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: startController,
                                  decoration: InputDecoration(
                                    hintText: "DD/MM/YYYY",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                    isDense: true,
                                  ),
                                  onChanged: (val) {
                                    try {
                                      if (val.length == 10) {
                                        DateTime parsed = DateFormat(
                                          'dd/MM/yyyy',
                                        ).parse(val);
                                        setState(() {
                                          tempStart = parsed;
                                        });
                                      }
                                    } catch (e) {}
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 20,
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "End Date",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: endController,
                                  decoration: InputDecoration(
                                    hintText: "DD/MM/YYYY",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                    isDense: true,
                                  ),
                                  onChanged: (val) {
                                    try {
                                      if (val.length == 10) {
                                        DateTime parsed = DateFormat(
                                          'dd/MM/yyyy',
                                        ).parse(val);
                                        setState(() {
                                          tempEnd = parsed;
                                        });
                                      }
                                    } catch (e) {}
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    // Quick Select Chips
                    SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Wrap(
                        direction: Axis.horizontal,
                        spacing: 5,
                        runSpacing: 5,
                        runAlignment: WrapAlignment.center,
                        children: [
                          _buildQuickSelectChip(
                            "Last 30 Days",
                            30,
                            setState,
                            (s, e) {
                              tempStart = s;
                              tempEnd = e;
                              startController.text = DateFormat(
                                'dd/MM/yyyy',
                              ).format(s);
                              endController.text = DateFormat(
                                'dd/MM/yyyy',
                              ).format(e);
                            },
                            tempStart,
                            tempEnd,
                          ),
                          SizedBox(width: 12),
                          _buildQuickSelectChip(
                            "Last 6 Months",
                            180,
                            setState,
                            (s, e) {
                              tempStart = s;
                              tempEnd = e;
                              startController.text = DateFormat(
                                'dd/MM/yyyy',
                              ).format(s);
                              endController.text = DateFormat(
                                'dd/MM/yyyy',
                              ).format(e);
                            },
                            tempStart,
                            tempEnd,
                          ),
                          SizedBox(width: 12),
                          _buildQuickSelectChip(
                            "Last 1 Year",
                            365,
                            setState,
                            (s, e) {
                              tempStart = s;
                              tempEnd = e;
                              startController.text = DateFormat(
                                'dd/MM/yyyy',
                              ).format(s);
                              endController.text = DateFormat(
                                'dd/MM/yyyy',
                              ).format(e);
                            },
                            tempStart,
                            tempEnd,
                          ),
                          SizedBox(width: 12),
                          _buildQuickSelectChip(
                            "Last 5 Years",
                            365 * 5,
                            setState,
                            (s, e) {
                              tempStart = s;
                              tempEnd = e;
                              startController.text = DateFormat(
                                'dd/MM/yyyy',
                              ).format(s);
                              endController.text = DateFormat(
                                'dd/MM/yyyy',
                              ).format(e);
                            },
                            tempStart,
                            tempEnd,
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    // Scrollable Calendar
                    Expanded(
                      child: ListView.builder(
                        reverse: true, // Current month at bottom
                        padding: EdgeInsets.symmetric(vertical: 10),
                        itemCount: totalMonths,
                        itemBuilder: (context, index) {
                          // but for "recent" maybe newest first.
                          // Let's stick to chronological as calculated above.
                          // Actually, let's reverse it so we see 2025 first?
                          // User usually wants to filter recent users. Let's show newest first.

                          DateTime monthDate = DateTime(
                            now.year,
                            now.month - index,
                          );

                          return _buildMonthView(
                            monthDate,
                            tempStart,
                            tempEnd,
                            (date) {
                              setState(() {
                                if (tempStart == null ||
                                    (tempStart != null && tempEnd != null)) {
                                  tempStart = date;
                                  tempEnd = null;
                                } else if (tempStart != null &&
                                    tempEnd == null) {
                                  if (date.isBefore(tempStart!)) {
                                    tempStart = date;
                                  } else {
                                    tempEnd = date;
                                  }
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    // Footer
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey,
                            ),
                            child: Text("Cancel"),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: (tempStart != null && tempEnd != null)
                                ? () {
                                    this.setState(() {
                                      _selectedDateRange = DateTimeRange(
                                        start: tempStart!,
                                        end: tempEnd!,
                                      );
                                    });
                                    Navigator.pop(context);
                                  }
                                : null,
                            child: Text("Apply"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMonthView(
    DateTime monthDate,
    DateTime? start,
    DateTime? end,
    Function(DateTime) onDateTap,
  ) {
    int daysInMonth = DateUtils.getDaysInMonth(monthDate.year, monthDate.month);
    int firstWeekday = DateTime(monthDate.year, monthDate.month, 1).weekday % 7;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              DateFormat('MMMM yyyy').format(monthDate),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 1,
            ),
            itemCount: daysInMonth + firstWeekday,
            itemBuilder: (context, index) {
              if (index < firstWeekday) return Container();

              int day = index - firstWeekday + 1;
              DateTime date = DateTime(monthDate.year, monthDate.month, day);

              bool isStart = start != null && DateUtils.isSameDay(date, start);
              bool isEnd = end != null && DateUtils.isSameDay(date, end);
              bool isInRange =
                  start != null &&
                  end != null &&
                  date.isAfter(start) &&
                  date.isBefore(end);

              return GestureDetector(
                onTap: () => onDateTap(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isStart || isEnd
                        ? Colors.green.shade700
                        : isInRange
                        ? Colors.green.shade100
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$day",
                    style: TextStyle(
                      color: isStart || isEnd ? Colors.white : Colors.black87,
                      fontWeight: (isStart || isEnd)
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelectChip(
    String label,
    int days,
    StateSetter setState,
    Function(DateTime, DateTime) onSelect,
    DateTime? currentStart,
    DateTime? currentEnd,
  ) {
    DateTime now = DateTime.now();
    DateTime end = DateTime(now.year, now.month, now.day);
    DateTime start = end.subtract(Duration(days: days));

    bool isSelected = false;
    if (currentStart != null && currentEnd != null) {
      isSelected =
          DateUtils.isSameDay(currentStart, start) &&
          DateUtils.isSameDay(currentEnd, end);
    }

    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: isSelected ? Colors.green.shade700 : Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        setState(() {
          onSelect(start, end);
        });
      },
    );
  }

  Future<void> showAccessCodeDialog(UserModel user) async {
    AccessCodeProvider accessCodeProvider = Provider.of<AccessCodeProvider>(
      context,
      listen: false,
    );
    await accessCodeProvider.getAccessCode();

    String? selectedCode;
    int cancelCount = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Access Code List"),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = (constraints.maxWidth / 150).floor();
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: accessCodeProvider.accessCodes.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2,
                        ),
                        itemBuilder: (context, index) {
                          final codeItem =
                              accessCodeProvider.accessCodes[index];
                          final isSelected = selectedCode == codeItem.code;

                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedCode = isSelected
                                    ? null
                                    : codeItem.code;
                                cancelCount =
                                    0; // Reset cancel count on selection
                              });
                            },
                            child: Card(
                              color: isSelected
                                  ? Colors.green.shade100
                                  : Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: isSelected
                                    ? BorderSide(
                                        color: Colors.green.shade700,
                                        width: 2,
                                      )
                                    : BorderSide.none,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Code: ${codeItem.code}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      "Use Count: ${codeItem.useCount}",
                                      style: const TextStyle(fontSize: 12),
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (selectedCode != null) {
                            selectedCode = null;
                            cancelCount = 1;
                          } else {
                            cancelCount++;
                            if (cancelCount >= 2) {
                              Navigator.pop(context); // Close dialog
                            }
                          }
                        });
                      },
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: selectedCode != null
                          ? () {
                              Map<String, dynamic> body = {
                                "code": selectedCode,
                                "email": user.email,
                                "userCategory": user.category,
                              };
                              accessCodeProvider.userAccess(body);
                              Navigator.pop(context); // Close dialog
                            }
                          : null,
                      child: const Text("Send"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AccessCodeProvider accessCodeProvider = Provider.of<AccessCodeProvider>(
      context,
      listen: true,
    );
    return Scaffold(
      backgroundColor: Color(
        0xFFF5F7FA,
      ), // Light grey background for modern feel
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                List<UserTabModel> categories = userProvider.userCategories;

                if (categories.isEmpty || _tabController == null) {
                  return Center(child: CircularProgressIndicator());
                }
                // Make sure the tab controller is in sync with the selected category
                int selectedIndex = categories.indexWhere((element) {
                  if (userProvider.getSelectedCategory == "" &&
                      element.category == "All") {
                    return true;
                  }
                  return element.category == userProvider.getSelectedCategory;
                });

                // If found valid index, update the tab controller
                if (selectedIndex != -1 &&
                    _tabController!.index != selectedIndex) {
                  _tabController!.animateTo(selectedIndex);
                }

                return Column(
                  children: [
                    // Category Tabs (Custom Implementation)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.asMap().entries.map((entry) {
                          int index = entry.key;
                          UserTabModel category = entry.value;
                          bool isSelected = _tabController?.index == index;

                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _tabController?.animateTo(index);
                                });
                                String selectedCategory = category.category;
                                if (selectedCategory == "All") {
                                  selectedCategory = "";
                                }
                                userProvider.setSelectedCategory(
                                  selectedCategory,
                                );
                                userProvider.getUser();
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.green.shade700
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.green.shade700
                                        : Colors.grey.shade300,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.green.shade700
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.03,
                                            ),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Text(
                                  "${category.category} (${category.count})",
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Filters and Date Picker Row
                    Row(
                      children: [
                        // Status Filters
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildFilterButton(context, 'Verified'),
                            _buildFilterButton(context, 'Pending'),
                            _buildFilterButton(context, 'Disabled'),
                            _buildFilterButton(context, 'Deleted'),
                          ],
                        ),
                        Spacer(), // Push Date Filter to the right
                        // Date Filter
                        InkWell(
                          onTap: _selectDateRange,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: Colors.grey.shade700,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  _selectedDateRange == null
                                      ? "Filter by Date"
                                      : "${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.end)}",
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                if (_selectedDateRange != null) ...[
                                  SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedDateRange = null;
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  var users = userProvider.usersByCategory;

                  // Apply Date Range Filter
                  if (_selectedDateRange != null) {
                    users = users.where((user) {
                      if (user.timestamps.isEmpty) return false;
                      try {
                        final createdAt = DateTime.parse(user.timestamps);
                        return createdAt.isAfter(
                              _selectedDateRange!.start.subtract(
                                Duration(days: 1),
                              ),
                            ) &&
                            createdAt.isBefore(
                              _selectedDateRange!.end.add(Duration(days: 1)),
                            );
                      } catch (e) {
                        return false;
                      }
                    }).toList();
                  }

                  if (userProvider.isLoading && users.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No users found",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return InkWell(
                        onTap: () {
                          GetxNavigation.next(
                            UserDetailsScreen.routeName,
                            arguments: user.id,
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Hero(
                                tag: 'user_avatar_${user.id}',
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade100,
                                    image:
                                        user.profilePicture.isNotEmpty &&
                                            user.profilePicture.last.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              "https://api.bhavnika.shop${user.profilePicture.last}",
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child:
                                      user.profilePicture.isEmpty ||
                                          user.profilePicture.last.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          color: Colors.grey.shade400,
                                          size: 30,
                                        )
                                      : null,
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${user.fName.isNotEmpty ? user.fName.last : ''} ${user.lName.isNotEmpty ? user.lName.last : ''}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      user.email,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    if (user.timestamps.isNotEmpty) ...[
                                      SizedBox(height: 4),
                                      Text(
                                        "Joined: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(user.timestamps))}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  // Active/Inactive Toggle
                                  Tooltip(
                                    message: user.isActive
                                        ? "Deactivate User"
                                        : "Activate User",
                                    child:
                                        (user.id != null &&
                                            _loadingUserIds.contains(user.id!))
                                        ? Container(
                                            width: 36,
                                            height: 36,
                                            padding: EdgeInsets.all(8),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.green,
                                                  ),
                                            ),
                                          )
                                        : IconButton(
                                            onPressed: () async {
                                              if (user.id == null) return;
                                              setState(() {
                                                _loadingUserIds.add(user.id!);
                                              });
                                              bool success = await userProvider
                                                  .userActiveInactive(
                                                    '${user.id}',
                                                  );
                                              if (success) {
                                                setState(() {
                                                  user.isActive =
                                                      !user.isActive;
                                                });
                                              }
                                              setState(() {
                                                _loadingUserIds.remove(
                                                  user.id!,
                                                );
                                              });
                                            },
                                            icon: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: user.isActive
                                                    ? Colors.green.withOpacity(
                                                        0.1,
                                                      )
                                                    : Colors.red.withOpacity(
                                                        0.1,
                                                      ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                user.isActive
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: user.isActive
                                                    ? Colors.green
                                                    : Colors.red,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                  ),
                                  SizedBox(width: 8),
                                  // Verify Button
                                  TextButton(
                                    onPressed: () async {
                                      if ((user.category == 'A' ||
                                              user.category == 'α') &&
                                          !user.isPinVerified) {
                                        showAccessCodeDialog(user);
                                      } else if ((user.category == 'B' ||
                                              user.category == 'β') &&
                                          !user.isOtpVerified) {
                                        Map<String, dynamic> body = {
                                          "email": user.email,
                                          "userCategory": user.category,
                                        };
                                        accessCodeProvider.userAccess(body);
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      backgroundColor:
                                          ((user.category == 'A' ||
                                                  user.category == 'α')
                                              ? user.isPinVerified
                                              : user.isOtpVerified)
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      (user.category == 'A' ||
                                              user.category == 'α')
                                          ? (user.isPinVerified
                                                ? 'Verified'
                                                : 'Verify PIN')
                                          : (user.isOtpVerified
                                                ? 'Verified'
                                                : 'Verify OTP'),
                                      style: TextStyle(
                                        color:
                                            ((user.category == 'A' ||
                                                    user.category == 'α')
                                                ? user.isPinVerified
                                                : user.isOtpVerified)
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  // Delete/Restore Button
                                  IconButton(
                                    tooltip: user.isDeleted
                                        ? "Restore User"
                                        : "Delete User",
                                    icon: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: user.isDeleted
                                            ? Colors.blue.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        user.isDeleted
                                            ? Icons.restore_outlined
                                            : Icons.delete_outline,
                                        color: user.isDeleted
                                            ? Colors.blue
                                            : Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                    onPressed: () async {
                                      bool isDelete = !user.isDeleted;
                                      bool? confirm = await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          title: Text(
                                            isDelete
                                                ? "Confirm Deletion"
                                                : "Confirm Restore",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: Text(
                                            isDelete
                                                ? "Are you sure you want to delete this user?"
                                                : "Are you sure you want to restore this user?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isDelete
                                                    ? Colors.red
                                                    : Colors.green,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () async {
                                                await userProvider.deleteUser(
                                                  '${user.id}',
                                                );
                                                Navigator.of(context).pop(true);
                                              },
                                              child: Text(
                                                isDelete ? "Delete" : "Restore",
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
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

  Widget _buildFilterButton(BuildContext context, String label) {
    final userProvider = Provider.of<UserProvider>(context);
    final isSelected = userProvider.statusFilter == label;
    var count = 0;
    int pendingCount = 0;
    for (var user in userProvider.usersByCategory) {
      if (!user.isPinVerified || !user.isOtpVerified) {
        pendingCount++;
      }
    }
    int disabledCount = 0;
    for (var user in userProvider.usersByCategory) {
      if (!user.isActive) {
        disabledCount++;
      }
    }
    int deletedCount = 0;
    for (var user in userProvider.usersByCategory) {
      if (user.isDeleted) {
        deletedCount++;
      }
    }
    int verifiedCount = 0;
    for (var user in userProvider.usersByCategory) {
      if (user.isPinVerified && user.isOtpVerified) {
        verifiedCount++;
      }
    }
    switch (label) {
      case 'Pending':
        count = pendingCount;
        break;
      case 'Disabled':
        count = disabledCount;
        break;
      case 'Deleted':
        count = deletedCount;
        break;
      case 'Verified':
        count = verifiedCount;
        break;
      default:
        count = 0;
    }
    return InkWell(
      onTap: () {
        final newVal = isSelected ? '' : label;
        userProvider.setStatusFilter(newVal);
        userProvider.getUser();
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.green.shade700 : Colors.grey.shade200,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.green.shade700.withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          "$label ($count)",
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
