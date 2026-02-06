#!/bin/bash

# Manual connection test with verbose output
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Find binary
if [ -f .build/arm64-apple-macosx/debug/inputshare ]; then
    BINARY=.build/arm64-apple-macosx/debug/inputshare
elif [ -f .build/x86_64-apple-macosx/debug/inputshare ]; then
    BINARY=.build/x86_64-apple-macosx/debug/inputshare
else
    echo "❌ Binary not found. Run: ./rebuild.sh"
    exit 1
fi

echo "🧪 Manual Connection Test"
echo "========================="
echo ""
echo "Binary: $BINARY"
echo "Architecture: $(file "$BINARY" | grep -o 'arm64\|x86_64')"
echo ""

# Check certificates
echo "📋 Checking certificates..."
if [ ! -d .certs ]; then
    echo "❌ .certs directory not found"
    echo "Run: ./setup.sh"
    exit 1
fi

if [ ! -f .certs/device-a.p12 ] || [ ! -f .certs/device-b.p12 ]; then
    echo "❌ Certificate files missing"
    echo "Run: ./setup.sh"
    exit 1
fi

PIN_A=$(cat .certs/device-a.pin 2>/dev/null)
PIN_B=$(cat .certs/device-b.pin 2>/dev/null)

if [ -z "$PIN_A" ] || [ -z "$PIN_B" ]; then
    echo "❌ Certificate pins missing"
    echo "Run: ./setup.sh"
    exit 1
fi

echo "✅ Certificates OK"
echo "   Device A pin: $PIN_A"
echo "   Device B pin: $PIN_B"
echo ""

echo "🚀 Starting receiver in foreground (Ctrl+C to stop)..."
echo "   This will show all receiver output"
echo ""
echo "Command:"
echo "$BINARY receive --port 4242 --identity-p12 .certs/device-a.p12 --identity-pass inputshare-dev --pin-sha256 $PIN_B"
echo ""
echo "Press Enter to start receiver..."
read

echo "Starting now..."
echo "==============="
$BINARY receive \
  --port 4242 \
  --identity-p12 .certs/device-a.p12 \
  --identity-pass inputshare-dev \
  --pin-sha256 $PIN_B
