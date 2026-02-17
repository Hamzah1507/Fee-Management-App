import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/student.dart';
import 'add_student_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Student>('students');

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),

      // ✅ MODERN APPBAR
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Fees Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ✅ BODY
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Student> box, _) {
          if (box.isEmpty) {
            return _emptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final student = box.getAt(index)!;
              return _studentCard(context, student);
            },
          );
        },
      ),

      // ✅ PREMIUM FAB
      floatingActionButton: FloatingActionButton.extended(
        elevation: 6,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddStudentScreen(),
            ),
          );
        },
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Student'),
      ),
    );
  }

  // ================= EMPTY STATE =================
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No students yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Tap + to add your first student',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ================= STUDENT CARD =================
  Widget _studentCard(BuildContext context, Student student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xff6C63FF), Color(0xff8F88FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),

        // ✅ AVATAR
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          child: Text(
            student.name.isNotEmpty
                ? student.name[0].toUpperCase()
                : '?',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff6C63FF),
            ),
          ),
        ),

        // ✅ NAME
        title: Text(
          student.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),

        // ✅ COURSE
        subtitle: Text(
          student.course,
          style: const TextStyle(color: Colors.white70),
        ),

        // ✅ FEES BADGE
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            '₹${student.fees}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),

        // ✅ DELETE WITH CONFIRM
        onLongPress: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Student'),
              content:
                  Text('Delete ${student.name}?'),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await student.delete();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Student deleted'),
              ),
            );
          }
        },
      ),
    );
  }
}
