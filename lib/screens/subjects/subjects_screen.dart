import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/subject_model.dart';
import '../../providers/subjects_provider.dart';
import '../../providers/admin_provider.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectsProvider>().loadSubjects();
    });
  }

  Future<void> _subjectDialog({SubjectModel? existing}) async {
    final colors = context.colors;
    final nameController = TextEditingController(text: existing?.name ?? '');
    int selectedCuatrimestre = existing?.cuatrimestre ?? 1;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            existing == null ? 'Nueva materia' : 'Editar materia',
            style: TextStyle(color: colors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                style: TextStyle(color: colors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Nombre de la materia',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButton<int>(
                value: selectedCuatrimestre,
                isExpanded: true,
                dropdownColor: colors.surface,
                items: List.generate(11, (i) => i + 1)
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          'Cuatrimestre $c',
                          style: TextStyle(color: colors.textPrimary),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setDialogState(() => selectedCuatrimestre = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (saved != true || nameController.text.trim().isEmpty || !mounted) return;

    final subjectsProvider = context.read<SubjectsProvider>();
    if (existing == null) {
      await subjectsProvider.addSubject(
        name: nameController.text.trim(),
        cuatrimestre: selectedCuatrimestre,
      );
    } else {
      await subjectsProvider.updateSubject(
        existing.copyWith(
          name: nameController.text.trim(),
          cuatrimestre: selectedCuatrimestre,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectsProvider = context.watch<SubjectsProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final grouped = subjectsProvider.subjectsByCuatrimestre;
    final cuatrimestres = grouped.keys.toList()..sort();
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Materias')),
      floatingActionButton: adminProvider.isAdminMode
          ? FloatingActionButton(
              backgroundColor: colors.emerald,
              onPressed: () => _subjectDialog(),
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
      body: subjectsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cuatrimestres.isEmpty
          ? Center(
              child: Text(
                'Aún no hay materias registradas',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: cuatrimestres.length,
                itemBuilder: (context, index) {
                  final cuatrimestre = cuatrimestres[index];
                  final subjects = grouped[cuatrimestre]!;
                  final isCurrent =
                      cuatrimestre == subjectsProvider.currentCuatrimestre;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: colors.surface,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isCurrent ? colors.emerald : colors.border,
                        ),
                      ),
                      child: ExpansionTile(
                        backgroundColor: Colors.transparent,
                        collapsedBackgroundColor: Colors.transparent,
                        initiallyExpanded: isCurrent,
                        collapsedIconColor: colors.textMuted,
                        iconColor: colors.emerald,
                        title: Row(
                          children: [
                            Text(
                              'Cuatrimestre $cuatrimestre',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.emerald,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'ACTUAL',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        children: subjects.map((subject) {
                          return ListTile(
                            title: Text(
                              subject.name,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: colors.textPrimary),
                            ),
                            trailing: adminProvider.isAdminMode
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          color: colors.textMuted,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _subjectDialog(existing: subject),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: colors.textMuted,
                                          size: 20,
                                        ),
                                        onPressed: () => subjectsProvider
                                            .removeSubject(subject),
                                      ),
                                    ],
                                  )
                                : null,
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
