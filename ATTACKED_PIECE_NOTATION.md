# Attacked Piece Notation for Fog of War Chess

## Overview

This document describes the extended FEN notation for marking pieces under attack in Fog of War Chess variants.

## Problem Statement

When playing Fog of War Chess online (e.g., on https://dagazproject.github.io/checkmate/dark-chess.htm), game UIs often indicate which of your pieces are under attack by hidden opponent pieces (typically shown brighter or highlighted). The standard FEN notation with asterisks (`*`) for fog squares cannot represent this information, making it impossible to analyze such positions with that context.

## Solution: Extended FEN Notation

We extend FEN notation with the `!` suffix to mark pieces under attack:

### Notation

- **Regular pieces**: `P`, `p`, `N`, `n`, `B`, `b`, `R`, `r`, `Q`, `q`, `K`, `k`
  - Pieces that are not under attack or are visible pieces in standard positions
  
- **Attacked pieces**: `P!`, `p!`, `N!`, `n!`, `B!`, `b!`, `R!`, `r!`, `Q!`, `q!`, `K!`, `k!`
  - Pieces under attack by hidden opponent pieces in fog squares
  
- **Fog squares**: `*`
  - Invisible/unknown squares (existing notation)

### Examples

#### Example 1: Simple Attacked Pawn
```
rnbqkbnr/pppppppp/8/8/7P!/8/PPPPPPP/RNBQKBNR w KQkq - 0 1
```
The White pawn on h4 (shown as `P!`) is under attack by a hidden Black piece.

#### Example 2: Multiple Attacked Pieces
```
********/********/8/8/4P!/8/PPP!PPPP/RNBQKBNR w KQkq - 0 1
```
Both the e4 pawn and d2 pawn are marked as attacked. The opponent's position is completely hidden (fog on ranks 8-7).

#### Example 3: Black Pieces Under Attack
```
rnbqkbnr/pp!ppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1
```
From Black's perspective, the c7 pawn is under attack by a hidden White piece.

## Use Cases

### 1. Online Game Analysis
You're playing Dark Chess online and your UI shows:
- Your h2 pawn is highlighted (under attack)
- Most of the board is fog
- You want to analyze the position in Fairy-Stockfish

**Solution**: Input the position with attacked piece notation:
```
position fen ********/********/8/8/8/8/PPPPPP!P/RNBQKBNR w KQkq - 0 1
```

### 2. Position Study
You're studying Fog of War tactics and want to document positions where pieces are threatened from fog squares.

### 3. Game Notation
Recording games where the UI provided attacked piece information, preserving that context for later analysis.

## Implementation Details

### FEN Parsing
The parser consumes the `!` character after piece letters but treats it as metadata. The piece is placed normally on the board, and the `!` marker indicates additional context about the fog-of-war situation.

**Code location**: `src/position.cpp` line ~320

### FEN Generation
When generating FEN with the `attackedPieces` bitboard parameter, pieces on squares in that bitboard are marked with `!`.

**Code location**: `src/position.cpp` line ~692

### Attacked Piece Detection
The `compute_attacked_pieces()` function determines which pieces could potentially be under attack from fog squares by checking if any fog square could contain an opponent piece that attacks them.

**Code location**: `src/imperfect/Visibility.cpp`

### Python API
```python
import pyffish as sf

# Get fog FEN with attacked pieces marked
fog_fen = sf.get_fog_fen(complete_fen, "fogofwar", mark_attacked=True)
```

The `mark_attacked` parameter (default: `False`) enables automatic computation and marking of attacked pieces.

## Technical Considerations

### 1. Conservative Detection
The `compute_attacked_pieces()` function is conservative - it marks a piece as potentially attacked if there's any fog square from which an opponent piece could theoretically attack it. This may over-estimate threats but ensures no attacks are missed.

### 2. Compatibility
- Positions with `!` markers are fully legal and can be analyzed normally
- The `!` marker is optional - standard FEN without it works as before
- Existing tools that don't understand `!` may ignore it or treat it as syntax error (depending on their parser strictness)

### 3. Performance
The attacked piece computation is lightweight and uses existing attack detection infrastructure. It does not significantly impact performance.

## Testing

### Test Suite: `tests/fog_attacked_notation.sh`
Comprehensive test suite covering:
1. Parsing FEN with single attacked piece
2. Parsing FEN with multiple attacked pieces  
3. Black attacked pieces (lowercase)
4. Attacked knights and other piece types
5. Combining fog squares and attacked pieces
6. Position legality verification
7. Standard gameplay compatibility
8. Edge cases

**All tests pass**: 8/8 ✓

### Demonstration: `tests/fog_attacked_demo.sh`
Interactive demonstration showing practical examples and use cases.

## Documentation

See `FOG_OF_WAR_GUIDE.md` for complete user documentation including:
- Extended FEN notation explanation
- Usage examples
- Python API documentation
- Practical use cases
- Integration with online games

## API Reference

### C++ API

```cpp
// Position.h
std::string fen(bool sfen = false, 
                bool showPromoted = false, 
                int countStarted = 0, 
                std::string holdings = "-", 
                Bitboard fogArea = 0, 
                Bitboard attackedPieces = 0) const;

// Visibility.h (FogOfWar namespace)
Bitboard compute_attacked_pieces(const Position& pos, 
                                  const VisibilityInfo& vi);
```

### Python API

```python
pyffish.get_fog_fen(fen, variant, chess960=False, mark_attacked=False)
```

**Parameters**:
- `fen`: Complete FEN string
- `variant`: Variant name (e.g., "fogofwar")
- `chess960`: Whether position is Chess960 (default: False)
- `mark_attacked`: Whether to mark attacked pieces with `!` (default: False)

**Returns**: Fog FEN string with `*` for fog squares and optionally `!` for attacked pieces

## Compatibility Notes

### Backward Compatibility
- ✅ Existing FEN strings work exactly as before
- ✅ The `!` marker is optional
- ✅ Code without `attackedPieces` parameter works unchanged (defaults to 0)

### Forward Compatibility
- FEN strings with `!` markers can be parsed by the updated engine
- Older versions may reject `!` markers (depending on parser implementation)
- External tools may need updates to handle `!` notation

## Future Enhancements

### Potential Additions
1. **Belief state integration**: Use attacked piece information to refine belief states in imperfect information search
2. **Strategic analysis**: Develop tactics and strategies specifically for positions with known attacked pieces
3. **UI integration**: Standardize the notation for use in graphical chess variant UIs
4. **Extended metadata**: Additional markers for other fog-of-war contexts (e.g., pieces that just moved)

## References

- Original issue: Request for notation to indicate attacked squares in FoW
- Dagaz Dark Chess: https://dagazproject.github.io/checkmate/dark-chess.htm
- Fog of War rules: See `OBSCURO_FOW_IMPLEMENTATION.md`
- User guide: See `FOG_OF_WAR_GUIDE.md`

## Conclusion

The attacked piece notation (`!` suffix) provides a simple, intuitive way to preserve context about threatened pieces when analyzing Fog of War positions. It bridges the gap between online game UIs that show this information and chess analysis engines that need it for accurate position evaluation.
