import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/shotkit_widgets.dart';
import '../../data/shotkit_store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.store,
    this.initiallyShowArchived = false,
  });
  final ShotKitStore store;
  final bool initiallyShowArchived;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool keepAwake = true;
  bool daylight = false;
  bool completionMarks = true;

  @override
  void initState() {
    super.initState();
    _load();
    if (widget.initiallyShowArchived) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showArchived();
      });
    }
  }

  Future<void> _load() async {
    final database = widget.store.database;
    keepAwake = (await database.setting('keepAwake')) != 'false';
    daylight = (await database.setting('onsetDaylight')) == 'true';
    completionMarks = (await database.setting('completionMarks')) != 'false';
    if (mounted) setState(() {});
  }

  void _save(String key, bool value) =>
      widget.store.database.setSetting(key, value.toString());

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
                const TitleBlock(
                  eyebrow: 'Kit',
                  title: 'Settings',
                  meta: Text(
                    'Tune ShotKit for your set.',
                    style: TextStyle(color: ShotKitColors.dim),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionLabel('On set'),
                      _SettingSwitch(
                        icon: Icons.screen_lock_portrait_outlined,
                        title: 'Keep screen awake',
                        subtitle: 'Only while On-set mode is open',
                        value: keepAwake,
                        onChanged: (value) {
                          setState(() => keepAwake = value);
                          _save('keepAwake', value);
                        },
                      ),
                      const SizedBox(height: 10),
                      _SettingSwitch(
                        icon: Icons.light_mode_outlined,
                        title: 'Daylight mode',
                        subtitle:
                            'High-contrast light theme for shooting outdoors',
                        value: daylight,
                        onChanged: (value) {
                          setState(() => daylight = value);
                          _save('onsetDaylight', value);
                        },
                      ),
                      const SizedBox(height: 14),
                      const SectionLabel('Export'),
                      _SettingSwitch(
                        icon: Icons.task_alt_rounded,
                        title: 'Completion marks in PDF',
                        subtitle: 'Default for new exports',
                        value: completionMarks,
                        onChanged: (value) {
                          setState(() => completionMarks = value);
                          _save('completionMarks', value);
                        },
                      ),
                      const SizedBox(height: 14),
                      const SectionLabel('Storage'),
                      _SettingsTile(
                        icon: Icons.folder_outlined,
                        title: 'Local media',
                        subtitle: 'Reference frames stay on this device',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'All reference frames are compressed and stored in ShotKit local media.',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _SettingsTile(
                        icon: Icons.archive_outlined,
                        title: 'Archived projects',
                        subtitle:
                            '${widget.store.archivedProjects.length} archived',
                        onTap: _showArchived,
                      ),
                      const SizedBox(height: 14),
                      const SectionLabel('Help'),
                      _SettingsTile(
                        icon: Icons.mail_outline_rounded,
                        title: 'Send feedback',
                        subtitle: _feedbackEmail,
                        onTap: _copyFeedbackEmail,
                      ),
                      const SizedBox(height: 32),
                      const HazardStripe(),
                      const SizedBox(height: 14),
                      Text(
                        'SHOTKIT · BUILD 1.1.0\nMade for the set, not the cloud.',
                        textAlign: TextAlign.center,
                        style: ShotKitText.mono(size: 10.5, height: 1.7),
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

  static const _feedbackEmail = 'thehirahasan@gmail.com';

  Future<void> _copyFeedbackEmail() async {
    await Clipboard.setData(const ClipboardData(text: _feedbackEmail));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email copied. Ideas and bug reports are welcome.'),
      ),
    );
  }

  Future<void> _showArchived() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetHandle(),
              const SizedBox(height: 8),
              if (widget.store.archivedProjects.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(28),
                  child: Text(
                    'No archived projects.',
                    style: TextStyle(color: ShotKitColors.dim),
                  ),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final project in widget.store.archivedProjects)
                        ListTile(
                          leading: Icon(
                            projectTypeIcon(project.type),
                            color: ShotKitColors.tape,
                          ),
                          title: Text(project.title),
                          subtitle: Text(
                            '${project.scenes.length} scenes · ${project.shotCount} shots',
                            style: const TextStyle(color: ShotKitColors.dim),
                          ),
                          trailing: TextButton(
                            onPressed: () async {
                              await widget.store.unarchiveProject(project);
                              if (context.mounted) Navigator.pop(context);
                            },
                            child: const Text('Restore'),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (mounted) setState(() {});
  }
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ShotKitColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ShotKitColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: ShotKitColors.tape),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: ShotKitColors.dim, fontSize: 12.5),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ShotKitColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ShotKitColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: ShotKitColors.dim),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: ShotKitColors.dim, fontSize: 12.5),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: ShotKitColors.dim,
        ),
      ),
    );
  }
}
