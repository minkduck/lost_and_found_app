import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GeneratorQrCode extends StatefulWidget {
  final String data;

  const GeneratorQrCode({Key? key, required this.data}) : super(key: key);

  @override
  State<GeneratorQrCode> createState() => _GeneratorQrCodeState();
}

class _GeneratorQrCodeState extends State<GeneratorQrCode> {
  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: widget.data.toString(),
      padding: const EdgeInsets.all(0),
      foregroundColor: AppColors.primaryColor,
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: const Size(100, 100),
      ),
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.circle,
      ),
    );
  }
}
