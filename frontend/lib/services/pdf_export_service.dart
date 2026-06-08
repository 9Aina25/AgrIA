import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfExportService {
  static Future<File> generateDiagnosisPdf({
    required String userName,
    required String plantName,
    required String diseaseName,
    required double confidence,
    required List<String> symptoms,
    required Map<String, List<String>> treatments,
    required DateTime date,
    String? additionalNotes,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => [
          _buildHeader(userName, date),
          pw.SizedBox(height: 20),
          _buildPlantInfo(plantName),
          pw.SizedBox(height: 20),
          _buildDiagnosisCard(diseaseName, confidence),
          pw.SizedBox(height: 20),
          _buildSymptomsSection(symptoms),
          pw.SizedBox(height: 20),
          _buildTreatmentsSection(treatments),
          if (additionalNotes != null) ...[
            pw.SizedBox(height: 20),
            _buildNotesSection(additionalNotes),
          ],
          pw.SizedBox(height: 30),
          _buildFooter(),
        ],
      ),
    );

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/diagnostic_agria_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  static pw.Widget _buildHeader(String userName, DateTime date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('AgrIA',
                style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green800)),
            pw.Text(
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Text('Rapport de diagnostic végétal',
            style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey)),
        pw.Divider(thickness: 2),
        pw.SizedBox(height: 10),
        pw.Text('Patient : $userName', style: pw.TextStyle(fontSize: 14)),
      ],
    );
  }

  static pw.Widget _buildPlantInfo(String plantName) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        children: [
          pw.Text('', style: pw.TextStyle(fontSize: 32)),
          pw.SizedBox(width: 15),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Plante diagnostiquée',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
              pw.Text(plantName,
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDiagnosisCard(String diseaseName, double confidence) {
    final isHighConfidence = confidence >= 80;
    final bgColor = isHighConfidence ? PdfColors.green50 : PdfColors.orange50;
    final borderColor =
        isHighConfidence ? PdfColors.green300 : PdfColors.orange300;
    final textColor =
        isHighConfidence ? PdfColors.green800 : PdfColors.orange800;

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: borderColor),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Diagnostic',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text(diseaseName,
              style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: textColor)),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Text('Niveau de confiance : '),
              pw.Text('${confidence.toStringAsFixed(1)}%',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: textColor)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.LinearProgressIndicator(
            value: confidence / 100,
            backgroundColor: PdfColors.grey200,
            valueColor: isHighConfidence ? PdfColors.green : PdfColors.orange,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSymptomsSection(List<String> symptoms) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(' Symptômes observés',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        ...symptoms.map((symptom) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: pw.TextStyle(fontSize: 14)),
                  pw.Expanded(
                      child:
                          pw.Text(symptom, style: pw.TextStyle(fontSize: 14))),
                ],
              ),
            )),
      ],
    );
  }

  static pw.Widget _buildTreatmentsSection(
      Map<String, List<String>> treatments) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(' Traitements recommandés',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        if (treatments.containsKey('preventif'))
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(' Traitements préventifs :',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 15)),
              pw.SizedBox(height: 8),
              ...treatments['preventif']!.map((t) => pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10, bottom: 6),
                    child: pw.Text('• $t', style: pw.TextStyle(fontSize: 13)),
                  )),
              pw.SizedBox(height: 12),
            ],
          ),
        if (treatments.containsKey('curatif'))
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Traitements curatifs :',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 15)),
              pw.SizedBox(height: 8),
              ...treatments['curatif']!.map((t) => pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10, bottom: 6),
                    child: pw.Text('• $t', style: pw.TextStyle(fontSize: 13)),
                  )),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildNotesSection(String notes) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(' Notes supplémentaires',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: pw.BorderRadius.circular(8)),
          child: pw.Text(notes, style: pw.TextStyle(fontSize: 13)),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 15),
        pw.Text('Ce rapport a été généré automatiquement par AgrIA',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            textAlign: pw.TextAlign.center),
        pw.SizedBox(height: 5),
        pw.Text('Intelligence Artificielle pour l\'Agriculture',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            textAlign: pw.TextAlign.center),
        pw.SizedBox(height: 5),
        pw.Text('www.agria.com',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            textAlign: pw.TextAlign.center),
      ],
    );
  }

  static Future<void> sharePdf(File file) async {
    await Share.shareXFiles([XFile(file.path)],
        text: '📊 Rapport de diagnostic AgrIA');
  }

  static Future<void> printPdf(File file) async {
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => file.readAsBytes());
  }
}
