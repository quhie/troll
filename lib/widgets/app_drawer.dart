// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../utils/app_theme.dart';
// import '../viewmodels/theme_viewmodel.dart';

// /// A modern app drawer with user profile section, navigation links,
// /// and theme toggle. Designed to provide a consistent navigation experience.
// class AppDrawer extends StatelessWidget {
//   const AppDrawer({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final themeViewModel = Provider.of<ThemeViewModel>(context);
//     final isDark = themeViewModel.isDarkMode;
//     final primaryColor = isDark ? AppTheme.darkPrimaryColor : AppTheme.primaryColor;

//     return Drawer(
//       backgroundColor: isDark ? AppTheme.darkSurfaceColor : Colors.white,
//       elevation: 0,
//       child: SafeArea(
//         child: Column(
//           children: [
//             // User profile section
//             _buildProfileHeader(context, isDark),

//             const SizedBox(height: 8),

//             // Divider
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Divider(
//                 color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
//                 thickness: 1,
//               ),
//             ),

//             const SizedBox(height: 8),

//             // Menu items
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.zero,
//                 children: [
//                   _buildMenuItem(
//                     context,
//                     title: 'Home',
//                     icon: Icons.home_rounded,
//                     onTap: () {
//                       Navigator.pop(context);
//                       // Add navigation to home if needed
//                     },
//                     isDark: isDark,
//                     isActive: true,
//                   ),
//                   _buildMenuItem(
//                     context,
//                     title: 'Sound Effects',
//                     icon: Icons.music_note_rounded,
//                     onTap: () {
//                       Navigator.pop(context);
//                       // Add navigation to sound effects
//                     },
//                     isDark: isDark,
//                   ),
//                   _buildMenuItem(
//                     context,
//                     title: 'Visual Effects',
//                     icon: Icons.flash_on_rounded,
//                     onTap: () {
//                       Navigator.pop(context);
//                       // Add navigation to visual effects
//                     },
//                     isDark: isDark,
//                   ),
//                   _buildMenuItem(
//                     context,
//                     title: 'Tools',
//                     icon: Icons.build_rounded,
//                     onTap: () {
//                       Navigator.pop(context);
//                       // Add navigation to tools
//                     },
//                     isDark: isDark,
//                   ),
//                   _buildMenuItem(
//                     context,
//                     title: 'Favorites',
//                     icon: Icons.favorite_rounded,
//                     onTap: () {
//                       Navigator.pop(context);
//                       // Add navigation to favorites
//                     },
//                     isDark: isDark,
//                   ),
//                   _buildMenuItem(
//                     context,
//                     title: 'Settings',
//                     icon: Icons.settings_rounded,
//                     onTap: () {
//                       Navigator.pop(context);
//                       // Add navigation to settings
//                     },
//                     isDark: isDark,
//                   ),
//                 ],
//               ),
//             ),

//             // Bottom section with theme toggle
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: isDark ? Colors.black12 : Colors.grey.shade50,
//                 border: Border(
//                   top: BorderSide(
//                     color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
//                     width: 1,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
//                     color: primaryColor,
//                     size: 20,
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Text(
//                       'Dark Mode',
//                       style: TextStyle(
//                         color: isDark ? Colors.white : Colors.black87,
//                         fontFamily: 'Poppins',
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                   Switch(
//                     value: isDark,
//                     activeColor: primaryColor,
//                     onChanged: (value) {
//                       themeViewModel.toggleTheme();
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             // App info at bottom
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 'TrollPro Max v1.0.0',
//                 style: TextStyle(
//                   color: isDark ? Colors.grey : Colors.grey.shade700,
//                   fontSize: 12,
//                   fontFamily: 'Poppins',
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Build the user profile header section
//   Widget _buildProfileHeader(BuildContext context, bool isDark) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//       child: Row(
//         children: [
//           // App logo or user avatar
//           Container(
//             width: 56,
//             height: 56,
//             decoration: BoxDecoration(
//               color: isDark ?
//                 AppTheme.darkPrimaryColor.withOpacity(0.2) :
//                 AppTheme.primaryColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(
//               Icons.celebration,
//               color: isDark ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
//               size: 28,
//             ),
//           ),
//           const SizedBox(width: 16),
//           // App title and tagline
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'TrollPro Max',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: isDark ? Colors.white : Colors.black87,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//                 Text(
//                   'The ultimate troll app',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Close button
//           IconButton(
//             icon: Icon(
//               Icons.close_rounded,
//               color: isDark ? Colors.white70 : Colors.black54,
//             ),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Build a menu item
//   Widget _buildMenuItem(
//     BuildContext context, {
//     required String title,
//     required IconData icon,
//     required VoidCallback onTap,
//     required bool isDark,
//     bool isActive = false,
//   }) {
//     final primaryColor = isDark ? AppTheme.darkPrimaryColor : AppTheme.primaryColor;
//     final textColor = isActive
//         ? primaryColor
//         : (isDark ? Colors.white : Colors.black87);
//     final bgColor = isActive
//         ? (isDark ? primaryColor.withOpacity(0.15) : primaryColor.withOpacity(0.1))
//         : Colors.transparent;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: bgColor,
//               borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   icon,
//                   color: isActive ? primaryColor : textColor.withOpacity(0.7),
//                   size: 22,
//                 ),
//                 const SizedBox(width: 16),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: textColor,
//                     fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//                 if (isActive) ...[
//                   const Spacer(),
//                   Container(
//                     width: 6,
//                     height: 24,
//                     decoration: BoxDecoration(
//                       color: primaryColor,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
