import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';


class BaseController extends FullLifeCycleController {
  RxBool isLoading = false.obs;
  static final share = BaseController();

  void showLoader({bool barrierDismissible = true}) async {
    if (isLoading.value) return;
    if (Get.isSnackbarOpen) {
      try {
        Get.back();
      } catch (e) {
        Loggers.error("Error closing snackbar: $e");
      }
    }
    isLoading.value = true;
    try {
      await Get.dialog(const LoaderWidget(),
          barrierDismissible: barrierDismissible);
    } catch (e) {
      Loggers.error("Error showing dialog: $e");
    }
    isLoading.value = false;
  }

  void stopLoader() {
    if (Get.isDialogOpen == true) {
      try {
        Navigator.of(Get.overlayContext!).pop();
      } catch (e) {
        try {
          Get.back();
        } catch (err) {
          Loggers.error("Error closing loader dialog: $err");
        }
      }
    }
  }

  void showSnackBar(String? title, {int second = 2}) {
    if (Get.isSnackbarOpen) {
      return;
    }

    Get.rawSnackbar(
      backgroundColor: blackPure(Get.context!),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(15),
      borderRadius: 10,
      isDismissible: true,
      duration: Duration(seconds: second),
      snackPosition: SnackPosition.TOP,
      messageText: Text(title?.capitalizeFirst?.tr ?? '',
          style: TextStyleCustom.outFitRegular400(
              color: whitePure(Get.context!), fontSize: 17)),
    );
  }

  void stopSnackBar() {
    if (Get.isSnackbarOpen) {
      Get.back();
    }
  }
}
