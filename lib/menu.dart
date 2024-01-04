import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Column(
        children:[ SizedBox(
          width: 200,
          height: 80,
          child: Card(
            elevation: 6,
            color: Colors.blueAccent,
            semanticContainer: true,
            // Implement InkResponse
            child: InkResponse(
              containedInkWell: true,
              highlightShape: BoxShape.rectangle,
              onTap: () {
                                context.go('/tables/');
                // Clear all showing snack bars
                ScaffoldMessenger.of(context).clearSnackBars();
                // Display a snack bar
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Let's me sleep. Don't touch me!"),
                ));
              },
              // Add image & text
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.table_view),
                  Text(
                    'List all tables',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10)
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: 200,
          height: 80,
          child: Card(
            elevation: 6,
            color: Colors.blueAccent,
            semanticContainer: true,
            // Implement InkResponse
            child: InkResponse(
              containedInkWell: true,
              highlightShape: BoxShape.rectangle,
              onTap: () {
                context.go('/forms/');
                // Clear all showing snack bars
                ScaffoldMessenger.of(context).clearSnackBars();
                // Display a snack bar
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Let's me sleep. Don't touch me!"),
                ));
              },
              // Add image & text
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.dynamic_form),
                  Text(
                    'List all forms',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10)
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: 200,
          height: 80,
          child: Card(
            elevation: 6,
            color: Colors.blueAccent,
            semanticContainer: true,
            // Implement InkResponse
            child: InkResponse(
              containedInkWell: true,
              highlightShape: BoxShape.rectangle,
              onTap: () {
                context.go('/tableviews/');
                // Clear all showing snack bars
                ScaffoldMessenger.of(context).clearSnackBars();
                // Display a snack bar
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Let's me sleep. Don't touch me!"),
                ));
              },
              // Add image & text
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.dynamic_form),
                  Text(
                    'List all views',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10)
                ],
              ),
            ),
          ),
        )
        ]
      ),
      ),
    );
    
  } 
}