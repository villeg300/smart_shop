import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

class NavigationController extends GetxController {
  final RxInt cureentIndex = 0.obs;

  void changeIndex(int index) {
    cureentIndex.value = index;
  }
}
