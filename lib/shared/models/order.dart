import 'product.dart';

enum OrderFinancialStatus {
  pending,
  authorized,
  partiallyPaid,
  paid,
  partiallyRefunded,
  refunded,
  voided,
  unknown;

  static OrderFinancialStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return OrderFinancialStatus.pending;
      case 'authorized':
        return OrderFinancialStatus.authorized;
      case 'partially_paid':
        return OrderFinancialStatus.partiallyPaid;
      case 'paid':
        return OrderFinancialStatus.paid;
      case 'partially_refunded':
        return OrderFinancialStatus.partiallyRefunded;
      case 'refunded':
        return OrderFinancialStatus.refunded;
      case 'voided':
        return OrderFinancialStatus.voided;
      default:
        return OrderFinancialStatus.unknown;
    }
  }

  String get displayLabel {
    switch (this) {
      case OrderFinancialStatus.pending:
        return 'Payment Pending';
      case OrderFinancialStatus.authorized:
        return 'Authorized';
      case OrderFinancialStatus.partiallyPaid:
        return 'Partially Paid';
      case OrderFinancialStatus.paid:
        return 'Paid';
      case OrderFinancialStatus.partiallyRefunded:
        return 'Partially Refunded';
      case OrderFinancialStatus.refunded:
        return 'Refunded';
      case OrderFinancialStatus.voided:
        return 'Voided';
      case OrderFinancialStatus.unknown:
        return 'Unknown';
    }
  }
}

enum OrderFulfillmentStatus {
  unfulfilled,
  partiallyFulfilled,
  fulfilled,
  restocked,
  pendingFulfillment,
  open,
  inProgress,
  onHold,
  scheduled,
  unknown;

  static OrderFulfillmentStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'unfulfilled':
        return OrderFulfillmentStatus.unfulfilled;
      case 'partially_fulfilled':
        return OrderFulfillmentStatus.partiallyFulfilled;
      case 'fulfilled':
        return OrderFulfillmentStatus.fulfilled;
      case 'restocked':
        return OrderFulfillmentStatus.restocked;
      case 'pending_fulfillment':
        return OrderFulfillmentStatus.pendingFulfillment;
      case 'open':
        return OrderFulfillmentStatus.open;
      case 'in_progress':
        return OrderFulfillmentStatus.inProgress;
      case 'on_hold':
        return OrderFulfillmentStatus.onHold;
      case 'scheduled':
        return OrderFulfillmentStatus.scheduled;
      default:
        return OrderFulfillmentStatus.unknown;
    }
  }

  String get displayLabel {
    switch (this) {
      case OrderFulfillmentStatus.unfulfilled:
        return 'Processing';
      case OrderFulfillmentStatus.partiallyFulfilled:
        return 'Partially Shipped';
      case OrderFulfillmentStatus.fulfilled:
        return 'Delivered';
      case OrderFulfillmentStatus.restocked:
        return 'Restocked';
      case OrderFulfillmentStatus.pendingFulfillment:
        return 'Pending';
      case OrderFulfillmentStatus.open:
        return 'Open';
      case OrderFulfillmentStatus.inProgress:
        return 'Shipped';
      case OrderFulfillmentStatus.onHold:
        return 'On Hold';
      case OrderFulfillmentStatus.scheduled:
        return 'Scheduled';
      case OrderFulfillmentStatus.unknown:
        return 'Unknown';
    }
  }
}

class OrderLineItem {
  final String title;
  final int quantity;
  final String? variantId;
  final String? variantTitle;
  final Money? price;
  final String? imageUrl;

  const OrderLineItem({
    required this.title,
    required this.quantity,
    this.variantId,
    this.variantTitle,
    this.price,
    this.imageUrl,
  });

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    final variant = json['variant'] as Map<String, dynamic>?;
    String? imageUrl;
    if (variant?['image'] != null) {
      imageUrl = (variant!['image'] as Map<String, dynamic>)['url'] as String?;
    }
    return OrderLineItem(
      title: json['title'] as String,
      quantity: json['quantity'] as int,
      variantId: variant?['id'] as String?,
      variantTitle: variant?['title'] as String?,
      price: variant?['price'] != null
          ? Money.fromJson(variant!['price'] as Map<String, dynamic>)
          : null,
      imageUrl: imageUrl,
    );
  }
}

class ShippingAddress {
  final String? firstName;
  final String? lastName;
  final String? address1;
  final String? address2;
  final String? city;
  final String? province;
  final String? country;
  final String? zip;
  final String? phone;

  const ShippingAddress({
    this.firstName,
    this.lastName,
    this.address1,
    this.address2,
    this.city,
    this.province,
    this.country,
    this.zip,
    this.phone,
  });

  String get formatted {
    final parts = <String>[
      if (firstName != null || lastName != null)
        '${firstName ?? ''} ${lastName ?? ''}'.trim(),
      if (address1 != null) address1!,
      if (address2 != null && address2!.isNotEmpty) address2!,
      if (city != null) city!,
      if (province != null) province!,
      if (zip != null) zip!,
      if (country != null) country!,
    ];
    return parts.join(', ');
  }

  Map<String, dynamic> toJson() => {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (address1 != null) 'address1': address1,
        if (address2 != null) 'address2': address2,
        if (city != null) 'city': city,
        if (province != null) 'province': province,
        if (country != null) 'country': country,
        if (zip != null) 'zip': zip,
        if (phone != null) 'phone': phone,
      };

  factory ShippingAddress.fromJson(Map<String, dynamic> json) =>
      ShippingAddress(
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        address1: json['address1'] as String?,
        address2: json['address2'] as String?,
        city: json['city'] as String?,
        province: json['province'] as String?,
        country: json['country'] as String?,
        zip: json['zip'] as String?,
        phone: json['phone'] as String?,
      );
}

class Order {
  final String id;
  final int orderNumber;
  final DateTime processedAt;
  final OrderFinancialStatus financialStatus;
  final OrderFulfillmentStatus fulfillmentStatus;
  final Money totalPrice;
  final Money? subtotalPrice;
  final Money? totalShippingPrice;
  final ShippingAddress? shippingAddress;
  final List<OrderLineItem> lineItems;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.processedAt,
    required this.financialStatus,
    required this.fulfillmentStatus,
    required this.totalPrice,
    this.subtotalPrice,
    this.totalShippingPrice,
    this.shippingAddress,
    this.lineItems = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        orderNumber: json['orderNumber'] as int,
        processedAt: DateTime.tryParse(json['processedAt'] as String? ?? '') ??
            DateTime.now(),
        financialStatus: OrderFinancialStatus.fromString(
            json['financialStatus'] as String?),
        fulfillmentStatus: OrderFulfillmentStatus.fromString(
            json['fulfillmentStatus'] as String?),
        totalPrice:
            Money.fromJson(json['totalPrice'] as Map<String, dynamic>),
        subtotalPrice: json['subtotalPrice'] != null
            ? Money.fromJson(json['subtotalPrice'] as Map<String, dynamic>)
            : null,
        totalShippingPrice: json['totalShippingPrice'] != null
            ? Money.fromJson(
                json['totalShippingPrice'] as Map<String, dynamic>)
            : null,
        shippingAddress: json['shippingAddress'] != null
            ? ShippingAddress.fromJson(
                json['shippingAddress'] as Map<String, dynamic>)
            : null,
        lineItems:
            ((json['lineItems'] as Map<String, dynamic>?)?['edges'] as List<dynamic>? ?? [])
                .map((e) => OrderLineItem.fromJson(
                    (e as Map<String, dynamic>)['node'] as Map<String, dynamic>))
                .toList(),
      );
}
