import 'package:flutter/material.dart';

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
    keepAwake = (await widget.store.database.setting('keepAwake')) != 'false';
    completionMarks =
        (await widget.store.database.setting('completionMarks')) != 'false';
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SlateHeader(
            title: 'Kit settings',
            subtitle: 'Tune the app for your set',
            showBack: true,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
              children: [
                const SectionLabel('On-set behaviour'),
                _SettingSwitch(
                  icon: Icons.light_mode_outlined,
                  title: 'Keep screen awake',
                  subtitle: 'Only while On-set mode is open',
                  value: keepAwake,
                  onChanged: (value) {
                    setState(() => keepAwake = value);
                    widget.store.database
                        .setSetting('keepAwake', value.toString());
                  },
                ),
                const SizedBox(height: 10),
                _SettingSwitch(
                  icon: Icons.task_alt_rounded,
                  title: 'Completion marks in PDF',
                  subtitle: 'Default for new exports',
                  value: completionMarks,
                  onChanged: (value) {
                    setState(() => completionMarks = value);
                    widget.store.database
                        .setSetting('completionMarks', value.toString());
                  },
                ),
                const SizedBox(height: 24),
                const SectionLabel('Storage'),
                _SettingsTile(
                  icon: Icons.folder_outlined,
                  title: 'Local media',
                  subtitle: 'Reference frames stay on this device',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'All reference frames are compressed and stored in ShotKit local media.'))),
                ),
                const SizedBox(height: 10),
                _SettingsTile(
                  icon: Icons.archive_outlined,
                  title: 'Archived projects',
                  subtitle: '${widget.store.archivedProjects.length} archived',
                  onTap: _showArchived,
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'SHOTKIT · BUILD 1.0.0\nMade for the set, not the cloud.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ShotKitColors.dim,
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showArchived() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: widget.store.archivedProjects.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: Text('No archived projects.')),
              )
            : ListView(
                shrinkWrap: true,
                children: widget.store.archivedProjects
                    .map(
                      (project) => ListTile(
                        title: Text(project.title),
                        subtitle: Text(
                            '${project.scenes.length} scenes · ${project.shotCount} shots'),
                        trailing: TextButton(
                          onPressed: () async {
                            await widget.store.unarchiveProject(project);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text('RESTORE'),
                        ),
                      ),
                    )
                    .toList(),
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
    return Container(
      decoration: BoxDecoration(
        color: ShotKitColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: ShotKitColors.line),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: ShotKitColors.tape,
        secondary: Icon(icon, color: ShotKitColors.tape),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: ShotKitColors.dim, fontSize: 11.5),
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
    return ListTile(
      onTap: onTap,
      tileColor: ShotKitColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
        side: const BorderSide(color: ShotKitColors.line),
      ),
      leading: Icon(icon, color: ShotKitColors.dim),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: ShotKitColors.dim, fontSize: 11.5),
      ),
      trailing: const Icon(Icons.chevron_right, color: ShotKitColors.dim),
    );
  }
}
