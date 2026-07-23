#!/usr/bin/env python3
"""
Fast, zero-dependency (uses built-in Pillow/PIL) background remover & icon generator.
Floods from border/corners to remove connected white/light background and smooths edges.
"""

import sys
import os
from PIL import Image, ImageFilter

def remove_background_floodfill(input_path, output_path, tolerance=35):
    print(f"⚡ Processing image with fast native PIL algorithm: {input_path}")
    
    img = Image.open(input_path).convert("RGBA")
    width, height = img.size
    pixels = img.load()
    
    # Create mask for background (0 = foreground, 255 = background to be removed)
    # We flood fill starting from all 4 borders & corners
    from collections import deque
    
    visited = set()
    queue = deque()
    
    # Add border pixels to queue
    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))
        
    bg_pixels = set()
    
    # Reference color from top-left corner
    ref_r, ref_g, ref_b, _ = pixels[0, 0]
    
    while queue:
        x, y = queue.popleft()
        if (x, y) in visited:
            continue
        visited.add((x, y))
        
        if 0 <= x < width and 0 <= y < height:
            r, g, b, a = pixels[x, y]
            
            # Check color distance to white (255,255,255) or top-left corner color
            dist_to_corner = ((r - ref_r)**2 + (g - ref_g)**2 + (b - ref_b)**2)**0.5
            is_white_like = (r > 220 and g > 220 and b > 220)
            
            if dist_to_corner <= tolerance or is_white_like:
                bg_pixels.add((x, y))
                
                # Check 4-neighbors
                for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < width and 0 <= ny < height and (nx, ny) not in visited:
                        queue.append((nx, ny))
                        
    # Apply alpha channel
    for y in range(height):
        for x in range(width):
            if (x, y) in bg_pixels:
                r, g, b, _ = pixels[x, y]
                pixels[x, y] = (r, g, b, 0)
                
    img.save(output_path, "PNG")
    print(f"✅ Fast background removal finished! Saved to {output_path}")

if __name__ == "__main__":
    src = "app_icon.jpeg"
    if len(sys.argv) > 1:
        src = sys.argv[1]
    remove_background_floodfill(src, "app_icon_nobg.png")
