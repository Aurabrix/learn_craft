import 'package:flutter/material.dart';
import 'package:learn_craft/features/auth/presentation/ui/duo_widgets.dart';

enum SourceType { pdf, docx, url }

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  SourceType _selected = SourceType.pdf;
  final _titleController = TextEditingController();
  final _urlController   = TextEditingController();
  String? _pickedFileName;

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _pickFile() {
    // TODO: wire file_picker
    setState(() => _pickedFileName = 'my_document.${_selected.name}');
  }

  void _onCreate() {
    // TODO: dispatch UploadBloc event
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  DuoBackButton(onTap: () => Navigator.of(context).pop()),
                  const SizedBox(width: 14),
                  Text(
                    'New Game',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const Spacer(),
                  // Diamond cost badge
                  _DiamondBadge(count: 10),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF0F0F0)),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title ────────────────────────────
                    Text(
                      'What do you want\nto learn?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1A2E),
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Upload a file or paste a URL — we\'ll\ndo the rest.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF777777),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Source type selector ─────────────
                    DuoLabel('SOURCE TYPE'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _SourceCard(
                          icon: Icons.picture_as_pdf_rounded,
                          label: 'PDF',
                          isSelected: _selected == SourceType.pdf,
                          onTap: () => setState(() => _selected = SourceType.pdf),
                        ),
                        const SizedBox(width: 10),
                        _SourceCard(
                          icon: Icons.description_rounded,
                          label: 'DOCX',
                          isSelected: _selected == SourceType.docx,
                          onTap: () => setState(() => _selected = SourceType.docx),
                        ),
                        const SizedBox(width: 10),
                        _SourceCard(
                          icon: Icons.link_rounded,
                          label: 'URL',
                          isSelected: _selected == SourceType.url,
                          onTap: () => setState(() => _selected = SourceType.url),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Game title ───────────────────────
                    DuoLabel('GAME TITLE'),
                    const SizedBox(height: 6),
                    DuoTextField(
                      controller: _titleController,
                      hint: 'e.g. Flutter Basics',
                    ),

                    const SizedBox(height: 24),

                    // ── File / URL input ─────────────────
                    if (_selected == SourceType.url) ...[
                      DuoLabel('PASTE URL'),
                      const SizedBox(height: 6),
                      DuoTextField(
                        controller: _urlController,
                        hint: 'https://example.com/article',
                        keyboardType: TextInputType.url,
                      ),
                    ] else ...[
                      DuoLabel('UPLOAD FILE'),
                      const SizedBox(height: 6),
                      _FilePicker(
                        fileName: _pickedFileName,
                        extension: _selected.name.toUpperCase(),
                        onTap: _pickFile,
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ── Create button ────────────────────
                    DuoGreenButton(
                      label: 'CREATE GAME',
                      onTap: _onCreate,
                    ),

                    const SizedBox(height: 16),

                    // ── Cost note ────────────────────────
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.diamond_rounded,
                              size: 14, color: Color(0xFF1CB0F6)),
                          const SizedBox(width: 5),
                          Text(
                            'This will cost 10 diamonds',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF777777),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Source type card ─────────────────────────────────────────
class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const _green       = Color(0xFF58CC02);
  static const _greenLight  = Color(0xFFEDFAD4);
  static const _greenShadow = Color(0xFF46A302);
  static const _grey        = Color(0xFFF7F7F7);
  static const _greyShadow  = Color(0xFFE5E5E5);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 80,
          decoration: BoxDecoration(
            color: isSelected ? _greenLight : _grey,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? _green : _greyShadow,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? _greenShadow : _greyShadow,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 26,
                  color: isSelected ? _green : const Color(0xFFAAAAAA)),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? _green : const Color(0xFFAAAAAA),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── File picker drop zone ────────────────────────────────────
class _FilePicker extends StatelessWidget {
  const _FilePicker({
    required this.fileName,
    required this.extension,
    required this.onTap,
  });

  final String? fileName;
  final String extension;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: hasFile
              ? const Color(0xFFEDFAD4)
              : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile
                ? const Color(0xFF58CC02)
                : const Color(0xFFE5E5E5),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasFile
                  ? Icons.check_circle_rounded
                  : Icons.upload_file_rounded,
              size: 36,
              color: hasFile
                  ? const Color(0xFF58CC02)
                  : const Color(0xFFAAAAAA),
            ),
            const SizedBox(height: 10),
            Text(
              hasFile ? fileName! : 'Tap to choose a .$extension file',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: hasFile
                    ? const Color(0xFF58CC02)
                    : const Color(0xFFAAAAAA),
              ),
            ),
            if (!hasFile) ...[
              const SizedBox(height: 4),
              Text(
                'Max 50 MB',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFAAAAAA).withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Diamond badge ────────────────────────────────────────────
class _DiamondBadge extends StatelessWidget {
  const _DiamondBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1CB0F6), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.diamond_rounded,
              size: 16, color: Color(0xFF1CB0F6)),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1CB0F6),
            ),
          ),
        ],
      ),
    );
  }
}
