#!/usr/bin/env python3
"""
process_app_icon.py — Fast, zero-dependency script using Python's built-in PIL (Pillow).
Removes background instantly and updates:
1. Android launcher icons (android/app/src/main/res/mipmap-*)
2. iOS launcher icons (ios/Runner/Assets.xcassets/AppIcon.appiconset)
3. Flutter internal asset (assets/images/app_icon.png)
"""

import sys
import os
from collections import deque
from PIL import Image

def remove_background_fast(input_path, output_path, tolerance=40):
    print(f"⚡ Processing '{input_path}' with fast native Python algorithm...")
    
    img = Image.open(input_path).convert("RGBA")
    width, height = img.size
    pixels = img.load()
    
    visited = set()
    queue = deque()
    
    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))
        
    bg_pixels = set()
    ref_r, ref_g, ref_b, _ = pixels[0, 0]
    
    while queue:
        x, y = queue.popleft()
        if (x, y) in visited:
            continue
        visited.add((x, y))
        
        if 0 <= x < width and 0 <= y < height:
            r, g, b, a = pixels[x, y]
            
            dist_to_corner = ((r - ref_r)**2 + (g - ref_g)**2 + (b - ref_b)**2)**0.5
            is_white_like = (r > 200 and g > 200 and b > 200)
            
            if dist_to_corner <= tolerance or is_white_like:
                bg_pixels.add((x, y))
                
                for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < width and 0 <= ny < height and (nx, ny) not in visited:
                        queue.append((nx, ny))
                        
    for y in range(height):
        for x in range(width):
            if (x, y) in bg_pixels:
                r, g, b, _ = pixels[x, y]
                pixels[x, y] = (r, g, b, 0)
                
    img.save(output_path, "PNG")
    print(f"✨ Background removed instantly! Saved transparent image to: {output_path}")

ANDROID_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
ANDROID_RES = "/home/gelnox/project/android/app/src/main/res"

IOS_SIZES = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}
IOS_ICON_DIR = "/home/gelnox/project/ios/Runner/Assets.xcassets/AppIcon.appiconset"
ASSET_IMAGE_PATH = "/home/gelnox/project/assets/images/app_icon.png"

def install_icons(src_png):
    img = Image.open(src_png).convert("RGBA")
    
    # 1. Android mipmap icons
    print("\n📱 Installing Android launcher icons...")
    for folder, size in ANDROID_SIZES.items():
        dest_dir = os.path.join(ANDROID_RES, folder)
        os.makedirs(dest_dir, exist_ok=True)
        dest_path = os.path.join(dest_dir, "ic_launcher.png")
        resized = img.resize((size, size), Image.LANCZOS)
        resized.save(dest_path, "PNG")
        print(f"  ✓ Android {folder}/ic_launcher.png ({size}x{size})")

    # 2. iOS AppIcon assets
    print("\n🍏 Installing iOS launcher icons...")
    os.makedirs(IOS_ICON_DIR, exist_ok=True)
    for filename, size in IOS_SIZES.items():
        dest_path = os.path.join(IOS_ICON_DIR, filename)
        resized = img.resize((size, size), Image.LANCZOS)
        resized.save(dest_path, "PNG")
        print(f"  ✓ iOS {filename} ({size}x{size})")

    # 3. Flutter assets/images/ folder
    print("\n📁 Copying transparent icon to Flutter assets...")
    os.makedirs(os.path.dirname(ASSET_IMAGE_PATH), exist_ok=True)
    img.save(ASSET_IMAGE_PATH, "PNG")
    print(f"  ✓ Flutter asset: {ASSET_IMAGE_PATH}")

def main():
    input_file = "app_icon.jpeg"
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    
    if not os.path.exists(input_file):
        for alt in ["app_icon.png", "app_icon.jpg", "app_icon.jpeg"]:
            if os.path.exists(alt):
                input_file = alt
                break

    if not os.path.exists(input_file):
        print(f"❌ Error: '{input_file}' not found.")
        sys.exit(1)

    output_nobg = "app_icon_nobg.png"
    remove_background_fast(input_file, output_nobg)
    install_icons(output_nobg)
    print("\n🎉 All launcher icons AND Flutter assets updated successfully!")

if __name__ == "__main__":
    main()
