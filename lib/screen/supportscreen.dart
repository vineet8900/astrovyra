import 'dart:io';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Supportmodel.dart/supportmodel.dart';
import 'package:astrokavach/model/supportlistmodel/supportlistmodel.dart';
import 'package:astrokavach/screen/support_summary.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // --- STATE VARIABLES ---
  List<SupportType>? _supportTypes;
  List<SupportTicket>? _tickets;
  bool _isLoading = true;
  String? _errorMessage;
  ReusableFunction reusableFunction = ReusableFunction();

  // --- CONTROLLERS ---
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllData();
    ReusableFunction reusableFunction = ReusableFunction();
    // Dono APIs ko call karein
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// Back button press handle karne ke liye confirmation dialog

  /// Dono API calls (Types aur Ticket List) ko ek saath fetch karta hai
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Future.wait ka use karke dono calls parallel mein chalayein
      final results = await Future.wait([
        AstroApiService.fetchSupportTypes(),
        AstroApiService.fetchSupportTickets(),
      ]);

      if (mounted) {
        setState(() {
          _supportTypes = results[0] as List<SupportType>?;
          _tickets = results[1] as List<SupportTicket>?;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load support data. Please try again.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Screen ki body ko build karne ke liye helper widget
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.grey));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadAllData,
              child: const Text("Retry"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            )
          ],
        ),
      );
    }

    if (_tickets == null || _tickets!.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAllData,
        child: ListView(
          children: const [
            SizedBox(height: 200),
            Center(child: Text("No support tickets found.")),
          ],
        ),
      );
    }

    // Agar tickets hain to ListView dikhayein
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _tickets!.length,
        itemBuilder: (context, index) {
          final ticket = _tickets![index];
          return _TicketListItem(ticket: ticket);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: 'support'.tr,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey.shade300,
              height: 1.0,
            ),
          ),
          actions: [],
        ),
        body: _buildBody(), // Body ko alag function se build karein
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_isLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Loading support options...")));
            } else if (_supportTypes != null && _supportTypes!.isNotEmpty) {
              _showSubmitDetailsDialog(context, _supportTypes!);
            } else {
              //  ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text(_errorMessage ?? "Could not load support options."))
              // );
            }
          },
          backgroundColor: CustomStyles.pinki,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
    );
  }

  void _showSubmitDetailsDialog(
      BuildContext context, List<SupportType> supportTypes) {
    _subjectController.clear();
    _messageController.clear();

    String? selectedSupportTypeValue;
    String? localSelectedFileName;
    File? documentFile; // File object store karein

    // Validation error messages
    String? subjectError;
    String? supportTypeError;
    String? messageError;
    String? fileError;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Center(
                        child: Text("Submit Details",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      const _FormLabel(label: "Subject"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          hintText: "Subject",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: subjectError != null
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: subjectError != null
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: subjectError != null
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        onChanged: (value) {
                          if (subjectError != null && value.trim().isNotEmpty) {
                            setState(() {
                              subjectError = null;
                            });
                          }
                        },
                      ),
                      if (subjectError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subjectError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 12),
                      const _FormLabel(label: "Support Type"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: supportTypeError != null
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: supportTypeError != null
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: supportTypeError != null
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        hint: const Text("Select Support"),
                        value: selectedSupportTypeValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedSupportTypeValue = newValue;
                            if (supportTypeError != null && newValue != null) {
                              supportTypeError = null;
                            }
                          });
                        },
                        items: supportTypes.map<DropdownMenuItem<String>>(
                          (SupportType type) {
                            return DropdownMenuItem<String>(
                              value: type.value,
                              child: Text(type.name),
                            );
                          },
                        ).toList(),
                      ),
                      if (supportTypeError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          supportTypeError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 12),
                      const _FormLabel(label: "Message"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Message",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: messageError != null
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: messageError != null
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: messageError != null
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        onChanged: (value) {
                          if (messageError != null && value.trim().isNotEmpty) {
                            setState(() {
                              messageError = null;
                            });
                          }
                        },
                      ),
                      if (messageError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          messageError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 12),
                      const Text("Upload File",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          try {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                            );

                            if (result != null &&
                                result.files.single.path != null) {
                              PlatformFile file = result.files.first;
                              if (file.size > 10 * 1024 * 1024) {
                                // 10MB limit
                                setState(() {
                                  fileError =
                                      "File size must be less than 10MB";
                                });
                                return;
                              }
                              setState(() {
                                localSelectedFileName = file.name;
                                documentFile = File(file.path!);
                                fileError =
                                    null; // Clear file error when valid file is selected
                              });
                            }
                          } catch (e) {
                            setState(() {
                              fileError = "Error selecting file";
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: fileError != null
                                  ? Colors.red
                                  : (localSelectedFileName != null
                                      ? Colors.green
                                      : Colors.grey),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  localSelectedFileName ?? "Choose File",
                                  style: TextStyle(
                                    color: fileError != null
                                        ? Colors.red
                                        : (localSelectedFileName != null
                                            ? Colors.green.shade800
                                            : Colors.black54),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                fileError != null
                                    ? Icons.error
                                    : (localSelectedFileName != null
                                        ? Icons.check_circle
                                        : Icons.cloud_upload_outlined),
                                color: fileError != null
                                    ? Colors.red
                                    : (localSelectedFileName != null
                                        ? Colors.green
                                        : Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (fileError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          fileError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.black),
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                "Close",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomStyles.pinki,
                                  foregroundColor: Colors.black),
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      // Clear previous errors
                                      setState(() {
                                        subjectError = null;
                                        supportTypeError = null;
                                        messageError = null;
                                        fileError = null;
                                      });

                                      // Validate fields
                                      bool hasErrors = false;

                                      if (_subjectController.text
                                          .trim()
                                          .isEmpty) {
                                        setState(() {
                                          subjectError = "Subject is required";
                                        });
                                        hasErrors = true;
                                      }

                                      if (selectedSupportTypeValue == null) {
                                        setState(() {
                                          supportTypeError =
                                              "Please select support type";
                                        });
                                        hasErrors = true;
                                      }

                                      if (_messageController.text
                                          .trim()
                                          .isEmpty) {
                                        setState(() {
                                          messageError = "Message is required";
                                        });
                                        hasErrors = true;
                                      }

                                      if (hasErrors) {
                                        return;
                                      }

                                      setState(() {
                                        isSubmitting = true;
                                      });

                                      try {
                                        final response = await AstroApiService
                                            .submitSupportTicket(
                                          subject:
                                              _subjectController.text.trim(),
                                          type: selectedSupportTypeValue!,
                                          message:
                                              _messageController.text.trim(),
                                          documentFile: documentFile,
                                        );

                                        if (mounted) {
                                          setState(() {
                                            isSubmitting = false;
                                          });

                                          if (response != null &&
                                              response.success) {
                                            Navigator.of(context)
                                                .pop(); // Dialog band karein
                                            _loadAllData(); // List ko refresh karein
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    "Ticket submitted successfully!"),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          } else {
                                            // --- MODIFICATION START ---
                                            // Dialog band karein
                                            Navigator.of(context).pop();
                                            // Red SnackBar dikhayein
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    "You have already raised an issue for this type."),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            // --- MODIFICATION END ---
                                          }
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          setState(() {
                                            isSubmitting = false;
                                            // Show your default file error message
                                            fileError =
                                                "The document must be a file of type: pdf, jpg, jpeg, png";
                                          });
                                        }
                                      }
                                    },
                              child: isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 3, color: Colors.black))
                                  : const Text(
                                      "Submit",
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Ticket item ke liye ek alag se widget
class _TicketListItem extends StatelessWidget {
  final SupportTicket ticket;
  const _TicketListItem({required this.ticket});

  Widget _getStatusChip(String status) {
    Color chipColor;
    Color textColor = Colors.white;
    String statusText = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'open':
        chipColor = Colors.green;
        break;
      case 'closed':
        chipColor = Colors.red;
        break;
      case 'in-progress':
        chipColor = Colors.orange;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(statusText,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
      backgroundColor: chipColor,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: Colors.grey.shade500, width: 1), // Grey border line
      ),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // NAYI SCREEN PE NAVIGATE KAREIN
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SupportDetailsScreen(ticketId: ticket.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          const TextSpan(
                              text: 'Ticket_Number:',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: ticket.ticketNumber,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                  ),
                  _getStatusChip(ticket.status),
                ],
              ),
              //const Divider(height: 20),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    const TextSpan(
                        text: 'Subject :',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: ticket.subject,
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    const TextSpan(
                        text: 'Type: ',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: ticket.type,
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Date: ${ticket.createdAt}',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Form labels ke liye helper widget
class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
            fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14),
        children: const <TextSpan>[
          TextSpan(
              text: ' *',
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
