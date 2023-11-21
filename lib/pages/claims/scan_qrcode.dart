import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lost_and_find_app/widgets/print_data_qrCode.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../utils/snackbar_utils.dart';

class ScanQrCode extends StatefulWidget {
  final String userId;
  const ScanQrCode({Key? key, required this.userId}) : super(key: key);

  @override
  State<ScanQrCode> createState() => _ScanQrCodeState();
}

class _ScanQrCodeState extends State<ScanQrCode> {
  final qrKey = GlobalKey(debugLabel: 'QR');

  Barcode? barcode;
  QRViewController? controller;
  bool isProcessingBarcode = false;

  void setupQrCodeScanner() async {
    if (controller != null) {
      controller!.scannedDataStream.listen((barcode) {
        if (!isProcessingBarcode) {
          isProcessingBarcode = true;
          setState(() {
            this.barcode = barcode;
          });

          if (barcode != null) {
            if (barcode.code == widget.userId) {
              controller!.pauseCamera();
              Future.delayed(Duration(seconds: 1), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrintDataQrCode(
                      result: barcode.code!,
                      userId: widget.userId,
                    ),
                  ),
                );
              });
            } else {
              controller!.pauseCamera();
              isProcessingBarcode = false;
              SnackbarUtils().showError(title: "Error", message: "The qrCode didn't matchs");
              Navigator.pop(context);
            }
          }
        }
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupQrCodeScanner();
  }
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();

    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text("Scan QR Code"),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            buildQrView(context),
            Positioned(bottom: 10, child: buildResult()),
            Positioned(top: 10, child: buildControlButtons()),
          ],
        ),
      ),
    );
  }

  Widget buildQrView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
            borderColor: Theme.of(context).primaryColor,
            borderWidth: 10,
            borderLength: 20,
            borderRadius: 10,
            cutOutSize: MediaQuery.of(context).size.width * 0.8),
      );

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    setupQrCodeScanner();
  }

  Widget buildResult() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white24
      ),
      child: Text(
        barcode != null ? 'Result: ${barcode!.code}' : 'Scan a code',
        maxLines: 3,
      ),
    );
  }

  Widget buildControlButtons() => Container(
    padding: EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.white24
    ),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(onPressed: () async {
          await controller?.toggleFlash();
          setState(() {

          });
        },
            icon: FutureBuilder<bool?>(
              future: controller?.getFlashStatus(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return Icon(
                      snapshot.data! ? Icons.flash_on : Icons.flash_off);
                } else {
                  return Container();
                }
              },
            )),
        IconButton(onPressed: () async {
          await controller?.flipCamera();
          setState(() {

          });
        },
            icon: FutureBuilder(
              future: controller?.getCameraInfo(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return Icon(Icons.switch_camera);
                } else {
                  return Container();
                }
              },
            )),

      ],
    ),
  );
}
