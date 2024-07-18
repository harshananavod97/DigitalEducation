part of 'unlock_premium_category_cubit.dart';

@immutable
abstract class UnlockPremiumCategoryState {}

class UnlockPremiumCategoryInitial extends UnlockPremiumCategoryState {}

class UnlockPremiumCategoryInProgress extends UnlockPremiumCategoryState {}

class UnlockPremiumCategorySuccess extends UnlockPremiumCategoryState {}

class UnlockPremiumCategoryFailure extends UnlockPremiumCategoryState {
  UnlockPremiumCategoryFailure(this.errorMessage);
  final String errorMessage;
}
