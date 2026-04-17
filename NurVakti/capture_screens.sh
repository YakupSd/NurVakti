#!/bin/bash
PROJECT_DIR="/Users/yakupsuda/YakupSuda_Projeler/NurVaktiGitHub/NurVakti"
SCREENSHOT_DIR="$PROJECT_DIR/Screenshots"
mkdir -p "$SCREENSHOT_DIR"
APP_ID="yakupsuda.NurVakti"
SIM_UUID="1DC9713C-99AE-4F34-B307-5F58344703D8"

echo "Using Simulator: $SIM_UUID"

# Launch app
echo "Launching $APP_ID..."
xcrun simctl launch $SIM_UUID $APP_ID
sleep 15

# Capture Home
echo "Capturing Home..."
xcrun simctl openurl $SIM_UUID "nurvakti://prayer"
sleep 5
xcrun simctl io $SIM_UUID screenshot "$SCREENSHOT_DIR/01_Home.png"

# Capture Quran
echo "Capturing Quran..."
xcrun simctl openurl $SIM_UUID "nurvakti://quran"
sleep 5
xcrun simctl io $SIM_UUID screenshot "$SCREENSHOT_DIR/02_Quran.png"

# Capture Dhikr
echo "Capturing Dhikr..."
xcrun simctl openurl $SIM_UUID "nurvakti://dhikr"
sleep 5
xcrun simctl io $SIM_UUID screenshot "$SCREENSHOT_DIR/03_Dhikr.png"

# Capture Alarms
echo "Capturing Alarms..."
xcrun simctl openurl $SIM_UUID "nurvakti://alarms"
sleep 5
xcrun simctl io $SIM_UUID screenshot "$SCREENSHOT_DIR/04_Alarms.png"

# Capture Settings
echo "Capturing Settings..."
xcrun simctl openurl $SIM_UUID "nurvakti://settings"
sleep 5
xcrun simctl io $SIM_UUID screenshot "$SCREENSHOT_DIR/05_Settings.png"

echo "Final Verification:"
ls -lh "$SCREENSHOT_DIR"/*.png
echo "✅ Screenshots captured in $SCREENSHOT_DIR"
