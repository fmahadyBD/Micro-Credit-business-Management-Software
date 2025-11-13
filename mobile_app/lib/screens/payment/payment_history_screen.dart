import 'package:flutter/material.dart';
import 'package:mobile_app/models/product_model.dart';
import 'package:mobile_app/screens/installment/installment_model.dart';
import 'package:mobile_app/screens/installment/installment_service.dart';
import 'package:mobile_app/screens/installment/member_model.dart'; // Use this MemberModel
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mobile_app/models/payment_schedule_model.dart';
import 'package:mobile_app/services/payment_schedule_service.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final int? installmentId;
  final InstallmentModel? installment;
  
  const PaymentHistoryScreen({
    Key? key, 
    this.installmentId,
    this.installment,
  }) : super(key: key);

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final PaymentScheduleService _paymentService = PaymentScheduleService();
  final InstallmentService _installmentService = InstallmentService();

  List<PaymentScheduleModel> _payments = [];
  InstallmentModel? _installment;
  InstallmentBalanceModel? _balance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.installmentId != null) {
      _loadPaymentHistory();
    }
    // If installment is passed, use it directly
    if (widget.installment != null) {
      _installment = widget.installment;
    }
  }

  Future<void> _loadPaymentHistory() async {
    setState(() => _isLoading = true);
    try {
      final payments = await _paymentService.getPaymentsByInstallmentId(widget.installmentId!);
      
      // Only fetch installment if not already passed
      if (widget.installment == null) {
        final installment = await _installmentService.getInstallmentById(widget.installmentId!);
        setState(() {
          _installment = installment;
        });
      } else {
        // Use the passed installment
        setState(() {
          _installment = widget.installment;
        });
      }
      
      final balance = await _paymentService.getInstallmentBalance(widget.installmentId!);
      
      setState(() {
        _payments = payments;
        _balance = balance;
      });
    } catch (e) {
      _showErrorSnackBar('Error loading history: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePDF() async {
    if (_installment == null || _balance == null) return;

    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Payment Schedule Report',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
                pw.Divider(thickness: 2),
              ],
            ),
          ),
          
          pw.SizedBox(height: 20),
          
          // Member Info
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Member Information',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 12),
                _buildPdfRow('Name', _installment!.member?.name ?? 'N/A'),
                _buildPdfRow('Phone', _installment!.member?.phone ?? 'N/A'),
                // _buildPdfRow('Address', _installment!.member?.address ?? 'N/A'),
                _buildPdfRow('Product', _installment!.product?.name ?? 'N/A'),
                _buildPdfRow('Installment ID', '#${_installment!.id}'),
              ],
            ),
          ),
          
          pw.SizedBox(height: 20),
          
          // Balance Summary
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Payment Summary',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 12),
                _buildPdfRow('Total Amount', '৳${_balance!.totalAmount.toStringAsFixed(2)}'),
                _buildPdfRow('Total Paid', '৳${_balance!.totalPaid.toStringAsFixed(2)}', 
                  valueColor: PdfColors.green700),
                _buildPdfRow('Remaining Balance', '৳${_balance!.remainingBalance.toStringAsFixed(2)}', 
                  valueColor: PdfColors.red700),
                pw.Divider(),
                _buildPdfRow('Monthly Amount', '৳${_balance!.monthlyAmount.toStringAsFixed(2)}'),
                _buildPdfRow('Total Payments', '${_balance!.totalPayments} times'),
                _buildPdfRow('Status', _balance!.status, 
                  valueColor: _balance!.status == 'COMPLETED' ? PdfColors.green700 : PdfColors.blue700),
              ],
            ),
          ),
          
          pw.SizedBox(height: 30),
          
          // Payment History Table
          pw.Text(
            'Payment History',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          
          _payments.isEmpty
              ? pw.Text('No payment records found')
              : pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _buildTableHeader('#'),
                        _buildTableHeader('Date'),
                        _buildTableHeader('Amount'),
                        _buildTableHeader('Agent'),
                        _buildTableHeader('Status'),
                        _buildTableHeader('Notes'),
                      ],
                    ),
                    // Data rows
                    ..._payments.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final payment = entry.value;
                      return pw.TableRow(
                        children: [
                          _buildTableCell(index.toString()),
                          _buildTableCell(DateFormat('dd/MM/yyyy').format(payment.paymentDate)),
                          _buildTableCell('৳${payment.paidAmount.toStringAsFixed(2)}'),
                          _buildTableCell(payment.agentName),
                          _buildTableCell(payment.status),
                          _buildTableCell(payment.notes ?? '-'),
                        ],
                      );
                    }).toList(),
                  ],
                ),
          
          pw.SizedBox(height: 30),
          
          // Footer
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Thank you for your business',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
              pw.Text(
                'Page ${context.pageNumber}/${context.pagesCount}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ],
          ),
        ],
      ),
    );

    // Show PDF preview
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'payment_schedule_${_installment!.id}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  pw.Widget _buildPdfRow(String label, String value, {PdfColor? valueColor}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 12)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          if (_installment != null && _payments.isNotEmpty)
            IconButton(
              icon: Icon(Icons.picture_as_pdf),
              onPressed: _generatePDF,
              tooltip: 'Generate PDF Report',
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    // Use passed installment if available, otherwise use fetched one
    final displayInstallment = _installment ?? widget.installment;
    
    if (displayInstallment == null) {
      return Center(
        child: Text('No installment selected'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPaymentHistory,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Enhanced Summary Card with Product and Member details
          _buildEnhancedSummaryCard(displayInstallment),
          
          SizedBox(height: 20),
          
          // Payment History List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Records',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${_payments.length} payments',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          if (_payments.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'No payment records yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._payments.map((payment) => _buildPaymentCard(payment)).toList(),
        ],
      ),
    );
  }

  Widget _buildEnhancedSummaryCard(InstallmentModel installment) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[50]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag, color: Colors.purple[700], size: 28),
                SizedBox(width: 12),
                Text(
                  'Product & Member Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            
            // Product Information
            Text(
              'Product Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            _buildDetailRow('Product Name', installment.product?.name ?? 'N/A'),
            _buildDetailRow('Category', installment.product?.category ?? 'N/A'),
            _buildDetailRow('Price', '৳${installment.product?.price?.toStringAsFixed(2) ?? '0.00'}'),
            
            SizedBox(height: 16),
            
            // Member Information
            Text(
              'Member Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            _buildDetailRow('Member Name', installment.member?.name ?? 'N/A'),
            _buildDetailRow('Phone', installment.member?.phone ?? 'N/A'),
            // _buildDetailRow('Address', installment.member?.address ?? 'N/A'),
            
            if (_balance != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    _buildBalanceRow(
                      'Total Amount', 
                      '৳${_balance!.totalAmount.toStringAsFixed(2)}',
                      Colors.grey[700]!,
                    ),
                    _buildBalanceRow(
                      'Total Paid', 
                      '৳${_balance!.totalPaid.toStringAsFixed(2)}',
                      Colors.green[700]!,
                    ),
                    _buildBalanceRow(
                      'Remaining', 
                      '৳${_balance!.remainingBalance.toStringAsFixed(2)}',
                      Colors.red[700]!,
                    ),
                    Divider(),
                    _buildBalanceRow(
                      'Monthly Amount', 
                      '৳${_balance!.monthlyAmount.toStringAsFixed(2)}',
                      Colors.blue[700]!,
                    ),
                    _buildBalanceRow(
                      'Payments Made', 
                      '${_balance!.totalPayments} times',
                      Colors.grey[600]!,
                    ),
                    _buildBalanceRow(
                      'Status', 
                      _balance!.status,
                      _balance!.status == 'COMPLETED' ? Colors.green[700]! : Colors.blue[700]!,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(PaymentScheduleModel payment) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.payment, color: Colors.green[700]),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '৳${payment.paidAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(payment.paymentDate),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: payment.status == 'COMPLETED' 
                        ? Colors.green[50] 
                        : Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: payment.status == 'COMPLETED' 
                          ? Colors.green[200]! 
                          : Colors.blue[200]!,
                    ),
                  ),
                  child: Text(
                    payment.status,
                    style: TextStyle(
                      color: payment.status == 'COMPLETED' 
                          ? Colors.green[700] 
                          : Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            if (payment.notes != null && payment.notes!.isNotEmpty) ...[
              Divider(height: 20),
              Row(
                children: [
                  Icon(Icons.note_outlined, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      payment.notes!,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            Divider(height: 20),
            
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Collected by: ${payment.agentName}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            
            if (payment.remainingAmount != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Remaining: ৳${payment.remainingAmount!.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}