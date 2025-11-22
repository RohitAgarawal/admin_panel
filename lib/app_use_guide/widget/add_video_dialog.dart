import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/app_use_guide_provider.dart';
import 'drop_zone.dart';
import 'package:http/http.dart' as http;

class AddVideoDialog extends StatefulWidget {
  const AddVideoDialog({super.key});

  @override
  State<AddVideoDialog> createState() => _AddVideoDialogState();
}

class _AddVideoDialogState extends State<AddVideoDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppUseGuideProvider>(context);

    return Center(
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Dialog(
          elevation: 12,
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.deepPurple.shade100,
                    width: 1,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Upload New Video",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 10),

                      // Title field
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Title",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: provider.setTitle,
                      ),
                      const SizedBox(height: 12),

                      // Description field
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: provider.setDescription,
                      ),
                      const SizedBox(height: 16),

                      // Drop zone
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.deepPurple.shade200),
                        ),
                        child: const DropZone(),
                      ),
                      const SizedBox(height: 16),

                      // Save button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: provider.hasVideo
                              ? const LinearGradient(
                                  colors: [
                                    Colors.deepPurpleAccent,
                                    Colors.purpleAccent,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : const LinearGradient(
                                  colors: [Colors.grey, Colors.grey],
                                ),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: (provider.hasVideo && !provider.isLoading)
                              ? () async {
                                  final videoMeta = provider.videoMetaData;
                                  print('Video Name: ${videoMeta.videoName}');
                                  print(
                                    'Video Extension: ${videoMeta.videoExtension}',
                                  );
                                  print('Video Size: ${videoMeta.videoSize}');
                                  print(
                                    'Base64: ${videoMeta.videoBase64?.substring(0, 50)}',
                                  );

                                  Map<String, dynamic> jsonData = {
                                    'title': provider.title,
                                    'description': provider.description,
                                    'metadata': videoMeta.toJson(),
                                  };
                                  http.StreamedResponse response =
                                      await provider.uploadVideo(jsonData);
                                  if (response.statusCode == 200) {
                                    // Refresh the list to get latest data
                                    await provider.getAppGuideVideo();
                                    Navigator.pop(context);
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: provider.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.cloud_upload_rounded,
                                  color: Colors.white,
                                ),
                          label: provider.isLoading
                              ? const Text(
                                  "Uploading...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                )
                              : const Text(
                                  "Upload Video",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      if (kIsWeb)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Tip: Drag and drop video files here.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
