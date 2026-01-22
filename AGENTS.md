# AGENTS.md

## Purpose
- This repo ships an iOS lock screen tweak plus a PreferenceLoader bundle.
- Theos builds the tweak and the preference bundle.
- Swift is the primary language, with small Objective-C shims for Orion.
- There is no dedicated test suite or lint pipeline in this repo.

## Repository layout
- Tweak sources: `Sources/Mooner` (Swift) and `Sources/MoonerC` (ObjC/C).
- Preference bundle: `mooner/Sources/mooner` (Swift) and `mooner/Sources/moonerC`.
- Preference bundle resources: `mooner/Resources` and `mooner/layout`.
- Theos packaging metadata: `control` and `Mooner.plist`.
- SwiftPM manifest for IDEs: `Package.swift` and `mooner/Package.swift`.

## Build, lint, test
### Prereqs
- Theos must be installed and `THEOS` must be set.
- Run `make spm` once to generate `.theos/spm_config` for SwiftPM support.
- Device-side install commands require a connected device or SSH target.
- Windows builds require a macOS environment (VM or CI); Swift/SDK tooling is macOS-only.

### Building on Windows (WSL + macOS VM)
- Use WSL for repo management (git, editing), but build inside a macOS VM.
- Share the repo folder with the VM (e.g., via SMB or a synced folder).
- Install Xcode, Command Line Tools, and Theos in the macOS VM.
- Run `make spm` once, then `make`/`make package` inside the VM.
- Copy the generated `.deb` from `packages/` back to Windows if needed.

### Build tweak + preference bundle (root)
- `make` builds the tweak and the preference bundle.
- `make package` creates the .deb package.
- `make install` installs on the target device.
- `make clean` cleans build artifacts.
- `make spm` generates SwiftPM config for Xcode/IDE indexing.
- `make package install` is acceptable if you need a quick rebuild + deploy.
- The root Makefile already pulls in the `mooner` subproject.

### Build preference bundle only
- `make` from `mooner` builds the preference bundle only.
- `make package` from `mooner` packages the preference bundle.
- `make install` from `mooner` installs the bundle only.
- Use this path when iterating on Settings UI without touching the tweak.

### SwiftPM (IDE/typecheck only)
- `swift build` after `make spm` can be used for IDE type-checking.
- SwiftPM is not the authoritative build for Theos packaging.
- SwiftPM uses Theos-generated flags, so keep `.theos/spm_config` fresh.

### Lint/format
- No lint or formatting tooling is configured in this repo.
- Follow the existing formatting and naming conventions manually.

### Tests
- No automated tests are present.
- There is no single-test runner configured.
- If you add tests later, document the exact command here.

### Packaging notes
- `control` defines the package metadata used by Theos.
- `Mooner.plist` provides tweak metadata for installation tooling.
- Update package version strings consistently when releasing.

## Code style and conventions
### Swift basics
- Indent with 4 spaces; keep braces on the same line.
- Use `let` by default and `var` only when mutation is required.
- Prefer explicit types for public APIs or when inference is unclear.
- Keep one blank line between logical sections (types, helpers, hooks).
- Use trailing closures where it improves readability.
- Keep `if`/`else if`/`else` aligned and avoid deep nesting.
- Prefer guard statements for early exits when it clarifies flow.
- Keep lines reasonably short; wrap long call chains.

### SwiftUI layout
- Keep view modifier chains on new lines, one modifier per line.
- Use `VStack`/`HStack` alignment parameters explicitly when needed.
- Keep constants near the view that uses them (colors, opacities).
- Avoid excessive `Spacer()` usage; add only when needed for layout.
- Preserve the current visual hierarchy; avoid reflowing the layout casually.
- Use `@State`/`@ObservedObject` consistently for view state.

### Hooking and Orion
- Group hooks by iOS version using `HookGroup` types.
- Use `ClassHook` subclasses for view/controller hooks.
- Always call `orig` before or after custom logic, matching existing pattern.
- Avoid heavy logic in hooks; delegate to helper functions when possible.
- Keep hook methods short and prefer helper functions for formatting.
- Keep hook state in module-level vars only when required by Orion.

### Objective-C/C
- Use `#import <...>` for system frameworks and Orion headers.
- Keep Objective-C shims minimal and focused on interop.
- Keep C/ObjC files ARC-friendly (`-fobjc-arc` already set in Makefile).
- Mirror Swift naming when exposing symbols to Swift.
- Keep function-level comments brief and only when behavior is non-obvious.

### Imports
- Order imports as: hooking frameworks, Apple frameworks, local modules.
- Examples: `import Orion`, then `SwiftUI/UIKit`, then `MoonerC`/`moonerC`.
- Remove unused imports; keep import blocks compact and unspaced.
- In Objective-C, prefer `#import` over `@import` for consistency.

### Formatting details
- Use one space after `//` in comments.
- Avoid trailing whitespace and stray blank lines at file ends.
- Keep method signatures on a single line when reasonable.
- Avoid semicolons in Swift; follow the current Swift style.
- Align closing braces with the owning declaration.
- Keep SwiftUI modifier chains aligned under the view.

### Naming
- Types and protocols: UpperCamelCase (e.g., `RootListController`).
- Methods and properties: lowerCamelCase.
- Bool properties start with `is`, `has`, or `should`.
- Preference keys are lowerCamelCase and live in `UserDefaults` suite.
- Use descriptive hook class names with iOS version prefixes when needed.
- Avoid abbreviations unless they are common in iOS APIs.

### Error handling
- Use defaults when reading preferences to keep tweak stable.
- Avoid force unwraps unless you are sure values are present at runtime.
- Reserve `fatalError` for build-time or configuration errors only.
- For C/ObjC interop, validate pointers before use when practical.
- Prefer nil-coalescing for preference reads and defaults.

### Runtime behavior
- Keep UI updates on the main thread when touching UIKit.
- Avoid heavy work in `viewDidLoad`/`didMoveToWindow` hooks.
- Prefer cached formatters or lightweight helpers when feasible.

### Preferences and plist data
- Preference suite: `com.now.moonerprefs` (keep consistent everywhere).
- Keep preference keys and defaults in sync with UI specifiers.
- Update `mooner/layout/Library/PreferenceLoader/Preferences/mooner.plist`
  when changing bundle names or controller classes.
- Root specifiers live in `mooner/Resources/Root.plist`.
- Use `PSListController` subclasses for settings controllers.

### Files and organization
- Tweak Swift code belongs in `Sources/Mooner`.
- Preference bundle Swift code belongs in `mooner/Sources/mooner`.
- C/ObjC headers live in `Sources/*C/include`.
- Keep module map updates in the `include` folder if needed.
- Keep Theos build flags local to Makefiles.
- Keep assets in `mooner/Resources` and reference them in plists.

## Cursor/Copilot rules
- No `.cursor/rules`, `.cursorrules`, or `.github/copilot-instructions.md` found.
- If rules are added later, mirror them in this document.

## Notes for agentic changes
- Do not reformat entire files; keep changes localized.
- Preserve existing API and preference key names unless required.
- When adding hooks, consider iOS 15/16 split used in `Tweak.x.swift`.
- Update Theos packaging metadata if you add new bundles or binaries.
