# WellSpent Extension Kit

What an extension to [WellSpent Budget](https://github.com/WellSpent-OC/WellSpent-Budget) builds on.

- **`PaletteValues` and `Palette`**: the app's colours, light and dark, so an extension looks like the app.
- **`SecretStore`**: where an extension keeps a secret a person gave it, such as a key for another service. On the Mac and iPhone it is the person's iCloud Keychain, never WellSpent's server.
- **`ExtensionHost`**: what an extension may read from and write to a person's budget. Plain values only. The app fills it in; an extension never touches the app's own types.

The app and every extension depend on this package, and on nothing of each other's.

## Use it

```swift
.package(url: "https://github.com/WellSpent-OC/WellSpent-ExtensionKit.git", from: "0.3.0")
```

## Test it

```sh
swift test
```

MIT licensed. See [LICENSE](LICENSE).
