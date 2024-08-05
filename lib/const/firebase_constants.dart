import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


// fire-base constants

FirebaseAuth auth = FirebaseAuth.instance ;
FirebaseFirestore fireStore = FirebaseFirestore.instance;
User ? currentUser = auth.currentUser ;
String user = auth.currentUser!.uid;

// premium collection

const usersCollection = 'users';
const userstokenCollection = 'userstoken';