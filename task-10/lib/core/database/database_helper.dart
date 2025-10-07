import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/notes/models/note_model.dart';
import '../../features/deadlines/models/deadline_model.dart';
import '../../features/split/models/expense_model.dart';
import '../../features/study_timer/models/study_session_model.dart';
import '../../features/grade_calculator/models/grade_model.dart';
import '../../features/timetable/models/timetable_model.dart';
import '../../features/attendance/models/attendance_model.dart';

class DatabaseHelper {
  // This makes the class a singleton, so you only have one instance.
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('studyhub.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path, 
      version: 5, 
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // This function is called once to create all your tables.
  Future _createDB(Database db, int version) async {
    await _createNotesTable(db);
    await _createDeadlinesTable(db);
    await _createGroupsTable(db);
    await _createStudySessionsTable(db);
    await _createGradeEntriesTable(db);
    await _createTimetableTable(db);
    await _createAttendanceTable(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to existing tables
      await db.execute('ALTER TABLE notes ADD COLUMN tags TEXT DEFAULT "[]"');
      await db.execute('ALTER TABLE notes ADD COLUMN shared INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE notes RENAME COLUMN lastEdited TO createdAt');
      await db.execute('ALTER TABLE deadlines ADD COLUMN completed INTEGER DEFAULT 0');
      
      // Create new table
      await _createGroupsTable(db);
    }
    if (oldVersion < 3) {
      // Add attachment support to notes
      await db.execute('ALTER TABLE notes ADD COLUMN attachments TEXT DEFAULT "[]"');
      await db.execute('ALTER TABLE notes ADD COLUMN createdBy TEXT DEFAULT ""');
      
      // Update expenses table to support participants
      // Note: We'll need to recreate the groups table since expenses are stored as JSON
      // The model changes will handle this automatically
    }
    if (oldVersion < 4) {
      // Add new feature tables
      await _createStudySessionsTable(db);
      await _createGradeEntriesTable(db);
      await _createTimetableTable(db);
    }
    if (oldVersion < 5) {
      // Add attendance table
      await _createAttendanceTable(db);
    }
  }

  Future _createNotesTable(Database db) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    await db.execute('''
      CREATE TABLE notes ( 
        id $idType, 
        title $textType,
        body $textType,
        subject $textType,
        tags TEXT DEFAULT "[]",
        createdAt $textType,
        shared $intType DEFAULT 0,
        attachments TEXT DEFAULT "[]",
        createdBy TEXT DEFAULT ""
      )
    ''');
  }

  Future _createDeadlinesTable(Database db) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    await db.execute('''
      CREATE TABLE deadlines (
        id $idType, 
        title $textType, 
        subject $textType,
        dueDate $textType, 
        priority $intType,
        completed $intType DEFAULT 0
      )
    ''');
  }

  Future _createGroupsTable(Database db) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    await db.execute('''
      CREATE TABLE groups (
        id $idType,
        name $textType,
        members $textType,
        expenses $textType
      )
    ''');
  }

  Future _createStudySessionsTable(Database db) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    await db.execute('''
      CREATE TABLE study_sessions (
        id $idType,
        subject $textType,
        durationMinutes $intType,
        startTime $textType,
        endTime TEXT,
        completed $intType DEFAULT 0,
        notes TEXT DEFAULT ""
      )
    ''');
  }

  Future _createGradeEntriesTable(Database db) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    await db.execute('''
      CREATE TABLE grade_entries (
        id $idType,
        subject $textType,
        assessmentName $textType,
        marksObtained $realType,
        totalMarks $realType,
        weightage $realType,
        date $textType,
        notes TEXT DEFAULT ""
      )
    ''');
  }

  Future _createTimetableTable(Database db) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    await db.execute('''
      CREATE TABLE timetable (
        id $idType,
        subject $textType,
        teacher $textType,
        room $textType,
        dayOfWeek $intType,
        timeSlot $textType,
        notes TEXT DEFAULT ""
      )
    ''');
  }

  Future _createAttendanceTable(Database db) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    await db.execute('''
      CREATE TABLE attendance (
        id $idType,
        subject $textType,
        date $textType,
        status $intType,
        notes TEXT DEFAULT ""
      )
    ''');
  }

  // --- Notes CRUD Methods ---
  Future<Note> createNote(Note note) async {
    final db = await instance.database;
    await db.insert('notes', note.toMap());
    return note;
  }

  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes', orderBy: 'createdAt DESC');
    return result.map((json) => Note.fromMap(json)).toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<int> deleteNote(String id) async {
    final db = await instance.database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // --- Deadlines CRUD Methods ---
  Future<Deadline> createDeadline(Deadline deadline) async {
    final db = await instance.database;
    await db.insert('deadlines', deadline.toMap());
    return deadline;
  }

  Future<List<Deadline>> readAllDeadlines() async {
    final db = await instance.database;
    final result = await db.query('deadlines', orderBy: 'dueDate ASC');
    return result.map((json) => Deadline.fromMap(json)).toList();
  }

  Future<int> updateDeadline(Deadline deadline) async {
    final db = await instance.database;
    return db.update('deadlines', deadline.toMap(), where: 'id = ?', whereArgs: [deadline.id]);
  }

  Future<int> deleteDeadline(String id) async {
    final db = await instance.database;
    return db.delete('deadlines', where: 'id = ?', whereArgs: [id]);
  }

  // --- Groups CRUD Methods ---
  Future<Group> createGroup(Group group) async {
    final db = await instance.database;
    await db.insert('groups', group.toMap());
    return group;
  }

  Future<List<Group>> readAllGroups() async {
    final db = await instance.database;
    final result = await db.query('groups', orderBy: 'name ASC');
    return result.map((json) => Group.fromMap(json)).toList();
  }

  Future<int> updateGroup(Group group) async {
    final db = await instance.database;
    return db.update('groups', group.toMap(), where: 'id = ?', whereArgs: [group.id]);
  }

  Future<int> deleteGroup(String id) async {
    final db = await instance.database;
    return db.delete('groups', where: 'id = ?', whereArgs: [id]);
  }

  // --- Study Sessions CRUD Methods ---
  Future<StudySession> createStudySession(StudySession session) async {
    final db = await instance.database;
    await db.insert('study_sessions', session.toMap());
    return session;
  }

  Future<List<StudySession>> readAllStudySessions() async {
    final db = await instance.database;
    final result = await db.query('study_sessions', orderBy: 'startTime DESC');
    return result.map((json) => StudySession.fromMap(json)).toList();
  }

  Future<int> updateStudySession(StudySession session) async {
    final db = await instance.database;
    return db.update('study_sessions', session.toMap(), where: 'id = ?', whereArgs: [session.id]);
  }

  Future<int> deleteStudySession(String id) async {
    final db = await instance.database;
    return db.delete('study_sessions', where: 'id = ?', whereArgs: [id]);
  }

  // --- Grade Entries CRUD Methods ---
  Future<GradeEntry> createGradeEntry(GradeEntry entry) async {
    final db = await instance.database;
    await db.insert('grade_entries', entry.toMap());
    return entry;
  }

  Future<List<GradeEntry>> readAllGradeEntries() async {
    final db = await instance.database;
    final result = await db.query('grade_entries', orderBy: 'date DESC');
    return result.map((json) => GradeEntry.fromMap(json)).toList();
  }

  Future<int> updateGradeEntry(GradeEntry entry) async {
    final db = await instance.database;
    return db.update('grade_entries', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<int> deleteGradeEntry(String id) async {
    final db = await instance.database;
    return db.delete('grade_entries', where: 'id = ?', whereArgs: [id]);
  }

  // --- Timetable CRUD Methods ---
  Future<TimetableEntry> createTimetableEntry(TimetableEntry entry) async {
    final db = await instance.database;
    await db.insert('timetable', entry.toMap());
    return entry;
  }

  Future<List<TimetableEntry>> readAllTimetableEntries() async {
    final db = await instance.database;
    final result = await db.query('timetable', orderBy: 'dayOfWeek ASC');
    return result.map((json) => TimetableEntry.fromMap(json)).toList();
  }

  Future<int> updateTimetableEntry(TimetableEntry entry) async {
    final db = await instance.database;
    return db.update('timetable', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<int> deleteTimetableEntry(String id) async {
    final db = await instance.database;
    return db.delete('timetable', where: 'id = ?', whereArgs: [id]);
  }

  // --- Attendance CRUD Methods ---
  Future<AttendanceRecord> createAttendanceRecord(AttendanceRecord record) async {
    final db = await instance.database;
    await db.insert('attendance', record.toMap());
    return record;
  }

  Future<List<AttendanceRecord>> readAllAttendanceRecords() async {
    final db = await instance.database;
    final result = await db.query('attendance', orderBy: 'date DESC');
    return result.map((json) => AttendanceRecord.fromMap(json)).toList();
  }

  Future<int> updateAttendanceRecord(AttendanceRecord record) async {
    final db = await instance.database;
    return db.update('attendance', record.toMap(), where: 'id = ?', whereArgs: [record.id]);
  }

  Future<int> deleteAttendanceRecord(String id) async {
    final db = await instance.database;
    return db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}