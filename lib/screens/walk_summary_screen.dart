import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/walk_session.dart';
import '../services/memory_card_service.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/calm_button.dart';
import '../widgets/walk_memory_card.dart';

class WalkSummaryScreen extends StatefulWidget {
  final WalkSession session;
  final StorageService storageService;
  final bool isHistoricalView;

  const WalkSummaryScreen({
    super.key,
    required this.session,
    required this.storageService,
    this.isHistoricalView = false,
  });

  @override
  State<WalkSummaryScreen> createState() => _WalkSummaryScreenState();
}

class _WalkSummaryScreenState extends State<WalkSummaryScreen> {
  final GlobalKey _cardKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();

  File? _selectedPhoto;
  late String _encouragingPhrase;
  late TextEditingController _noteController;
  bool _isSharing = false;
  bool _isSaving = false;

  final List<String> _encouragingPhrases = [
    "A gentle step forward 🌱",
    "Mind clear, feet grounded ✨",
    "Every stride was an act of kindness 🌸",
    "Breathe in tranquility, step with ease 🍃",
    "Showing up for myself today 🌻",
    "Pure peace in every single pace 🌿",
  ];

  @override
  void initState() {
    super.initState();
    _encouragingPhrase = widget.session.encouragingPhrase.isNotEmpty
        ? widget.session.encouragingPhrase
        : _encouragingPhrases.first;

    _noteController = TextEditingController(text: widget.session.customNote ?? "");

    if (widget.session.photoPath != null) {
      final f = File(widget.session.photoPath!);
      if (f.existsSync()) {
        _selectedPhoto = f;
      }
    }

    // Auto-save new session on completion
    if (!widget.isHistoricalView) {
      widget.storageService.saveWalkSession(widget.session);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 88,
      );

      if (picked != null) {
        setState(() {
          _selectedPhoto = File(picked.path);
        });
      }
    } catch (e) {
      debugPrint("Photo picker error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not load photo. Please check camera/gallery permission."),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Add Walk Memory Photo",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Capture something peaceful you saw along the way.",
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                ),
                title: const Text("Take Photo with Camera", style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentPeachSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: AppColors.accentPeach),
                ),
                title: const Text("Choose from Gallery", style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedPhoto != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWarm,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, color: AppColors.textMuted),
                  ),
                  title: const Text("Remove Photo", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedPhoto = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareCard() async {
    setState(() => _isSharing = true);
    final caption = "I completed a peaceful ${widget.session.distanceKm.toStringAsFixed(2)} km walk with WalkMate 🌱";
    final success = await MemoryCardService.shareMemoryCard(_cardKey, caption: caption);
    setState(() => _isSharing = false);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Walk card ready! Saved temporarily for sharing."),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _saveCard() async {
    setState(() => _isSaving = true);
    final path = await MemoryCardService.saveMemoryCardLocally(_cardKey);
    setState(() => _isSaving = false);

    if (mounted) {
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Saved memory card to device: ${path.split('/').last} 🌸"),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not save card image."),
            backgroundColor: AppColors.accentPeach,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          widget.isHistoricalView ? "Walk Memory" : "Walk Completed 🌱",
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.primary),
            onPressed: _shareCard,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!widget.isHistoricalView) ...[
                  const Text(
                    "Wonderful Walk! ✨",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "You gave your body and mind pure care. Here is your memory card:",
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],

                // RepaintBoundary for WalkMemoryCard (Ready to capture/export)
                RepaintBoundary(
                  key: _cardKey,
                  child: WalkMemoryCard(
                    session: widget.session,
                    encouragingPhrase: _encouragingPhrase,
                    customNote: _noteController.text,
                    photoFile: _selectedPhoto,
                  ),
                ),

                const SizedBox(height: 24),

                // Photo Button and Customization controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _showPhotoOptions,
                      icon: Icon(
                        _selectedPhoto != null ? Icons.photo_camera_rounded : Icons.add_a_photo_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        _selectedPhoto != null ? "Change Photo" : "Add Walk Photo",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        side: const BorderSide(color: AppColors.primarySoft, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _saveCard,
                      icon: const Icon(Icons.download_rounded, size: 18, color: AppColors.textDark),
                      label: const Text(
                        "Download",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        side: const BorderSide(color: AppColors.divider, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Select Encouraging Phrase Section
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Choose Memory Phrase",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _encouragingPhrases.map((phrase) {
                          final isSelected = _encouragingPhrase == phrase;
                          return ChoiceChip(
                            label: Text(
                              phrase,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.textDark,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.canvas,
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.divider,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _encouragingPhrase = phrase;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Share Button and Done Button
                Row(
                  children: [
                    Expanded(
                      child: CalmButton(
                        label: "Share Memory",
                        icon: Icons.share_rounded,
                        style: CalmButtonStyle.terracotta,
                        isLoading: _isSharing,
                        onPressed: _shareCard,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CalmButton(
                        label: "Back Home",
                        icon: Icons.home_rounded,
                        style: CalmButtonStyle.primary,
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
