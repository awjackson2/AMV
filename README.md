Developed by: Aksel W. Jackson
Maintained by:
Last update: Sep 27, 2024

# Sakubunn

## Electrode Visualization Tool for Neural Montages

A simple visualization tool for displaying electrode placements on a head template. This tool allows you to input electrode pairs and generates a visual representation showing their positions on a standard head model.

### Features

- Manually input electrode pairs in the format (E001,E002) (E003,E004)
- Visualize up to 8 electrode pairs with different colored rings
- Coordinates based on standard 256-electrode system
- Automatically generates output images with highlighted electrode positions

### Requirements

- Linux/Unix environment
- ImageMagick (`sudo apt install imagemagick` or equivalent for your distribution)
- CSV file with electrode coordinates (included)

### Usage

```bash
bash visualize-montage-manual.sh
```

Follow the prompts to input electrode pairs. The script will generate a visualization in the output directory.

### Files

- `visualize-montage-manual.sh`: Interactive script for manual electrode pair input
- `visualize-montage.sh`: Automated script for processing montages from JSON configuration
- `electrodes.csv`: Contains coordinates for 256 standard electrode positions
- `ring photos/`: Directory containing overlay images for electrode visualization
- `256template.png`: Head template image

### Author

Created by Alex Jackson for electrode placement visualization in neurostimulation applications.

![promptAMV](https://github.com/user-attachments/assets/4ec35418-0c99-4474-a987-b553f49cb2da)

![highlighted__E056_E085___E170_E205_](https://github.com/user-attachments/assets/fa14f094-c71f-489a-8e5b-a8dc4083aa60)

