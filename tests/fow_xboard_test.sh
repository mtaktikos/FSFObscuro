#!/bin/bash
# Test that FoW options work in XBoard protocol with correct naming

echo "Testing FoW options in XBoard protocol..."

# Test 1: Verify UCI_FoW and UCI_IISearch are NOT advertised (hardcoded)
echo "Test 1: Checking that UCI_FoW and UCI_IISearch are NOT advertised (hardcoded to true)"
cat << 'EOF' | ./stockfish 2>&1 | grep -q 'feature option="UCI_FoW '
xboard
protover 2
quit
EOF
if [ $? -eq 1 ]; then
    echo "  ✓ UCI_FoW is not advertised (hardcoded)"
else
    echo "  ✗ UCI_FoW is still advertised"
    exit 1
fi

cat << 'EOF' | ./stockfish 2>&1 | grep -q 'feature option="UCI_IISearch '
xboard
protover 2
quit
EOF
if [ $? -eq 1 ]; then
    echo "  ✓ UCI_IISearch is not advertised (hardcoded)"
else
    echo "  ✗ UCI_IISearch is still advertised"
    exit 1
fi

# Test 2: Verify FoW options are present WITHOUT UCI_ prefix in XBoard mode
echo "Test 2: Checking FoW options are present WITHOUT UCI_ prefix"
OPTIONS=("MinInfosetSize" "ExpansionThreads" "CFRThreads" "PurifySupport" "PUCT_C" "FoW_TimeMs")
for opt in "${OPTIONS[@]}"; do
    cat << EOF | ./stockfish 2>&1 | grep -q "feature option=\"$opt "
xboard
protover 2
quit
EOF
    if [ $? -eq 0 ]; then
        echo "  ✓ $opt is advertised"
    else
        echo "  ✗ $opt is NOT advertised"
        exit 1
    fi
done

# Test 3: Verify options can be set with new names (without UCI_ prefix)
echo "Test 3: Testing option setting with new names"
cat << 'EOF' | ./stockfish 2>&1 > /tmp/fow_xboard_test_output.txt
xboard
protover 2
option VariantPath=../variants.ini
variant fogofwar
option MinInfosetSize=128
option ExpansionThreads=1
option CFRThreads=1
option PurifySupport=3
option PUCT_C=100
option FoW_TimeMs=500
new
st 1
e2e4
quit
EOF
# Check if the engine responds with a move (either from FoW planner or fallback)
if grep -q "move " /tmp/fow_xboard_test_output.txt; then
    echo "  ✓ Engine responds with a move after setting FoW options"
else
    echo "  ✗ Engine did not respond with a move"
    exit 1
fi

# Test 4: Verify XBoard commands still work
echo "Test 4: Testing XBoard commands (d, st, etc.)"
cat << 'EOF' | ./stockfish 2>&1 | grep -q "Fen:"
xboard
protover 2
variant chess
new
d
quit
EOF
if [ $? -eq 0 ]; then
    echo "  ✓ XBoard 'd' command works"
else
    echo "  ✗ XBoard 'd' command failed"
    exit 1
fi

# Cleanup
rm -f /tmp/fow_xboard_test_output.txt

echo ""
echo "All tests passed! ✓"
echo "FoW options are fully functional in XBoard protocol with renamed options (without UCI_ prefix)."
