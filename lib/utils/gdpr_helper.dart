import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iabtcf_consent_info/iabtcf_consent_info.dart';

/// To Test in Development, uncomment 'For Testing' Parts, and add your test device id.
/// To get your device test id, after running the app, in the console search for message similar to following example
/// Use new ConsentDebugSettings.Builder().addTestDeviceHashedId("35D4E39098439E5F50EAF7895CC1ADA9") to set this as a debug device.

class GdprHelper {
  /// For Testing
  // static const _testIds = [
  //   'E503DD4405B5CAACF12BCEDDD07A7332',
  //   '35D4E39098439E5F50EAF7895CC1ADA9',
  // ];

  ///
  static Future<FormError?> initialize() async {
    final completer = Completer<FormError?>();

    final params = ConsentRequestParameters(

        /// For Testing
        // consentDebugSettings: ConsentDebugSettings(
        //   debugGeography: DebugGeography.debugGeographyEea,
        //   testIdentifiers: _testIds,
        // ),
        );

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          await _loadConsentForm();
        } else {
          await _initialize();
        }

        completer.complete();
      },
      completer.complete,
    );

    return completer.future;
  }

  static Future<bool> changePrivacyPreferences() async {
    final completer = Completer<bool>();

    ConsentInformation.instance
        .requestConsentInfoUpdate(ConsentRequestParameters(), () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        ConsentForm.loadConsentForm((consentForm) {
          consentForm.show((formError) async {
            await _initialize();
            completer.complete(true);
          });
        }, (formError) {
          completer.complete(false);
        });
      } else {
        completer.complete(false);
      }
    }, (error) {
      completer.complete(false);
    });

    return completer.future;
  }

  ///
  static Future<FormError?> _loadConsentForm() async {
    final completer = Completer<FormError?>();

    ConsentForm.loadConsentForm(
      (form) async {
        final status = await ConsentInformation.instance.getConsentStatus();

        if (status == ConsentStatus.required) {
          form.show((_) => completer.complete(_loadConsentForm()));
        } else {
          await _initialize();
          completer.complete();
        }
      },
      completer.complete,
    );

    return completer.future;
  }

  ///
  static Future<void> _initialize() async {
    await MobileAds.instance.initialize();

    /// For Testing
    // final configuration = RequestConfiguration(testDeviceIds: _testIds);
    // await MobileAds.instance.updateRequestConfiguration(configuration);
  }

  static Future<void> reset() async {
    await ConsentInformation.instance.reset();
  }

  ///
  static Future<bool> isUnderGdpr() async {
    final info = await IabtcfConsentInfo.instance.currentConsentInfo();
    return info?.gdprApplies ?? false;
  }
}
