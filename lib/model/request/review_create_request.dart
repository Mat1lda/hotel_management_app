import 'dart:io';

import 'package:dio/dio.dart';

class ReviewCreateRequest {
  final String details;
  final int star;
  final String type;
  final int idCustomer;
  final List<File> images;

  const ReviewCreateRequest({
    required this.details,
    required this.star,
    required this.type,
    required this.idCustomer,
    this.images = const [],
  });

  Future<FormData> toFormData() async {
    final form = FormData();
    form.fields
      ..add(MapEntry('details', details))
      ..add(MapEntry('star', star.toString()))
      ..add(MapEntry('type', type))
      ..add(MapEntry('idCustomer', idCustomer.toString()));

    for (final f in images) {
      final fileName = f.path.split(Platform.pathSeparator).last;
      form.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            f.path,
            filename: fileName,
          ),
        ),
      );
    }

    return form;
  }
}


