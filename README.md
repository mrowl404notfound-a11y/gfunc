# gfunc

**Universal Function Call Graph Tool** — Fast, accurate function search across Solidity, Rust, Move, and Go.

Uses ripgrep for speed + smart parsing for accuracy. Properly handles `module::func()`, `contract.func()`, `Self::func()` patterns.

![Python](https://img.shields.io/badge/Python-3.8+-blue)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Features

- **Multi-language** — Solidity, Rust, Move, Go (auto-detected)
- **Call graph analysis** — Find callers, callees, and cross-references
- **Super Slice** — Extract a function with all its dependencies, callers, types, and security notes
- **Smart parsing** — Handles comments, strings, block comments, qualified calls
- **Fast** — Uses `ripgrep` for file discovery, Python for parsing
- **Zero dependencies** — Pure Python 3.8+, only needs `ripgrep` (optional, falls back to Python glob)

## Installation

```bash
# One-liner install
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/gfunc/main/install.sh | bash

# Or clone and install manually
git clone https://github.com/YOUR_USERNAME/gfunc.git
cd gfunc
chmod +x install.sh
./install.sh
```

### Requirements

- **Python 3.8+**
- **ripgrep** (`rg`) — optional but recommended for speed

```bash
# Install ripgrep (if not already installed)
# Ubuntu/Debian
sudo apt install ripgrep

# macOS
brew install ripgrep

# Arch
sudo pacman -S ripgrep
```

## Usage

### Basic Search — Find definitions + callers

```bash
gfunc deposit src/
gfunc transfer .
gfunc swap                    # searches current directory
```

### Exact Match

```bash
gfunc transfer --exact        # only "transfer", not "transferFrom"
gfunc -e swap .
```

### Callers — Who calls this function?

```bash
gfunc --callers-of swap .
gfunc --callers-of deposit src/
```

### Callees — What does this function call?

```bash
gfunc --callees-of main .
gfunc --callees-of swap src/
```

### Cross-References — Callers + Callees combined

```bash
gfunc --xrefs withdraw .
```

### Super Slice — Full function with dependencies

The killer feature. Extracts a function with:
- Call graph visualization
- Full source code with line numbers
- All called functions (resolved recursively, 3 levels deep)
- Struct/type definitions from the same file
- Security notes (critical function detection, access control, complexity)

```bash
gfunc --slice swap .
gfunc --slice mint src/
gfunc --slice deposit -o slices/    # save to file
```

**Example output:**

```
# 🎯 SUPER SLICE: `swap()`

| | |
|---|---|
| **File** | `src/SwapVM.sol` |
| **Lines** | 127–185 |
| **Contract** | `SwapVM` |
| **Access** | `public` (no restrictions) |
| **Criticality** | 🔴 CRITICAL |

## 🔗 Call Graph

  quote()       ──▶  swap()       [src/Router.sol:45]
  fillOrder()   ──▶  swap()       [src/Executor.sol:78]
                     │
                     ├──▶  hash()
                     ├──▶  runLoop()
                     ├──▶  _transferIn()
                     └──▶  _transferOut()
```

### Force Language

```bash
gfunc --lang solidity swap .
gfunc --lang rust deposit .
gfunc --lang move transfer .
gfunc --lang go handler .
```

### JSON Output

```bash
gfunc --json deposit .
gfunc --callers-of swap --json .
```

### Include Test Files

By default, test directories are excluded. To include them:

```bash
gfunc --include-tests swap .
gfunc -t deposit .
```

## Supported Languages

| Language | Extensions | Qualified Calls | Example |
|----------|-----------|----------------|---------|
| **Solidity** | `.sol` | `contract.func()` | `token.transfer()` |
| **Rust** | `.rs` | `module::func()` | `Self::deposit()` |
| **Move** | `.move` | `module::func()` | `coin::transfer()` |
| **Go** | `.go`, `.gno` | `pkg.Func()` | `bank.Send()` |

## Excluded Directories

By default, these directories are skipped:

`node_modules`, `target`, `build`, `out`, `.git`, `vendor`, `lib`, `artifacts`, `cache`, `typechain`, `coverage`, `deployments`, `__pycache__`, `.next`, `dist`

Test directories (skipped unless `--include-tests`):

`test`, `tests`, `test_`, `_test`, `testing`, `fixtures`, `mocks`, `mock`, `testdata`, `testutil`, `testutils`

## All Options

```
gfunc <name> [path]                # Find definitions + callers
gfunc --callers-of <name> [path]   # Who calls this function
gfunc --callees-of <name> [path]   # What this function calls
gfunc --xrefs <name> [path]        # Callers + callees combined
gfunc --slice <name> [path]        # Full function slice with deps
gfunc --exact / -e                 # Exact name match
gfunc --lang solidity              # Force language
gfunc --json / -j                  # JSON output
gfunc --include-tests / -t         # Include test files
gfunc --defs-only / -d             # Only show definitions
gfunc --calls-only / -c            # Only show call references
gfunc --no-color                   # Disable colored output
gfunc -o <dir>                     # Output directory for slices
```

## Use Cases

### Smart Contract Auditing

```bash
# Find all entry points for a swap function
gfunc --slice swap src/

# Track who calls a critical admin function
gfunc --callers-of setOwner .

# Understand a function's full dependency tree
gfunc --slice withdraw -o audit_slices/
```

### Code Exploration

```bash
# Quickly understand a new codebase
gfunc transfer .          # Find all transfer-related functions
gfunc --xrefs deposit .   # See full context of deposit
```

### Bug Hunting

```bash
# Slice every external function for review
for func in swap deposit withdraw; do
  gfunc --slice $func -o slices/
done
```

## License

MIT License — see [LICENSE](LICENSE)




curl -s --max-time 10 "https://1.1.1.1/dns-query?name=idos.network&type=A" -H "accept: application/dns-json" | python3 -m json.tool 2>/dev/null
