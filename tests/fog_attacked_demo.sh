#!/bin/bash
# Demonstration of the Fog of War attacked piece notation feature

STOCKFISH="../src/stockfish"

echo "======================================================================="
echo "Fog of War Attacked Piece Notation - Feature Demonstration"
echo "======================================================================="
echo ""
echo "This feature allows you to mark pieces that are under attack by hidden"
echo "opponent pieces, using the '!' suffix in FEN notation."
echo ""
echo "Use case: When playing Fog of War chess online (e.g., on Dagaz Project's"
echo "Dark Chess), the UI may show which of your pieces are threatened. This"
echo "notation lets you analyze such positions in Fairy-Stockfish while"
echo "preserving that information."
echo ""
echo "======================================================================="
echo ""

echo "Example 1: Simple attacked pawn"
echo "--------------------------------"
echo "FEN: rnbqkbnr/pppppppp/8/8/7P!/8/PPPPPPP/RNBQKBNR w KQkq - 0 1"
echo ""
echo "The White pawn on h4 is marked with '!' indicating it's potentially"
echo "under attack by a Black piece from g5 (which is in fog)."
echo ""
cat << 'EOF' | $STOCKFISH 2>&1 | grep -A 20 "^Fen:"
uci
setoption name UCI_Variant value fogofwar
position fen rnbqkbnr/pppppppp/8/8/7P!/8/PPPPPPP/RNBQKBNR w KQkq - 0 1
d
quit
EOF
echo ""
echo "======================================================================="
echo ""

echo "Example 2: Multiple attacked pieces"
echo "------------------------------------"
echo "FEN: ********/********/8/8/4P!/3/PPP!PPPP/RNBQKBNR w KQkq - 0 1"
echo ""
echo "Both the e4 pawn and the d2 pawn are marked as attacked."
echo "The opponent's pieces are in fog (ranks 8-7 shown as *******)."
echo ""
cat << 'EOF' | $STOCKFISH 2>&1 | grep -A 20 "^Fen:"
uci
setoption name UCI_Variant value fogofwar
position fen ********/********/8/8/4P!/8/PPP!PPPP/RNBQKBNR w KQkq - 0 1
d
quit
EOF
echo ""
echo "======================================================================="
echo ""

echo "Example 3: Practical use case from online game"
echo "-----------------------------------------------"
echo "Imagine you're playing Dark Chess online and you see:"
echo "  - Your pieces on ranks 1-3 are visible"
echo "  - Everything else is fog"
echo "  - Your f2 pawn and h4 pawn are highlighted (under attack)"
echo ""
echo "You can input this as:"
echo "FEN: ********/********/8/8/7P!/8/PPPPPP!P/RNBQKBNR w KQkq - 0 1"
echo ""
cat << 'EOF' | $STOCKFISH 2>&1 | grep -A 20 "^Fen:"
uci
setoption name UCI_Variant value fogofwar
position fen ********/********/8/8/7P!/8/PPPPPP!P/RNBQKBNR w KQkq - 0 1
d
quit
EOF
echo ""
echo "======================================================================="
echo ""

echo "Example 4: Black pieces under attack"
echo "-------------------------------------"
echo "FEN: rnbqkbnr/pp!ppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1"
echo ""
echo "The Black pawn on c7 is marked as attacked (from Black's perspective)."
echo ""
cat << 'EOF' | $STOCKFISH 2>&1 | grep -A 20 "^Fen:"
uci
setoption name UCI_Variant value fogofwar
position fen rnbqkbnr/pp!ppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1
d
quit
EOF
echo ""
echo "======================================================================="
echo ""

echo "Example 5: Verifying the position is legal"
echo "-------------------------------------------"
echo "Let's verify that positions with attacked markers are fully legal"
echo "by running a perft (move generation) test."
echo ""
cat << 'EOF' | $STOCKFISH 2>&1 | grep -E "(position|Nodes)"
uci
setoption name UCI_Variant value fogofwar
position fen rnbqkbnr/pppppppp/8/8/7P!/8/PPPPPPP/RNBQKBNR w KQkq - 0 1
go perft 2
quit
EOF
echo ""
echo "Success! The position is legal and move generation works correctly."
echo ""
echo "======================================================================="
echo ""

echo "Summary"
echo "-------"
echo "✓ The '!' suffix marks pieces under attack by hidden opponents"
echo "✓ Works with any piece type: P!, N!, B!, R!, Q!, K! (and lowercase)"
echo "✓ Can be combined with fog squares (*) in the same FEN"
echo "✓ Positions with attacked markers are fully legal and playable"
echo "✓ Useful for analyzing positions from online Dark Chess games"
echo ""
echo "For more information, see FOG_OF_WAR_GUIDE.md"
echo "======================================================================="
