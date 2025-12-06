import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // Replaces share_plus

class ReceiptService {
  /// Generates the receipt PDF and opens the system print/preview dialog
  static Future<void> generateAndShowReceipt({
    required String amount,
    required String currencySymbol,
    required String recipientName,
    required String recipientAccount,
    required String dateStr,
    required String timeStr,
    required String refId,
    required bool isReceiving,
  }) async {
    final pdf = pw.Document();

    // Define colors for PDF
    final PdfColor primaryColor = PdfColor.fromInt(0xFF6200EE);
    final PdfColor successColor = PdfColor.fromInt(0xFF4CAF50);
    final PdfColor textColor = PdfColor.fromInt(0xFF000000);
    final PdfColor grayColor = PdfColor.fromInt(0xFF9E9E9E);

    final statusColor = isReceiving ? successColor : primaryColor;
    final titleText = isReceiving ? 'Money Received' : 'Transfer Successful';
    final amountSign = isReceiving ? '+' : '-';
    final userLabel = isReceiving ? 'From' : 'To';

    // Build PDF Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // --- Header ---
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: statusColor,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(10)),
                ),
                child: pw.Text(
                  "SiBehGoodBank",
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              pw.SizedBox(height: 40),

              // --- Success Icon ---
              pw.Container(
                height: 60,
                width: 60,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: statusColor,
                ),
                child: pw.Center(
                  child: pw.Text(
                    "OK",
                    style: pw.TextStyle(
                        color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // --- Title & Amount ---
              pw.Text(
                titleText,
                style: pw.TextStyle(fontSize: 20, color: grayColor),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                '$amountSign$currencySymbol $amount',
                style: pw.TextStyle(
                  fontSize: 40,
                  fontWeight: pw.FontWeight.bold,
                  color: textColor,
                ),
              ),
              pw.SizedBox(height: 40),

              // --- Divider ---
              pw.Divider(color: grayColor),
              pw.SizedBox(height: 20),

              // --- Details Table ---
              _buildPdfRow(
                  'Transaction Type', isReceiving ? 'Credit' : 'Debit'),
              pw.SizedBox(height: 10),
              _buildPdfRow(userLabel, recipientName),
              pw.SizedBox(height: 10),
              _buildPdfRow('Account', recipientAccount),
              pw.SizedBox(height: 10),
              _buildPdfRow('Date', dateStr),
              pw.SizedBox(height: 10),
              _buildPdfRow('Time', timeStr),
              pw.SizedBox(height: 10),
              _buildPdfRow('Reference ID', refId),

              pw.SizedBox(height: 40),
              pw.Divider(color: grayColor),

              // --- Footer ---
              pw.SizedBox(height: 20),
              pw.Text(
                "Thank you for banking with SiBehGoodBank.",
                style: const pw.TextStyle(color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    // Instead of sharing a file, we invoke the native Print/Preview dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt_$refId', // Filename if user decides to save
    );
  }

  static pw.Widget _buildPdfRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 14),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: PdfColors.black,
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
