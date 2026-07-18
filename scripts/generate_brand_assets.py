"""Generate Android launcher, adaptive, splash, and Play Store icons.

Usage: python scripts/generate_brand_assets.py path/to/shotkit-icon-master.png
"""

from pathlib import Path
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
RES = ROOT / "android" / "app" / "src" / "main" / "res"


def save_resized(image: Image.Image, path: Path, size: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.resize((size, size), Image.Resampling.LANCZOS).save(path, optimize=True)


def extract_foreground(master: Image.Image) -> Image.Image:
    rgba = master.convert("RGBA")
    pixels = rgba.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
            red, green, blue, _ = pixels[x, y]
            brightness = max(red, green, blue)
            # The generated master uses a near-black backdrop. Preserve the
            # yellow/red mark and softly remove antialiased backdrop pixels.
            alpha = max(0, min(255, round((brightness - 32) * 8)))
            pixels[x, y] = (red, green, blue, alpha)
    return rgba


def rounded_legacy(master: Image.Image) -> Image.Image:
    rgba = master.convert("RGBA")
    mask = Image.new("L", rgba.size, 0)
    corner = round(rgba.width * 0.19)
    from PIL import ImageDraw

    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, rgba.width - 1, rgba.height - 1), radius=corner, fill=255
    )
    rgba.putalpha(ImageChops.multiply(rgba.getchannel("A"), mask))
    return rgba


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        Path("C:/Windows/Fonts/seguisb.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf"),
        Path("C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size)
    return ImageFont.load_default(size=size)


def create_feature_graphic(foreground: Image.Image, path: Path) -> None:
    graphic = Image.new("RGB", (1024, 500), "#0B0D0F")
    draw = ImageDraw.Draw(graphic)
    # Subtle production-grid structure without competing with the message.
    for x in range(0, 1024, 64):
        draw.line((x, 0, x, 500), fill="#12161A", width=1)
    for y in range(0, 500, 64):
        draw.line((0, y, 1024, y), fill="#12161A", width=1)

    bounds = foreground.getbbox()
    mark = foreground.crop(bounds)
    mark.thumbnail((330, 330), Image.Resampling.LANCZOS)
    graphic.paste(mark, (82, (500 - mark.height) // 2), mark)

    draw.text((485, 142), "SHOTKIT", font=font(74, bold=True), fill="#F3F0E8")
    draw.rounded_rectangle((487, 235, 582, 244), radius=4, fill="#F4C84A")
    draw.text(
        (485, 275),
        "Plan the frame. Own the set.",
        font=font(30),
        fill="#A9ADB2",
    )
    path.parent.mkdir(parents=True, exist_ok=True)
    graphic.save(path, optimize=True)


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("Pass the generated ShotKit master PNG path.")

    source = Path(sys.argv[1]).resolve()
    master = Image.open(source).convert("RGB")
    branding = ROOT / "assets" / "branding"
    store = ROOT / "assets" / "play-store"
    branding.mkdir(parents=True, exist_ok=True)
    store.mkdir(parents=True, exist_ok=True)
    master.save(branding / "shotkit-icon-master.png", optimize=True)
    save_resized(master, store / "app-icon-512.png", 512)

    foreground = extract_foreground(master)
    foreground.save(branding / "shotkit-mark-transparent.png", optimize=True)
    create_feature_graphic(foreground, store / "feature-graphic-1024x500.png")
    legacy = rounded_legacy(master)

    legacy_sizes = {
        "mdpi": 48,
        "hdpi": 72,
        "xhdpi": 96,
        "xxhdpi": 144,
        "xxxhdpi": 192,
    }
    adaptive_sizes = {
        "mdpi": 108,
        "hdpi": 162,
        "xhdpi": 216,
        "xxhdpi": 324,
        "xxxhdpi": 432,
    }
    for density, size in legacy_sizes.items():
        save_resized(legacy, RES / f"mipmap-{density}" / "ic_launcher.png", size)
        save_resized(legacy, RES / f"mipmap-{density}" / "ic_launcher_round.png", size)
    for density, size in adaptive_sizes.items():
        save_resized(
            foreground,
            RES / f"mipmap-{density}" / "ic_launcher_foreground.png",
            size,
        )

    save_resized(foreground, RES / "drawable-nodpi" / "launch_logo.png", 180)


if __name__ == "__main__":
    main()
