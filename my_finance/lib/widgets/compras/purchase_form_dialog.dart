import 'package:flutter/material.dart';
import 'package:my_finance/data/expense_data.dart';
import 'package:my_finance/models/expense_item.dart';
import 'package:my_finance/models/purchase_category.dart';
import 'package:my_finance/utils/date_formatters.dart';

Future<void> showPurchaseFormDialog(
  BuildContext context,
  ExpenseData expenseData, {
  ExpenseItem? existing,
}) async {
  final isEditing = existing != null;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name ?? '');
  final amountController = TextEditingController(
    text: existing != null ? existing.amount.toStringAsFixed(2) : '',
  );
  DateTime selectedDate = existing?.date ?? DateTime.now();
  PurchaseCategory selectedCategory =
      existing?.category ?? PurchaseCategory.outros;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          var saving = false;

          Future<void> pickDate() async {
            final now = DateTime.now();
            final firstDay = DateTime(now.year, now.month, 1);
            final lastDay = now;
            final date = await showDatePicker(
              context: dialogContext,
              initialDate: selectedDate,
              firstDate: firstDay,
              lastDate: lastDay,
            );
            if (date != null) {
              setDialogState(() {
                selectedDate = date;
              });
            }
          }

          Future<void> save() async {
            if (!formKey.currentState!.validate()) return;

            final normalizedAmount = amountController.text.replaceAll(',', '.');
            final parsedAmount = double.tryParse(normalizedAmount);
            if (parsedAmount == null || parsedAmount <= 0) return;

            setDialogState(() {
              saving = true;
            });

            try {
              final expense = ExpenseItem(
                name: nameController.text.trim(),
                amount: parsedAmount,
                date: selectedDate,
                category: selectedCategory,
              );

              if (isEditing) {
                await expenseData.updateExpense(existing, expense);
              } else {
                await expenseData.addExpense(expense);
              }

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? 'Compra atualizada com sucesso!'
                          : 'Compra registrada com sucesso!',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (dialogContext.mounted) {
                setDialogState(() {
                  saving = false;
                });
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao salvar compra: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            }
          }

          return AlertDialog(
            title: Text(isEditing ? 'Editar compra' : 'Nova compra'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da compra',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shopping_cart),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o nome da compra';
                        }
                        if (value.trim().length < 2) {
                          return 'Nome deve ter pelo menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Valor',
                        prefixText: 'R\$ ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o valor';
                        }
                        final val = double.tryParse(value.replaceAll(',', '.'));
                        if (val == null) return 'Valor inválido';
                        if (val <= 0) return 'Valor deve ser maior que zero';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<PurchaseCategory>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                      items: PurchaseCategory.values
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category.label),
                            ),
                          )
                          .toList(),
                      onChanged: saving
                          ? null
                          : (value) {
                              if (value == null) return;
                              setDialogState(() {
                                selectedCategory = value;
                              });
                            },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_today,
                        color: Colors.deepPurple,
                      ),
                      title: const Text('Data da compra'),
                      subtitle: Text(formatDate(selectedDate)),
                      trailing: TextButton(
                        onPressed: pickDate,
                        child: const Text('Alterar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                onPressed: saving ? null : save,
                icon: const Icon(Icons.check),
                label: Text(
                  saving
                      ? 'Salvando...'
                      : isEditing
                      ? 'Salvar'
                      : 'Adicionar',
                ),
              ),
            ],
          );
        },
      );
    },
  );

  nameController.dispose();
  amountController.dispose();
}
