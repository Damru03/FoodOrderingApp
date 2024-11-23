Food Ordering App
A Flutter-based mobile application for managing food orders with features like adding food items, setting a target cost, saving orders for specific dates, and viewing saved orders.

Features
Database Management:

Uses SQLite for managing food items and orders.
Preloaded database with popular food items and prices.
Food Item Management:

Add, update, or delete food items.
Order Management:

Save selected food items for a specific date.
View saved orders with details like date, items, and total cost.
Query and Sort:

Query orders by date.
Sort food items and orders by price, date, or name.
Technology Stack
Flutter: UI framework for cross-platform app development.
Dart: Programming language for building the app.
SQLite: Database for local storage.
Screens
Splash Screen:

Displays the app name and transitions to the home screen.
Home Screen:

Navigation to food item management, cart, and order management screens.
Food Management Screen:

Manage food items (add, update, delete).
Cart Screen:

Select food items, set target cost, pick a date, and save orders.
Order Management Screen:

View and manage saved orders.

How It Works
1. Database Initialization
The app initializes the SQLite database with two tables:
food_items: Stores food names and costs.
orders: Stores saved orders with items, date, and total cost.
2. Adding/Updating Food Items
Users can add, edit, or delete food items via the Food Management Screen.
3. Saving Orders
Users can:
Add items to the cart.
Set a target cost and select a date.
Save the order, which calculates the total cost and stores it in the database.
4. Viewing Orders
Users can view saved orders in the Order Management Screen.
Orders are displayed with the date, items, and total cost.
Challenges Faced
Setting up database migrations for evolving schemas.
Resolving merge conflicts during Git synchronization.
Future Enhancements
Implement user authentication.
Add filtering and advanced sorting features.
Introduce a cloud-based backend for syncing orders across devices.
