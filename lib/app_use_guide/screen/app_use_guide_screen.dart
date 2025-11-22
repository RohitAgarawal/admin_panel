import 'dart:math';
import 'dart:html' as html;

import 'package:admin_panel/app_use_guide/provider/app_use_guide_provider.dart';
import 'package:admin_panel/app_use_guide/widget/add_video_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUseGuideScreen extends StatefulWidget {
  static const String routeName = "/app-use-guide-screen";

  const AppUseGuideScreen({super.key});

  @override
  State<AppUseGuideScreen> createState() => _AppUseGuideScreenState();
}

class _AppUseGuideScreenState extends State<AppUseGuideScreen> {
  @override
  void initState() {
    // TODO: implement initState
    Future.microtask((){
      AppUseGuideProvider provider = Provider.of<AppUseGuideProvider>(context, listen: false);
      provider.getAppGuideVideo();
    });
    super.initState();
  }
  String formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];

    // Use log() from dart:math — not bytes.log()
    int i = (log(bytes) / log(1024)).floor();
    double size = bytes / pow(1024, i);

    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }


  String formatDate(String dateString) {
    try {
      final utcDate = DateTime.parse(dateString); // Parse UTC or ISO string
      final localDate = utcDate.toLocal(); // Convert to local timezone
      return DateFormat('dd MMM yyyy, hh:mm a').format(localDate);
    } catch (_) {
      return dateString; // fallback if parsing fails
    }
  }


  Future<void> openVideo(String url) async {
    if (kIsWeb) {
      html.window.open(url, '_blank');
    } else {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
  Widget _infoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.deepPurpleAccent),
      label: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
      backgroundColor: Colors.deepPurple.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'App Use Guide - Videos',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          // Refresh button (disabled while loading)
          Consumer<AppUseGuideProvider>(
            builder: (context, provider, _) => IconButton(
              tooltip: 'Refresh',
              onPressed: provider.isLoading ? null : () => provider.getAppGuideVideo(),
              icon: provider.isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.refresh, color: Colors.deepPurple),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.deepPurpleAccent,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Video",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: '',
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (_, __, ___) => const SizedBox.shrink(),
                  transitionBuilder: (context, anim1, anim2, child) {
                    return Transform.scale(
                      scale: anim1.value,
                      child: Opacity(
                        opacity: anim1.value,
                        child: const AddVideoDialog(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<AppUseGuideProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (provider.appUseGuideVideoList.isEmpty) {
              return const Center(child: Text("No videos available."));
            } else {
              return ListView.builder(
                itemCount: provider.appUseGuideVideoList.length,
                itemBuilder: (context, index) {
                  final video = provider.appUseGuideVideoList[index];
                  final videoUrl =
                      "https://api.bhavnika.shop${video.videoName}"; // ✅ change to your server domain
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xfff8f9ff), Color(0xfff2f4ff)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Card(
                        margin: EdgeInsets.zero,
                        color: Colors.white.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🎬 Video thumbnail or icon
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Colors.deepPurple,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // 🧾 Video info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            video.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                        ),
                                        // visibility toggle button
                                        IconButton(
                                          onPressed: () async {
                                            // toggle visibility
                                            await provider.updateAppGuideVisibility(video.id, !video.visibility);
                                          },
                                          icon: Icon(
                                            video.visibility ? Icons.visibility : Icons.visibility_off,
                                            color: video.visibility ? Colors.green : Colors.grey,
                                          ),
                                          tooltip: video.visibility ? 'Visible - tap to hide' : 'Hidden - tap to show',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      video.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Meta info
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        _infoChip(
                                          Icons.storage_rounded,
                                          formatBytes(video.videoSize),
                                        ),
                                        _infoChip(
                                          Icons.video_file_outlined,
                                          video.videoExtension.toUpperCase(),
                                        ),
                                        _infoChip(
                                          Icons.calendar_today_outlined,
                                          formatDate(video.createdAt),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // 🔗 View button
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: ElevatedButton.icon(
                                        onPressed: () => openVideo(videoUrl),
                                        icon: const Icon(Icons.open_in_new_rounded,
                                            color: Colors.white),
                                        label: const Text(
                                          "View Video",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurpleAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 10,
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
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
