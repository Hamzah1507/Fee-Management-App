import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/student.dart';
import 'add_student_screen.dart';
import 'student_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  // ✅ VERY IMPORTANT — dispose inside STATE
  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // ✅ prevents keyboard auto open on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentsRef = FirebaseFirestore.instance.collection('students');

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Fees Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // 🔍 SEARCH BAR
            _searchBar(),

            // 📊 DASHBOARD
            StreamBuilder<QuerySnapshot>(
              stream: studentsRef
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                return _dashboard(snapshot.data!.docs);
              },
            ),

            // 📋 STUDENT LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: studentsRef
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _emptyState();
                  }

                  // ✅ FILTER LOGIC (THE REAL MAGIC)
                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name =
                        (data['name'] ?? '').toString().toLowerCase();
                    final course =
                        (data['course'] ?? '').toString().toLowerCase();

                    final query = _searchQuery.toLowerCase();

                    return name.contains(query) || course.contains(query);
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No matching students',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final student = Student.fromMap(
                        doc.id,
                        doc.data() as Map<String, dynamic>,
                      );
                      return _studentCard(context, student);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        elevation: 6,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddStudentScreen()),
          );
        },
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Student'),
      ),
    );
  }

  // ================= SEARCH BAR =================
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: false, // ✅ prevents auto keyboard
        onTapOutside: (_) => _searchFocusNode.unfocus(), // ✅ fixes blink
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        decoration: InputDecoration(
          hintText: 'Search student...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= EMPTY STATE =================
  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey),
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

  // ================= DASHBOARD =================
  Widget _dashboard(List<QueryDocumentSnapshot> docs) {
    int totalStudents = docs.length;
    int totalFees = 0;
    int totalPaid = 0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalFees += (data['totalFees'] ?? 0) as int;
      totalPaid += (data['paidFees'] ?? 0) as int;
    }

    final pending = totalFees - totalPaid;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _statCard('Students', totalStudents, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('Collected', totalPaid, Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statCard('Total Fees', totalFees, Colors.black)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('Pending', pending, Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  // ================= STAT CARD =================
  Widget _statCard(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            '₹$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDetailsScreen(student: student),
            ),
          );
        },
        leading: CircleAvatar(
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
        title: Text(
          student.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          student.course,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
