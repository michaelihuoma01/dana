// import 'dart:io';

// import 'package:dana/utilities/filters.dart';
// import 'package:flutter/material.dart';

// class LiquidSwipePagesService {
//   static List<Container> getImageFilteredPaged(
//       {@required File imageFile,
//       @required bool isCrop,
//       @required double height,
//       @required double width}) {
//     final Image image = Image(image: FileImage(File('${imageFile.path}')));

//     List<Container> pages = [];
//     filters.forEach((filter) {
//       Container colorFilterPage = Container(
//         height: height,
//         width: width,
//         child: ColorFiltered(
//           colorFilter: ColorFilter.matrix(filter.matrixValues),
//           child: Container(
//               decoration: BoxDecoration(
//             // color: Colors.white,
//             image: DecorationImage(
//               fit: (isCrop == true) ? BoxFit.cover : BoxFit.contain,
//               // alignment: FractionalOffset.topCenter,
//               image: FileImage(imageFile),
//             ),
//           )),
//         ),
//       );
//       pages.add(colorFilterPage);
//     });
//     return pages;
//   }
// }
