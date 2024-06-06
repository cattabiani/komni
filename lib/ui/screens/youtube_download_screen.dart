import 'package:flutter/material.dart';
import 'package:komni/utils/styles.dart';
import 'package:komni/utils/utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:komni/models/storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class KYoutubeDownloadScreen extends StatefulWidget {
  final KStorage storage;

  const KYoutubeDownloadScreen({super.key, required this.storage});

  @override
  State<KYoutubeDownloadScreen> createState() => _KYoutubeDownloadScreenState();
}

class _KYoutubeDownloadScreenState extends State<KYoutubeDownloadScreen> {
  late TextEditingController _urlController;
  late FocusNode _urlFocus;
  final List<List> _streams = [];
  int _selectedStream = 0;
  String _fileName = "";
  final _yt = YoutubeExplode();

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _urlFocus = FocusNode();
    // Delay the focus request to ensure the layout is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _urlFocus.requestFocus();
      selectAllText(_urlController);
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocus.dispose();
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: KStyles.stdGreen,
            title: const Text('Youtube Download', style: KStyles.boldTextStyle),
            actions: [
              KStyles.stdButton(
                  onPressed: _update, icon: const Icon(Icons.check)),
              KStyles.stdButton(
                  onPressed: _download, icon: const Icon(Icons.download)),
            ]),
        body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
              padding: KStyles.stdEdgeInset,
              child: TextField(
                decoration:
                    const InputDecoration(hintText: "ENTER youtube url here"),
                controller: _urlController,
                focusNode: _urlFocus,
                style: KStyles.stdTextStyle,
                onEditingComplete: () async {
                  await _update();
                },
              )),
          Container(
              margin: KStyles.stdEdgeInset,
              decoration: KStyles.stdBoxDecoration(16.0),
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                      value: _selectedStream,
                      items: List.generate(_streams.length, (index) {
                        return DropdownMenuItem<int>(
                            alignment: Alignment.center,
                            value: index,
                            child: Text(
                                "${_streams[index][0]} / ${_streams[index][1]} / ${_streams[index][2]} / ${_streams[index][3]}",
                                style: KStyles.stdTextStyle));
                      }),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedStream = newValue!;
                        });
                      }))),
          const Text("Download folder:", style: KStyles.boldTextStyle),
          Container(
              color: KStyles.stdGreen,
              child: Text(widget.storage.downloadPath,
                  style: KStyles.stdTextStyle)),
          KStyles.stdButton(
              onPressed: _updateDownloadFolder,
              icon: const Icon(Icons.folder_open))
        ]));
  }

  Future<void> _updateDownloadFolder() async {
    if (widget.storage.downloadPath.isEmpty) {
      setState(() async {
        widget.storage.downloadPath =
            (await getDownloadsDirectory())?.path ?? "";
      });
    }

    try {
      String? newPath = await FilePicker.platform
          .getDirectoryPath(initialDirectory: widget.storage.downloadPath);

      if (newPath != null) {
        setState(() {
          widget.storage.downloadPath = newPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error selecting download folder: ${e.toString()}"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _download() async {
    if (_selectedStream >= _streams.length || _fileName.isEmpty) return;

    if (widget.storage.downloadPath.isEmpty) {
      widget.storage.downloadPath = (await getDownloadsDirectory())?.path ?? "";
    }

    final stream = _streams[_selectedStream][4];
    final ext = _streams[_selectedStream][3];

    late String path;
    try {
      path = await getPath(widget.storage.downloadPath, _fileName, ext);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    final file = File(path);
    final fileStream = file.openWrite();

    try {
      await _yt.videos.streamsClient.get(stream).pipe(fileStream);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    await fileStream.flush();
    await fileStream.close();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File downloaded successfully in: "$path"'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _update() async {
    _streams.clear();
    _selectedStream = 0;
    _fileName = "";

    final url = _urlController.text.trim();

    late VideoId id;
    try {
      id = VideoId(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Corrupted url'),
          duration: Duration(seconds: 3),
        ),
      );

      return;
    }

    final manifest = await _yt.videos.streamsClient.getManifest(id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video found'),
          duration: Duration(seconds: 3),
        ),
      );
    }

    final video = await _yt.videos.get(id);
    _fileName = sanitize(video.title);

    for (var stream in manifest.streams) {
      if (!stream.codec.subtype.contains("webm") &&
          !stream.codec.subtype.contains("mp4")) continue;
      if (stream.runtimeType.toString().contains("VideoOnly")) continue;
      String t = stream.runtimeType.toString().contains("Muxed")
          ? "Muxed"
          : "AudioOnly";
      String t0 = stream.codec.subtype.contains("mp4")
          ? "mp4"
          : stream.codec.subtype.contains("webm")
              ? "webm"
              : "";
      _streams.add([t, stream.qualityLabel, stream.size, t0, stream]);
      // print("${stream.codec.subtype} ||| ${stream.qualityLabel} ||| ${stream.size} ||| ${stream.runtimeType}");
    }

    _streams.sort((a, b) => a[0] == b[0]
        ? b[2].totalBytes.compareTo(a[2].totalBytes)
        : a[0] == "Muxed"
            ? -1
            : 1);

    setState(() {});
    _urlFocus.unfocus();
  }
}
