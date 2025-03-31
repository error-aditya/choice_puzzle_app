  // Future<Map<String, int>?> _showCustomSizeDialog() async {
  //   final TextEditingController rowsController = TextEditingController();
  //   final TextEditingController colsController = TextEditingController();

  //   return await showDialog<Map<String, int>>(
  //     context: context,
  //     builder: (context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         backgroundColor: Colors.transparent,
  //         child: Stack(
  //           alignment: Alignment.center,
  //           children: [
  //             Container(
  //               padding: EdgeInsets.all(20),
  //               decoration: BoxDecoration(
  //                 gradient: LinearGradient(
  //                   colors: [Color(0xFF514A9D), Color(0xFF24C6DC)],
  //                   begin: Alignment.topLeft,
  //                   end: Alignment.bottomRight,
  //                 ),
  //                 borderRadius: BorderRadius.circular(20),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.5),
  //                     blurRadius: 10,
  //                     offset: Offset(0, 5),
  //                   ),
  //                 ],
  //               ),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Text(
  //                     "Choose Your Puzzle",
  //                     style: GoogleFonts.poppins(
  //                       fontSize: 22,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                   SizedBox(height: 15),
  //                   TextField(
  //                     controller: rowsController,
  //                     maxLength: 2,
  //                     keyboardType: TextInputType.number,
  //                     decoration: InputDecoration(
  //                       hintText: 'Enter Rows',
  //                       hoverColor: Colors.grey,
  //                       floatingLabelStyle: TextStyle(
  //                         color: Colors.black,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                       filled: true,
  //                       fillColor: Colors.white.withOpacity(0.8),
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(height: 10),
  //                   TextField(
  //                     controller: colsController,
  //                     maxLength: 2,
  //                     keyboardType: TextInputType.number,
  //                     decoration: InputDecoration(
  //                       hoverColor: Colors.grey,
  //                       hintText: "Enter Columns",
  //                       filled: true,
  //                       fillColor: Colors.white.withValues(
  //                         red: .8,
  //                         green: .8,
  //                         blue: .8,
  //                       ),
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(height: 20),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                     children: [
  //                       ElevatedButton(
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.redAccent,
  //                           padding: EdgeInsets.symmetric(
  //                             horizontal: 20,
  //                             vertical: 10,
  //                           ),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                           ),
  //                         ),
  //                         onPressed: () => Navigator.pop(context),
  //                         child: Text("Cancel", style: TextStyle(fontSize: 18)),
  //                       ),
  //                       ElevatedButton(
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.greenAccent[700],
  //                           padding: EdgeInsets.symmetric(
  //                             horizontal: 20,
  //                             vertical: 10,
  //                           ),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                           ),
  //                         ),
  //                         onPressed: () {
  //                           final int? rows = int.tryParse(rowsController.text);
  //                           final int? cols = int.tryParse(colsController.text);

  //                           if (rows != null &&
  //                               cols != null &&
  //                               rows > 0 &&
  //                               cols > 0) {
  //                             Navigator.pop(context, {
  //                               'rows': rows,
  //                               'cols': cols,
  //                             });
  //                           }
  //                         },
  //                         child: Text("Start", style: TextStyle(fontSize: 18)),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }