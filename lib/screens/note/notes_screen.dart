import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getNotes();
    setState(() {
      _notes = data;
      _isLoading = false;
    });
  }

  void _showNoteDialog({Map<String, dynamic>? note}) {
    final titleController = TextEditingController(text: note?['title'] ?? '');
    final contentController = TextEditingController(text: note?['content'] ?? '');
    String category = note?['category'] ?? 'Action Item';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(note == null ? 'New Farm Note / Task' : 'Edit Note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: category,
                items: ['Action Item', 'Future Development', 'Maintenance', 'General']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => category = val ?? 'General',
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contentController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Details / Action Needed'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) return;

              final noteData = {
                'title': titleController.text.trim(),
                'content': contentController.text.trim(),
                'category': category,
                'createdAt': DateTime.now().toIso8601String(),
              };

              if (note == null) {
                await DatabaseHelper.instance.insertNote(noteData);
              }
              if (mounted) {
                Navigator.pop(context);
                _refreshNotes();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Notebook & Action Plan'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? const Center(child: Text('No notes recorded yet.'))
              : ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final item = _notes[index];
                    final isDone = item['isCompleted'] == 1;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Checkbox(
                          value: isDone,
                          onChanged: (val) async {
                            await DatabaseHelper.instance.updateNoteStatus(item['id'], val ?? false);
                            _refreshNotes();
                          },
                        ),
                        title: Text(
                          item['title'],
                          style: TextStyle(
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['content'] ?? ''),
                            const SizedBox(height: 4),
                            Chip(
                              label: Text(item['category'], style: const TextStyle(fontSize: 10)),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            await DatabaseHelper.instance.deleteNote(item['id']);
                            _refreshNotes();
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        child: const Icon(Icons.add_task),
      ),
    );
  }
}