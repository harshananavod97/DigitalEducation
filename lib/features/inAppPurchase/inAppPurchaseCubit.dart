import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/inAppPurchase/in_app_purchase_repo.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

abstract class InAppPurchaseState {}

class InAppPurchaseInitial extends InAppPurchaseState {}

class InAppPurchaseLoading extends InAppPurchaseState {}

class InAppPurchaseNotAvailable extends InAppPurchaseState {}

class InAppPurchaseAvailable extends InAppPurchaseState {
  InAppPurchaseAvailable({required this.products, required this.notFoundIds});

  final List<ProductDetails> products;

  final List<String> notFoundIds;
}

class InAppPurchaseFailure extends InAppPurchaseState {
  InAppPurchaseFailure({required this.errorMessage, required this.notFoundIds});

  final String errorMessage;
  final List<String> notFoundIds;
}

class InAppPurchaseProcessInProgress extends InAppPurchaseState {
  InAppPurchaseProcessInProgress(this.products);

  final List<ProductDetails> products;
}

class InAppPurchaseProcessFailure extends InAppPurchaseState {
  InAppPurchaseProcessFailure({
    required this.errorMessage,
    required this.products,
  });

  final String errorMessage;
  final List<ProductDetails> products;
}

class InAppPurchaseProcessSuccess extends InAppPurchaseState {
  InAppPurchaseProcessSuccess({
    required this.products,
    required this.purchasedProductId,
    required this.purchaseToken,
  });

  final List<ProductDetails> products;
  final String purchasedProductId;
  final String purchaseToken;

  Future<bool> verifyAndPurchase() async {
    return InAppPurchaseRepo().verifyAndPurchase(
      productId: purchasedProductId,
      purchaseToken: purchaseToken,
    );
  }
}

class InAppPurchaseCubit extends Cubit<InAppPurchaseState> {
  InAppPurchaseCubit() : super(InAppPurchaseInitial());

  //product ids of consumable products
  List<String>? productIds;
  final InAppPurchase inAppPurchase = InAppPurchase.instance;

  late StreamSubscription<List<PurchaseDetails>> _subscription;

  //load product and set up listener for purchase stream
  Future<void> initializePurchase(List<String> productIds) async {
    emit(InAppPurchaseLoading());
    _subscription = inAppPurchase.purchaseStream.listen(
      _purchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (e) {
        emit(
          InAppPurchaseProcessFailure(
            errorMessage: purchaseErrorKey,
            products: _getProducts(),
          ),
        );
      },
    );

    //to confirm in-app purchase is available or not
    final isAvailable = await inAppPurchase.isAvailable();
    if (!isAvailable) {
      emit(InAppPurchaseNotAvailable());
    } else {
      //if in-app purchase is available then load products with given id
      await _loadProducts(productIds);
    }
  }

  //it will load products form store
  Future<void> _loadProducts(List<String> productIds) async {
    //load products for purchase (consumable product)
    final productDetailResponse =
        await inAppPurchase.queryProductDetails(productIds.toSet());
    if (productDetailResponse.error != null) {
      //error while getting products from store
      emit(
        InAppPurchaseFailure(
          errorMessage: productsFetchedFailureKey,
          notFoundIds: productDetailResponse.notFoundIDs,
        ),
      );
    }
    //if there is not any product to purchase (consumable)
    else if (productDetailResponse.productDetails.isEmpty) {
      emit(
        InAppPurchaseFailure(
          errorMessage: noProductsKey,
          notFoundIds: productDetailResponse.notFoundIDs,
        ),
      );
    } else {
      productDetailResponse.productDetails
          .sort((first, second) => first.rawPrice.compareTo(second.rawPrice));
      emit(
        InAppPurchaseAvailable(
          products: productDetailResponse.productDetails,
          notFoundIds: productDetailResponse.notFoundIDs,
        ),
      );
    }
  }

  Future<void> restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
  }

  Future<void> buyNonConsumableProducts(ProductDetails productDetails) async {
    emit(InAppPurchaseProcessInProgress(_getProducts()));
    final purchaseParam = PurchaseParam(productDetails: productDetails);
    //start purchase
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }

  //to buy product
  Future<void> buyConsumableProducts(ProductDetails productDetails) async {
    emit(InAppPurchaseProcessInProgress(_getProducts()));
    final purchaseParam = PurchaseParam(productDetails: productDetails);
    //start purchase
    await InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _purchaseUpdate(List<PurchaseDetails> purchaseDetails) async {
    for (final purchaseDetail in purchaseDetails) {
      if (purchaseDetail.status == PurchaseStatus.error ||
          purchaseDetail.status == PurchaseStatus.canceled) {
        emit(
          InAppPurchaseProcessFailure(
            errorMessage: purchaseDetail.error?.message ?? purchaseErrorKey,
            products: _getProducts(),
          ),
        );
      } else if (purchaseDetail.status == PurchaseStatus.purchased ||
          purchaseDetail.status == PurchaseStatus.restored) {
        await inAppPurchase.completePurchase(purchaseDetail);
        emit(
          InAppPurchaseProcessSuccess(
            products: _getProducts(),
            purchasedProductId: purchaseDetail.productID,
            purchaseToken:
                purchaseDetail.verificationData.serverVerificationData,
          ),
        );
      }

      if (Platform.isAndroid) {
        final androidAddition = inAppPurchase
            .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        await androidAddition.consumePurchase(purchaseDetail);
      }

      if (purchaseDetail.pendingCompletePurchase) {
        await inAppPurchase.completePurchase(purchaseDetail);
      }
    }
  }

  Future<bool> verifyAndPurchase() async {
    if (state is InAppPurchaseProcessSuccess) {
      final success = state as InAppPurchaseProcessSuccess;

      final ok = await InAppPurchaseRepo()
          .verifyAndPurchase(
        productId: success.purchasedProductId,
        purchaseToken: success.purchaseToken,
      )
          .catchError(
        (Object e) {
          emit(
            InAppPurchaseProcessFailure(
              errorMessage: e.toString(),
              products: _getProducts(),
            ),
          );
          return false;
        },
      );

      return ok;
    }

    return false;
  }

  List<ProductDetails> _getProducts() {
    if (state is InAppPurchaseAvailable) {
      return (state as InAppPurchaseAvailable).products;
    }
    if (state is InAppPurchaseProcessSuccess) {
      return (state as InAppPurchaseProcessSuccess).products;
    }
    if (state is InAppPurchaseProcessFailure) {
      return (state as InAppPurchaseProcessFailure).products;
    }
    if (state is InAppPurchaseProcessInProgress) {
      return (state as InAppPurchaseProcessInProgress).products;
    }
    return [];
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
