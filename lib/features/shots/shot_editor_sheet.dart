import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/shot_options.dart';
import '../../core/theme/app_theme.dart';
import '../../data/media_service.dart';
import '../../data/models.dart';

class ShotDraft {
  const ShotDraft({
    required this.description,
    required this.size,
    required this.angle,
    required this.movement,
    required this.lens,
    required this.camera,
    required this.notes,
    required this.imagePath,
    required this.durationSec,
    required this.mustHave,
    required this.addAnother,
  });

  final String description;
  final String size;
  final String angle;
  final String movement;
  final String lens;
  final String camera;
  final String notes;
  final String? imagePath;
  final int? durationSec;
  final bool mustHave;
  final bool addAnother;
}

Future<ShotDraft?> showShotEditor(
  BuildContext context,
  Scene scene,
  MediaService media, {
  Shot? existing,
  String? initialDescription,
}) {
  return Navigator.of(context).push<ShotDraft>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _ShotEditor(
        scene: scene,
        media: media,
        existing: existing,
        initialDescription: initialDescription,
      ),
    ),
  );
}

class _ShotEditor extends StatefulWidget {
  const _ShotEditor({
    required this.scene,
    required this.media,
    this.existing,
    this.initialDescription,
  });

  final Scene scene;
  final MediaService media;
  final Shot? existing;
  final String? initialDescription;

  @override
  State<_ShotEditor> createState() => _ShotEditorState();
}

class _ShotEditorState extends State<_ShotEditor> {
  static const _steps = [
    ('Describe', 'What is the frame for?'),
    ('Shot size', 'Choose the framing'),
    ('Angle', 'Place the camera'),
    ('Movement', 'Plan how it travels'),
    ('Camera kit', 'Pick lens and camera'),
    ('Finish', 'Reference and set notes'),
  ];

  late final TextEditingController description;
  late final TextEditingController notes;
  late final TextEditingController duration;
  late final TextEditingController customLens;
  late final TextEditingController customCamera;
  late String size;
  late String angle;
  late String movement;
  late String lens;
  late String camera;
  late bool mustHave;
  String? imagePath;
  bool pickingImage = false;
  int step = 0;

  bool get editing => widget.existing != null;
  bool get isLastStep => step == _steps.length - 1;

  @override
  void initState() {
    super.initState();
    final shot = widget.existing;
    description = TextEditingController(
        text: shot?.description ?? widget.initialDescription);
    notes = TextEditingController(text: shot?.notes);
    duration = TextEditingController(text: shot?.durationSec?.toString());
    final savedLens = shot?.lens ?? '50mm';
    final savedCamera = shot?.camera ?? 'A-Cam';
    lens = ShotOptions.lenses.contains(savedLens) ? savedLens : 'Custom';
    camera = ShotOptions.cameras.contains(savedCamera) ? savedCamera : 'Custom';
    customLens = TextEditingController(text: lens == 'Custom' ? savedLens : '');
    customCamera =
        TextEditingController(text: camera == 'Custom' ? savedCamera : '');
    size = shot?.size ?? 'CU';
    angle = shot?.angle ?? 'Eye level';
    movement = shot?.movement ?? 'Static';
    mustHave = shot?.mustHave ?? true;
    imagePath = shot?.imagePath;
  }

  @override
  void dispose() {
    description.dispose();
    notes.dispose();
    duration.dispose();
    customLens.dispose();
    customCamera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _steps[step];
    return PopScope(
      canPop: step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && step > 0) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: step > 0 ? _back : () => Navigator.pop(context),
            icon:
                Icon(step > 0 ? Icons.arrow_back_rounded : Icons.close_rounded),
            tooltip: step > 0 ? 'Previous step' : 'Close editor',
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(editing ? 'EDIT SHOT' : 'NEW SHOT',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800)),
              Text(widget.scene.title,
                  style: const TextStyle(
                      color: ShotKitColors.dim,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400)),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                  child: Text('${step + 1} / ${_steps.length}',
                      style: const TextStyle(
                          color: ShotKitColors.dim,
                          fontFamily: ShotKitFonts.mono,
                          fontSize: 11.5))),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(5),
            child: LinearProgressIndicator(
                value: (step + 1) / _steps.length, minHeight: 5),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: ShotKitColors.tape.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(_stepIcon(step),
                        color: ShotKitColors.tape, size: 20),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(current.$1,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(current.$2,
                            style: const TextStyle(
                                color: ShotKitColors.dim, fontSize: 12.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: KeyedSubtree(key: ValueKey(step), child: _stepBody()),
              ),
            ),
            const Divider(height: 1),
            SafeArea(
              top: false,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: _navigation()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBody() {
    return switch (step) {
      0 => _describeStep(),
      1 => _shotSizeStep(),
      2 => _angleStep(),
      3 => _movementStep(),
      4 => _kitStep(),
      _ => _finishStep(),
    };
  }

  Widget _describeStep() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: description,
          autofocus: !editing,
          textCapitalization: TextCapitalization.sentences,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
              labelText: 'Shot description',
              hintText: 'e.g. Bride reveal to family'),
        ),
        const SizedBox(height: 18),
        Text('PRIORITY', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _PriorityCard(
                    label: 'Must-have',
                    hint: 'Critical coverage',
                    icon: Icons.radio_button_checked,
                    selected: mustHave,
                    onTap: () => setState(() => mustHave = true))),
            const SizedBox(width: 10),
            Expanded(
                child: _PriorityCard(
                    label: 'Nice to have',
                    hint: 'Optional coverage',
                    icon: Icons.add_circle_outline,
                    selected: !mustHave,
                    onTap: () => setState(() => mustHave = false))),
          ],
        ),
        const SizedBox(height: 20),
        const _Tip(
            icon: Icons.bolt_rounded,
            text: 'Keep it observable: subject + action + moment.'),
      ],
    );
  }

  Widget _shotSizeStep() {
    final explanation = _shotSizeExplanation(size);
    return _PickerStep(
      preview: _AnimatedShotSizePreview(value: size),
      explanation: _ExplanationCard(
        key: ValueKey(size),
        code: size,
        title: explanation.$1,
        body: explanation.$2,
      ),
      label: 'CHOOSE FRAMING',
      itemCount: ShotOptions.sizes.length,
      itemBuilder: (context, index) {
        final value = ShotOptions.sizes[index];
        return _VisualOption(
            label: value,
            selected: value == size,
            cue: _ShotSizeCue(value),
            onTap: () => setState(() => size = value));
      },
    );
  }

  Widget _angleStep() {
    final explanation = _angleExplanation(angle);
    return _PickerStep(
      preview: _AnimatedAnglePreview(value: angle),
      explanation: _ExplanationCard(
        key: ValueKey(angle),
        code: angle,
        title: explanation.$1,
        body: explanation.$2,
      ),
      label: 'CHOOSE CAMERA ANGLE',
      itemCount: ShotOptions.angles.length,
      itemBuilder: (context, index) {
        final value = ShotOptions.angles[index];
        return _VisualOption(
            label: value,
            selected: value == angle,
            cue: _AngleCue(value),
            onTap: () => setState(() => angle = value));
      },
    );
  }

  Widget _movementStep() {
    final explanation = _movementExplanation(movement);
    return _PickerStep(
      preview: _AnimatedMovementPreview(value: movement),
      explanation: _ExplanationCard(
        key: ValueKey(movement),
        code: movement,
        title: explanation.$1,
        body: explanation.$2,
      ),
      label: 'CHOOSE CAMERA MOVEMENT',
      itemCount: ShotOptions.movements.length,
      itemBuilder: (context, index) {
        final value = ShotOptions.movements[index];
        return _VisualOption(
            label: value,
            selected: value == movement,
            cue: Icon(_movementIcon(value), size: 27),
            onTap: () => setState(() => movement = value));
      },
    );
  }

  Widget _kitStep() {
    final lenses = [...ShotOptions.lenses, 'Custom'];
    final cameras = [...ShotOptions.cameras, 'Custom'];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('LENS / FOCAL LENGTH',
            style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: lenses
              .map((value) => _CompactOption(
                  label: value,
                  selected: lens == value,
                  icon: Icons.center_focus_strong_rounded,
                  onTap: () => setState(() => lens = value)))
              .toList(),
        ),
        if (lens == 'Custom') ...[
          const SizedBox(height: 12),
          TextField(
              controller: customLens,
              decoration: const InputDecoration(
                  labelText: 'Custom lens', hintText: 'e.g. 28–70mm')),
        ],
        const SizedBox(height: 24),
        Text('CAMERA', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cameras
              .map((value) => _CompactOption(
                  label: value,
                  selected: camera == value,
                  icon: value == 'Drone'
                      ? Icons.flight_rounded
                      : Icons.videocam_outlined,
                  onTap: () => setState(() => camera = value)))
              .toList(),
        ),
        if (camera == 'Custom') ...[
          const SizedBox(height: 12),
          TextField(
              controller: customCamera,
              decoration: const InputDecoration(
                  labelText: 'Camera name', hintText: 'e.g. FX3 handheld')),
        ],
        const SizedBox(height: 20),
        TextField(
          controller: duration,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
              labelText: 'Duration estimate', suffixText: 'seconds'),
        ),
      ],
    );
  }

  Widget _finishStep() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ReferenceFrame(
            path: imagePath,
            media: widget.media,
            loading: pickingImage,
            onPick: _pickImage,
            onRemove: () => setState(() => imagePath = null)),
        const SizedBox(height: 16),
        TextField(
            controller: notes,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
                labelText: 'Set notes',
                hintText:
                    'Blocking, focus, performance, light, or sound notes')),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: ShotKitColors.surface,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: ShotKitColors.line)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SHOT SUMMARY',
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 9),
              Text(
                  description.text.trim().isEmpty
                      ? 'Untitled shot'
                      : description.text.trim(),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 7),
              Text(
                  '$size · $angle · $movement · ${_resolvedLens()} · ${_resolvedCamera()}',
                  style: const TextStyle(
                      color: ShotKitColors.dim,
                      fontFamily: ShotKitFonts.mono,
                      fontSize: 11.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _navigation() {
    if (!isLastStep) {
      return Row(
        children: [
          if (step > 0) ...[
            IconButton.outlined(
                onPressed: _back,
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Previous step'),
            const SizedBox(width: 10),
          ],
          Expanded(
              child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('NEXT'))),
        ],
      );
    }
    return Row(
      children: [
        IconButton.outlined(
            onPressed: _back,
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Previous step'),
        const SizedBox(width: 10),
        if (!editing) ...[
          Expanded(
              child: OutlinedButton(
                  onPressed: () => _save(true),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('SAVE & NEXT'))),
          const SizedBox(width: 10),
        ],
        Expanded(
            child: FilledButton(
                onPressed: () => _save(false),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(editing ? 'SAVE CHANGES' : 'SAVE SHOT'))),
      ],
    );
  }

  void _next() {
    if (step == 0 && description.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Give the shot a short description.')));
      return;
    }
    if (step < _steps.length - 1) setState(() => step++);
  }

  void _back() {
    if (step > 0) setState(() => step--);
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera)),
            ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery)),
          ],
        ),
      ),
    );
    if (source == null) return;
    setState(() => pickingImage = true);
    try {
      final path = await widget.media.pickAndStore(source);
      if (mounted && path != null) setState(() => imagePath = path);
    } finally {
      if (mounted) setState(() => pickingImage = false);
    }
  }

  String _resolvedLens() =>
      lens == 'Custom' && customLens.text.trim().isNotEmpty
          ? customLens.text.trim()
          : lens;
  String _resolvedCamera() =>
      camera == 'Custom' && customCamera.text.trim().isNotEmpty
          ? customCamera.text.trim()
          : camera;

  void _save(bool addAnother) {
    final text = description.text.trim();
    if (text.isEmpty) {
      setState(() => step = 0);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Give the shot a short description.')));
      return;
    }
    Navigator.pop(
      context,
      ShotDraft(
        description: text,
        size: size,
        angle: angle,
        movement: movement,
        lens: _resolvedLens(),
        camera: _resolvedCamera(),
        notes: notes.text.trim(),
        imagePath: imagePath,
        durationSec: int.tryParse(duration.text),
        mustHave: mustHave,
        addAnother: addAnother,
      ),
    );
  }
}

/// Preview and explanation above a grid of options. The header stays pinned
/// while the grid scrolls; on short screens or with large text it takes at
/// most 55% of the height and scrolls on its own, so the grid stays usable.
class _PickerStep extends StatelessWidget {
  const _PickerStep({
    required this.preview,
    required this.explanation,
    required this.label,
    required this.itemCount,
    required this.itemBuilder,
  });

  final Widget preview;
  final Widget explanation;
  final String label;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(builder: (context, constraints) {
      final tileWidth = (constraints.maxWidth - 32 - 16) / 3;
      // Tiles grow with the font size so the cue and a two-line label fit.
      final tileHeight =
          math.max(tileWidth / 1.08, 66 + scaler.scale(12) * 2.6);
      return Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight * .55),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      children: [
                        preview,
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: explanation,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 9),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(label,
                                style: Theme.of(context).textTheme.labelSmall)),
                        const Icon(Icons.swipe_vertical_rounded,
                            color: ShotKitColors.dim, size: 17),
                        const SizedBox(width: 5),
                        const Text('SCROLL OPTIONS',
                            style: TextStyle(
                                color: ShotKitColors.dim,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: .7)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  mainAxisExtent: tileHeight),
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            ),
          ),
        ],
      );
    });
  }
}

/// Selected value on the left, preview caption on the right. Both truncate
/// rather than overlap when names are long or the font is large.
class _PreviewLabels extends StatelessWidget {
  const _PreviewLabels({required this.label, required this.caption});
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 3,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.centerLeft,
                children: [...previous, if (current != null) current],
              ),
              child: Text(label,
                  key: ValueKey(label),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: ShotKitColors.tape,
                      fontFamily: ShotKitFonts.mono,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8)),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 2,
            child: Text(caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: ShotKitColors.dim,
                    fontFamily: ShotKitFonts.mono,
                    fontSize: 9.5,
                    letterSpacing: .7)),
          ),
        ],
      ),
    );
  }
}

/// The selected option's code chip next to its title and explanation.
class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    super.key,
    required this.code,
    required this.title,
    required this.body,
  });

  final String code;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: ShotKitColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: ShotKitColors.line)),
      child: LayoutBuilder(
        builder: (context, box) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Long names ("Three-quarter rear") wrap instead of pushing the
            // explanation off screen.
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: box.maxWidth * .45),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                    color: ShotKitColors.tape,
                    borderRadius: BorderRadius.circular(7)),
                child: Text(code,
                    style: const TextStyle(
                        color: ShotKitColors.tapeInk,
                        fontFamily: ShotKitFonts.mono,
                        fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: ShotKitColors.dim,
                          height: 1.35,
                          fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisualOption extends StatelessWidget {
  const _VisualOption(
      {required this.label,
      required this.selected,
      required this.cue,
      required this.onTap});
  final String label;
  final bool selected;
  final Widget cue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? ShotKitColors.tape.withValues(alpha: .12)
          : ShotKitColors.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
          side: BorderSide(
              color: selected ? ShotKitColors.tape : ShotKitColors.line,
              width: selected ? 1.5 : 1)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Center(
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: IconTheme(
                              data: IconThemeData(
                                  color: selected
                                      ? ShotKitColors.tape
                                      : ShotKitColors.dim),
                              child: cue)))),
              const SizedBox(height: 6),
              // Option names stay readable in the fixed grid; they grow up
              // to 130% with the system font size.
              MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.3,
                child: Text(label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color:
                            selected ? ShotKitColors.tape : ShotKitColors.paper,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

(String, String) _shotSizeExplanation(String value) => switch (value) {
      'Macro' => (
          'Macro / microscopic detail',
          'Magnifies a very small subject or texture beyond normal close-up scale for tactile, abstract, or precise detail.'
        ),
      'ECU' => (
          'Extreme close-up',
          'Isolates eyes, lips, texture, or a tiny story detail. Use it for maximum intensity and emphasis.'
        ),
      'BCU' => (
          'Big close-up',
          'Frames the face extremely tightly, often cropping forehead and chin, while keeping the expression readable.'
        ),
      'CU' => (
          'Close-up',
          'Prioritizes face and emotion while removing most environmental distraction.'
        ),
      'MCU' => (
          'Medium close-up',
          'Frames head and chest. Strong for dialogue, interviews, and intimate reactions.'
        ),
      'MS' => (
          'Medium shot',
          'Shows the subject from waist up, balancing performance, gesture, and location.'
        ),
      'Cowboy' => (
          'Cowboy / American shot',
          'Frames around mid-thigh upward. Originally kept a holster visible; now useful for hands, stance, and action.'
        ),
      'MLS' => (
          'Medium long shot',
          'Frames roughly from the knees up. Useful when body language and movement both matter.'
        ),
      'FS' => (
          'Full shot',
          'Fits the complete subject from head to toe, prioritizing full-body performance with limited surrounding space.'
        ),
      'LS' => (
          'Long shot',
          'Shows the full subject and their immediate environment. Great for blocking and action.'
        ),
      'ELS' => (
          'Extreme long shot',
          'Makes environment, geography, and scale the story. The subject becomes visually small.'
        ),
      'Establishing' => (
          'Establishing shot',
          'Introduces location, time, geography, or context before closer coverage. Often wide, but defined by purpose.'
        ),
      'Master' => (
          'Master shot',
          'Covers the complete scene and its essential action continuously, providing spatial continuity and edit safety.'
        ),
      'Single' => (
          'Single',
          'Frames one principal subject alone. The actual crop can still range from close-up to full or wide.'
        ),
      'OTS' => (
          'Over-the-shoulder',
          'Connects two people spatially and gives dialogue a clear point of view.'
        ),
      'POV' => (
          'Point of view',
          'Shows what the character sees so the audience experiences the moment through them.'
        ),
      'Insert' => (
          'Insert shot',
          'Isolates an object or action detail that carries information or helps the edit.'
        ),
      'Two-shot' => (
          'Two-shot',
          'Keeps two subjects in one composition to show relationship, distance, and shared action.'
        ),
      'Three-shot' => (
          'Three-shot',
          'Frames three subjects together to preserve group dynamics, reactions, and spatial relationships.'
        ),
      'Group' => (
          'Group shot',
          'Composes four or more subjects in one frame for ensemble action, hierarchy, or collective reaction.'
        ),
      'Cutaway' => (
          'Cutaway',
          'Temporarily leaves the main action for a related subject, environment, or reaction that supports the edit.'
        ),
      _ => (
          'Shot size',
          'Choose how much of the subject and environment the audience should see.'
        ),
    };

double _shotSizeScale(String value) => switch (value) {
      'Macro' => 1.82,
      'ECU' => 1.55,
      'BCU' => 1.38,
      'CU' => 1.22,
      'MCU' => .98,
      'MS' => .78,
      'Cowboy' => .69,
      'MLS' => .63,
      'FS' => .53,
      'LS' => .43,
      'ELS' => .31,
      'Establishing' => .22,
      'Master' => .39,
      'Insert' => 1.3,
      _ => .72,
    };

class _AnimatedShotSizePreview extends StatefulWidget {
  const _AnimatedShotSizePreview({required this.value});
  final String value;

  @override
  State<_AnimatedShotSizePreview> createState() =>
      _AnimatedShotSizePreviewState();
}

class _AnimatedShotSizePreviewState extends State<_AnimatedShotSizePreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late double fromScale;
  late double toScale;

  double get displayScale {
    final eased = Curves.easeOutCubic.transform(controller.value);
    return fromScale + (toScale - fromScale) * eased;
  }

  @override
  void initState() {
    super.initState();
    fromScale = _shotSizeScale(widget.value) * .86;
    toScale = _shotSizeScale(widget.value);
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420))
      ..addListener(() => setState(() {}))
      ..forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedShotSizePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      fromScale = displayScale;
      toScale = _shotSizeScale(widget.value);
      controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF090A0B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ShotKitColors.line),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _LargeFramingPainter(
                  scale: displayScale,
                  special: widget.value,
                  color: ShotKitColors.paper,
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              top: 11,
              child: _PreviewLabels(
                  label: widget.value, caption: '16:9 · LIVE FRAME'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LargeFramingPainter extends CustomPainter {
  const _LargeFramingPainter(
      {required this.scale, required this.special, required this.color});
  final double scale;
  final String special;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final guide = Paint()
      ..color = ShotKitColors.paper.withValues(alpha: .12)
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(size.width / 3, 0), Offset(size.width / 3, size.height), guide);
    canvas.drawLine(Offset(size.width * 2 / 3, 0),
        Offset(size.width * 2 / 3, size.height), guide);
    canvas.drawLine(
        Offset(0, size.height / 3), Offset(size.width, size.height / 3), guide);
    canvas.drawLine(Offset(0, size.height * 2 / 3),
        Offset(size.width, size.height * 2 / 3), guide);

    final subject = Paint()..color = color.withValues(alpha: .88);
    final subjectSoft = Paint()..color = color.withValues(alpha: .2);
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    void person(double x, double personScale, {double opacity = 1}) {
      final paint = Paint()..color = color.withValues(alpha: .88 * opacity);
      final headRadius = 15 * personScale;
      final headY = size.height / 2 - 30 * personScale;
      canvas.drawCircle(Offset(x, headY), headRadius, paint);
      final body = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(x, headY + 55 * personScale),
            width: 52 * personScale,
            height: 82 * personScale),
        Radius.circular(18 * personScale),
      );
      canvas.drawRRect(body, paint);
    }

    if (special == 'Two-shot') {
      person(size.width * .38, .78);
      person(size.width * .62, .78);
    } else if (special == 'Three-shot') {
      person(size.width * .31, .65);
      person(size.width * .5, .7);
      person(size.width * .69, .65);
    } else if (special == 'Group') {
      for (var i = 0; i < 5; i++) {
        person(size.width * (.22 + i * .14), i.isEven ? .5 : .58);
      }
    } else if (special == 'Master') {
      person(size.width * .4, .42);
      person(size.width * .6, .42);
    } else if (special == 'OTS') {
      canvas.drawCircle(Offset(size.width * .16, size.height * 1.03),
          size.height * .48, subjectSoft);
      person(size.width * .66, .82);
    } else if (special == 'POV') {
      final center = size.center(Offset.zero);
      canvas.drawCircle(center, size.height * .16, guide);
      canvas.drawCircle(center, 5, subject);
      canvas.drawLine(Offset(center.dx - 38, center.dy),
          Offset(center.dx + 38, center.dy), guide);
      canvas.drawLine(Offset(center.dx, center.dy - 30),
          Offset(center.dx, center.dy + 30), guide);
      final hand = RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * .57, size.height * .58, 72, 30),
          const Radius.circular(13));
      canvas.drawRRect(hand, subjectSoft);
    } else if (special == 'Insert' || special == 'Macro') {
      final object = RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: size.center(Offset.zero),
              width: size.width * (special == 'Macro' ? .72 : .4),
              height: size.height * (special == 'Macro' ? .58 : .28)),
          const Radius.circular(16));
      canvas.drawRRect(object, subject);
      canvas.drawCircle(size.center(const Offset(28, 0)), 7,
          Paint()..color = const Color(0xFF090A0B));
    } else if (special == 'Cutaway' || special == 'Establishing') {
      final mountain = Path()
        ..moveTo(0, size.height * .78)
        ..lineTo(size.width * .23, size.height * .42)
        ..lineTo(size.width * .38, size.height * .64)
        ..lineTo(size.width * .6, size.height * .3)
        ..lineTo(size.width, size.height * .76)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(mountain, subjectSoft);
      if (special == 'Establishing') person(size.width * .52, .2);
    } else {
      person(size.width / 2, scale);
    }
    canvas.restore();

    final corners = Paint()
      ..color = ShotKitColors.tape.withValues(alpha: .75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const length = 15.0;
    canvas.drawLine(const Offset(8, 8), const Offset(8 + length, 8), corners);
    canvas.drawLine(const Offset(8, 8), const Offset(8, 8 + length), corners);
    canvas.drawLine(
        Offset(size.width - 8, 8), Offset(size.width - 8 - length, 8), corners);
    canvas.drawLine(
        Offset(size.width - 8, 8), Offset(size.width - 8, 8 + length), corners);
    canvas.drawLine(Offset(8, size.height - 8),
        Offset(8 + length, size.height - 8), corners);
    canvas.drawLine(Offset(8, size.height - 8),
        Offset(8, size.height - 8 - length), corners);
    canvas.drawLine(Offset(size.width - 8, size.height - 8),
        Offset(size.width - 8 - length, size.height - 8), corners);
    canvas.drawLine(Offset(size.width - 8, size.height - 8),
        Offset(size.width - 8, size.height - 8 - length), corners);
  }

  @override
  bool shouldRepaint(covariant _LargeFramingPainter oldDelegate) =>
      oldDelegate.scale != scale ||
      oldDelegate.special != special ||
      oldDelegate.color != color;
}

class _ShotSizeCue extends StatelessWidget {
  const _ShotSizeCue(this.value);
  final String value;

  @override
  Widget build(BuildContext context) {
    final scale = _shotSizeScale(value);
    return CustomPaint(
      size: const Size(78, 50),
      painter: _ShotSizePainter(
        scale: scale,
        special: value,
        color: IconTheme.of(context).color ?? ShotKitColors.dim,
      ),
    );
  }
}

class _ShotSizePainter extends CustomPainter {
  const _ShotSizePainter(
      {required this.scale, required this.special, required this.color});
  final double scale;
  final String special;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = color.withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final fill = Paint()..color = color.withValues(alpha: .85);
    final frame =
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4));
    canvas.drawRRect(frame, line);
    canvas.save();
    canvas.clipRRect(frame);

    void person(double centerX, double personScale) {
      final headRadius = 5.5 * personScale;
      final headY = size.height / 2 - 11 * personScale;
      canvas.drawCircle(Offset(centerX, headY), headRadius, fill);
      final body = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(centerX, headY + 20 * personScale),
            width: 18 * personScale,
            height: 27 * personScale),
        Radius.circular(7 * personScale),
      );
      canvas.drawRRect(body, fill);
    }

    if (special == 'Two-shot') {
      person(size.width * .36, .72);
      person(size.width * .64, .72);
    } else if (special == 'Three-shot') {
      person(size.width * .25, .55);
      person(size.width * .5, .62);
      person(size.width * .75, .55);
    } else if (special == 'Group') {
      for (var i = 0; i < 5; i++) {
        person(size.width * (.14 + i * .18), i.isEven ? .42 : .5);
      }
    } else if (special == 'Master') {
      person(size.width * .38, .4);
      person(size.width * .62, .4);
    } else if (special == 'OTS') {
      canvas.drawCircle(Offset(8, size.height + 3), 23, fill);
      person(size.width * .66, .72);
    } else if (special == 'POV') {
      canvas.drawCircle(size.center(Offset.zero), 11, line);
      canvas.drawCircle(size.center(Offset.zero), 3, fill);
      canvas.drawLine(Offset(size.width / 2 - 17, size.height / 2),
          Offset(size.width / 2 + 17, size.height / 2), line);
      canvas.drawLine(Offset(size.width / 2, size.height / 2 - 14),
          Offset(size.width / 2, size.height / 2 + 14), line);
    } else if (special == 'Insert' || special == 'Macro') {
      final insert = RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: size.center(Offset.zero),
              width: special == 'Macro' ? 62 : 42,
              height: special == 'Macro' ? 38 : 22),
          const Radius.circular(6));
      canvas.drawRRect(insert, fill);
      canvas.drawCircle(size.center(const Offset(9, 0)), 3,
          Paint()..color = ShotKitColors.surface);
    } else if (special == 'Cutaway' || special == 'Establishing') {
      final landscape = Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width * .25, size.height * .5)
        ..lineTo(size.width * .43, size.height * .74)
        ..lineTo(size.width * .68, size.height * .38)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(landscape, fill);
      if (special == 'Establishing') person(size.width * .52, .18);
    } else {
      person(size.width / 2, scale);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShotSizePainter oldDelegate) =>
      oldDelegate.scale != scale ||
      oldDelegate.special != special ||
      oldDelegate.color != color;
}

(String, String) _angleExplanation(String value) => switch (value) {
      'Eye level' => (
          'Neutral and honest',
          'Keeps the audience equal with the subject. Natural for dialogue, interviews, and balanced coverage.'
        ),
      'Shoulder level' => (
          'Camera at shoulder height',
          'A natural portrait height with slightly more authority than eye level. Common for clean dialogue coverage.'
        ),
      'Hip level' => (
          'Camera near the waist',
          'Emphasizes hands, movement, weapons, or physical action while giving the subject extra presence.'
        ),
      'Knee level' => (
          'Camera near knee height',
          'Adds foreground depth and stature without becoming as extreme as a ground-level or worm’s-eye view.'
        ),
      'High' => (
          'Look down on the subject',
          'Can make a subject feel smaller, exposed, vulnerable, or reveal more of the surrounding space.'
        ),
      'Low' => (
          'Look up at the subject',
          'Adds power, scale, confidence, or threat by placing the audience below the subject.'
        ),
      'Dutch' => (
          'Tilt the horizon',
          'Creates visual imbalance and tension. Best used deliberately for unease, chaos, or disorientation.'
        ),
      'Overhead' => (
          'Camera directly above',
          'Turns action into graphic shapes and clearly reveals geography, blocking, objects, or choreography.'
        ),
      'Ground' => (
          'Camera at floor level',
          'Makes foreground texture and movement feel huge while giving the frame an energetic, dramatic scale.'
        ),
      "Worm's-eye" => (
          'Extreme upward view',
          'Looks sharply up from below, exaggerating height and making subjects or architecture feel monumental.'
        ),
      "Bird's-eye" => (
          'Very high oblique view',
          'Observes action from far above at an angle, showing geography while retaining visible depth and dimension.'
        ),
      'Aerial' => (
          'Elevated establishing view',
          'A broad view captured from the air or a very high platform to establish location, scale, and movement.'
        ),
      'Front' => (
          'Face the subject directly',
          'Creates symmetry, confrontation, honesty, or direct audience connection by viewing the subject head-on.'
        ),
      'Three-quarter front' => (
          'Turn slightly off-axis',
          'Shows the front and one side of the subject, adding facial dimension while preserving emotional access.'
        ),
      'Profile' => (
          'View from the side',
          'Creates a graphic silhouette and clearly shows gaze direction, movement, distance, or separation.'
        ),
      'Three-quarter rear' => (
          'Observe from behind and beside',
          'Keeps some facial or body context while placing the audience closer to the subject’s point of view.'
        ),
      'Rear' => (
          'View directly from behind',
          'Withholds the face and invites the audience to follow, observe, or share what the subject is seeing.'
        ),
      _ => (
          'Camera angle',
          'Choose where the audience stands vertically in relation to the subject.'
        ),
    };

class _AnimatedAnglePreview extends StatefulWidget {
  const _AnimatedAnglePreview({required this.value});
  final String value;

  @override
  State<_AnimatedAnglePreview> createState() => _AnimatedAnglePreviewState();
}

class _AnimatedAnglePreviewState extends State<_AnimatedAnglePreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late String previousValue;

  @override
  void initState() {
    super.initState();
    previousValue = widget.value;
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480))
      ..addListener(() => setState(() {}))
      ..forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedAnglePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      previousValue = oldWidget.value;
      controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF090A0B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ShotKitColors.line),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _AnglePreviewPainter(
                    from: previousValue,
                    to: widget.value,
                    progress: Curves.easeOutCubic.transform(controller.value)),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              top: 11,
              child: _PreviewLabels(
                  label: widget.value.toUpperCase(),
                  caption: 'ANGLE · LIVE VIEW'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnglePreviewPainter extends CustomPainter {
  const _AnglePreviewPainter(
      {required this.from, required this.to, required this.progress});
  final String from;
  final String to;
  final double progress;

  (double, double, double) _config(String value) => switch (value) {
        'High' => (.67, -.10, .78),
        'Low' => (.34, .08, 1.17),
        'Shoulder level' => (.49, 0, 1.03),
        'Hip level' => (.41, 0, 1.09),
        'Knee level' => (.32, .02, 1.16),
        'Dutch' => (.52, -.20, 1.0),
        'Overhead' => (.76, 0, .68),
        'Ground' => (.22, .03, 1.32),
        "Worm's-eye" => (.16, .07, 1.42),
        "Bird's-eye" => (.73, -.05, .66),
        'Aerial' => (.82, 0, .48),
        _ => (.52, 0, 1.0),
      };

  double _mix(double a, double b) => a + (b - a) * progress;

  @override
  void paint(Canvas canvas, Size size) {
    final a = _config(from);
    final b = _config(to);
    final horizon = _mix(a.$1, b.$1) * size.height;
    final roll = _mix(a.$2, b.$2);
    final subjectScale = _mix(a.$3, b.$3);
    final active = progress < .5 ? from : to;
    final paper = Paint()..color = ShotKitColors.paper.withValues(alpha: .88);
    final soft = Paint()
      ..color = ShotKitColors.paper.withValues(alpha: .13)
      ..strokeWidth = 1;
    final tape = Paint()
      ..color = ShotKitColors.tape.withValues(alpha: .85)
      ..strokeWidth = 1.5;

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(roll);
    canvas.translate(-size.width / 2, -size.height / 2);

    canvas.drawLine(
        Offset(-30, horizon), Offset(size.width + 30, horizon), soft);
    canvas.drawLine(
        Offset(size.width / 2, horizon), Offset(-20, size.height + 25), soft);
    canvas.drawLine(Offset(size.width / 2, horizon),
        Offset(size.width + 20, size.height + 25), soft);
    canvas.drawLine(Offset(size.width / 2, horizon),
        Offset(size.width / 2, size.height), soft);

    if (active == 'Overhead') {
      final center = Offset(size.width / 2, size.height * .57);
      canvas.drawCircle(center, 24 * subjectScale, paper);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(center.dx, center.dy + 31 * subjectScale),
              width: 48 * subjectScale,
              height: 31 * subjectScale),
          paper);
      canvas.drawCircle(
          center,
          39,
          Paint()
            ..color = ShotKitColors.tape.withValues(alpha: .18)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    } else {
      final footY = size.height * 1.04;
      final bodyHeight = 88 * subjectScale;
      final headRadius = 15 * subjectScale;
      final headY = footY - bodyHeight - headRadius * 1.25;
      canvas.drawCircle(Offset(size.width / 2, headY), headRadius, paper);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(
                      size.width / 2, headY + headRadius + bodyHeight / 2 - 3),
                  width: 51 * subjectScale,
                  height: bodyHeight),
              Radius.circular(18 * subjectScale)),
          paper);
      final ink = Paint()..color = const Color(0xFF090A0B);
      if (active == 'Front') {
        canvas.drawCircle(
            Offset(size.width / 2 - headRadius * .34, headY), 2, ink);
        canvas.drawCircle(
            Offset(size.width / 2 + headRadius * .34, headY), 2, ink);
      } else if (active == 'Profile') {
        canvas.drawCircle(
            Offset(size.width / 2 + headRadius * .28, headY), 2, ink);
        canvas.drawCircle(
            Offset(size.width / 2 + headRadius, headY + 1), 3, paper);
      } else if (active == 'Three-quarter front') {
        canvas.drawCircle(
            Offset(size.width / 2 - headRadius * .18, headY), 2, ink);
        canvas.drawCircle(
            Offset(size.width / 2 + headRadius * .38, headY), 2, ink);
      } else if (active == 'Three-quarter rear') {
        canvas.drawArc(
            Rect.fromCircle(
                center: Offset(size.width / 2, headY), radius: headRadius * .7),
            -.9,
            1.8,
            false,
            ink..style = PaintingStyle.stroke);
      } else if (active == 'Rear') {
        canvas.drawArc(
            Rect.fromCircle(
                center: Offset(size.width / 2, headY),
                radius: headRadius * .72),
            0,
            math.pi,
            false,
            ink..style = PaintingStyle.stroke);
      }
    }
    canvas.restore();

    final cameraY = active == 'High' || active == "Bird's-eye"
        ? size.height * .26
        : active == 'Aerial' || active == 'Overhead'
            ? size.height * .16
            : active == 'Low' || active == 'Ground' || active == "Worm's-eye"
                ? size.height * .76
                : active == 'Knee level'
                    ? size.height * .67
                    : active == 'Hip level'
                        ? size.height * .59
                        : active == 'Shoulder level'
                            ? size.height * .48
                            : size.height * .49;
    final camera = Offset(26, cameraY);
    final target = Offset(size.width / 2, size.height * .53);
    canvas.drawLine(
        camera,
        target,
        Paint()
          ..color = ShotKitColors.tape.withValues(alpha: .42)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: camera, width: 25, height: 16),
            const Radius.circular(4)),
        tape);
    canvas.drawCircle(Offset(camera.dx + 15, camera.dy), 5, tape);
  }

  @override
  bool shouldRepaint(covariant _AnglePreviewPainter oldDelegate) =>
      oldDelegate.from != from ||
      oldDelegate.to != to ||
      oldDelegate.progress != progress;
}

class _AngleCue extends StatelessWidget {
  const _AngleCue(this.value);
  final String value;

  @override
  Widget build(BuildContext context) {
    final icon = switch (value) {
      'High' => Icons.south_east_rounded,
      'Low' => Icons.north_east_rounded,
      'Shoulder level' => Icons.accessibility_new_rounded,
      'Hip level' => Icons.align_vertical_center_rounded,
      'Knee level' => Icons.vertical_align_bottom_rounded,
      'Dutch' => Icons.screen_rotation_alt_rounded,
      'Overhead' => Icons.vertical_align_bottom_rounded,
      'Ground' => Icons.vertical_align_top_rounded,
      "Worm's-eye" => Icons.keyboard_double_arrow_up_rounded,
      "Bird's-eye" => Icons.keyboard_double_arrow_down_rounded,
      'Aerial' => Icons.flight_rounded,
      'Front' => Icons.face_rounded,
      'Three-quarter front' => Icons.threesixty_rounded,
      'Profile' => Icons.switch_left_rounded,
      'Three-quarter rear' => Icons.threesixty_rounded,
      'Rear' => Icons.person_rounded,
      _ => Icons.east_rounded,
    };
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.videocam_outlined, size: 22),
      const SizedBox(height: 2),
      Icon(icon, size: 24)
    ]);
  }
}

(String, String) _movementExplanation(String value) => switch (value) {
      'Static' => (
          'Lock the frame',
          'The camera does not move. Lets composition and performance carry the moment with calm, deliberate focus.'
        ),
      'Pan' => (
          'Rotate left or right',
          'Turns the camera horizontally from one position to reveal space, follow action, or connect two subjects.'
        ),
      'Whip pan' => (
          'Pan with extreme speed',
          'Creates directional blur and high energy, often hiding a transition or snapping attention to new action.'
        ),
      'Tilt' => (
          'Rotate up or down',
          'Pivots vertically to reveal height, follow rising action, or move attention between details.'
        ),
      'Roll' => (
          'Rotate around the lens axis',
          'Spins or tilts the entire horizon during the shot for disorientation, impact, or a stylized transition.'
        ),
      'Dolly' => (
          'Move through physical space',
          'Pushes toward or pulls away from the subject, changing perspective and adding emotional momentum.'
        ),
      'Push in' => (
          'Move physically closer',
          'Gradually increases emphasis and intimacy while changing perspective between subject and background.'
        ),
      'Pull out' => (
          'Move physically away',
          'Reveals context, distance, isolation, or a new story element as the physical field of view expands.'
        ),
      'Dolly zoom' => (
          'Dolly and zoom in opposition',
          'Keeps subject size similar while the background stretches or compresses—the classic Vertigo effect.'
        ),
      'Truck' => (
          'Move laterally left or right',
          'Translates the entire camera sideways without rotating, changing perspective across foreground and background.'
        ),
      'Pedestal' => (
          'Raise or lower the camera',
          'Moves the camera vertically without tilting, preserving its viewing direction while changing height.'
        ),
      'Track' => (
          'Travel beside the subject',
          'Moves laterally with action so the subject stays framed while the environment flows behind them.'
        ),
      'Arc / orbit' => (
          'Curve around the subject',
          'Travels on a circular path to reveal relationships, shift the background, or build dramatic energy.'
        ),
      'Slider' => (
          'Short controlled travel',
          'Creates a precise, smooth push or lateral move over a compact distance for parallax and product detail.'
        ),
      'Crane' => (
          'Sweep vertically through space',
          'Raises or lowers the camera on a large arc for a grand reveal, transition, or dramatic change of scale.'
        ),
      'Jib' => (
          'Compact crane movement',
          'Uses a pivoting arm for smooth rises, drops, and arcs where a full crane would be unnecessary.'
        ),
      'Handheld' => (
          'Organic human motion',
          'Adds responsive shake and immediacy. Useful for urgency, realism, intimacy, or controlled chaos.'
        ),
      'Shoulder rig' => (
          'Body-supported handheld',
          'Keeps organic operator energy but adds weight and control, popular for documentary and narrative following.'
        ),
      'Steadicam' => (
          'Isolated operator movement',
          'Mechanically stabilizes walking and running shots while retaining a natural, human path through space.'
        ),
      'Gimbal' => (
          'Smooth floating follow',
          'Stabilized movement follows complex action with fluid energy while keeping the frame controlled.'
        ),
      'Drone' => (
          'Move freely through the air',
          'Reveals scale and geography with rising, descending, orbiting, or traveling aerial perspectives.'
        ),
      'Cable cam' => (
          'Travel along a suspended line',
          'Flies smoothly across long, repeatable paths above crowds, terrain, stages, or sporting action.'
        ),
      'Vehicle mount' => (
          'Camera fixed to a vehicle',
          'Moves with a car, bike, boat, or rig for speed, road energy, and a consistent relationship to the vehicle.'
        ),
      'Snorricam' => (
          'Camera fixed to the performer',
          'Locks the subject in frame while the world moves around them, creating an intense subjective effect.'
        ),
      'Zoom' => (
          'Change focal length',
          'Magnifies the subject without moving the camera. Perspective stays fixed while framing tightens or widens.'
        ),
      'Crash zoom' => (
          'Zoom extremely fast',
          'Punches rapidly into or out of a subject for shock, comedy, discovery, or stylized emphasis.'
        ),
      'Rack focus' => (
          'Shift focus between depth planes',
          'Moves attention from one subject distance to another without moving the camera; technically a focus move.'
        ),
      _ => (
          'Camera movement',
          'Choose how the camera travels and how that motion should make the audience feel.'
        ),
    };

class _AnimatedMovementPreview extends StatefulWidget {
  const _AnimatedMovementPreview({required this.value});
  final String value;

  @override
  State<_AnimatedMovementPreview> createState() =>
      _AnimatedMovementPreviewState();
}

class _AnimatedMovementPreviewState extends State<_AnimatedMovementPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2100))
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant _AnimatedMovementPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) controller.forward(from: 0);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF090A0B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ShotKitColors.line),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) => CustomPaint(
                  painter: _MovementPreviewPainter(
                      value: widget.value, phase: controller.value),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              top: 11,
              child: _PreviewLabels(
                  label: widget.value.toUpperCase(),
                  caption: 'MOTION · LIVE LOOP'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovementPreviewPainter extends CustomPainter {
  const _MovementPreviewPainter({required this.value, required this.phase});
  final String value;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final wave = math.sin(phase * math.pi * 2);
    final pulse = (1 - math.cos(phase * math.pi * 2)) / 2;
    var sceneDx = 0.0;
    var sceneDy = 0.0;
    var roll = 0.0;
    var subjectScale = 1.0;

    switch (value) {
      case 'Pan':
        sceneDx = -wave * 26;
      case 'Whip pan':
        sceneDx = -math.sin(phase * math.pi * 2) * 58;
      case 'Tilt':
        sceneDy = wave * 19;
      case 'Roll':
        roll = wave * .32;
      case 'Dolly':
        subjectScale = .82 + pulse * .48;
      case 'Push in':
        subjectScale = .78 + pulse * .62;
      case 'Pull out':
        subjectScale = 1.4 - pulse * .62;
      case 'Dolly zoom':
        subjectScale = .98 + wave * .025;
      case 'Truck':
        sceneDx = -phase * 78;
      case 'Pedestal':
        sceneDy = wave * 27;
      case 'Track':
        sceneDx = -phase * 78;
      case 'Arc / orbit':
        sceneDx = wave * 31;
        subjectScale = 1 + math.cos(phase * math.pi * 2) * .08;
      case 'Slider':
        sceneDx = wave * 19;
      case 'Crane':
        sceneDx = wave * 10;
        sceneDy = -pulse * 32;
        subjectScale = 1 - pulse * .16;
      case 'Jib':
        sceneDx = wave * 14;
        sceneDy = -pulse * 24;
        subjectScale = 1 - pulse * .1;
      case 'Handheld':
        sceneDx = math.sin(phase * math.pi * 14) * 4;
        sceneDy = math.cos(phase * math.pi * 18) * 3;
        roll = math.sin(phase * math.pi * 11) * .018;
      case 'Shoulder rig':
        sceneDx = math.sin(phase * math.pi * 8) * 2.8;
        sceneDy = math.cos(phase * math.pi * 10) * 2;
        roll = math.sin(phase * math.pi * 7) * .012;
      case 'Steadicam':
        sceneDx = wave * 13;
        sceneDy = math.cos(phase * math.pi * 2) * 3;
      case 'Gimbal':
        sceneDx = wave * 16;
        sceneDy = math.cos(phase * math.pi * 2) * 5;
      case 'Drone':
        sceneDy = -pulse * 27;
        subjectScale = 1 - pulse * .3;
      case 'Cable cam':
        sceneDx = -phase * 92;
        sceneDy = wave * 5;
      case 'Vehicle mount':
        sceneDx = -phase * 126;
        sceneDy = math.sin(phase * math.pi * 18) * 1.5;
      case 'Snorricam':
        sceneDx = math.sin(phase * math.pi * 6) * 11;
        sceneDy = math.cos(phase * math.pi * 8) * 5;
      case 'Zoom':
        subjectScale = .82 + pulse * .52;
      case 'Crash zoom':
        subjectScale = .72 + math.pow(pulse, .22).toDouble() * .72;
    }

    final soft = Paint()
      ..color = ShotKitColors.paper.withValues(alpha: .13)
      ..strokeWidth = 1;
    final paper = Paint()..color = ShotKitColors.paper.withValues(alpha: .88);
    final tape = Paint()
      ..color = ShotKitColors.tape.withValues(alpha: .9)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(roll);
    canvas.translate(-size.width / 2 + sceneDx, -size.height / 2 + sceneDy);

    final horizonY = size.height * .55;
    canvas.drawLine(
        Offset(-100, horizonY), Offset(size.width + 120, horizonY), soft);
    for (var i = -2; i < 8; i++) {
      var x = i * 66.0;
      final flowing = value == 'Track' ||
          value == 'Truck' ||
          value == 'Cable cam' ||
          value == 'Vehicle mount' ||
          value == 'Snorricam';
      if (flowing) x -= (phase * 66) % 66;
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, horizonY - 37, 28, 37),
              const Radius.circular(3)),
          Paint()..color = ShotKitColors.paper.withValues(alpha: .07));
      canvas.drawLine(
          Offset(x + 14, horizonY), Offset(x - 24, size.height + 25), soft);
    }

    final followsSubject = value == 'Track' ||
        value == 'Cable cam' ||
        value == 'Vehicle mount' ||
        value == 'Snorricam';
    final centerX = followsSubject ? size.width / 2 - sceneDx : size.width / 2;
    final footY = size.height * .96;
    final headRadius = 13 * subjectScale;
    final bodyHeight = 64 * subjectScale;
    final headY = footY - bodyHeight - headRadius * 1.3;
    canvas.drawCircle(Offset(centerX, headY), headRadius, paper);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center:
                    Offset(centerX, headY + headRadius + bodyHeight / 2 - 2),
                width: 43 * subjectScale,
                height: bodyHeight),
            Radius.circular(15 * subjectScale)),
        paper);
    canvas.restore();

    _drawMotionCue(canvas, size, tape, wave, pulse);
  }

  void _drawMotionCue(
      Canvas canvas, Size size, Paint paint, double wave, double pulse) {
    final center = Offset(size.width / 2, size.height * .83);
    const arrow = 6.0;

    void arrowLine(Offset from, Offset to) {
      canvas.drawLine(from, to, paint);
      final direction = math.atan2(to.dy - from.dy, to.dx - from.dx);
      canvas.drawLine(
          to,
          Offset(to.dx - arrow * math.cos(direction - .65),
              to.dy - arrow * math.sin(direction - .65)),
          paint);
      canvas.drawLine(
          to,
          Offset(to.dx - arrow * math.cos(direction + .65),
              to.dy - arrow * math.sin(direction + .65)),
          paint);
    }

    switch (value) {
      case 'Static':
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(center: center, width: 32, height: 22),
                const Radius.circular(5)),
            paint);
        canvas.drawLine(center + const Offset(-10, 15),
            center + const Offset(10, 15), paint);
      case 'Pan':
      case 'Whip pan':
      case 'Truck':
      case 'Track':
      case 'Slider':
      case 'Cable cam':
      case 'Vehicle mount':
        arrowLine(center - const Offset(42, 0), center + const Offset(42, 0));
        arrowLine(center + const Offset(42, 8), center - const Offset(42, -8));
      case 'Tilt':
      case 'Pedestal':
      case 'Drone':
        arrowLine(center + const Offset(0, 22), center - const Offset(0, 34));
      case 'Dolly':
      case 'Push in':
        arrowLine(center + const Offset(45, 0), center + const Offset(12, 0));
      case 'Pull out':
        arrowLine(center + const Offset(12, 0), center + const Offset(45, 0));
      case 'Dolly zoom':
        arrowLine(center + const Offset(44, 0), center + const Offset(12, 0));
        arrowLine(center - const Offset(12, 8), center - const Offset(44, -8));
      case 'Roll':
      case 'Arc / orbit':
        canvas.drawArc(
            Rect.fromCircle(center: center, radius: 28), .3, 4.9, false, paint);
        arrowLine(
            center + const Offset(-25, -12), center + const Offset(-18, -22));
      case 'Handheld':
      case 'Shoulder rig':
      case 'Snorricam':
        final path = Path()..moveTo(center.dx - 40, center.dy);
        for (var i = 1; i <= 8; i++) {
          path.lineTo(center.dx - 40 + i * 10, center.dy + (i.isEven ? -4 : 4));
        }
        canvas.drawPath(path, paint);
      case 'Gimbal':
      case 'Steadicam':
        canvas.drawCircle(center, 24 + wave * 2, paint);
        canvas.drawCircle(center, 8, paint);
      case 'Zoom':
      case 'Crash zoom':
        final inset = 8 + pulse * 12;
        canvas.drawRect(
            Rect.fromLTWH(
                inset, inset, size.width - inset * 2, size.height - inset * 2),
            paint);
      case 'Crane':
      case 'Jib':
        final path = Path()
          ..moveTo(center.dx - 48, center.dy + 15)
          ..quadraticBezierTo(
              center.dx - 8, center.dy + 4, center.dx + 35, center.dy - 40);
        canvas.drawPath(path, paint);
        arrowLine(
            center + const Offset(20, -25), center + const Offset(35, -40));
      case 'Rack focus':
        canvas.drawCircle(center - const Offset(30, 0), 13 + pulse * 4, paint);
        canvas.drawCircle(center + const Offset(30, 0), 17 - pulse * 4, paint);
        arrowLine(center - const Offset(12, 0), center + const Offset(12, 0));
    }
  }

  @override
  bool shouldRepaint(covariant _MovementPreviewPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.phase != phase;
}

IconData _movementIcon(String value) => switch (value) {
      'Static' => Icons.lock_outline_rounded,
      'Pan' => Icons.swap_horiz_rounded,
      'Whip pan' => Icons.keyboard_double_arrow_right_rounded,
      'Tilt' => Icons.swap_vert_rounded,
      'Roll' => Icons.rotate_right_rounded,
      'Dolly' => Icons.arrow_forward_rounded,
      'Push in' => Icons.arrow_forward_rounded,
      'Pull out' => Icons.arrow_back_rounded,
      'Dolly zoom' => Icons.center_focus_strong_rounded,
      'Truck' => Icons.compare_arrows_rounded,
      'Pedestal' => Icons.height_rounded,
      'Track' => Icons.trending_flat_rounded,
      'Arc / orbit' => Icons.threesixty_rounded,
      'Slider' => Icons.linear_scale_rounded,
      'Crane' => Icons.height_rounded,
      'Jib' => Icons.call_made_rounded,
      'Handheld' => Icons.vibration_rounded,
      'Shoulder rig' => Icons.personal_video_rounded,
      'Steadicam' => Icons.accessibility_new_rounded,
      'Gimbal' => Icons.motion_photos_on_outlined,
      'Drone' => Icons.flight_rounded,
      'Cable cam' => Icons.cable_rounded,
      'Vehicle mount' => Icons.directions_car_filled_rounded,
      'Snorricam' => Icons.person_pin_circle_rounded,
      'Zoom' => Icons.zoom_in_rounded,
      'Crash zoom' => Icons.double_arrow_rounded,
      'Rack focus' => Icons.filter_center_focus_rounded,
      _ => Icons.videocam_outlined,
    };

IconData _stepIcon(int step) => switch (step) {
      0 => Icons.edit_note_rounded,
      1 => Icons.photo_size_select_large_rounded,
      2 => Icons.video_camera_back_outlined,
      3 => Icons.motion_photos_on_outlined,
      4 => Icons.camera_outlined,
      _ => Icons.fact_check_outlined,
    };

class _CompactOption extends StatelessWidget {
  const _CompactOption(
      {required this.label,
      required this.selected,
      required this.icon,
      required this.onTap});
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: Icon(icon,
          size: 17,
          color: selected ? ShotKitColors.tapeInk : ShotKitColors.dim),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: ShotKitColors.tape,
      backgroundColor: ShotKitColors.surface,
      side:
          BorderSide(color: selected ? ShotKitColors.tape : ShotKitColors.line),
      labelStyle: TextStyle(
          color: selected ? ShotKitColors.tapeInk : ShotKitColors.paper,
          fontWeight: FontWeight.w700),
    );
  }
}

class _PriorityCard extends StatelessWidget {
  const _PriorityCard(
      {required this.label,
      required this.hint,
      required this.icon,
      required this.selected,
      required this.onTap});
  final String label;
  final String hint;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? ShotKitColors.record.withValues(alpha: .1)
          : ShotKitColors.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: selected ? ShotKitColors.record : ShotKitColors.line)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon,
                color: selected ? ShotKitColors.record : ShotKitColors.dim),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(hint,
                style:
                    const TextStyle(color: ShotKitColors.dim, fontSize: 11.5)),
          ]),
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: ShotKitColors.tape, size: 19),
      const SizedBox(width: 9),
      Expanded(
          child: Text(text, style: const TextStyle(color: ShotKitColors.dim)))
    ]);
  }
}

class _ReferenceFrame extends StatelessWidget {
  const _ReferenceFrame(
      {required this.path,
      required this.media,
      required this.loading,
      required this.onPick,
      required this.onRemove});
  final String? path;
  final MediaService media;
  final bool loading;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return OutlinedButton.icon(
        onPressed: loading ? null : onPick,
        icon: loading
            ? const SizedBox.square(
                dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.add_a_photo_outlined),
        label: const Text('ADD REFERENCE FRAME'),
        style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(18),
            side: const BorderSide(color: ShotKitColors.line)),
      );
    }
    return FutureBuilder<File?>(
      future: media.resolve(path),
      builder: (context, snapshot) => Row(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                  width: 112,
                  height: 70,
                  child: snapshot.data == null
                      ? const ColoredBox(color: ShotKitColors.surface)
                      : Image.file(snapshot.data!, fit: BoxFit.cover))),
          const SizedBox(width: 12),
          const Expanded(
              child: Text('Reference frame attached',
                  style: TextStyle(fontWeight: FontWeight.w700))),
          IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remove frame'),
        ],
      ),
    );
  }
}
