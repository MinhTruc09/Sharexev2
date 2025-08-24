import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharexev2/config/env.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;
  
  // Initialize Firebase
  static Future<void> initialize() async {
    try {
      if (!Env.enableFirebase) {
        print('Firebase is disabled in environment');
        return;
      }
      
      await Firebase.initializeApp();
      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      
      print('Firebase initialized successfully');
    } catch (e) {
      print('Failed to initialize Firebase: $e');
    }
  }
  
  // Get Firestore instance
  static FirebaseFirestore? get firestore => _firestore;
  
  // Get Auth instance
  static FirebaseAuth? get auth => _auth;
  
  // Check if Firebase is available
  static bool get isAvailable => _firestore != null && _auth != null;
  
  // Get current user
  static User? get currentUser => _auth?.currentUser;
  
  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth?.signOut();
    } catch (e) {
      print('Failed to sign out: $e');
    }
  }
  
  // Create document in Firestore
  static Future<DocumentReference> createDocument(
    String collection, 
    Map<String, dynamic> data
  ) async {
    if (!isAvailable) {
      throw Exception('Firebase is not available');
    }
    
    try {
      return await _firestore!.collection(collection).add(data);
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }
  
  // Update document in Firestore
  static Future<void> updateDocument(
    String collection, 
    String documentId, 
    Map<String, dynamic> data
  ) async {
    if (!isAvailable) {
      throw Exception('Firebase is not available');
    }
    
    try {
      await _firestore!.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }
  
  // Delete document from Firestore
  static Future<void> deleteDocument(String collection, String documentId) async {
    if (!isAvailable) {
      throw Exception('Firebase is not available');
    }
    
    try {
      await _firestore!.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }
  
  // Get document from Firestore
  static Future<DocumentSnapshot> getDocument(
    String collection, 
    String documentId
  ) async {
    if (!isAvailable) {
      throw Exception('Firebase is not available');
    }
    
    try {
      return await _firestore!.collection(collection).doc(documentId).get();
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }
  
  // Query documents from Firestore
  static Future<QuerySnapshot> queryDocuments(
    String collection, {
    String? field,
    dynamic isEqualTo,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    if (!isAvailable) {
      throw Exception('Firebase is not available');
    }
    
    try {
      Query query = _firestore!.collection(collection);
      
      if (field != null && isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      }
      
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      return await query.get();
    } catch (e) {
      throw Exception('Failed to query documents: $e');
    }
  }
}
