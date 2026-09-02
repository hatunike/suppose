# App Icon

Source art for the Suppose app icon.

**Concept:** three smooth curves fanning upward from a single origin point —
divergent projections of the same starting point ("suppose the rate is X…,
suppose I contribute Y…"). One bold curve, two lighter alternates. Single
teal-green accent.

## Files

- `AppIcon-light.svg` / `AppIcon-dark.svg` / `AppIcon-tinted.svg` — the three
  iOS 26 appearance variants (any / dark / tinted).

The rendered 1024×1024 PNGs live in
`Suppose/Assets.xcassets/AppIcon.appiconset/`.

## Regenerate the PNGs

Requires `librsvg` (`brew install librsvg`):

```sh
cd Design/AppIcon
for v in light dark tinted; do
  rsvg-convert -w 1024 -h 1024 AppIcon-$v.svg \
    -o ../../Suppose/Assets.xcassets/AppIcon.appiconset/AppIcon-$v.png
done
```
