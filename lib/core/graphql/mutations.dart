class ShopifyMutations {
  ShopifyMutations._();

  static const String cartCreateMutation = r'''
    mutation CartCreate($input: CartInput!) {
      cartCreate(input: $input) {
        cart {
          id
          checkoutUrl
          totalQuantity
          cost {
            subtotalAmount { amount currencyCode }
            totalAmount { amount currencyCode }
          }
          lines(first: 50) {
            edges {
              node {
                id
                quantity
                cost {
                  totalAmount { amount currencyCode }
                  amountPerQuantity { amount currencyCode }
                  compareAtAmountPerQuantity { amount currencyCode }
                }
                merchandise {
                  ... on ProductVariant {
                    id
                    title
                    price { amount currencyCode }
                    compareAtPrice { amount currencyCode }
                    selectedOptions { name value }
                    image { url altText }
                    product {
                      id handle title
                      images(first: 1) { edges { node { url altText } } }
                    }
                  }
                }
              }
            }
          }
        }
        userErrors { field message }
      }
    }
  ''';

  static const String cartLinesAddMutation = r'''
    mutation CartLinesAdd($cartId: ID!, $lines: [CartLineInput!]!) {
      cartLinesAdd(cartId: $cartId, lines: $lines) {
        cart {
          id
          totalQuantity
          cost {
            subtotalAmount { amount currencyCode }
            totalAmount { amount currencyCode }
          }
          lines(first: 50) {
            edges {
              node {
                id
                quantity
                cost {
                  totalAmount { amount currencyCode }
                  amountPerQuantity { amount currencyCode }
                  compareAtAmountPerQuantity { amount currencyCode }
                }
                merchandise {
                  ... on ProductVariant {
                    id title
                    price { amount currencyCode }
                    compareAtPrice { amount currencyCode }
                    selectedOptions { name value }
                    image { url altText }
                    product {
                      id handle title
                      images(first: 1) { edges { node { url altText } } }
                    }
                  }
                }
              }
            }
          }
        }
        userErrors { field message }
      }
    }
  ''';

  static const String cartLinesUpdateMutation = r'''
    mutation CartLinesUpdate($cartId: ID!, $lines: [CartLineUpdateInput!]!) {
      cartLinesUpdate(cartId: $cartId, lines: $lines) {
        cart {
          id
          totalQuantity
          cost {
            subtotalAmount { amount currencyCode }
            totalAmount { amount currencyCode }
          }
          lines(first: 50) {
            edges {
              node {
                id
                quantity
                cost {
                  totalAmount { amount currencyCode }
                  amountPerQuantity { amount currencyCode }
                  compareAtAmountPerQuantity { amount currencyCode }
                }
                merchandise {
                  ... on ProductVariant {
                    id title
                    price { amount currencyCode }
                    compareAtPrice { amount currencyCode }
                    selectedOptions { name value }
                    image { url altText }
                    product {
                      id handle title
                      images(first: 1) { edges { node { url altText } } }
                    }
                  }
                }
              }
            }
          }
        }
        userErrors { field message }
      }
    }
  ''';

  static const String cartLinesRemoveMutation = r'''
    mutation CartLinesRemove($cartId: ID!, $lineIds: [ID!]!) {
      cartLinesRemove(cartId: $cartId, lineIds: $lineIds) {
        cart {
          id
          totalQuantity
          cost {
            subtotalAmount { amount currencyCode }
            totalAmount { amount currencyCode }
          }
          lines(first: 50) {
            edges {
              node {
                id
                quantity
                cost {
                  totalAmount { amount currencyCode }
                  amountPerQuantity { amount currencyCode }
                  compareAtAmountPerQuantity { amount currencyCode }
                }
                merchandise {
                  ... on ProductVariant {
                    id title
                    price { amount currencyCode }
                    compareAtPrice { amount currencyCode }
                    selectedOptions { name value }
                    image { url altText }
                    product {
                      id handle title
                      images(first: 1) { edges { node { url altText } } }
                    }
                  }
                }
              }
            }
          }
        }
        userErrors { field message }
      }
    }
  ''';

  static const String cartDiscountCodesUpdateMutation = r'''
    mutation CartDiscountCodesUpdate($cartId: ID!, $discountCodes: [String!]!) {
      cartDiscountCodesUpdate(cartId: $cartId, discountCodes: $discountCodes) {
        cart {
          id
          discountCodes { code applicable }
          cost {
            subtotalAmount { amount currencyCode }
            totalAmount { amount currencyCode }
          }
        }
        userErrors { field message }
      }
    }
  ''';

  static const String customerCreateMutation = r'''
    mutation CustomerCreate($input: CustomerCreateInput!) {
      customerCreate(input: $input) {
        customer {
          id
          email
          firstName
          lastName
        }
        customerUserErrors { code field message }
      }
    }
  ''';

  static const String customerAccessTokenCreateMutation = r'''
    mutation CustomerAccessTokenCreate($input: CustomerAccessTokenCreateInput!) {
      customerAccessTokenCreate(input: $input) {
        customerAccessToken {
          accessToken
          expiresAt
        }
        customerUserErrors { code field message }
      }
    }
  ''';

  static const String customerAccessTokenDeleteMutation = r'''
    mutation CustomerAccessTokenDelete($customerAccessToken: String!) {
      customerAccessTokenDelete(customerAccessToken: $customerAccessToken) {
        deletedAccessToken
        deletedCustomerAccessTokenId
        userErrors { field message }
      }
    }
  ''';

  static const String customerAddressCreateMutation = r'''
    mutation CustomerAddressCreate($customerAccessToken: String!, $address: MailingAddressInput!) {
      customerAddressCreate(customerAccessToken: $customerAccessToken, address: $address) {
        customerAddress {
          id
          firstName
          lastName
          address1
          address2
          city
          province
          country
          zip
          phone
        }
        customerUserErrors { code field message }
      }
    }
  ''';
}
