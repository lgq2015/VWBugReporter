#!/bin/sh
set -e

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

realpath() {
  DIRECTORY=$(cd "${1%/*}" && pwd)
  FILENAME="${1##*/}"
  echo "$DIRECTORY/$FILENAME"
}

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm\""
      xcrun mapc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE=$(realpath "${PODS_ROOT}/$1")
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Base/JMCViewController.xib"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Core/attachments/JMCAttachmentsView.xib"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Core/inbox/JMCIssuePreviewCell.xib"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Core/inbox/JMCIssueViewController.xib"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Core/sketch/JMCSketchViewController.xib"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/audio_attachment.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/audio_attachment@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/background_overlay.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/background_overlay@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/Balloon_1.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/Balloon_2.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/bluedot.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/button_base.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/button_base@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/cancel.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/de.lproj/JMCLocalizable.strings"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/en.lproj/JMCLocalizable.strings"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_capture.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_capture@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_1.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_1@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_2.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_2@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_3.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_3@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_4.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_4@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_5.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_5@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_6.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_6@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_7.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_7@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_8.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_8@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_active.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_active@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_pulse.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_pulse@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_recording.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_recording@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/megaphone.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/megaphone@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/notsent.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/notsent@2x.png"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Base/JMCViewController.xib"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Core/attachments/JMCAttachmentsView.xib"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Core/inbox/JMCIssuePreviewCell.xib"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Core/inbox/JMCIssueViewController.xib"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Core/sketch/JMCSketchViewController.xib"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/audio_attachment.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/audio_attachment@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/background_overlay.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/background_overlay@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/Balloon_1.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/Balloon_2.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/bluedot.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/button_base.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/button_base@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/cancel.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/de.lproj/JMCLocalizable.strings"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/en.lproj/JMCLocalizable.strings"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_capture.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_capture@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_1.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_1@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_2.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_2@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_3.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_3@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_4.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_4@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_5.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_5@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_6.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_6@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_7.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_7@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_8.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_8@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_active.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_active@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_pulse.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_record_pulse@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_recording.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/icon_recording@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/megaphone.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/megaphone@2x.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/notsent.png"
  install_resource "JIRAConnect/JIRAConnect/JMCClasses/Resources/notsent@2x.png"
fi

rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  case "${TARGETED_DEVICE_FAMILY}" in
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;
  esac

  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "`realpath $PODS_ROOT`*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
