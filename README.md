## Features
Core:
- Add new inventory items (name, quantity, price, category)
- Edit existing items
- Delete items (swipe to delete or delete button in edit screen)
- Real-time listing of items with live updates from Firestore

Enhanced (Extra Credit Implemented):
1. Search & Category Filter
	- Search bar filters items by name in real time
	- Category filter chips (All, General, Food, Electronics, Clothing)
2. Data Insights Dashboard
	- Total unique items
	- Total inventory value (quantity * price)
	- Out-of-stock items list

## Tech Stack
- Flutter (Dart)
- Firebase Core
- Cloud Firestore

## Data Model
`Item` fields:
- id (String, Firestore document id)
- name (String)
- quantity (int)
- price (double)
- category (String)
- createdAt (DateTime / Firestore Timestamp)

## Firestore Operations
| Operation | Code |
|-----------|------|
| Create | `FirebaseFirestore.instance.collection('items').add(item.toMap())` |
| Read (stream) | `FirebaseFirestore.instance.collection('items').snapshots()` |
| Update | `FirebaseFirestore.instance.collection('items').doc(id).update(item.toMap())` |
| Delete | `FirebaseFirestore.instance.collection('items').doc(id).delete()` |