import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqldbui2/page/translate.dart';

class FormularyAccessHistory extends StatelessWidget {
  final String user;
  final DateTime? accessDate;
  final String kindOfAccess;
  final String patchNote;

  const FormularyAccessHistory({
    Key? key,
    required this.user,
    required this.accessDate,
    required this.kindOfAccess,
    required this.patchNote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? formattedDate = accessDate != null ? DateFormat("yyyy-MM-dd HH:mm").format(accessDate!) : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person, color: Colors.blue, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(future: getOnFlow(user), builder: (a,s) {
                  if (s.data != null) {
                    return Text(
                      s.data!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return Text(
                    user,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
                const SizedBox(height: 4),
                formattedDate == null ? Container() : FutureBuilder(future: getOnFlow("Date: $formattedDate"), builder: (a,s) {
                  if (s.data != null) {
                    return Text(s.data!);
                  }
                  return Text("Date: $formattedDate");
                }),
                FutureBuilder(future: getOnFlow("Access: $kindOfAccess"), builder: (a,s) {
                  if (s.data != null) {
                    return Text(s.data!);
                  }
                  return Text("Access: $kindOfAccess");
                }),
                if (patchNote != "") 
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        patchNote,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.history, color: Colors.grey),
        ],
      ),
    );
  }
}
