# App icon source

The "Ready Signal" mark (phone + checkmark), same design as the logo concept.

- `icon_square.svg` / `.png` — full-bleed square (no corner rounding), used
  as the iOS App Store icon and the Android legacy launcher icon source.
  The OS applies its own corner mask on top.
- `icon_background.svg` / `.png` — the gradient fill alone, used as the
  Android Adaptive Icon background layer.
- `icon_foreground.svg` / `.png` — the phone+check glyph alone on a
  transparent background, sized to fit Android's adaptive-icon safe zone
  (centered, ≤66% of the 108dp canvas), used as the foreground layer.

## Regenerating

After editing an SVG, re-render the PNGs (needs `rsvg-convert`, install via
`brew install librsvg`) and re-run the launcher-icon generator:

```bash
rsvg-convert -w 1024 -h 1024 assets/icon/icon_square.svg -o assets/icon/icon_square.png
rsvg-convert -w 432 -h 432 assets/icon/icon_background.svg -o assets/icon/icon_background.png
rsvg-convert -w 432 -h 432 assets/icon/icon_foreground.svg -o assets/icon/icon_foreground.png

dart run flutter_launcher_icons
```

This overwrites every generated file under `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
and `android/app/src/main/res/{mipmap-*,drawable-*}/`.
