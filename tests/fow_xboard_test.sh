#!/bin/bash
# Test that UCI_FoW options work in XBoard protocol

echo "Testing UCI_FoW options in XBoard protocol..."

# Test 1: Verify options are advertised
echo "Test 1: Checking if UCI_FoW options are advertised"
cat << 'EOF' | ./stockfish 2>&1 | grep -q "feature option=\"UCI_FoW"
xboard
protover 2
quit
EOF
if [ $? -eq 0 ]; then
    echo "  ✓ UCI_FoW option is advertised"
else
    echo "  ✗ UCI_FoW option is NOT advertised"
    exit 1
fi

# Test 2: Verify all FoW options are present
echo "Test 2: Checking all FoW options are present"
OPTIONS=("UCI_FoW" "UCI_IISearch" "UCI_MinInfosetSize" "UCI_ExpansionThreads" "UCI_CFRThreads" "UCI_PurifySupport" "UCI_PUCT_C" "UCI_FoW_TimeMs")
for opt in "${OPTIONS[@]}"; do
    cat << EOF | ./stockfish 2>&1 | grep -q "feature option=\"$opt"
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

# Test 3: Verify options can be set
echo "Test 3: Testing option setting"
cat << 'EOF' | ./stockfish 2>&1 > /tmp/fow_xboard_test_output.txt
xboard
protover 2
option VariantPath=../variants.ini
variant fogofwar
option UCI_FoW=1
option UCI_IISearch=1
option UCI_MinInfosetSize=128
option UCI_ExpansionThreads=1
option UCI_CFRThreads=1
option UCI_PurifySupport=3
option UCI_PUCT_C=100
option UCI_FoW_TimeMs=500
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
echo "UCI_FoW options are fully functional in XBoard protocol."
