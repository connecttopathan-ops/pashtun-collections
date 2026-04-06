class ProductImage {
  final String url;
  final String? altText;
  final int? width;
  final int? height;

  const ProductImage({
    required this.url,
    this.altText,
    this.width,
    this.height,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
        url: json['url'] as String,
        altText: json['altText'] as String?,
        width: json['width'] as int?,
        height: json['height'] as int?,
      );
}

class SelectedOption {
  final String name;
  final String value;

  const SelectedOption({required this.name, required this.value});

  factory SelectedOption.fromJson(Map<String, dynamic> json) => SelectedOption(
        name: json['name'] as String,
        value: json['value'] as String,
      );
}

class Money {
  final String amount;
  final String currencyCode;

  const Money({required this.amount, required this.currencyCode});

  double get value => double.tryParse(amount) ?? 0.0;

  factory Money.fromJson(Map<String, dynamic> json) => Money(
        amount: json['amount'] as String,
        currencyCode: json['currencyCode'] as String,
      );

  static Money? fromJsonOrNull(Map<String, dynamic>? json) {
    if (json == null) return null;
    return Money.fromJson(json);
  }
}

class ProductVariant {
  final String id;
  final String title;
  final bool availableForSale;
  final int? quantityAvailable;
  final Money price;
  final Money? compareAtPrice;
  final List<SelectedOption> selectedOptions;
  final ProductImage? image;

  const ProductVariant({
    required this.id,
    required this.title,
    required this.availableForSale,
    this.quantityAvailable,
    required this.price,
    this.compareAtPrice,
    required this.selectedOptions,
    this.image,
  });

  bool get isOnSale =>
      compareAtPrice != null && compareAtPrice!.value > price.value;

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        id: json['id'] as String,
        title: json['title'] as String,
        availableForSale: json['availableForSale'] as bool? ?? false,
        quantityAvailable: json['quantityAvailable'] as int?,
        price: Money.fromJson(json['price'] as Map<String, dynamic>),
        compareAtPrice: Money.fromJsonOrNull(
            json['compareAtPrice'] as Map<String, dynamic>?),
        selectedOptions: (json['selectedOptions'] as List<dynamic>? ?? [])
            .map((e) => SelectedOption.fromJson(e as Map<String, dynamic>))
            .toList(),
        image: json['image'] != null
            ? ProductImage.fromJson(json['image'] as Map<String, dynamic>)
            : null,
      );
}

class ProductOption {
  final String id;
  final String name;
  final List<String> values;

  const ProductOption({
    required this.id,
    required this.name,
    required this.values,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) => ProductOption(
        id: json['id'] as String,
        name: json['name'] as String,
        values: (json['values'] as List<dynamic>).cast<String>(),
      );
}

class Product {
  final String id;
  final String handle;
  final String title;
  final String? description;
  final String? descriptionHtml;
  final bool availableForSale;
  final List<String> tags;
  final String? vendor;
  final String? productType;
  final List<ProductImage> images;
  final List<ProductOption> options;
  final List<ProductVariant> variants;
  final Money? minPrice;
  final Money? maxPrice;
  final Money? compareAtMinPrice;
  final Map<String, String> metafields;

  const Product({
    required this.id,
    required this.handle,
    required this.title,
    this.description,
    this.descriptionHtml,
    required this.availableForSale,
    required this.tags,
    this.vendor,
    this.productType,
    required this.images,
    required this.options,
    required this.variants,
    this.minPrice,
    this.maxPrice,
    this.compareAtMinPrice,
    this.metafields = const {},
  });

  bool get isOnSale =>
      compareAtMinPrice != null && compareAtMinPrice!.value > (minPrice?.value ?? 0);

  int get discountPercent {
    if (!isOnSale) return 0;
    final orig = compareAtMinPrice!.value;
    final sale = minPrice?.value ?? orig;
    if (orig <= 0) return 0;
    return ((1 - sale / orig) * 100).round();
  }

  List<String> get sizeOptions {
    final opt = options.firstWhere(
      (o) => o.name.toLowerCase() == 'size',
      orElse: () => const ProductOption(id: '', name: '', values: []),
    );
    return opt.values;
  }

  List<String> get colorOptions {
    final opt = options.firstWhere(
      (o) => o.name.toLowerCase() == 'color' || o.name.toLowerCase() == 'colour',
      orElse: () => const ProductOption(id: '', name: '', values: []),
    );
    return opt.values;
  }

  ProductImage? get featuredImage => images.isNotEmpty ? images.first : null;

  factory Product.fromJson(Map<String, dynamic> json) {
    final priceRange = json['priceRange'] as Map<String, dynamic>?;
    final compareAtPriceRange = json['compareAtPriceRange'] as Map<String, dynamic>?;

    final metafields = <String, String>{};
    if (json['metafields'] != null) {
      for (final mf in json['metafields'] as List<dynamic>) {
        if (mf == null) continue;
        final m = mf as Map<String, dynamic>;
        final key = '${m['namespace']}.${m['key']}';
        metafields[key] = m['value'] as String? ?? '';
      }
    }

    return Product(
      id: json['id'] as String,
      handle: json['handle'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      descriptionHtml: json['descriptionHtml'] as String?,
      availableForSale: json['availableForSale'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
      vendor: json['vendor'] as String?,
      productType: json['productType'] as String?,
      images: (json['images'] as Map<String, dynamic>?)?['edges'] != null
          ? ((json['images'] as Map<String, dynamic>)['edges'] as List<dynamic>)
              .map((e) => ProductImage.fromJson(
                  (e as Map<String, dynamic>)['node'] as Map<String, dynamic>))
              .toList()
          : [],
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => ProductOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      variants: (json['variants'] as Map<String, dynamic>?)?['edges'] != null
          ? ((json['variants'] as Map<String, dynamic>)['edges'] as List<dynamic>)
              .map((e) => ProductVariant.fromJson(
                  (e as Map<String, dynamic>)['node'] as Map<String, dynamic>))
              .toList()
          : [],
      minPrice: priceRange?['minVariantPrice'] != null
          ? Money.fromJson(
              priceRange!['minVariantPrice'] as Map<String, dynamic>)
          : null,
      maxPrice: priceRange?['maxVariantPrice'] != null
          ? Money.fromJson(
              priceRange!['maxVariantPrice'] as Map<String, dynamic>)
          : null,
      compareAtMinPrice: compareAtPriceRange?['minVariantPrice'] != null
          ? Money.fromJson(
              compareAtPriceRange!['minVariantPrice'] as Map<String, dynamic>)
          : null,
      metafields: metafields,
    );
  }
}
