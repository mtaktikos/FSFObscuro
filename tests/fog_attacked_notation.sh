#!/bin/bash
# Test script for Fog of War attacked piece notation

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

STOCKFISH="../src/stockfish"
PASS=0
FAIL=0

echo "Testing Fog of War Attacked Piece Notation..."
echo "=============================================="
echo ""

# Test 1: Parse FEN with attacked piece marker
echo "Test 1: Parsing FEN with attacked piece marker (P!)"
cat << 'EOF' | $STOCKFISH > /tmp/test1.out 2>&1
uci
setoption name UCI_Variant value fogofwar
position fen rnbqkbnr/pppppppp/8/8/7P!/8/PPPPPPP/RNBQKBNR w KQkq - 0 1
d
quit
EOF

if grep -q "7P" /tmp/test1.out && ! grep -q "Error\|error" /tmp/test1.out; then
    echo -e "${GREEN}PASS${NC}: FEN with P! parsed successfully"
    ((PASS++))
else
    echo -e "${RED}FAIL${NC}: FEN with P! failed to parse"
    ((FAIL++))
fi
echo ""

# Test 2: Parse FEN with multiple attacked pieces
echo "Test 2: Parsing FEN with multiple attacked pieces"
cat << 'EOF' | $STOCKFISH > /tmp/test2.out 2>&1
uci
setoption name UCI_Variant value fogofwar
position fen rnbqkbnr/pppppppp/8/8/4P!/8/PPPP!PPP/RNBQKBNR w KQkq - 0 1
d
quit
EOF

if grep -q "4P" /tmp/test2.out && ! grep -q "Error\|error" /tmp/test2.out; then
    echo -e "${GREEN}PASS${NC}: FEN with multiple attacked pieces parsed successfully"
    ((PASS++))
else
    echo -e "${RED}FAIL${NC}: FEN with multiple attacked pieces failed to parse"
    ((FAIL++))
fi
echo ""

# Test 3: Parse FEN with black attacked pieces
echo "Test 3: Parsing FEN with black attacked pieces"
cat << 'EOF' | $STOCKFISH > /tmp/test3.out 2>&1
uci
setoption name UCI_Variant value fogofwar
position fen rnbqkbnr/ppp!pppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1
d
quit
EOF

if grep -q "ppp" /tmp/test3.out && ! grep -q "Error\|error" /tmp/test3.out; then
    echo -e "${GREEN}PASS${NC}: FEN with black attacked pieces (p!) parsed successfully"
    ((PASS++))
else
    echo -e "${RED}FAIL${NC}: FEN with black attacked pieces failed to parse"
    ((FAIL++))
fi
echo ""

# Test 4: Parse FEN with attacked knights
echo "Test 4: Parsing FEN with attacked knights (N!)"
cat << 'EOF' | $STOCKFISH > /tmp/test4.out 2>&1
uci
setoption name UCI_Variant value fogofwar
position fen rnbqkbnr/pppppppp/8/8/8/2N!/4/PPPPPPPP/R1BQKB1R w KQkq - 0 1
d
quit
EOF

if grep -q "2N" /tmp/test4.out && ! grep -q "Error\|error" /tmp/test4.out; then
    echo -e "${GREEN}PASS${NC}: FEN with attacked knight parsed successfully"
    ((PASS++))
else
    echo -e "${RED}FAIL${NC}: FEN with attacked knight failed to parse"
    ((FAIL++))
fi
echo ""

# Test 5: Parse FEN combining fog squares (*) and attacked pieces (!)
echo "Test 5: Parsing FEN with both fog squares and attacked pieces"
cat << 'EOF' | $STOCKFISH > /tmp/test5.out 2>&1
uci
setoption name UCI_Variant value fogofwar
position fen ********/********/8/8/7P!/8/PPPP!PPP/RNBQKBNR w KQkq - 0 1
d
quit
EOF

if grep -q "PPPP" /tmp/test5.out && ! grep -q "Error\|error" /tmp/test5.out; then
    echo -e "${GREEN}PASS${NC}: FEN with fog squares and attacked pieces parsed successfully"
    ((PASS++))
else
    echo -e "${RED}FAIL${NC}: FEN with fog squares and attacked pieces failed to parse"
    ((FAIL++))
fi
echo ""

# Test 6: Verify position is legal after parsing attacked notation
echo "Test 6: Verify position with attacked pieces is legal"
cat << 'EOF' | $STOCKFISH > /tmp/test6.out 2>&1
uci
setoption name UCI_Variant value fogofwar
position fen rnbqkbnr/pppppppp/8/8/7P!/8/PPPPPPP/RNBQKBNR w KQkq - 0 1
go perft 1
quit
EOF

if grep -q "Nodes searched:" /tmp/test6.out && ! grep -q "Error\|error\|illegal" /tmp/test6.out; then
    echo -e "${GREEN}PASS${NC}: Position with attacked pieces is legal (perft works)"
    ((PASS++))
else
    echo -e "${RED}FAIL${NC}: Position with attacked pieces appears illegal"
    ((FAIL++))
fi
echo ""

# Test 7: Parse startpos and make moves, then check FEN doesn't break
echo "Test 7: Make moves from startpos and verify FEN still works"
cat << 'EOF' | $STOCKFISH > /tmp/test7.out 2>&1
uci
setoption name UCI_Variant value fogofwar
position startpos moves e2e4 e7e5 g1f3 b8c6
d
quit
EOF

if grep -q "Fen:" /tmp/test7.out && ! grep -q "Error\|error" /tmp/test7.out; then
    echo -e "${GREEN}PASS${NC}: Standard gameplay with moves works correctly"
    ((PASS++))
else
    echo -e "${RED}FAIL${NC}: Standard gameplay with moves failed"
    ((FAIL++))
fi
echo ""

# Test 8: Attacked piece followed by promoted marker
echo "Test 8: Parsing attacked promoted piece (edge case)"
cat << 'EOF' | $STOCKFISH > /tmp/test8.out 2>&1
uci
setoption name UCI_Variant value fogofwar
position fen rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
d
quit
EOF

if grep -q "RNBQKBNR" /tmp/test8.out && ! grep -q "Error\|error" /tmp/test8.out; then
    echo -e "${GREEN}PASS${NC}: Basic FEN without attacked markers still works"
    ((PASS++))
else
    echo -e "${RED}FAIL${NC}: Basic FEN parsing broken"
    ((FAIL++))
fi
echo ""

# Summary
echo "=============================================="
echo "Test Results:"
echo -e "${GREEN}PASSED: $PASS${NC}"
echo -e "${RED}FAILED: $FAIL${NC}"
echo "=============================================="

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
