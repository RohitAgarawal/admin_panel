import 'dart:html' as html;
import 'dart:typed_data';
import 'package:admin_panel/utils/toast_message/toast_message.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../provider/app_use_guide_provider.dart';

class DropZone extends StatefulWidget {
  final Widget? icon;
  final Widget? text;

  const DropZone({super.key, this.text, this.icon});

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  final ValueNotifier<bool> _dragging = ValueNotifier(false);
  VideoPlayerController? _controller;
  String? _webVideoUrl;
  Future<void>? _initializeVideoFuture;

  @override
  void dispose() {
    _controller?.dispose();
    if (kIsWeb && _webVideoUrl != null) {
      html.Url.revokeObjectUrl(_webVideoUrl!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppUseGuideProvider>(context, listen: true);

    return InkWell(
      onTap: () async {
        try {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowMultiple: false,
            type: FileType.custom,
            allowedExtensions: ['mp4'],
            withData: true, // ✅ Critical: Ensures file bytes are included on web
          );

          if (result != null && result.files.isNotEmpty) {
            final file = result.files.single;
            if (kIsWeb && file.bytes != null) {
              _loadVideoFromBytes(file.bytes!, file.name);
              provider.setVideo(file.bytes!, file.name);
            } else if (!kIsWeb) {
              ToastMessage.error("Error", "Platform not supported");
            }
          }
        } catch (e) {
          ToastMessage.error("Error", "Failed to pick file: $e");
          print('File picker error: $e');
        }
      },
      child: DropTarget(
        onDragDone: (detail) async {
          final file = detail.files.first;
          if (_isVideo(file.name)) {
            final bytes = await file.readAsBytes();
            _loadVideoFromBytes(bytes, file.name);
            provider.setVideo(bytes, file.name);
          } else {
            ToastMessage.warning("Invalid Video format",
                "Please drop a valid .mp4 video file.");
          }
        },
        onDragEntered: (_) => _dragging.value = true,
        onDragExited: (_) => _dragging.value = false,
        child: ValueListenableBuilder(
          valueListenable: _dragging,
          builder: (ctx, isDragging, _) {
            return Container(
              decoration: BoxDecoration(
                color: isDragging ? Colors.blue.withOpacity(0.2) : Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              height: double.infinity,
              width: double.infinity,
              child: provider.hasVideo
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  _videoPreview(),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        _controller?.pause();
                        provider.removeVideo();
                        _controller?.dispose();
                        setState(() => _controller = null);
                      },
                    ),
                  ),
                ],
              )
                  : _emptyView(),
            );
          },
        ),
      ),
    );
  }

  Widget _videoPreview() {
    return FutureBuilder(
      future: _initializeVideoFuture,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: VideoPlayer(_controller!),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _emptyView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget.icon ??
            const Icon(Icons.video_file, size: 60, color: Colors.grey),
        const SizedBox(height: 10),
        widget.text ??
            const Text('Drop video or click to select (Video format: .mp4)',
                style: TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }

  bool _isVideo(String name) => name.endsWith('.mp4');

  void _loadVideoFromBytes(Uint8List bytes, String name) {
    if (kIsWeb && _webVideoUrl != null) {
      html.Url.revokeObjectUrl(_webVideoUrl!);
    }

    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    _webVideoUrl = url;

    _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..setLooping(true);
    _initializeVideoFuture = _controller!.initialize().then((_) {
      setState(() {});
    });
  }
}
