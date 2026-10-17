import 'package:care247assignment/infrastructure/models/customer_model.dart';
import 'package:flutter/material.dart';

class NewResultScreen extends StatelessWidget {
  final CustomerModel customer;

  const NewResultScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(8), right: Radius.circular(8)),
        ),
        leadingWidth: 24,
        title: Text(
          '${customer.firstName} ${customer.lastName}',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff801c8c),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BackgroundCard(
            title: 'Basic Information',
            children: [
              BasicInfoRow(label: 'First Name', value: customer.firstName),
              BasicInfoRow(label: 'Last Name', value: customer.lastName),
              BasicInfoRow(label: 'Date of Birth', value: customer.dateOfBirth),
              BasicInfoRow(label: 'Marital Status', value: customer.maritalStatus),
              BasicInfoRow(label: 'Secure ID', value: customer.secureId),
            ],
          ),
          const SizedBox(height: 16),
          BackgroundCard(
            title: 'Addresses',
            emptyText: 'Addresses is not provided.',
            children: [
              for (final address in customer.addresses) ...[
                CustomTile(
                  title: address.type,
                  lines: [address.street, '${address.city}, ${address.state} ${address.zipCode}'],
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          BackgroundCard(
            title: 'Phones',
            emptyText: 'Phone numbers is not provided.',
            children: [
              for (final phone in customer.phones)
                CustomTile(title: phone.type, lines: [phone.number], isPrimary: phone.isPrimary),
            ],
          ),
          const SizedBox(height: 16),
          BackgroundCard(
            title: 'Emails',
            emptyText: 'Email addresses is not provided.',
            children: [
              for (final email in customer.emails)
                CustomTile(title: email.type, lines: [email.address], isPrimary: email.isPrimary),
            ],
          ),
        ],
      ),
    );
  }
}

class BackgroundCard extends StatelessWidget {
  const BackgroundCard({super.key, required this.title, required this.children, this.emptyText = ''});

  final String title;
  final List<Widget> children;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(header: true, child: Text(title, style: textTheme.titleMedium)),
            const Divider(height: 24),
            if (children.isEmpty) ...[Text(emptyText, style: textTheme.labelSmall)] else ...[...children],
          ],
        ),
      ),
    );
  }
}

class BasicInfoRow extends StatelessWidget {
  const BasicInfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label :', style: TextStyle(color: theme.colorScheme.outline)),
          ),
          Expanded(child: Text(value.isEmpty ? '—' : value,style: theme.textTheme.titleSmall,)),
        ],
      ),
    );
  }
}

class CustomTile extends StatelessWidget {
  const CustomTile({super.key, required this.title, required this.lines, this.isPrimary = false});

  final String title;
  final List<String> lines;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final label = title.isEmpty ? 'UnKnown' : title[0].toUpperCase() + title.substring(1);
    var theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (isPrimary) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Color(0xfff58030), borderRadius: BorderRadius.circular(12)),
                  child: Text('Primary', style: TextStyle(fontSize: 12, color: Color(0xff801c8c))),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          for (final line in lines) ...[Text(line, style: theme.textTheme.bodyLarge)],
        ],
      ),
    );
  }
}
