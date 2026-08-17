import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_finance/utils/date_formatters.dart';

class SpendingLimitSection extends StatefulWidget {
  final double spendingLimit;
  final double totalSpent;
  final ValueChanged<double> onChanged;

  const SpendingLimitSection({
    super.key,
    required this.spendingLimit,
    required this.totalSpent,
    required this.onChanged,
  });

  @override
  State<SpendingLimitSection> createState() => _SpendingLimitSectionState();
}

class _SpendingLimitSectionState extends State<SpendingLimitSection> {
  late final TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.spendingLimit > 0
          ? widget.spendingLimit.toStringAsFixed(2).replaceAll('.', ',')
          : '',
    );
  }

  @override
  void didUpdateWidget(SpendingLimitSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spendingLimit != widget.spendingLimit && !_isEditing) {
      _controller.text = widget.spendingLimit > 0
          ? widget.spendingLimit.toStringAsFixed(2).replaceAll('.', ',')
          : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = double.tryParse(_controller.text.replaceAll(',', '.')) ?? 0.0;
    setState(() {
      _isEditing = false;
    });
    widget.onChanged(value);
  }

  bool get _isOverLimit =>
      widget.spendingLimit > 0 && widget.totalSpent > widget.spendingLimit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: _isEditing,
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    var text = newValue.text.replaceAll('.', ',');
                    text = text.replaceAll(RegExp(r'[^0-9,]'), '');
                    final commaIndex = text.indexOf(',');
                    if (commaIndex != -1) {
                      text = '${text.substring(0, commaIndex + 1)}'
                          '${text.substring(commaIndex + 1).replaceAll(',', '')}';
                    }
                    final commaPos = text.indexOf(',');
                    if (commaPos != -1 && text.length - commaPos - 1 > 2) {
                      text = text.substring(0, commaPos + 3);
                    }
                    return TextEditingValue(
                      text: text,
                      selection: TextSelection.collapsed(offset: text.length),
                    );
                  }),
                ],
                decoration: InputDecoration(
                  labelText: 'Limite mensal',
                  border: const OutlineInputBorder(),
                  prefixText: 'R\$ ',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                  suffixIcon: _isEditing
                      ? IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          tooltip: 'Salvar limite',
                          onPressed: _save,
                        )
                      : IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Editar limite',
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
        if (widget.spendingLimit > 0) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                _isOverLimit ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                color: _isOverLimit ? Colors.redAccent : Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isOverLimit
                      ? 'Limite ultrapassado! (${formatCurrency(widget.totalSpent)} de ${formatCurrency(widget.spendingLimit)})'
                      : 'Gasto: ${formatCurrency(widget.totalSpent)} / ${formatCurrency(widget.spendingLimit)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: _isOverLimit ? Colors.redAccent : Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (widget.totalSpent / widget.spendingLimit).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: _isOverLimit ? Colors.redAccent : const Color(0xFF5A2E6F),
            ),
          ),
        ],
      ],
    );
  }
}
