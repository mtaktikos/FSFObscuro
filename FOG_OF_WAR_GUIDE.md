# Fog-of-War Chess Guide for Fairy-Stockfish

This guide explains how to play and analyze Fog-of-War (FoW) chess variants using Fairy-Stockfish from the command line.

## What is Fog-of-War Chess?

In Fog-of-War chess, players can only see squares that their pieces can attack or move to. The opponent's pieces on unseen squares are hidden, creating an imperfect information game similar to poker or StarCraft.

## Available FoW Variants

Fairy-Stockfish supports three FoW-based variants:

- **fogofwar**: Standard chess with fog-of-war rules
- **darkcrazyhouse**: Crazyhouse with fog-of-war rules. When you have a piece in hand, all empty squares are visible (you can drop anywhere)
- **darkcrazyhouse2**: Crazyhouse with fog-of-war rules. You can only drop pieces on visible squares (standard FoW vision rules apply)

## Basic Usage (Standard FoW Play)

### Using UCI Protocol

1. Start Fairy-Stockfish and initialize UCI:
```
uci
```

2. Select the FoW variant:
```
setoption name UCI_Variant value fogofwar
```

3. Set up the starting position:
```
position startpos
```

4. Make moves and get the fog view:
```
position startpos moves e2e4
go movetime 1000
```

5. The engine will search and return its best move considering the fog-of-war rules.

### Using CECP/XBoard Protocol

1. Set the protocol:
```
xboard
```

2. Send protocol version:
```
protover 2
```

3. (Optional) Load variants if using fogofwar variant:
```
option VariantPath=variants.ini
```

4. Select the variant:
```
variant fogofwar
```

5. (Optional) Enable FoW Obscuro-style search:
```
option UCI_FoW=1
option UCI_IISearch=1
option UCI_FoW_TimeMs=5000
```

6. Start a new game:
```
new
```

7. (Optional) Display the board:
```
d
```

8. Make your first move:
```
e2e4
```

9. The engine will automatically reply with its move.

10. Continue playing by making moves. The engine will respond after each move.

**Note:** All FoW configuration options are available in XBoard protocol via the `option NAME=VALUE` command. See the "FoW Configuration Options" section below for details.

## Advanced: Obscuro-Style Imperfect Information Search

Fairy-Stockfish includes an advanced search algorithm specifically designed for imperfect information games, based on the Obscuro research paper. This uses game-theoretic search techniques including:

- **Belief state management**: Tracks all possible board states consistent with observations
- **Counterfactual Regret Minimization (CFR)**: Computes Nash equilibrium strategies
- **Knowledge-Limited Subgame Solving (KLUSS)**: Solves local subgames efficiently
- **Game-Theoretic CFR expansion**: Explores the game tree using PUCT selection

### Enabling Obscuro Search

To use the advanced imperfect information search:

```
uci
setoption name UCI_Variant value fogofwar
setoption name UCI_FoW value true
setoption name UCI_IISearch value true
position startpos
go movetime 5000
```

### FoW Configuration Options

The following UCI options control the Obscuro search behavior. These options can be set via UCI protocol using `setoption name NAME value VALUE` or via XBoard/CECP protocol using `option NAME=VALUE`.

#### `UCI_FoW` (default: false)
Enable Fog-of-War search mode. Must be set to `true` to use imperfect information search.

UCI:
```
setoption name UCI_FoW value true
```

XBoard:
```
option UCI_FoW=1
```

#### `UCI_IISearch` (default: true)
Enable Imperfect Information Search. When true, uses the full Obscuro algorithm. When false, uses simplified search.

UCI:
```
setoption name UCI_IISearch value true
```

XBoard:
```
option UCI_IISearch=1
```

#### `UCI_MinInfosetSize` (default: 256, range: 1-10000)
Minimum number of nodes in an information set before expansion. Larger values create bigger subgames, improving solution quality but increasing computation time.

UCI:
```
setoption name UCI_MinInfosetSize value 256
```

XBoard:
```
option UCI_MinInfosetSize=256
```

#### `UCI_ExpansionThreads` (default: 2, range: 1-16)
Number of threads for GT-CFR expansion (PUCT-based game tree exploration). More threads explore more branches in parallel.

UCI:
```
setoption name UCI_ExpansionThreads value 2
```

XBoard:
```
option UCI_ExpansionThreads=2
```

#### `UCI_CFRThreads` (default: 1, range: 1-8)
Number of threads for CFR solving. Typically 1 is sufficient since CFR is memory-bound.

UCI:
```
setoption name UCI_CFRThreads value 1
```

XBoard:
```
option UCI_CFRThreads=1
```

#### `UCI_PurifySupport` (default: 3, range: 1-10)
Maximum support for action purification (max number of actions to consider). Lower values force more deterministic play, higher values allow more mixed strategies.

UCI:
```
setoption name UCI_PurifySupport value 3
```

XBoard:
```
option UCI_PurifySupport=3
```

#### `UCI_PUCT_C` (default: 100, range: 1-1000)
Exploration constant for PUCT selection in GT-CFR. Higher values encourage more exploration, lower values focus on exploitation.

UCI:
```
setoption name UCI_PUCT_C value 100
```

XBoard:
```
option UCI_PUCT_C=100
```

#### `UCI_FoW_TimeMs` (default: 5000, range: 100-600000)
Time budget in milliseconds for FoW search. The planner will use approximately this much time to compute strategies before selecting an action.

UCI:
```
setoption name UCI_FoW_TimeMs value 5000
```

XBoard:
```
option UCI_FoW_TimeMs=5000
```

### Example: Full Configuration

Here's a complete example configuring all FoW options for strong play.

**Using UCI:**
```
uci
setoption name UCI_Variant value fogofwar
setoption name UCI_FoW value true
setoption name UCI_IISearch value true
setoption name UCI_MinInfosetSize value 512
setoption name UCI_ExpansionThreads value 4
setoption name UCI_CFRThreads value 1
setoption name UCI_PurifySupport value 3
setoption name UCI_PUCT_C value 100
setoption name UCI_FoW_TimeMs value 10000
position startpos
go
```

**Using XBoard:**
```
xboard
protover 2
option VariantPath=variants.ini
variant fogofwar
option UCI_FoW=1
option UCI_IISearch=1
option UCI_MinInfosetSize=512
option UCI_ExpansionThreads=4
option UCI_CFRThreads=1
option UCI_PurifySupport=3
option UCI_PUCT_C=100
option UCI_FoW_TimeMs=10000
new
e2e4
```

### Tuning for Different Scenarios

**Fast play (weaker but quick)**:

UCI:
```
setoption name UCI_MinInfosetSize value 128
setoption name UCI_ExpansionThreads value 1
setoption name UCI_FoW_TimeMs value 1000
```

XBoard:
```
option UCI_MinInfosetSize=128
option UCI_ExpansionThreads=1
option UCI_FoW_TimeMs=1000
```

**Strong play (slower but better)**:

UCI:
```
setoption name UCI_MinInfosetSize value 1024
setoption name UCI_ExpansionThreads value 8
setoption name UCI_FoW_TimeMs value 30000
```

XBoard:
```
option UCI_MinInfosetSize=1024
option UCI_ExpansionThreads=8
option UCI_FoW_TimeMs=30000
```

**Blitz/Bullet (very fast)**:

UCI:
```
setoption name UCI_MinInfosetSize value 64
setoption name UCI_ExpansionThreads value 2
setoption name UCI_FoW_TimeMs value 500
```

XBoard:
```
option UCI_MinInfosetSize=64
option UCI_ExpansionThreads=2
option UCI_FoW_TimeMs=500
```

## Playing Dark Crazyhouse Variants

### Dark Crazyhouse

Dark Crazyhouse combines Crazyhouse rules (captured pieces can be dropped back on the board) with Fog-of-War. **When you have a piece in hand, all empty squares become visible**, allowing you to drop anywhere:

```
uci
setoption name UCI_Variant value darkcrazyhouse
setoption name UCI_FoW value true
position startpos
go movetime 5000
```

Key features:
- Not knowing what pieces your opponent has in their hand
- When you capture a piece and have it in hand, you can see all empty squares
- Drops allowed on any empty square when you have pieces
- Managing your own captured pieces while dealing with incomplete information

### Dark Crazyhouse 2

Dark Crazyhouse 2 is a more restrictive variant where **you can only drop pieces on squares you can see** (based on standard FoW vision rules):

```
uci
setoption name UCI_Variant value darkcrazyhouse2
setoption name UCI_FoW value true
position startpos
go movetime 5000
```

Key differences from Dark Crazyhouse:
- Drops restricted to visible squares only
- No automatic visibility of empty squares when holding pieces
- More strategic piece placement required
- Surprise drops only possible in areas your pieces can already see

## Analyzing FoW Positions

To analyze a specific FoW position, use the `position fen` command with a FoW FEN string:

```
uci
setoption name UCI_Variant value fogofwar
setoption name UCI_FoW value true
position fen rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1
go infinite
```

To stop the search:
```
stop
```

## FEN Notation with Fog Squares

Fairy-Stockfish supports a special FEN notation for Fog-of-War positions that includes invisible/fog squares. This allows you to input and analyze positions with incomplete information.

### Asterisk (*) Notation for Fog Squares

In Fog-of-War FEN strings, the asterisk character `*` represents an **invisible or fog square** - a square that the current player cannot see. This notation extends standard FEN to represent imperfect information positions.

**Key points:**
- `*` = invisible/fog square (contents unknown to the player)
- Regular piece letters (e.g., `P`, `n`, `K`) = visible pieces
- Numbers (e.g., `3`, `8`) = visible empty squares
- The engine treats `*` squares as "wall squares" internally

### Complete FEN Examples with Fog Squares

#### Example 1: Starting Position from Black's Perspective
After White plays e2-e4, Black's fog view shows:

```
********/********/********/********/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
```

This FEN represents:
- Black cannot see White's back rank or most of the board (8 asterisks on ranks 8-5)
- Black can see White's starting pawn and piece positions (ranks 2-1)
- All other FEN fields (side to move, castling rights, en passant, etc.) are standard

#### Example 2: Mid-Game Position with Mixed Visibility

```
********/********/2******/Pp*p***1/4P3/4*3/1PPP1PPP/RNBQKBNR w KQkq b6 0 1
```

This FEN represents:
- Ranks 8-7 are completely invisible (fog)
- Rank 6 has 2 visible empty squares, then 6 fog squares
- Rank 5 shows a White pawn on a5, Black pawn on b5, fog on c5, Black pawn on d5, fog on e5-g5, and 1 empty square
- Rank 4 shows a White pawn on e4
- Rank 3 shows fog on e3
- Ranks 2-1 show White's pieces (fully visible)
- En passant square b6 is specified (standard FEN notation)

### Inputting FEN Positions for Analysis

To analyze a position with fog squares, use the standard `position fen` command:

**Using UCI Protocol:**
```
uci
setoption name UCI_Variant value fogofwar
setoption name UCI_FoW value true
position fen ********/********/2******/Pp*p***1/4P3/4*3/1PPP1PPP/RNBQKBNR w KQkq b6 0 1
go movetime 5000
```

**Using XBoard Protocol:**
```
xboard
protover 2
option VariantPath=variants.ini
variant fogofwar
option UCI_FoW=1
option UCI_IISearch=1
setboard ********/********/2******/Pp*p***1/4P3/4*3/1PPP1PPP/RNBQKBNR w KQkq b6 0 1
```

### Getting Fog FEN from a Complete Position

You can convert a complete (perfect information) FEN to a fog FEN showing what one player sees using the `get_fog_fen()` function in the Python bindings:

```python
import pyffish as sf

# Complete position FEN
complete_fen = "rnbqkbnr/p1p2ppp/8/Pp1pp3/4P3/8/1PPP1PPP/RNBQKBNR w KQkq b6 0 1"

# Get what White sees (from White's perspective)
white_fog_fen = sf.get_fog_fen(complete_fen, "fogofwar")
print("White sees:", white_fog_fen)
# Output: ********/********/2******/Pp*p***1/4P3/4*3/1PPP1PPP/RNBQKBNR w KQkq b6 0 1
```

The `get_fog_fen()` function:
- Takes a complete FEN and variant name as input
- Returns a FEN with `*` characters marking squares invisible to the current player
- Visibility is computed based on:
  - Squares occupied by the player's pieces
  - Squares the player's pieces can move to or attack
  - Special fog-of-war rules (pawn diagonal vision, blocking, etc.)

### Visibility Rules and Attacked Squares

**Important:** You do **not** need to manually specify which squares are attacked by the opponent. The engine automatically computes visibility based on piece positions and fog-of-war rules:

1. **Visible squares** (shown as pieces or empty):
   - Squares occupied by your own pieces
   - Squares your pieces can move to
   - Squares your pieces can attack
   - Empty squares along piece attack paths (until blocked)

2. **Invisible squares** (shown as `*`):
   - All other squares on the board
   - Opponent pieces in fog (unknown pieces)
   - Empty squares you cannot see

3. **Automatic computation:**
   - The engine computes which squares each player can see
   - When you input a FEN with `*`, the engine knows those squares are unknown
   - When analyzing, the engine considers all possible piece arrangements in fog squares
   - Attacked squares are determined by the game rules and visible piece positions

### Special Cases

#### Pawn Diagonal Vision
Pawns reveal their diagonal attack squares even if empty:
```python
fen = "8/8/8/8/3P4/8/8/K6k w - - 0 1"
fog_fen = sf.get_fog_fen(fen, "fogofwar")
# The pawn on d4 reveals c5 and e5 (diagonals) even though they're empty
```

#### Blocked Pieces
Pieces can see the first blocking piece but not squares beyond:
```python
fen = "8/8/8/3p4/3R4/8/8/K6k w - - 0 1"
fog_fen = sf.get_fog_fen(fen, "fogofwar")
# The rook on d4 sees the pawn on d5 but not d6, d7, d8
```

#### En Passant Visibility
The en passant square is visible if you have a pawn that can capture it:
```python
fen = "rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 1"
fog_fen = sf.get_fog_fen(fen, "fogofwar")
# The e5 pawn reveals the d6 en passant square
```

### Use Cases for FEN with Fog Squares

1. **Position Analysis:** Input a specific fog situation to analyze the best moves
2. **Game State Reconstruction:** Recreate a game position from a player's perspective
3. **Testing:** Create test positions with specific visibility configurations
4. **Teaching:** Demonstrate fog-of-war concepts with concrete examples
5. **Debugging:** Verify the engine's visibility computation for edge cases

## Viewing the Fog-of-War Board State

The engine internally tracks what each player can see. When making moves via UCI, the engine automatically:
1. Updates the true game state
2. Computes visibility for the side to move
3. Builds a belief state (set of consistent positions)
4. Searches over the belief state to find the best move

Note: The standard UCI protocol does not have a built-in command to display the fog view from the command line. To get the fog view, you would need to use a GUI that supports FoW or query via the pyffish Python bindings:

```python
import pyffish as sf

fen = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
fog_fen = sf.get_fog_fen(fen, "fogofwar")
print(fog_fen)  # Shows what black sees (e.g., "********/********/...")
```

## NNUE Evaluation

All three FoW variants use NNUE (neural network) evaluation:

- **fogofwar**: Uses standard chess NNUE
- **darkcrazyhouse**: Uses crazyhouse NNUE
- **darkcrazyhouse2**: Uses crazyhouse NNUE

The Obscuro search algorithm (CFR, KLUSS, GT-CFR) is for **search** (deciding which positions to evaluate), while NNUE is for **evaluation** (scoring individual positions). They work together seamlessly:
- The search explores the game tree and belief states
- NNUE evaluates leaf positions to guide the search
- The fact that pieces use "commoner" instead of "king" doesn't affect NNUE

**Note**: NNUE networks are trained on complete-information games. In FoW positions, NNUE evaluates each possible board state in the belief set as if it were a standard chess/crazyhouse position. The search algorithm then aggregates these evaluations to make decisions under uncertainty.

## FoW Rules Summary

From the Obscuro paper (Appendix A), the key fog-of-war rules are:

1. **Vision**: You see all squares your pieces can attack or move to
2. **Pawn vision**: Pawns reveal their diagonal attack squares (even if empty)
3. **Blocked pieces**: You see the blocking piece but not squares beyond it
4. **En passant**: The en passant square is revealed if you have a pawn that can capture it
5. **Castling**: You can only castle if you can see that the king/rook haven't moved
6. **Check**: You may not know you're in check if the attacking piece is in fog

## Performance Tips

1. **Time management**: Set `UCI_FoW_TimeMs` appropriately for your time control
2. **Thread allocation**: More expansion threads help with complex positions
3. **Information set size**: Larger values are better for endgames, smaller for opening/middlegame
4. **Purification support**: Keep at 3 for balanced play, reduce to 1-2 for more tactical positions

## Troubleshooting

**Engine is too slow**: Reduce `UCI_MinInfosetSize`, `UCI_ExpansionThreads`, or `UCI_FoW_TimeMs`

**Engine plays poorly**: Increase `UCI_MinInfosetSize` and `UCI_FoW_TimeMs`, add more `UCI_ExpansionThreads`

**Engine doesn't respond**: Make sure you set `position startpos` or `position fen ...` after selecting the variant

**FoW search not working**: Verify both `UCI_FoW value true` and `UCI_IISearch value true` are set

## References

- Obscuro paper: "Optimal play in imperfect-information games using counterfactual regret minimization"
- FoW chess rules: See paper Appendix A
- UCI protocol: http://wbec-ridderkerk.nl/html/UCIProtocol.html
- Fairy-Stockfish: https://github.com/fairy-stockfish/Fairy-Stockfish

## Implementation Status

The current implementation includes:
- ✅ Core Obscuro algorithm (CFR, KLUSS, GT-CFR)
- ✅ FoW visibility computation (Appendix A rules)
- ✅ Belief state management
- ✅ UCI integration and options
- ✅ Multi-threaded search
- ⚠️ Belief enumeration (simplified - currently stores true position only)
- ⚠️ Action purification (placeholder implementation)
- 🔲 Full KLUSS order-2 neighborhood computation
- 🔲 Instrumentation (Appendix B.4 metrics)

For development status and technical details, see `OBSCURO_FOW_IMPLEMENTATION.md`.
