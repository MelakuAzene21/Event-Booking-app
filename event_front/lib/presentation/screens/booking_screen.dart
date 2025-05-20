import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:event_booking_app/data/models/booking_model.dart';
import 'package:event_booking_app/domain/providers/event_provider.dart';
import 'package:event_booking_app/domain/providers/booking_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:event_booking_app/core/config/api_config.dart';
import 'package:event_booking_app/core/utils/secure_storage.dart';
import 'package:event_booking_app/domain/providers/ticket_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String eventId;

  const BookingScreen({super.key, required this.eventId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String? selectedTicketType;
  int ticketCount = 1;
  bool isLoading = false;
  bool showQrCode = false;
  BookingModel? booking;
  String? txRef;

  Future<Map<String, dynamic>?> _getUserProfile() async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      print('Error: No token found in secure storage');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'token=$token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Profile fetch response: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error fetching profile: Status ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> _initializePayment(double amount) async {
    setState(() {
      isLoading = true;
    });

    try {
      final token = await SecureStorage.getToken();
      if (token == null) throw Exception('No authentication token found. Please log in again.');

      print('Initializing payment with amount: $amount, currency: ETB');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/payment/initialize'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'token=$token',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': 'ETB',
        }),
      ).timeout(const Duration(seconds: 10));

      print('Payment initialization response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final paymentData = jsonDecode(response.body);
        final paymentUrl = paymentData['paymentUrl'];
        txRef = paymentData['tx_ref'];

        if (paymentUrl != null) {
          await _showPaymentModal(paymentUrl);
        } else {
          throw Exception('Payment URL not found in response');
        }
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Failed to initialize payment';
        throw Exception('Server error: $errorMessage');
      }
    } catch (e) {
      print('Error initializing payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing payment: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showPaymentModal(String paymentUrl) async {
    bool paymentSuccessful = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(0),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.9,
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(paymentUrl)),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      javaScriptEnabled: true,
                      useShouldOverrideUrlLoading: true,
                      mediaPlaybackRequiresUserGesture: false,
                      cacheEnabled: true,
                      clearCache: false,
                      javaScriptCanOpenWindowsAutomatically: false,
                      resourceCustomSchemes: [],
                    ),
                    android: AndroidInAppWebViewOptions(
                      useHybridComposition: true,
                      hardwareAcceleration: true,
                    ),
                  ),
                  onWebViewCreated: (controller) {
                    print('InAppWebView created');
                  },
                  onLoadStart: (controller, url) {
                    print('InAppWebView loading: $url');
                  },
                  onLoadStop: (controller, url) {
                    print('InAppWebView finished loading: $url');
                  },
                  onLoadError: (controller, url, code, message) {
                    print('InAppWebView error: $code, $message');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error loading payment page: $message')),
                    );
                    Navigator.of(context).pop();
                  },
                  onRenderProcessGone: (controller, details) {
                    print('InAppWebView renderer crashed: $details');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment page crashed. Please try again.')),
                    );
                    Navigator.of(context).pop();
                  },
                  shouldOverrideUrlLoading: (controller, navigationAction) async {
                    final url = navigationAction.request.url.toString();
                    print('Navigating to: $url');
                    if (url.contains('test-payment-receipt') || url.contains('payment-receipt') || url.contains('success')) {
                      paymentSuccessful = true;
                      Navigator.of(context).pop();
                      return NavigationActionPolicy.CANCEL;
                    }
                    if (url.contains('cancel') || url.contains('error')) {
                      Navigator.of(context).pop();
                      return NavigationActionPolicy.CANCEL;
                    }
                    return NavigationActionPolicy.ALLOW;
                  },
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      if (txRef != null) {
                        await _verifyTransaction();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (paymentSuccessful) {
      Future.microtask(() => _verifyTransaction());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment was cancelled or failed')),
      );
    }
  }


Future<void> _verifyTransaction() async {
  if (txRef == null || selectedTicketType == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: Transaction reference or ticket type missing')),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('No authentication token found. Please log in again.');

    final userProfile = await _getUserProfile();
    if (userProfile == null) throw Exception('Failed to fetch user profile');

    final userId = userProfile['_id'];
    print('Verifying transaction with txRef: $txRef, userId: $userId');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/payment/verify-transaction/$txRef'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'token=$token',
      },
      body: jsonEncode({
        'eventId': widget.eventId,
        'ticketType': selectedTicketType,
        'ticketCount': ticketCount,
        'userId': userId,
      }),
    ).timeout(const Duration(seconds: 10));

    print('Transaction verification response: ${response.statusCode}, ${response.body}');

    final contentType = response.headers['content-type'];
    if (contentType == null || !contentType.contains('application/json')) {
      throw Exception('Invalid server response: Expected JSON, received ${contentType ?? 'unknown'}');
    }

    final verifyData = jsonDecode(response.body);

    if (response.statusCode == 200 && verifyData['success']) {
      setState(() {
        booking = BookingModel.fromJson(verifyData['book']);
        showQrCode = true;
      });

      // Invalidate ticketsProvider to ensure fresh data
      ref.invalidate(ticketsProvider);

      // Show success modal
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment Successful!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your booking has been confirmed. You can view your ticket details now.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              QrImageView(
                data: 'TCK-${booking!.id}-${booking!.userId}-${booking!.eventId}',
                size: 150,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Pass temporaryBooking and isBookingProcessing
                  context.push('/tickets', extra: {
                    'temporaryBooking': booking,
                    'isBookingProcessing': true,
                  });
                },
                child: const Text(
                  'View Ticket',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final errorMessage = verifyData['message'] ?? 'Failed to verify transaction';
      throw Exception('Server error: $errorMessage (Status: ${response.statusCode})');
    }
  } catch (e) {
    print('Error verifying transaction: $e');
    String errorMessage;
    if (e.toString().contains('404')) {
      errorMessage = 'Transaction verification endpoint not found. Please contact support.';
    } else if (e.toString().contains('Invalid server response')) {
      errorMessage = 'Invalid server response. Please try again or contact support.';
    } else {
      errorMessage = 'Error verifying transaction: ${e.toString()}';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailsProvider(widget.eventId));
    final bookingState = ref.watch(bookingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Book Your Event',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: eventAsync.when(
        data: (event) {
          if (showQrCode && booking != null) {
            // Success modal handles this, so return empty container
            return Container();
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Name
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Secure your spot for this exciting event!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Ticket Type Dropdown
                      const Text(
                        'Ticket Type',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Select Ticket Type'),
                          ),
                          value: selectedTicketType,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: event.ticketTypes
                              .map((ticket) => DropdownMenuItem(
                                    value: ticket.name,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text('${ticket.name} (\$${ticket.price})'),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTicketType = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Ticket Counter
                      const Text(
                        'Number of Tickets',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: ticketCount > 1
                                ? () {
                                    setState(() {
                                      ticketCount--;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.remove_circle, color: Colors.blueAccent),
                          ),
                          Text(
                            '$ticketCount',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: ticketCount < 10
                                ? () {
                                    setState(() {
                                      ticketCount++;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
                          ),
                        ],
                      ),
                      Slider(
                        value: ticketCount.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: Colors.blueAccent,
                        inactiveColor: Colors.grey[300],
                        onChanged: (value) {
                          setState(() {
                            ticketCount = value.toInt();
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Total Amount
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '\$${selectedTicketType != null ? (event.ticketTypes.firstWhere((t) => t.name == selectedTicketType).price * ticketCount).toStringAsFixed(2) : '0.00'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Error Message
                      if (bookingState.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Error: ${bookingState.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      // Proceed to Payment Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: selectedTicketType == null
                              ? null
                              : () async {
                                  final ticketType = event.ticketTypes.firstWhere((t) => t.name == selectedTicketType);
                                  final totalAmount = ticketType.price * ticketCount;
                                  await _initializePayment(totalAmount);
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blueAccent,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Proceed to Payment',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}