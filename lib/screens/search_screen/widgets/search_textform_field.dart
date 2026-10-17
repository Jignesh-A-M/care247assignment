import 'package:care247assignment/infrastructure/config/search_config.dart';
import 'package:flutter/material.dart';

class SearchTextFormField extends StatelessWidget {
  const SearchTextFormField({
    super.key,
    required this.config,
    required this.controller,
    required this.focusNode,
    required this.textInputAction,
    this.onSubmitted,
  });

  final FieldConfig config;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    switch (config.type) {
      case FieldType.text:
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: textInputAction,
          keyboardType: TextInputType.name,
          autocorrect: false,
          onTapOutside: (_) => focusNode.unfocus(),
          style: TextStyle(color: Colors.white),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: config.label,
            labelStyle: TextStyle(color: Colors.white70),
            hintText: config.placeholder,
            hintStyle: TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            fillColor: Colors.white,
            focusColor: Colors.white,
            contentPadding: EdgeInsets.all(4),
          ),
          onFieldSubmitted: (_) {
            if (textInputAction == TextInputAction.done) onSubmitted?.call();
          },
        );
      case FieldType.date:
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          readOnly: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: config.label,
            labelStyle: TextStyle(color: Colors.white70),
            hintText: config.placeholder,
            hintStyle: TextStyle(color: Colors.white70),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            fillColor: Colors.white,
            focusColor: Colors.white,
            contentPadding: EdgeInsets.all(4),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.white),
          ),
          onTap: () => _pickDate(context),
        );
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final initial = DateTime.tryParse(controller.text) ?? DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked == null || !context.mounted) {
      focusNode.unfocus();
      return;
    }
    controller.text = _formatDate(picked);
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
