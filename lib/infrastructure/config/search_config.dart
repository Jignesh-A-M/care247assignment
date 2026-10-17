enum FieldType { text, date }

class FieldConfig {
  final String key;
  final FieldType type;
  final String label;
  final String? placeholder;
  final int renderOrder;

  const FieldConfig({
    required this.key,
    required this.type,
    required this.label,
    this.placeholder,
    required this.renderOrder,
  });
}

final List<FieldConfig> searchConfig = [
  FieldConfig(
    key: 'firstName',
    type: FieldType.text,
    label: 'First Name',
    placeholder: 'Enter first name',
    renderOrder: 1,
  ),
  FieldConfig(
    key: 'lastName',
    type: FieldType.text,
    label: 'Last Name',
    placeholder: 'Enter last name',
    renderOrder: 2,
  ),
  FieldConfig(
    key: 'dateOfBirth',
    type: FieldType.date,
    label: 'Date of Birth',
    placeholder: 'Select date of birth',
    renderOrder: 3,
  ),
];
