import 'package:flutter/material.dart';

import 'models/cart_model.dart';
import 'services/cart_storage_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    CartStorageService.initialize();
  }

  Future<void> _showEditDraftDialog(MedicineDraft draft) async {
    final titleController = TextEditingController(text: draft.title);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Draft'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: draft.createdAt),
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Created at',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                return;
              }

              await CartStorageService.updateDraft(
                draftId: draft.id,
                title: titleController.text.trim(),
              );
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMedicine({
    required String draftId,
    required int medicineIndex,
  }) async {
    await CartStorageService.removeMedicine(
      draftId: draftId,
      medicineIndex: medicineIndex,
    );
  }

  Future<void> _setBoughtStatus({
    required String draftId,
    required int medicineIndex,
    required bool isBought,
  }) async {
    await CartStorageService.setMedicineBoughtStatus(
      draftId: draftId,
      medicineIndex: medicineIndex,
      isBought: isBought,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.green[50],
        child: ValueListenableBuilder<List<MedicineDraft>>(
          valueListenable: CartStorageService.draftsNotifier,
          builder: (context, drafts, child) {
            if (drafts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list_alt_outlined,
                        size: 72, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Your list is empty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add medicines from search results to create a list.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: drafts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final draft = drafts[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: Text(
                          '${draft.medicines.length}',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        draft.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('Created at ${draft.createdAt}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditDraftDialog(draft),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red[700],
                            tooltip: 'Delete list',
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete list?'),
                                  content: Text(
                                      'Delete the list "${draft.title}"? This cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                await CartStorageService.removeDraft(
                                    draftId: draft.id);
                              }
                            },
                          ),
                        ],
                      ),
                      children: [
                        if (draft.medicines.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No medicines added yet.'),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: draft.medicines.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, medicineIndex) {
                              final medicine = draft.medicines[medicineIndex];
                              return ListTile(
                                leading: Icon(
                                  medicine.isBought
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: medicine.isBought
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                title: Text(
                                  medicine.genericName,
                                  style: TextStyle(
                                    decoration: medicine.isBought
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: medicine.isBought
                                        ? Colors.grey[600]
                                        : Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  'Drug Code: ${medicine.drugCode} • ${medicine.unitSize} • ₹${medicine.mrp}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Mark Bought',
                                      icon: Icon(
                                        Icons.check,
                                        color: medicine.isBought
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      onPressed: () => _setBoughtStatus(
                                        draftId: draft.id,
                                        medicineIndex: medicineIndex,
                                        isBought: true,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Mark Left',
                                      icon: Icon(
                                        Icons.close,
                                        color: !medicine.isBought
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      onPressed: () => _setBoughtStatus(
                                        draftId: draft.id,
                                        medicineIndex: medicineIndex,
                                        isBought: false,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Delete',
                                      icon: const Icon(Icons.delete_outline),
                                      color: Colors.red[700],
                                      onPressed: () => _deleteMedicine(
                                        draftId: draft.id,
                                        medicineIndex: medicineIndex,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
