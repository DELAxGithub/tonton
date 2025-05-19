#!/bin/bash

# Run image analysis integration tests

set -e  # Exit immediately if a command exits with a non-zero status

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}   Tonton Image Analysis Test Suite    ${NC}"
echo -e "${GREEN}=======================================${NC}"

# Directory setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."
ROOT_DIR="$(pwd)"
TEST_ASSETS_DIR="$ROOT_DIR/test/assets"

# Create test assets directory if it doesn't exist
if [ ! -d "$TEST_ASSETS_DIR" ]; then
  echo -e "${YELLOW}Creating test assets directory...${NC}"
  mkdir -p "$TEST_ASSETS_DIR"
fi

# Check if the test image exists, prompt to create one if not
TEST_IMAGE_PATH="$TEST_ASSETS_DIR/test_food_image.jpg"
if [ ! -f "$TEST_IMAGE_PATH" ]; then
  echo -e "${YELLOW}Test image not found at: $TEST_IMAGE_PATH${NC}"
  echo -e "${YELLOW}Please provide a food image for testing.${NC}"
  
  read -p "Do you want to create a placeholder image for testing? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Creating a placeholder image...${NC}"
    
    # Try using ImageMagick if available
    if command -v convert > /dev/null; then
      convert -size 300x300 xc:white -font Arial -pointsize 20 -fill black \
        -gravity center -annotate 0 "Test Food Image" "$TEST_IMAGE_PATH"
      echo -e "${GREEN}Created placeholder image with ImageMagick.${NC}"
    else
      # Fallback to a simple file creation
      echo "This is a placeholder for a test food image." > "$TEST_IMAGE_PATH"
      echo -e "${YELLOW}Created a text file placeholder. For proper testing, please replace with an actual image.${NC}"
    fi
  else
    echo -e "${RED}Test image is required for full testing.${NC}"
    echo -e "${YELLOW}Tests will be skipped or may fail without a proper test image.${NC}"
  fi
fi

# Step 1: Check Configuration
echo -e "\n${GREEN}Step 1: Checking configuration...${NC}"
if command -v dart > /dev/null; then
  dart pub get  # Ensure dependencies are up to date
  dart run "$ROOT_DIR/tools/verify_config.dart"
else
  echo -e "${RED}Dart not found. Please install the Flutter SDK.${NC}"
  exit 1
fi

# Step 2: Run unit tests
echo -e "\n${GREEN}Step 2: Running unit tests...${NC}"
flutter test test/ai_service_test.dart --skip-network

# Step 3: Run Edge Function test if credentials are available
echo -e "\n${GREEN}Step 3: Testing Edge Function...${NC}"
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo -e "${YELLOW}Supabase credentials not found in environment variables.${NC}"
  echo -e "${YELLOW}To test the Edge Function, please set SUPABASE_URL and SUPABASE_ANON_KEY.${NC}"
  echo -e "${YELLOW}Example: export SUPABASE_URL='https://your-project-id.supabase.co'${NC}"
  echo -e "${YELLOW}Example: export SUPABASE_ANON_KEY='your-anon-key'${NC}"
  
  read -p "Do you want to enter Supabase credentials now? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter Supabase URL: " SUPABASE_URL
    read -p "Enter Supabase Anon Key: " SUPABASE_ANON_KEY
    export SUPABASE_URL
    export SUPABASE_ANON_KEY
    
    if [ -f "$TEST_IMAGE_PATH" ]; then
      dart run "$ROOT_DIR/tools/test_edge_function.dart" --image="$TEST_IMAGE_PATH"
    else
      echo -e "${RED}Test image not found. Edge Function test skipped.${NC}"
    fi
  else
    echo -e "${YELLOW}Edge Function test skipped.${NC}"
  fi
else
  if [ -f "$TEST_IMAGE_PATH" ]; then
    dart run "$ROOT_DIR/tools/test_edge_function.dart" --image="$TEST_IMAGE_PATH"
  else
    echo -e "${RED}Test image not found. Edge Function test skipped.${NC}"
  fi
fi

# Step 4: Check for integration tests
echo -e "\n${GREEN}Step 4: Checking for integration tests...${NC}"
if [ -f "$ROOT_DIR/test/image_analysis_integration_test.dart" ]; then
  echo -e "${YELLOW}Integration tests can only be run on a device or emulator.${NC}"
  echo -e "${YELLOW}Use the following command to run them manually:${NC}"
  echo -e "${YELLOW}  flutter test integration_test/image_analysis_integration_test.dart --device-id=<your_device_id>${NC}"
else
  echo -e "${RED}Integration tests not found. Skipping.${NC}"
fi

echo -e "\n${GREEN}=======================================${NC}"
echo -e "${GREEN}   Test suite completed!    ${NC}"
echo -e "${GREEN}=======================================${NC}"