import 'dart:math';
import 'package:image/image.dart' as img;

class ImagePreset {
  final String name;
  final List<Map<String, dynamic>> filters;

  ImagePreset({
    required this.name,
    required this.filters,
  });
}

class PresetCategory {
  final String name;
  final List<ImagePreset> presets;

  PresetCategory({required this.name, required this.presets});

  static final List<PresetCategory> allCategories = [
    PresetCategory(
      name: "Creative",
      presets: [
        ImagePreset(
          name: "Vintage Glow",
          filters: [
            {"name": "sepia", "intensity": 0.7},
            {
              "name": "colorControls",
              "brightness": 0.1,
              "contrast": 1.05,
              "saturation": 0.9
            },
            {"name": "vignette", "intensity": 0.8, "radius": 1.2},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Dreamy Haze",
          filters: [
            {"name": "gaussianBlur", "radius": 2.0},
            {
              "name": "colorControls",
              "brightness": 0.2,
              "saturation": 0.8
            },
            {
              "name": "overlay",
              "color": [255, 240, 220, 60], // Warm white
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Pop Art",
          filters: [
            {"name": "posterize", "levels": 8.0},
            {
              "name": "colorControls",
              "contrast": 1.2,
              "saturation": 1.6
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Surreal",
          filters: [
            {"name": "kaleidoscope", "count": 6, "angle": 0.1},
            {
              "name": "colorControls",
              "saturation": 1.3,
              "contrast": 1.1
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Comic Effect",
          filters: [
            {"name": "comic"},
            {
              "name": "colorControls",
              "contrast": 1.1
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Crystallize",
          filters: [
            {
              "name": "crystallize",
              "radius": 15.0,
              "centerX": 0.5,
              "centerY": 0.5
            },
            {
              "name": "colorControls",
              "brightness": 0.05,
              "saturation": 1.1
            },
            {"name": "balanceColors"},
          ],
        ),
      ],
    ),
    PresetCategory(
      name: "Color",
      presets: [
        ImagePreset(
          name: "Vivid",
          filters: [
            {
              "name": "colorControls",
              "brightness": 0.1,
              "contrast": 1.15,
              "saturation": 1.5
            },
            {"name": "vignette", "intensity": 0.5, "radius": 1.0},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Cool Tone",
          filters: [
            {
              "name": "colorControls",
              "saturation": 0.9,
              "hue": -10.0
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Warm Tone",
          filters: [
            {
              "name": "colorControls",
              "saturation": 1.1,
              "hue": 15.0
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Pastel",
          filters: [
            {
              "name": "colorControls",
              "brightness": 0.2,
              "saturation": 0.7,
              "contrast": 0.9
            },
            {"name": "vignette", "intensity": 0.3, "radius": 1.2},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "High Contrast",
          filters: [
            {
              "name": "colorControls",
              "contrast": 1.3,
              "saturation": 1.2
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Faded",
          filters: [
            {
              "name": "colorControls",
              "brightness": 0.1,
              "contrast": 0.85,
              "saturation": 0.6
            },
            {"name": "vignette", "intensity": 0.6, "radius": 1.4},
            {"name": "balanceColors"},
          ],
        ),
      ],
    ),
    PresetCategory(
      name: "Black & White",
      presets: [
        ImagePreset(
          name: "Classic B&W",
          filters: [
            {"name": "grayscale"},
            {"name": "vignette", "intensity": 0.15, "radius": 1.10},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "High Contrast B&W",
          filters: [
            {"name": "grayscale"},
            {
              "name": "colorControls",
              "contrast": 1.4,
              "brightness": 0.05
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Soft B&W",
          filters: [
            {"name": "grayscale"},
            {
              "name": "colorControls",
              "contrast": 1.0,
              "brightness": 0.15
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Faded B&W",
          filters: [
            {"name": "grayscale"},
            {"name": "vignette", "intensity": 0.5, "radius": 1.0},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Silver Tone",
          filters: [
            {"name": "grayscale"},
            {
              "name": "colorControls",
              "contrast": 1.1,
              "brightness": 0.1
            },
            {"name": "balanceColors"},
          ],
        ),
      ],
    ),
    PresetCategory(
      name: "Portraits",
      presets: [
        ImagePreset(
          name: "Smooth Skin",
          filters: [
            {"name": "gaussianBlur", "radius": 1.0},
            {
              "name": "colorControls",
              "brightness": 0.1,
              "contrast": 1.05
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Dramatic",
          filters: [
            {
              "name": "colorControls",
              "contrast": 1.2,
              "saturation": 0.9
            },
            {"name": "vignette", "intensity": 1.0, "radius": 1.3},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Bright Portrait",
          filters: [
            {
              "name": "colorControls",
              "brightness": 0.15,
              "contrast": 1.1,
              "saturation": 1.2
            },
            {"name": "vignette", "intensity": 0.4, "radius": 1.0},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Moody",
          filters: [
            {
              "name": "colorControls",
              "brightness": -0.05,
              "contrast": 1.15,
              "saturation": 0.8
            },
            {"name": "vignette", "intensity": 0.7, "radius": 1.4},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Warm Portrait",
          filters: [
            {
              "name": "colorControls",
              "brightness": 0.1,
              "saturation": 1.1,
              "hue": 15.0
            },
            {"name": "vignette", "intensity": 0.5, "radius": 1.2},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Cinematic",
          filters: [
            {
              "name": "colorControls",
              "contrast": 1.2,
              "saturation": 0.85
            },
            {"name": "vignette", "intensity": 0.9, "radius": 1.3},
            {"name": "gaussianBlur", "radius": 0.5},
            {"name": "balanceColors"},
          ],
        ),
      ],
    ),
    PresetCategory(
      name: "Classic",
      presets: [
        ImagePreset(
          name: "Old Film",
          filters: [
            {"name": "sepia", "intensity": 0.5},
            {"name": "noise", "level": 0.02},
            {"name": "vignette", "intensity": 0.7, "radius": 1.2},
            {
              "name": "colorControls",
              "contrast": 1.05,
              "saturation": 0.8
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Retro Fade",
          filters: [
            {
              "name": "colorControls",
              "brightness": 0.1,
              "contrast": 0.9,
              "saturation": 0.7
            },
            {"name": "vignette", "intensity": 0.6, "radius": 1.4},
            {"name": "dotScreen", "angle": 0.0, "width": 6.0},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Soft Focus",
          filters: [
            {"name": "gaussianBlur", "radius": 1.5},
            {
              "name": "colorControls",
              "brightness": 0.15,
              "contrast": 1.0,
              "saturation": 0.9
            },
            {"name": "vignette", "intensity": 0.5, "radius": 1.2},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Classic Chrome",
          filters: [
            {
              "name": "colorControls",
              "contrast": 1.15,
              "saturation": 1.0,
              "brightness": 0.05
            },
            {"name": "vignette", "intensity": 0.5, "radius": 1.0},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Warm Sepia",
          filters: [
            {"name": "sepia", "intensity": 0.6},
            {
              "name": "colorControls",
              "brightness": 0.1,
              "contrast": 1.05,
              "hue": 15.0
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Vintage Portrait",
          filters: [
            {"name": "sepia", "intensity": 0.4},
            {
              "name": "colorControls",
              "brightness": 0.1,
              "contrast": 1.1,
              "saturation": 0.85
            },
            {"name": "vignette", "intensity": 0.9, "radius": 1.3},
            {"name": "noise", "level": 0.01},
            {"name": "balanceColors"},
          ],
        ),
      ],
    ),
    PresetCategory(
      name: "Cinematic",
      presets: [
        ImagePreset(
          name: "Blockbuster",
          filters: [
            {
              "name": "colorControls",
              "contrast": 1.25,
              "saturation": 0.9,
              "brightness": -0.05
            },
            {"name": "vignette", "intensity": 0.8, "radius": 1.2},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Noir",
          filters: [
            {"name": "grayscale"},
            {
              "name": "colorControls",
              "contrast": 1.5,
              "brightness": -0.1
            },
            {"name": "vignette", "intensity": 1.0, "radius": 1.4},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Golden Hour",
          filters: [
            {
              "name": "colorControls",
              "brightness": 0.1,
              "saturation": 1.0,
              "hue": 20.0
            },
            {"name": "gaussianBlur", "radius": 0.5},
            {"name": "vignette", "intensity": 0.6, "radius": 1.1},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Teal & Orange",
          filters: [
            {
              "name": "colorControls",
              "contrast": 1.2,
              "saturation": 1.3,
              "hue": 5.0
            },
            {
              "name": "overlay",
              "color": [255, 147, 0, 50], // Orange tint
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Soft Drama",
          filters: [
            {
              "name": "colorControls",
              "contrast": 1.1,
              "saturation": 0.95,
              "brightness": 0.05
            },
            {"name": "gaussianBlur", "radius": 1.0},
            {"name": "vignette", "intensity": 0.7, "radius": 1.3},
            {"name": "balanceColors"},
          ],
        ),
      ],
    ),
    PresetCategory(
      name: "Nature",
      presets: [
        ImagePreset(
          name: "Lush Green",
          filters: [
            {
              "name": "colorControls",
              "brightness": 0.1,
              "contrast": 1.1,
              "saturation": 1.4,
              "hue": -5.0
            },
            {"name": "vignette", "intensity": 0.4, "radius": 1.0},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Sky Blue",
          filters: [
            {
              "name": "colorControls",
              "saturation": 1.3,
              "hue": -10.0
            },
            {"name": "vignette", "intensity": 0.5, "radius": 1.2},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Sunlit",
          filters: [
            {
              "name": "colorControls",
              "brightness": 0.15,
              "contrast": 1.05,
              "saturation": 1.2
            },
            {
              "name": "overlay",
              "color": [255, 255, 200, 40], // Warm sunlight
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Earthy",
          filters: [
            {
              "name": "colorControls",
              "contrast": 1.1,
              "saturation": 1.0,
              "hue": 10.0
            },
            {"name": "sepia", "intensity": 0.3},
            {"name": "vignette", "intensity": 0.6, "radius": 1.3},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Forest Glow",
          filters: [
            {
              "name": "colorControls",
              "brightness": 0.1,
              "saturation": 1.2,
              "contrast": 1.05
            },
            {"name": "gaussianBlur", "radius": 0.5},
            {"name": "balanceColors"},
          ],
        ),
      ],
    ),
    PresetCategory(
      name: "Urban",
      presets: [
        ImagePreset(
          name: "Gritty",
          filters: [
            {
              "name": "colorControls",
              "contrast": 1.3,
              "saturation": 0.7,
              "brightness": -0.05
            },
            {"name": "noise", "level": 0.03},
            {"name": "vignette", "intensity": 0.8, "radius": 1.4},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "City Lights",
          filters: [
            {
              "name": "colorControls",
              "contrast": 1.2,
              "saturation": 0.9,
              "brightness": 0.1
            },
            {"name": "vignette", "intensity": 0.7, "radius": 1.2},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Monochrome",
          filters: [
            {"name": "grayscale"},
            {
              "name": "colorControls",
              "contrast": 1.3,
              "brightness": 0.05
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Industrial",
          filters: [
            {
              "name": "colorControls",
              "contrast": 1.25,
              "saturation": 0.8
            },
            {"name": "noise", "level": 0.02},
            {"name": "vignette", "intensity": 0.9, "radius": 1.3},
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Neon",
          filters: [
            {
              "name": "colorControls",
              "contrast": 1.4,
              "saturation": 1.5
            },
            {"name": "vignette", "intensity": 0.6, "radius": 1.1},
            {"name": "balanceColors"},
          ],
        ),
      ],
    ),
    PresetCategory(
      name: "Abstract",
      presets: [
        ImagePreset(
          name: "Mosaic",
          filters: [
            {
              "name": "crystallize",
              "radius": 10.0,
              "centerX": 0.5,
              "centerY": 0.5
            },
            {
              "name": "colorControls",
              "saturation": 1.2,
              "contrast": 1.1
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Pixelated",
          filters: [
            {"name": "posterize", "levels": 6.0},
            {
              "name": "colorControls",
              "contrast": 1.2,
              "saturation": 1.3
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Fractal",
          filters: [
            {"name": "kaleidoscope", "count": 8, "angle": 0.15},
            {
              "name": "colorControls",
              "saturation": 1.5,
              "contrast": 1.2
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Patterned",
          filters: [
            {"name": "dotScreen", "angle": 0.1, "width": 5.0},
            {
              "name": "colorControls",
              "contrast": 1.1,
              "saturation": 1.2
            },
            {"name": "balanceColors"},
          ],
        ),
        ImagePreset(
          name: "Vivid Abstract",
          filters: [
            {
              "name": "colorControls",
              "contrast": 1.3,
              "saturation": 1.8,
              "brightness": 0.1
            },
            {"name": "gaussianBlur", "radius": 0.5},
            {"name": "balanceColors"},
          ],
        ),
      ],
    ),
  ];
}

class ImageProcessor {
  final Random _random = Random();

  img.Image applyPreset(ImagePreset preset, img.Image image) {
    if (image.width == 0 || image.height == 0) {
      return img.Image.from(image); // Return copy of empty image
    }

    img.Image result = img.Image.from(image);

    for (var filterConfig in preset.filters) {
      final filterName = filterConfig["name"] as String;

      switch (filterName) {
        case "colorControls":
          result = img.adjustColor(
            result,
            brightness: filterConfig["brightness"]?.toDouble() ?? 0.0,
            contrast: filterConfig["contrast"]?.toDouble() ?? 1.0,
            saturation: filterConfig["saturation"]?.toDouble() ?? 1.0,
            hue: filterConfig["hue"]?.toDouble() ?? 0.0,
          );
          break;

        case "sepia":
          result = img.sepia(result,
              amount: filterConfig["intensity"]?.toDouble() ?? 1.0);
          break;

        case "grayscale":
          result = img.grayscale(result);
          break;

        case "gaussianBlur":
          final radius = filterConfig["radius"]?.toDouble() ?? 0.0;
          if (radius > 0) {
            result = img.gaussianBlur(result, radius.toInt());
          }
          break;

        case "vignette":
          final intensity = filterConfig["intensity"]?.toDouble() ?? 1.0;
          final radius = filterConfig["radius"]?.toDouble() ?? 1.0;
          result = _applyVignette(result, intensity, radius);
          break;

        case "noise":
          final level = filterConfig["level"]?.toDouble() ?? 0.0;
          if (level > 0) {
            result = _addNoise(result, level);
          }
          break;

        case "posterize":
          final levels = filterConfig["levels"]?.toDouble() ?? 6.0;
          result = _posterize(result, levels);
          break;

        case "dotScreen":
          final angle = filterConfig["angle"]?.toDouble() ?? 0.0;
          final width = filterConfig["width"]?.toDouble() ?? 6.0;
          result = _dotScreen(result, angle, width);
          break;

        case "comic":
          result = _comicEffect(result);
          break;

        case "kaleidoscope":
          final count = filterConfig["count"]?.toInt() ?? 6;
          final angle = filterConfig["angle"]?.toDouble() ?? 0.1;
          result = _kaleidoscope(result, count, angle);
          break;

        case "crystallize":
          final radius = filterConfig["radius"]?.toDouble() ?? 15.0;
          final centerX = filterConfig["centerX"]?.toDouble() ?? 0.5;
          final centerY = filterConfig["centerY"]?.toDouble() ?? 0.5;
          result = _crystallize(result, radius, centerX, centerY);
          break;

        case "overlay":
          final color = filterConfig["color"] as List<int>? ?? [255, 255, 255, 255];
          result = _applyOverlay(result, color);
          break;

        case "balanceColors":
          result = _balanceColors(result);
          break;
      }
    }

    return result;
  }

  img.Image _applyVignette(img.Image image, double intensity, double radius) {
    int width = image.width;
    int height = image.height;
    img.Image result = img.Image.from(image);

    double maxDistance = sqrt((width / 2) * (width / 2) + (height / 2) * (height / 2));
    double vignetteStrength = intensity * radius;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double dx = x - width / 2;
        double dy = y - height / 2;
        double distance = sqrt(dx * dx + dy * dy);
        double vignetteFactor = 1.0 - (distance / maxDistance) * vignetteStrength;
        vignetteFactor = vignetteFactor.clamp(0.4, 1.0);

        int pixel = image.getPixel(x, y);
        int r = (img.getRed(pixel) * vignetteFactor).toInt();
        int g = (img.getGreen(pixel) * vignetteFactor).toInt();
        int b = (img.getBlue(pixel) * vignetteFactor).toInt();

        result.setPixel(x, y, img.getColor(r, g, b));
      }
    }

    return result;
  }

  img.Image _addNoise(img.Image image, double noiseLevel) {
    img.Image result = img.Image.from(image);
    int width = image.width;
    int height = image.height;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);

        int noise = (noiseLevel * 255 * (_random.nextDouble() - 0.5)).toInt();
        r = (r + noise).clamp(0, 255);
        g = (g + noise).clamp(0, 255);
        b = (b + noise).clamp(0, 255);

        result.setPixel(x, y, img.getColor(r, g, b));
      }
    }

    return result;
  }

  img.Image _posterize(img.Image image, double levels) {
    img.Image result = img.Image.from(image);
    int width = image.width;
    int height = image.height;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);

        r = (r / (255 / levels)).floor() * (255 ~/ levels);
        g = (g / (255 / levels)).floor() * (255 ~/ levels);
        b = (b / (255 / levels)).floor() * (255 ~/ levels);

        result.setPixel(x, y, img.getColor(r, g, b));
      }
    }

    return result;
  }

  img.Image _dotScreen(img.Image image, double angle, double width) {
    img.Image result = img.Image.from(image);
    int imageWidth = image.width;
    int imageHeight = image.height;

    for (int y = 0; y < imageHeight; y++) {
      for (int x = 0; x < imageWidth; x++) {
        double sinAngle = sin(angle);
        double cosAngle = cos(angle);
        double value = sin((x * cosAngle + y * sinAngle) * 2 * pi / width);
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);

        double intensity = (value + 1) / 2;
        r = (r * intensity).toInt().clamp(0, 255);
        g = (g * intensity).toInt().clamp(0, 255);
        b = (b * intensity).toInt().clamp(0, 255);

        result.setPixel(x, y, img.getColor(r, g, b));
      }
    }

    return result;
  }

  img.Image _comicEffect(img.Image image) {
    img.Image result = img.Image.from(image);
    int width = image.width;
    int height = image.height;

    // Edge enhancement with balanced kernel
    List<double> edgeKernel = [
      -0.5, -0.5, -0.5,
      -0.5, 5.0, -0.5,
      -0.5, -0.5, -0.5,
    ];
    result = img.convolution(result, edgeKernel);

    // Moderate color quantization
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixel = result.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);

        r = (r / (255 / 10)).floor() * (255 ~/ 10);
        g = (g / (255 / 10)).floor() * (255 ~/ 10);
        b = (b / (255 / 10)).floor() * (255 ~/ 10);

        result.setPixel(x, y, img.getColor(r, g, b));
      }
    }

    return result;
  }

  img.Image _kaleidoscope(img.Image image, int count, double angle) {
    img.Image result = img.Image.from(image);
    int width = image.width;
    int height = image.height;
    double centerX = width / 2;
    double centerY = height / 2;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double dx = x - centerX;
        double dy = y - centerY;
        double r = sqrt(dx * dx + dy * dy);
        double theta = atan2(dy, dx) + angle;

        double segment = 2 * pi / count;
        theta = theta % segment;
        if (theta > segment / 2) {
          theta = segment - theta;
        }

        int srcX = (centerX + r * cos(theta)).toInt().clamp(0, width - 1);
        int srcY = (centerY + r * sin(theta)).toInt().clamp(0, height - 1);

        result.setPixel(x, y, image.getPixel(srcX, srcY));
      }
    }

    return result;
  }

  img.Image _crystallize(img.Image image, double radius, double centerX, double centerY) {
    img.Image result = img.Image.from(image);
    int width = image.width;
    int height = image.height;
    int cx = (centerX * width).toInt();
    int cy = (centerY * height).toInt();

    List<Offsets> centers = [];
    double step = radius * 0.8;
    for (double y = 0; y < height; y += step) {
      for (double x = 0; x < width; x += step) {
        centers.add(Offsets(
          x + _random.nextDouble() * radius * 0.5,
          y + _random.nextDouble() * radius * 0.5,
        ));
      }
    }

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double minDist = double.infinity;
        Offsets closestCenter = centers[0];

        for (var center in centers) {
          double dx = x - center.dx;
          double dy = y - center.dy;
          double dist = dx * dx + dy * dy;
          if (dist < minDist) {
            minDist = dist;
            closestCenter = center;
          }
        }

        int srcX = closestCenter.dx.toInt().clamp(0, width - 1);
        int srcY = closestCenter.dy.toInt().clamp(0, height - 1);
        result.setPixel(x, y, image.getPixel(srcX, srcY));
      }
    }

    return result;
  }

  img.Image _applyOverlay(img.Image image, List<int> color) {
    img.Image result = img.Image.from(image);
    int width = image.width;
    int height = image.height;
    int rOverlay = color[0];
    int gOverlay = color[1];
    int bOverlay = color[2];
    double alpha = (color.length > 3 ? color[3] : 255) / 255.0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);

        r = (r * (1 - alpha) + rOverlay * alpha).toInt().clamp(0, 255);
        g = (g * (1 - alpha) + gOverlay * alpha).toInt().clamp(0, 255);
        b = (b * (1 - alpha) + bOverlay * alpha).toInt().clamp(0, 255);

        result.setPixel(x, y, img.getColor(r, g, b));
      }
    }

    return result;
  }

  img.Image _balanceColors(img.Image image) {
    img.Image result = img.Image.from(image);
    int width = image.width;
    int height = image.height;

    if (width == 0 || height == 0) {
      return result;
    }

    // Calculate average RGB values
    double rSum = 0, gSum = 0, bSum = 0;
    int pixelCount = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixel = image.getPixel(x, y);
        rSum += img.getRed(pixel);
        gSum += img.getGreen(pixel);
        bSum += img.getBlue(pixel);
        pixelCount++;
      }
    }

    double rAvg = rSum / pixelCount;
    double gAvg = gSum / pixelCount;
    double bAvg = bSum / pixelCount;

    // Skip balancing if all channels are zero
    double avgIntensity = (rAvg + gAvg + bAvg) / 3;
    if (avgIntensity == 0) {
      return result;
    }

    // Use a small epsilon to avoid division by zero
    const double epsilon = 1e-10;
    rAvg = rAvg == 0 ? epsilon : rAvg;
    gAvg = gAvg == 0 ? epsilon : gAvg;
    bAvg = bAvg == 0 ? epsilon : bAvg;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);

        // Adjust channels to balance around average intensity
        r = (r * avgIntensity / rAvg).toInt().clamp(0, 255);
        g = (g * avgIntensity / gAvg).toInt().clamp(0, 255);
        b = (b * avgIntensity / bAvg).toInt().clamp(0, 255);

        result.setPixel(x, y, img.getColor(r, g, b));
      }
    }

    return result;
  }
}

class Offsets {
  final double dx;
  final double dy;

  Offsets(this.dx, this.dy);
}