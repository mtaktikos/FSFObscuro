# XBoard Support for UCI_FoW Options

## Summary

This document describes the implementation that enables all UCI_FoW options to work in the XBoard/CECP protocol, allowing users to use Fog-of-War search features without needing to switch to UCI protocol.

## Problem Statement

The FOG_OF_WAR_GUIDE.md mentioned several UCI options for analyzing fogofwar variants:
- UCI_Variant
- UCI_FoW
- UCI_IISearch
- UCI_MinInfosetSize
- UCI_ExpansionThreads
- UCI_CFRThreads
- UCI_PurifySupport
- UCI_PUCT_C
- UCI_FoW_TimeMs

These options were advertised in XBoard protocol via `feature option` commands, and could be set using the `option NAME=VALUE` command. However, they were not actually being used during gameplay because the XBoard `go()` function only invoked the normal search algorithm, not the FoW planner.

## Solution

### Code Changes

The solution involved modifying `src/xboard.cpp` to check for UCI_FoW options and invoke the FoW planner when appropriate:

1. **Added FoW planner header**: `#include "imperfect/Planner.h"`

2. **Modified StateMachine::go()**: Added logic to:
   - Check if `UCI_FoW` and `UCI_IISearch` options are enabled
   - Configure FoW planner with all UCI_FoW options
   - Invoke the planner and output the move in XBoard format
   - Handle the `moveAfterSearch` flag properly
   - Fall back to normal search if the planner returns MOVE_NONE

### How It Works

When a game is played in XBoard protocol:

1. User sets options: `option UCI_FoW=1`, `option UCI_IISearch=1`, etc.
2. User starts a game with `new` and makes a move
3. XBoard's `go()` function is called
4. The function checks if FoW mode is enabled
5. If yes, it configures and invokes the FoW planner
6. The planner returns a move, which is output and applied
7. If the planner returns MOVE_NONE, it falls back to normal search

### Compatibility

- All other XBoard commands (`d`, `st`, `variant`, etc.) continue to work normally
- UCI protocol behavior is unchanged
- Users can freely switch between UCI and XBoard protocols

## Usage Examples

### Basic Usage

```
xboard
protover 2
option VariantPath=variants.ini
variant fogofwar
option UCI_FoW=1
option UCI_IISearch=1
new
e2e4
```

### Advanced Configuration

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
st 10
e2e4
```

## Testing

A comprehensive test suite was created in `tests/fow_xboard_test.sh` that verifies:

1. All 8 UCI_FoW options are advertised in XBoard protocol
2. Options can be set via the `option NAME=VALUE` command
3. Engine responds with moves after configuring FoW options
4. Other XBoard commands remain functional
5. All tests pass successfully

Run the test suite:
```bash
cd src
bash ../tests/fow_xboard_test.sh
```

## Documentation

The FOG_OF_WAR_GUIDE.md has been updated with:
- XBoard protocol usage instructions
- Both UCI and XBoard syntax for all options
- Complete configuration examples
- Tuning scenarios with XBoard commands

## Known Limitations

The FoW planner implementation may return MOVE_NONE in some cases. When this happens, the code falls back to normal search to ensure the game can continue. This is a limitation of the FoW planner implementation itself, not the XBoard integration.

## Files Modified

- `src/xboard.cpp`: Added FoW planner integration
- `FOG_OF_WAR_GUIDE.md`: Updated with XBoard examples
- `.gitignore`: Added to exclude build artifacts
- `tests/fow_xboard_test.sh`: New test suite for XBoard FoW support

## Conclusion

All UCI_FoW options now work seamlessly in both UCI and XBoard protocols. Users can configure and use FoW search features without needing to use UCI protocol, achieving the goal specified in the problem statement.
