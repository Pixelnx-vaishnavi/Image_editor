import 'package:image/image.dart' as img;


class ImagePreset {
  final String name;
  final double brightness; // -1.0 to 1.0
  final double contrast; // 0.5 to 2.0
  final double saturation; // 0.0 to 2.0
  final bool isSepia; // Apply sepia effect
  final bool isGrayscale; // Apply grayscale effect

  ImagePreset({
    required this.name,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.isSepia = false,
    this.isGrayscale = false,
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
          name: "Vintage",
          isSepia: true,
          brightness: 0.1,
          saturation: 0.8,
          contrast: 1.1,
        ),
        ImagePreset(
          name: "Pop",
          contrast: 1.3,
          saturation: 1.5,
          brightness: 0.05,
        ),
        ImagePreset(
          name: "Dreamy",
          brightness: 0.25,
          saturation: 0.7,
          contrast: 0.9,
        ),
        ImagePreset(
          name: "Vivid",
          contrast: 1.4,
          saturation: 1.7,
          brightness: 0.1,
        ),
      ],
    ),
    PresetCategory(
      name: "Natural",
      presets: [
        ImagePreset(name: "Original"),
        ImagePreset(
          name: "Bright",
          brightness: 0.2,
          contrast: 1.1,
          saturation: 1.1,
        ),
        ImagePreset(
          name: "Clarity",
          contrast: 1.2,
          brightness: 0.15,
          saturation: 1.05,
        ),
        ImagePreset(
          name: "Pure",
          brightness: 0.1,
          contrast: 1.05,
          saturation: 1.0,
        ),
      ],
    ),
    PresetCategory(
      name: "Warm",
      presets: [
        ImagePreset(
          name: "Sunset",
          brightness: 0.15,
          saturation: 1.2,
          contrast: 1.05,
        ),
        ImagePreset(
          name: "Golden",
          brightness: 0.2,
          saturation: 1.25,
          contrast: 1.1,
        ),
        ImagePreset(
          name: "Cozy",
          brightness: 0.1,
          saturation: 1.15,
          contrast: 1.0,
          isSepia: true,
        ),
        ImagePreset(
          name: "Amber",
          brightness: 0.18,
          saturation: 1.3,
          contrast: 1.08,
        ),
      ],
    ),
    PresetCategory(
      name: "Cool",
      presets: [
        ImagePreset(
          name: "Frost",
          brightness: -0.1,
          saturation: 0.9,
          contrast: 1.1,
        ),
        ImagePreset(
          name: "Glacial",
          brightness: -0.15,
          saturation: 0.85,
          contrast: 1.15,
        ),
        ImagePreset(
          name: "Mint",
          brightness: 0.05,
          saturation: 1.05,
          contrast: 1.1,
        ),
        ImagePreset(
          name: "Breeze",
          brightness: -0.05,
          saturation: 0.95,
          contrast: 1.0,
        ),
      ],
    ),
    PresetCategory(
      name: "Vivid",
      presets: [
        ImagePreset(
          name: "Radiant",
          brightness: 0.15,
          contrast: 1.3,
          saturation: 1.8,
        ),
        ImagePreset(
          name: "Bold",
          brightness: 0.1,
          contrast: 1.4,
          saturation: 1.9,
        ),
        ImagePreset(
          name: "Neon",
          brightness: 0.2,
          contrast: 1.35,
          saturation: 1.85,
        ),
        ImagePreset(
          name: "Sparkle",
          brightness: 0.25,
          contrast: 1.25,
          saturation: 1.7,
        ),
      ],
    ),
    PresetCategory(
      name: "Soft",
      presets: [
        ImagePreset(
          name: "Pastel",
          brightness: 0.2,
          contrast: 0.9,
          saturation: 0.8,
        ),
        ImagePreset(
          name: "Silk",
          brightness: 0.25,
          contrast: 0.85,
          saturation: 0.75,
        ),
        ImagePreset(
          name: "Mellow",
          brightness: 0.15,
          contrast: 0.95,
          saturation: 0.7,
        ),
        ImagePreset(
          name: "Cloudy",
          brightness: 0.3,
          contrast: 0.8,
          saturation: 0.65,
        ),
      ],
    ),
    PresetCategory(
      name: "Dramatic",
      presets: [
        ImagePreset(
          name: "Cinematic",
          brightness: -0.1,
          contrast: 1.5,
          saturation: 0.9,
        ),
        ImagePreset(
          name: "Moody",
          brightness: -0.15,
          contrast: 1.6,
          saturation: 0.85,
        ),
        ImagePreset(
          name: "Epic",
          brightness: -0.05,
          contrast: 1.55,
          saturation: 0.95,
        ),
        ImagePreset(
          name: "Noir",
          isGrayscale: true,
          contrast: 1.7,
          brightness: -0.2,
        ),
      ],
    ),
    PresetCategory(
      name: "Retro",
      presets: [
        ImagePreset(
          name: "Old Film",
          isSepia: true,
          brightness: -0.05,
          contrast: 1.2,
          saturation: 0.7,
        ),
        ImagePreset(
          name: "Faded",
          brightness: 0.1,
          contrast: 0.9,
          saturation: 0.6,
        ),
        ImagePreset(
          name: "Polaroid",
          isSepia: true,
          brightness: 0.15,
          contrast: 1.1,
          saturation: 0.75,
        ),
        ImagePreset(
          name: "70s",
          brightness: 0.05,
          contrast: 1.25,
          saturation: 1.3,
        ),
      ],
    ),
    PresetCategory(
      name: "Monochrome",
      presets: [
        ImagePreset(
          name: "Classic B&W",
          isGrayscale: true,
          contrast: 1.2,
          brightness: 0.0,
        ),
        ImagePreset(
          name: "High Contrast",
          isGrayscale: true,
          contrast: 1.6,
          brightness: -0.1,
        ),
        ImagePreset(
          name: "Soft Mono",
          isGrayscale: true,
          contrast: 1.0,
          brightness: 0.15,
        ),
        ImagePreset(
          name: "Dark Mono",
          isGrayscale: true,
          contrast: 1.4,
          brightness: -0.15,
        ),
      ],
    ),
    PresetCategory(
      name: "Artistic",
      presets: [
        ImagePreset(
          name: "Sketch",
          isGrayscale: true,
          contrast: 1.8,
          brightness: 0.1,
        ),
        ImagePreset(
          name: "Watercolor",
          brightness: 0.2,
          contrast: 0.9,
          saturation: 1.4,
        ),
        ImagePreset(
          name: "Impressionist",
          brightness: 0.15,
          contrast: 1.0,
          saturation: 1.5,
        ),
        ImagePreset(
          name: "Surreal",
          brightness: 0.1,
          contrast: 1.3,
          saturation: 1.6,
        ),
      ],
    ),
  ];
}


class ImageProcessor {
  img.Image applyPreset(ImagePreset preset, img.Image image) {
    img.Image result = img.Image.from(image);

    // Apply brightness, contrast, saturation
    result = img.adjustColor(
      result,
      brightness: preset.brightness,
      contrast: preset.contrast,
      saturation: preset.saturation,
    );

    // Apply sepia
    if (preset.isSepia) {
      result = img.sepia(result, amount: 0.7);
    }

    // Apply grayscale
    if (preset.isGrayscale) {
      result = img.grayscale(result);
    }

    return result;
  }
}