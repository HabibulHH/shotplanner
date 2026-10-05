import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/shotkit_widgets.dart';
import '../../data/models.dart';
import '../../data/shotkit_store.dart';
import 'pdf_export_service.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key, required this.store, required this.project});
  final ShotKitStore store;
  final Project project;

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool detailed = true;
  bool includeCompleted = true;
  bool preparing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TopBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                TitleBlock(
                  eyebrow: widget.project.title,
                  title: 'Export PDF',
                  meta: Text(
                    '${widget.project.scenes.length} scenes · ${widget.project.shotCount} shots',
                    style: const TextStyle(color: ShotKitColors.dim),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: ShotKitColors.success.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ShotKitColors.success.withValues(alpha: .3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.offline_bolt_outlined,
                              color: ShotKitColors.success,
                            ),
                            SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BUILT ENTIRELY ON YOUR PHONE',
                                    style: TextStyle(
                                      color: ShotKitColors.success,
                                      fontFamily: ShotKitFonts.mono,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'No upload, account, or internet connection.',
                                    style: TextStyle(
                                      color: ShotKitColors.dim,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SectionLabel('Choose a layout'),
                      Row(
                        children: [
                          Expanded(
                            child: _LayoutCard(
                              title: 'Detailed',
                              subtitle: 'Scene pages + frames',
                              selected: detailed,
                              detailed: true,
                              onTap: () => setState(() => detailed = true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _LayoutCard(
                              title: 'Compact',
                              subtitle: 'Clipboard table',
                              selected: !detailed,
                              detailed: false,
                              onTap: () => setState(() => detailed = false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const SectionLabel('Document options'),
                      Material(
                        color: ShotKitColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: ShotKitColors.line),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: MediaQuery.withClampedTextScaling(
                          // Option labels grow up to 140% so long words still fit.
                          maxScaleFactor: 1.4,
                          child: SwitchListTile(
                            value: includeCompleted,
                            onChanged: (value) =>
                                setState(() => includeCompleted = value),
                            title: const Text(
                              'Include completion marks',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: const Text(
                              'Useful for crew handoff',
                              style: TextStyle(color: ShotKitColors.dim),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: ShotKitColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ShotKitColors.line),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              color: ShotKitColors.tape,
                              size: 21,
                            ),
                            SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                'Every generated file is checked for pages and file size before the share sheet opens. Missing frames become labelled placeholders—never a blank export.',
                                style: TextStyle(
                                  color: ShotKitColors.dim,
                                  height: 1.45,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: preparing ? null : _prepare,
                        icon: preparing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.picture_as_pdf_outlined),
                        label: Text(
                          preparing ? 'Checking pages…' : 'Create PDF & share',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _prepare() async {
    setState(() => preparing = true);
    try {
      final service = PdfExportService(widget.store.media);
      final result = await service.build(
        widget.project,
        detailed ? PdfLayout.detailed : PdfLayout.compact,
        includeCompleted: includeCompleted,
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _PdfPreviewPage(
            project: widget.project,
            bytes: result.bytes,
            pageCount: result.pageCount,
            onShare: () async {
              await service.share(widget.project, result);
              await widget.store.reviews.maybeAsk();
            },
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not create PDF: $error')));
      }
    } finally {
      if (mounted) setState(() => preparing = false);
    }
  }
}

class _PdfPreviewPage extends StatelessWidget {
  const _PdfPreviewPage(
      {required this.project,
      required this.bytes,
      required this.pageCount,
      required this.onShare});
  final Project project;
  final Uint8List bytes;
  final int pageCount;
  final Future<void> Function() onShare;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$pageCount ${pageCount == 1 ? 'PAGE' : 'PAGES'} VERIFIED'),
        actions: [
          IconButton(
              onPressed: onShare,
              icon: const Icon(Icons.ios_share_rounded),
              tooltip: 'Share PDF')
        ],
      ),
      body: PdfPreview(
        build: (_) async => bytes,
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: true,
        pdfFileName: '${project.title} shot-list.pdf',
      ),
    );
  }
}

class _LayoutCard extends StatelessWidget {
  const _LayoutCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.detailed,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final bool selected;
  final bool detailed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      // Option labels grow up to 140% so long words still fit.
      maxScaleFactor: 1.4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? ShotKitColors.tape.withValues(alpha: .08)
                : ShotKitColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? ShotKitColors.tape : ShotKitColors.line,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E6E0),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    detailed ? 4 : 6,
                    (i) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        width: detailed && i.isOdd ? 74 : double.infinity,
                        decoration: BoxDecoration(
                          color: i == 0
                              ? const Color(0xFF272A30)
                              : const Color(0xFFB8B6B0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle,
                      color: ShotKitColors.tape,
                      size: 18,
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style:
                    const TextStyle(color: ShotKitColors.dim, fontSize: 11.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
