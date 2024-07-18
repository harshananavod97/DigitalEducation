import 'dart:async';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/authLocalDataSource.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/auth/cubits/referAndEarnCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/uploadProfileCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:flutterquiz/utils/validators.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class CreateOrEditProfileScreen extends StatefulWidget {
  const CreateOrEditProfileScreen({
    required this.isNewUser,
    super.key,
  });

  final bool isNewUser;

  @override
  State<CreateOrEditProfileScreen> createState() =>
      _SelectProfilePictureScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<UploadProfileCubit>(
            create: (_) => UploadProfileCubit(ProfileManagementRepository()),
          ),
          BlocProvider<ReferAndEarnCubit>(
            create: (_) => ReferAndEarnCubit(AuthRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
        ],
        child: CreateOrEditProfileScreen(
          isNewUser: routeSettings.arguments! as bool,
        ),
      ),
    );
  }
}

class _SelectProfilePictureScreen extends State<CreateOrEditProfileScreen> {
  File? selectedImage;
  String? selectedAvatar;

  final _formKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  TextEditingController? emailController;
  TextEditingController? phoneController;
  TextEditingController inviteTextEditingController = TextEditingController();
  bool iHaveInviteCode = false;

  bool isPhoneTextFieldEnabled = false;
  bool isEmailTextFieldEnabled = false;

  @override
  void initState() {
    super.initState();
    final authType = AuthLocalDataSource.getAuthType();
    if (!widget.isNewUser) {
      if (authType == 'mobile') {
        isEmailTextFieldEnabled = true;
        isPhoneTextFieldEnabled = false;
      } else if (authType == 'gmail' ||
          authType == 'email' ||
          authType == 'apple') {
        isEmailTextFieldEnabled = false;
        isPhoneTextFieldEnabled = true;
      }
    }
  }

  //convert image to file
  Future<void> uploadProfileImage(String imageName) async {
    final byteData = await rootBundle.load(Assets.profile(imageName));
    final file = File('${(await getTemporaryDirectory()).path}/temp.png');
    await file.writeAsBytes(
      byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );
    await context.read<UploadProfileCubit>().uploadProfilePicture(file);
  }

  Widget _buildCurrentProfilePictureContainer({
    required String image,
    required bool isFile,
    required bool isAsset,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    if (image.isEmpty) {
      if (widget.isNewUser) {
        return DottedBorder(
          strokeWidth: 3,
          padding: EdgeInsets.zero,
          borderType: BorderType.RRect,
          dashPattern: const [8, 3],
          color: colorScheme.onTertiary.withOpacity(.5),
          radius: const Radius.circular(8),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: colorScheme.surface,
              minimumSize: Size(width * .9, 48),
            ),
            onPressed: chooseImageFromCameraOrGallery,
            child: Text(
              context.tr('choosePhoto')!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeights.medium,
                color: colorScheme.onTertiary,
              ),
            ),
          ),
        );
      }
      return GestureDetector(
        onTap: chooseImageFromCameraOrGallery,
        child: Container(
          width: width * (0.3),
          height: width * (0.3),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.add_a_photo,
              color: colorScheme.surface,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: width * (0.3),
      height: width * (0.3),
      child: LayoutBuilder(
        builder: (_, constraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: width * (0.3),
                  height: width * (0.3),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.surface),
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(width * .15),
                    child: isFile
                        ? Image.file(File(image))
                        : QImage.circular(
                            imageUrl: isAsset ? Assets.profile(image) : image,
                          ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: chooseImageFromCameraOrGallery,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(5),
                    height: constraints.maxWidth * (0.25),
                    width: constraints.maxWidth * (0.25),
                    child: Icon(
                      Icons.add_a_photo,
                      color: Theme.of(context).primaryColor,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // get image File camera
  Future<void> _getFromCamera(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    final croppedFile = await _croppedImage(pickedFile!.path);

    setState(() {
      selectedImage = File(croppedFile!.path);
      selectedAvatar = null;
    });
  }

  //get image file from library
  Future<void> _getFromGallery(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    final croppedFile = await _croppedImage(pickedFile!.path);

    setState(() {
      selectedImage = File(croppedFile!.path);
      selectedAvatar = null;
    });
  }

  Future<CroppedFile?> _croppedImage(String pickedFilePath) async {
    final title = context.tr('cropperLbl');

    return ImageCropper().cropImage(
      sourcePath: pickedFilePath,
      aspectRatioPresets: [CropAspectRatioPreset.square],
      cropStyle: CropStyle.circle,
      compressFormat: ImageCompressFormat.png,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: title,
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Theme.of(context).colorScheme.surface,
          initAspectRatio: CropAspectRatioPreset.square,
          activeControlsWidgetColor: Theme.of(context).primaryColor,
        ),
        IOSUiSettings(title: title),
      ],
    );
  }

  void chooseImageFromCameraOrGallery() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      builder: (_) {
        final size = MediaQuery.sizeOf(context);
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: UiUtils.bottomSheetTopRadius,
          ),
          height: size.height * .21,
          padding: EdgeInsets.only(
            top: size.height * .02,
            left: size.width * UiUtils.hzMarginPct,
            right: size.width * UiUtils.hzMarginPct,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('profilePhotoLbl')!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _getFromCamera(context);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onTertiary
                                  .withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).primaryColor,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.tr('cameraLbl')!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _getFromGallery(context);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onTertiary
                                  .withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            Icons.photo_library_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.tr('photoLibraryLbl')!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectAvatarText() {
    return Center(
      child: Text(
        "${toBeginningOfSentenceCase(context.tr("orLbl"))} ${context.tr("selectProfilePhotoLbl")!}",
        style: TextStyle(
          color: Theme.of(context).colorScheme.onTertiary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDefaultAvtarImage(int index, String imageName) {
    return GestureDetector(
      onTap: () => setState(() {
        selectedAvatar = imageName;
        selectedImage = null;
      }),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final size = constraints.maxHeight * .66;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 7),
            height: size,
            width: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(
                  Assets.profile(imageName),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultAvtarImages() {
    final defaultProfileImages =
        (context.read<SystemConfigCubit>().state as SystemConfigFetchSuccess)
            .defaultProfileImages;

    if (widget.isNewUser) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * (0.23),
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: defaultProfileImages.length,
          itemBuilder: (_, i) => _buildDefaultAvtarImage(
            i,
            defaultProfileImages[i],
          ),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * (0.13),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: defaultProfileImages.length,
        itemBuilder: (_, i) => _buildDefaultAvtarImage(
          i,
          defaultProfileImages[i],
        ),
      ),
    );
  }

  //continue button will listen to two cubit one is for changing name and other is
  //for uploading profile picture
  Widget _buildContinueButton(UserProfile userProfile) {
    return BlocConsumer<UploadProfileCubit, UploadProfileState>(
      bloc: context.read<UploadProfileCubit>(),
      listener: (context, state) {
        if (state is UploadProfileFailure) {
          UiUtils.showSnackBar(
            context.tr(
              convertErrorCodeToLanguageKey(state.errorMessage),
            )!,
            context,
          );
        } else if (state is UploadProfileSuccess) {
          context.read<UserDetailsCubit>().updateUserProfileUrl(state.imageUrl);
        }
      },
      builder: (context, state) {
        /// for updating name,email, number
        return BlocConsumer<ReferAndEarnCubit, ReferAndEarnState>(
          listener: (_, referState) {
            if (referState is ReferAndEarnFailure) {
              UiUtils.showSnackBar(
                context.tr(
                  convertErrorCodeToLanguageKey(referState.errorMessage),
                )!,
                context,
              );
            }
            if (referState is ReferAndEarnSuccess) {
              context.read<UserDetailsCubit>().updateUserProfile(
                    name: referState.userProfile.name,
                    email: referState.userProfile.email,
                    mobile: referState.userProfile.mobileNumber,
                    coins: referState.userProfile.coins,
                  );

              context.read<UpdateUserDetailCubit>().updateProfile(
                    email: emailController!.text,
                    name: nameController!.text,
                    mobile: phoneController!.text,
                  );

              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.home,
                (_) => false,
                arguments: false,
              );
            }
          },
          builder: (context, referState) {
            return BlocConsumer<UpdateUserDetailCubit, UpdateUserDetailState>(
              listener: (_, state) {
                if (state is UpdateUserDetailSuccess ||
                    state is UpdateUserDetailFailure) {
                  context.shouldPop();
                }
              },
              builder: (updateContext, updateState) {
                final textButtonKey =
                    updateState is UpdateUserDetailInProgress ||
                            context.read<UploadProfileCubit>().state
                                is UploadProfileInProgress
                        ? 'uploadingBtn'
                        : 'continueLbl';
                return TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onPressed: () async {
                    //if upload profile is in progress
                    if (state is UploadProfileInProgress) {
                      return;
                    }

                    if (context.read<UpdateUserDetailCubit>().state
                        is UpdateUserDetailInProgress) {
                      return;
                    }

                    //if update name is in progress
                    if (referState is ReferAndEarnProgress) {
                      return;
                    }

                    //if profile is empty
                    if (selectedAvatar == null &&
                        selectedImage == null &&
                        userProfile.profileUrl!.isEmpty) {
                      UiUtils.showSnackBar(
                        context.tr('selectProfileLbl')!,
                        context,
                      );
                      return;
                    }
                    //if use has not enter the name then so enter name snack bar
                    if (nameController!.text.isEmpty) {
                      UiUtils.showSnackBar(
                        context.tr('enterValidNameMsg')!,
                        context,
                      );
                      return;
                    }

                    if (selectedAvatar != null) {
                      await uploadProfileImage(selectedAvatar ?? '');
                    } else if (selectedImage != null) {
                      await context
                          .read<UploadProfileCubit>()
                          .uploadProfilePicture(selectedImage);
                    }

                    if (widget.isNewUser) {
                      if (iHaveInviteCode) {
                        context.read<ReferAndEarnCubit>().getReward(
                              name: nameController!.text.trim(),
                              userProfile: userProfile,
                              friendReferralCode:
                                  inviteTextEditingController.text.trim(),
                              authType:
                                  context.read<AuthCubit>().getAuthProvider(),
                            );
                      }

                      /// ----
                      if (emailController!.text.isNotEmpty ||
                          phoneController!.text.isNotEmpty) {
                        context.read<UserDetailsCubit>().updateUserProfile(
                              email: emailController!.text.trim(),
                              name: nameController!.text.trim(),
                              mobile: phoneController!.text.trim(),
                            );

                        await context
                            .read<UpdateUserDetailCubit>()
                            .updateProfile(
                              email: emailController!.text,
                              name: nameController!.text,
                              mobile: phoneController!.text,
                            );
                      }

                      await Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.home,
                        (_) => false,
                        arguments: false,
                      );
                    } else {
                      context.read<UserDetailsCubit>().updateUserProfile(
                            email: emailController!.text.trim(),
                            name: nameController!.text.trim(),
                            mobile: phoneController!.text.trim(),
                          );

                      await context.read<UpdateUserDetailCubit>().updateProfile(
                            email: emailController!.text,
                            name: nameController!.text,
                            mobile: phoneController!.text,
                          );
                    }
                  },
                  child: Text(
                    context.tr(textButtonKey)!,
                    style: Theme.of(context).textTheme.headlineSmall!.merge(
                          TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNameTextFieldContainer() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.isNewUser) ...[
          Text(
            context.tr('profileName')!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onTertiary,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.surface,
          ),
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: TextFormField(
            validator: (_) => null,
            cursorColor: colorScheme.onTertiary,
            controller: nameController,
            style: TextStyle(
              color: colorScheme.onTertiary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: context.tr('enterNameLbl'),
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: colorScheme.onTertiary.withOpacity(.4),
              ),
              contentPadding: const EdgeInsets.only(left: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailTextFieldContainer() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('emailAddress')!,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onTertiary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isEmailTextFieldEnabled
                ? colorScheme.surface
                : colorScheme.onTertiary.withOpacity(0.2),
          ),
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: Form(
            key: _formKey,
            child: TextFormField(
              cursorColor: colorScheme.onTertiary,
              readOnly: !isEmailTextFieldEnabled,
              enabled: isEmailTextFieldEnabled,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                return Validators.validateEmail(
                  val!,
                  context.tr('emailRequiredMsg'),
                  context.tr('enterValidEmailMsg'),
                );
              },
              style: TextStyle(
                color: colorScheme.onTertiary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: context.tr('enterEmailLbl'),
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: colorScheme.onTertiary.withOpacity(.4),
                ),
                contentPadding: const EdgeInsets.only(left: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneTextFieldContainer() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('phoneNumber')!,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onTertiary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isPhoneTextFieldEnabled
                ? colorScheme.surface
                : colorScheme.onTertiary.withOpacity(0.2),
          ),
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: TextFormField(
            cursorColor: colorScheme.onTertiary,
            validator: (_) => null,
            readOnly: !isPhoneTextFieldEnabled,
            enabled: isPhoneTextFieldEnabled,
            controller: phoneController,
            inputFormatters: [
              LengthLimitingTextInputFormatter(maxPhoneNumberLength),
              FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: TextInputType.phone,
            style: TextStyle(
              color: isPhoneTextFieldEnabled
                  ? colorScheme.onTertiary
                  : colorScheme.onTertiary.withOpacity(0.4),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: '-',
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: colorScheme.onTertiary.withOpacity(.4),
              ),
              contentPadding: const EdgeInsets.only(left: 10),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildNameAndReferCodeContainer() {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: colorScheme.surface,
        ),
        padding: const EdgeInsets.all(15),
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr(iHaveInviteCodeKey)!,
                  style: TextStyle(
                    fontWeight: FontWeights.medium,
                    fontSize: 18,
                    color: colorScheme.onTertiary,
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    thumbColor: iHaveInviteCode
                        ? Theme.of(context).primaryColor
                        : const Color(0xFF5c5c5c),
                    activeColor: Theme.of(context).scaffoldBackgroundColor,
                    trackColor: Theme.of(context).scaffoldBackgroundColor,
                    value: iHaveInviteCode,
                    onChanged: (v) => setState(() => iHaveInviteCode = v),
                  ),
                ),
              ],
            ),
            if (iHaveInviteCode) ...[
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.onTertiary.withOpacity(0.1),
                ),
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  cursorColor: colorScheme.onTertiary,
                  validator: (_) => null,
                  controller: inviteTextEditingController,
                  style: TextStyle(
                    color: colorScheme.onTertiary,
                    fontSize: 18,
                    fontWeight: FontWeights.medium,
                  ),
                  decoration: InputDecoration(
                    hintText: context.tr(enterReferralCodeLbl),
                    hintStyle: TextStyle(
                      color: colorScheme.onTertiary.withOpacity(.3),
                      fontSize: 18,
                      fontWeight: FontWeights.medium,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      SizedBox(height: iHaveInviteCode ? 15 : 80),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appBar = !widget.isNewUser
        ? QAppBar(title: Text(context.tr('editProfile')!))
        : null;

    return PopScope(
      canPop: !widget.isNewUser,
      child: Scaffold(
        appBar: appBar,
        body: Stack(
          children: [
            BlocConsumer<UserDetailsCubit, UserDetailsState>(
              listener: (context, state) {
                //when user register first time then set this listener
                if (state is UserDetailsFetchSuccess && widget.isNewUser) {
                  UiUtils.fetchBookmarkAndBadges(
                    context: context,
                    userId: state.userProfile.userId!,
                  );
                }
              },
              bloc: context.read<UserDetailsCubit>(),
              builder: (context, state) {
                if (state is UserDetailsFetchInProgress ||
                    state is UserDetailsInitial) {
                  return const Center(child: CircularProgressContainer());
                }
                if (state is UserDetailsFetchFailure) {
                  return ErrorContainer(
                    showBackButton: true,
                    errorMessage:
                        convertErrorCodeToLanguageKey(state.errorMessage),
                    onTapRetry: () {
                      context.read<UserDetailsCubit>().fetchUserDetails();
                    },
                    showErrorImage: true,
                  );
                }

                final userProfile =
                    (state as UserDetailsFetchSuccess).userProfile;

                nameController ??=
                    TextEditingController(text: userProfile.name);
                emailController ??=
                    TextEditingController(text: userProfile.email);
                phoneController ??=
                    TextEditingController(text: userProfile.mobileNumber);

                final size = MediaQuery.of(context).size;

                // TODO(J): too many conditionals,
                //  separate isNewUser logic to one place.
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * .025),
                      Center(
                        child: _buildCurrentProfilePictureContainer(
                          image: selectedAvatar != null
                              ? selectedAvatar!
                              : selectedImage != null
                                  ? selectedImage!.path
                                  : userProfile.profileUrl ?? '',
                          isFile: selectedImage != null,
                          isAsset: selectedAvatar != null,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildSelectAvatarText(),
                      SizedBox(height: size.height * .025),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * UiUtils.hzMarginPct,
                        ),
                        child: _buildDefaultAvtarImages(),
                      ),
                      if (widget.isNewUser)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Divider(color: Color(0xFF707070)),
                        )
                      else
                        const Divider(),
                      SizedBox(height: size.height * .02),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * UiUtils.hzMarginPct,
                        ),
                        child: _buildNameTextFieldContainer(),
                      ),
                      SizedBox(height: size.height * .03),
                      if (!widget.isNewUser) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * UiUtils.hzMarginPct,
                          ),
                          child: _buildEmailTextFieldContainer(),
                        ),
                        SizedBox(height: size.height * .03),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * UiUtils.hzMarginPct,
                          ),
                          child: _buildPhoneTextFieldContainer(),
                        ),
                        SizedBox(height: size.height * .03),
                      ] else ...[
                        ..._buildNameAndReferCodeContainer(),
                      ],
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * UiUtils.hzMarginPct,
                        ),
                        child: _buildContinueButton(userProfile),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
