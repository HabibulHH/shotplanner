import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/media_service.dart';
import '../../data/models.dart';

enum PdfLayout { detailed, compact }

class PdfExportResult {
  const PdfExportResult({required this.bytes, required this.pageCount});
  final Uint8List bytes;
  final int pageCount;
}

class PdfExportService {
  PdfExportService(this.mediaService);
  final MediaService mediaService;

  Future<PdfExportResult> build(Project project, PdfLayout layout,
      {required bool includeCompleted, required bool isPro}) async {
    final document = pw.Document(
      title: '${project.title} Shot List',
      author: 'ShotKit',
      creator: 'ShotKit',
    );
    var pageCount = 0;
    if (layout == PdfLayout.detailed) {
      if (project.scenes.isEmpty) {
        document.addPage(_emptyPage(project, isPro));
        pageCount = 1;
      } else {
        for (var sceneIndex = 0;
            sceneIndex < project.scenes.length;
            sceneIndex++) {
          final scene = project.scenes[sceneIndex];
          final rows = <pw.Widget>[];
          for (var shotIndex = 0; shotIndex < scene.shots.length; shotIndex++) {
            rows.add(await _detailedShot(scene.shots[shotIndex], sceneIndex,
                shotIndex, includeCompleted));
            rows.add(pw.SizedBox(height: 8));
          }
          document.addPage(
            pw.MultiPage(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.all(32),
              header: (_) => _sceneHeader(project, scene, sceneIndex),
              footer: (_) => _footer(isPro),
              build: (_) => rows.isEmpty ? [_emptyScene()] : rows,
            ),
          );
          pageCount += _estimateDetailedPages(scene.shots.length);
        }
      }
    } else {
      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(26),
          header: (_) => _projectHeader(project),
          footer: (_) => _footer(isPro),
          build: (_) => _compact(project, includeCompleted),
        ),
      );
      pageCount =
          project.shotCount == 0 ? 1 : ((project.shotCount + 18) / 19).ceil();
    }
    final bytes = await document.save();
    if (bytes.length <= 1024 || pageCount <= 0) {
      throw StateError(
          'PDF verification failed: the document has no usable pages.');
    }
    return PdfExportResult(bytes: bytes, pageCount: pageCount);
  }

  Future<void> share(Project project, PdfExportResult result) =>
      Printing.sharePdf(
        bytes: result.bytes,
        filename: '${_safeName(project.title)}_shot-list.pdf',
      );

  pw.Page _emptyPage(Project project, bool isPro) => pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _projectHeader(project),
              pw.SizedBox(height: 40),
              pw.Text('No scenes have been added yet.',
                  style: const pw.TextStyle(color: PdfColors.grey700)),
              pw.Spacer(),
              _footer(isPro),
            ]),
      );

  pw.Widget _projectHeader(Project project) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(project.title.toUpperCase(),
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 3),
        pw.Text(
            '${project.type}  ·  ${project.scenes.length} scenes  ·  ${project.shotCount} shots',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColors.grey500),
      ]);

  pw.Widget _sceneHeader(Project project, Scene scene, int index) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(
            'SC ${(index + 1).toString().padLeft(2, '0')}  ${scene.title.toUpperCase()}',
            style: pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 3),
        pw.Text(
            '${scene.location}  ·  ${scene.timeOfDay.label}  ·  ${scene.completed}/${scene.shots.length} done',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.SizedBox(height: 10),
      ]);

  Future<pw.Widget> _detailedShot(
      Shot shot, int sceneIndex, int shotIndex, bool includeCompleted) async {
    pw.Widget thumbnail;
    final bytes = await mediaService.pdfThumbnail(shot.imagePath);
    if (bytes != null) {
      try {
        thumbnail = pw.Image(pw.MemoryImage(bytes),
            width: 118, height: 70, fit: pw.BoxFit.cover);
      } catch (_) {
        thumbnail = _placeholder(sceneIndex, shotIndex);
      }
    } else {
      thumbnail = _placeholder(sceneIndex, shotIndex);
    }
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        thumbnail,
        pw.SizedBox(width: 12),
        pw.Expanded(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
              pw.Text(
                  '${_shotCode(sceneIndex, shotIndex)}  ${shot.description}',
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text(
                  '${shot.size}  ·  ${shot.angle}  ·  ${shot.movement}  ·  ${shot.lens}  ·  ${shot.camera}',
                  style: const pw.TextStyle(
                      fontSize: 8.5, color: PdfColors.grey700)),
              if (shot.notes.isNotEmpty) ...[
                pw.SizedBox(height: 6),
                pw.Text(shot.notes, style: const pw.TextStyle(fontSize: 9))
              ],
            ])),
        if (includeCompleted)
          pw.Text(shot.isDone ? 'DONE' : 'OPEN',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      ]),
    );
  }

  List<pw.Widget> _compact(Project project, bool includeCompleted) {
    final data = <List<String>>[];
    for (var sceneIndex = 0; sceneIndex < project.scenes.length; sceneIndex++) {
      final scene = project.scenes[sceneIndex];
      for (var shotIndex = 0; shotIndex < scene.shots.length; shotIndex++) {
        final shot = scene.shots[shotIndex];
        data.add([
          _shotCode(sceneIndex, shotIndex),
          scene.title,
          shot.description,
          shot.size,
          shot.angle,
          shot.movement,
          shot.lens,
          shot.camera,
          if (includeCompleted) shot.isDone ? 'YES' : '',
        ]);
      }
    }
    final headers = [
      '#',
      'Scene',
      'Shot',
      'Size',
      'Angle',
      'Move',
      'Lens',
      'Cam',
      if (includeCompleted) 'Done'
    ];
    return [
      if (data.isEmpty)
        pw.Padding(
            padding: const pw.EdgeInsets.only(top: 30),
            child: pw.Text('No shots have been added yet.'))
      else
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey900),
          cellStyle: const pw.TextStyle(fontSize: 7.5),
          cellPadding:
              const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          border: const pw.TableBorder(
              horizontalInside:
                  pw.BorderSide(color: PdfColors.grey300, width: .5)),
        ),
    ];
  }

  pw.Widget _placeholder(int sceneIndex, int shotIndex) => pw.Container(
        width: 118,
        height: 70,
        alignment: pw.Alignment.center,
        color: PdfColors.grey300,
        child: pw.Text(_shotCode(sceneIndex, shotIndex),
            style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700)),
      );

  pw.Widget _emptyScene() => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 24),
      child: pw.Text('No shots on this scene.',
          style: const pw.TextStyle(color: PdfColors.grey700)));
  pw.Widget _footer(bool isPro) => pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(isPro ? 'ShotKit' : 'Made with ShotKit',
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)));
  int _estimateDetailedPages(int shots) =>
      shots == 0 ? 1 : ((shots + 6) / 7).ceil();
  String _safeName(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  String _shotCode(int sceneIndex, int shotIndex) {
    var value = shotIndex + 1;
    var letters = '';
    while (value > 0) {
      value--;
      letters = String.fromCharCode(65 + value % 26) + letters;
      value ~/= 26;
    }
    return '${sceneIndex + 1}$letters';
  }
}
