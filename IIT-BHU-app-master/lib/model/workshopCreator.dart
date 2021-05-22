import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iit_app/data/internet_connection_interceptor.dart';
import 'package:iit_app/model/appConstants.dart';
import 'package:iit_app/ui/dialogBoxes.dart';
import 'package:iit_app/model/built_post.dart';
import 'package:built_collection/built_collection.dart';

class WorkshopCreater {
  String title;
  String description;
  int clubId;
  String date;
  String time;
  // ignore: non_constant_identifier_names
  bool is_workshop;
  String location;
  String latitude;
  String longitude;
  String audience;
  List<int> contactIds = [];
  Map<int, String> contactNameofId = {};
  Map<int, String> tagNameofId = {};
  String link;

  WorkshopCreater({String editingDate, String editingTime}) {
    if (editingDate == null) {
      date = convertDate(DateTime.now());
      time = converTime(TimeOfDay.now());
    } else {
      date = editingDate;
      time = editingTime;
    }
  }
  String convertDate(DateTime date) {
    return date.toString().substring(0, 10);
  }

  String converTime(TimeOfDay time) {
    return time.toString().substring(10, 15);
  }

  static String nameOfContact(String fullName) {
    print(fullName);
    var name = fullName.trim().split(' ');
    if (name.length < 2) return fullName;
    name = name.sublist(0, 2);
    return (name[0] + ' ' + name[1]);
  }

//one should be null between club and entity
  Future create({
    @required BuildContext context,
    @required ClubListPost club,
    @required EntityListPost entity,
    MemoryImage image,
  }) async {
    var nullCount = 0;
    if (club == null) nullCount++;
    if (entity == null) nullCount++;

    assert(
        nullCount == 1,
        nullCount == 0
            ? 'entity and club both should not be null'
            : 'one should be null between club and entity');

    bool _created = false;

    var newWorkshop = BuiltWorkshopCreatePost((b) => b
          ..title = title
          ..description = description
          ..date = date
          ..time = time
          ..is_workshop = is_workshop
          ..location = location
          ..latitude = latitude
          ..longitude = longitude
          ..audience = audience
          ..contacts = contactIds.build().toBuilder()
          ..tags = tagNameofId.keys.toList().build().toBuilder()
        // ..link = link
        );

    if (club != null) {
      await AppConstants.service
          .createClubWorkshop(club.id, AppConstants.djangoToken, newWorkshop)
          .then((value) async {
        if (value.isSuccessful) {
          print('Created!');
          _updateWorkshopWithImage(value.body['id'], image);
          await CreatePageDialogBoxes.showSuccesfulDialog(context: context);
          _created = true;
        }
      }).catchError((onError) {
        if (onError is InternetConnectionException) {
          AppConstants.internetErrorFlushBar.showFlushbar(context);
          return;
        }
        print('Error printing CREATED workshop: ${onError.toString()}');
      });
    } else if (entity != null) {
      await AppConstants.service
          .createEntityWorkshop(
              entity.id, AppConstants.djangoToken, newWorkshop)
          .then((value) async {
        if (value.isSuccessful) {
          print('Created!');
          await _updateWorkshopWithImage(value.body['id'], image);
          await CreatePageDialogBoxes.showSuccesfulDialog(context: context);
          _created = true;
        }
      }).catchError((onError) {
        if (onError is InternetConnectionException) {
          AppConstants.internetErrorFlushBar.showFlushbar(context);
          return;
        }
        print('Error printing CREATED workshop: ${onError.toString()}');
      });
    }

    if (_created) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', ModalRoute.withName('/root'));
    }
  }

  Future _updateWorkshopWithImage(int workshopId, MemoryImage image) async {
    final imageUrl = await _uploadImageToFirestore(image, workshopId);
    if (imageUrl != null) {
      await AppConstants.service
          .updateWorkshopByPatch(
              workshopId,
              AppConstants.djangoToken,
              BuiltWorkshopDetailPost((b) => b
                ..title = title
                ..date = date
                ..image_url = imageUrl
                ..is_workshop = is_workshop))
          .then((value) {
        print("image url updated successfully");
      }).catchError((err) {
        print('error in updating image url: $err');
      });
    }
  }

  static Future<String> _uploadImageToFirestore(
      MemoryImage memoryImage, int workshopId) async {
    if (memoryImage == null) return null;

    final storageRef = FirebaseStorage.instance.ref().child('workshops');
    final uploadTask =
        storageRef.child('$workshopId').putData(memoryImage.bytes);

    return await uploadTask.then((val) async => await val.ref.getDownloadURL(),
        onError: (err) {
      print('image could not be uploaded : $err');
      return null;
    });
  }

  static Future<void> deleteImageFromFirestore(String imageUrl) async {
    if (imageUrl == null) return;
    try {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
    } catch (e) {
      print('image could not be deleted: ${e.toString()}');
    }
  }

  Future<bool> edit({
    @required BuildContext context,
    @required BuiltWorkshopDetailPost widgetWorkshopData,
    NetworkImage oldImage,
    MemoryImage newImage,
  }) async {
    bool _edited = false;

    final editedWorkshop = BuiltWorkshopDetailPost((b) => b
          ..title = title
          ..description = description
          ..date = date
          ..time = time
          ..is_workshop = is_workshop
          ..location = location
          ..latitude = latitude
          ..longitude = longitude
          ..audience = audience
        // ..link = link
        );
    await AppConstants.service
        .updateWorkshopByPatch(
            widgetWorkshopData.id, AppConstants.djangoToken, editedWorkshop)
        .catchError((onError) {
      print('Error editing workshop: ${onError.toString()}');
      CreatePageDialogBoxes.showUnsuccessfulDialog(context: context);
    }).then((value) async {
      if (value.isSuccessful) {
        print('Edited!');
        if (widgetWorkshopData.image_url != null &&
            widgetWorkshopData.image_url.isNotEmpty &&
            oldImage == null) {
          await deleteImageFromFirestore(widgetWorkshopData.image_url);
        }

        await _updateWorkshopWithImage(widgetWorkshopData.id, newImage);

        await CreatePageDialogBoxes.showSuccesfulDialog(
            context: context, isEditing: true);
        _edited = true;
      }
    }).catchError((onError) {
      if (onError is InternetConnectionException) {
        AppConstants.internetErrorFlushBar.showFlushbar(context);
        return;
      }
      print('Error printing EDITED workshop: ${onError.toString()}');
    });

    await AppConstants.service
        .updateContacts(
      widgetWorkshopData.id,
      AppConstants.djangoToken,
      BuiltContacts(
        (b) => b..contacts = contactIds.build().toBuilder(),
      ),
    )
        .catchError((onError) {
      if (onError is InternetConnectionException) {
        AppConstants.internetErrorFlushBar.showFlushbar(context);
      }
      print('Error editing contacts in edited workshop: ${onError.toString()}');
    });

    await AppConstants.service
        .updateTags(
            widgetWorkshopData.id,
            AppConstants.djangoToken,
            BuiltTags(
              (b) => b..tags = tagNameofId.keys.toList().build().toBuilder(),
            ))
        .catchError((onError) {
      if (onError is InternetConnectionException) {
        AppConstants.internetErrorFlushBar.showFlushbar(context);
      }
      print('Error editing tags in edited workshop: ${onError.toString()}');
    });
    return _edited;
  }
}
