#!/bin/bash

# Directory where the ring images are stored
ring_photos_dir="ring photos"

# Directory where the output images will be stored
output_dir="outputs"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Prompt for up to 8 electrode pairs in the format "(E001,E002) (E003,E004) (E005,E006) ..."
echo "Enter up to 8 electrode pairs (in the format (E001,E002) (E003,E004) ...):"
read electrode_pairs_input

# Split the input into individual pairs by space
IFS=' ' read -r -a electrode_pairs <<< "$electrode_pairs_input"

# Ring images for each pair (up to 8 pairs)
ring_images=("$ring_photos_dir/pair1ring.png" "$ring_photos_dir/pair2ring.png" "$ring_photos_dir/pair3ring.png" "$ring_photos_dir/pair4ring.png" "$ring_photos_dir/pair5ring.png" "$ring_photos_dir/pair6ring.png" "$ring_photos_dir/pair7ring.png" "$ring_photos_dir/pair8ring.png")

# Function to generate a filename based on electrode pairs
generate_output_filename() {
    # Join electrode pairs with underscores and remove parentheses
    local pairs_string=$(echo "${electrode_pairs_input}" | sed 's/[(),]/_/g' | sed 's/ /_/g')
    echo "$output_dir/highlighted_${pairs_string}.png"
}

# Function to overlay the ring for a pair of electrodes
overlay_rings() {
    local electrode_label=$1
    local ring_image=$2  # Use the passed ring image

    # Get modified coordinates for the current electrode label from the CSV (using modifiedxcord and modifiedycord)
    coords=$(awk -F, -v label="$electrode_label" '$1 == label {print $3, $5}' "electrodes.csv")
    if [ -z "$coords" ]; then
        echo "Coordinates not found for $electrode_label"
        return
    fi

    # Read coordinates into variables
    IFS=' ' read -r x_adjusted y_adjusted <<< "$coords"

    # Use ImageMagick to overlay the ring image onto the output image at the specified coordinates
    convert "$output_image" "$ring_image" -geometry +${x_adjusted}+${y_adjusted} -composite "$output_image"
}

# Generate the output image filename based on electrode pairs
output_image=$(generate_output_filename)

# Initialize output image to the template image
cp "256template.png" "$output_image"

# Loop through the electrode pairs and overlay the corresponding rings
for i in "${!electrode_pairs[@]}"; do
    # Extract the pair (removing parentheses and splitting by comma)
    pair=${electrode_pairs[$i]}
    pair=${pair//[()]/}  # Remove parentheses
    IFS=',' read -r -a electrodes <<< "$pair"  # Split into individual electrodes

    # Determine which ring image to use (pair1ring to pair8ring)
    ring_image=${ring_images[$i]}

    # Overlay rings for each electrode in the current pair
    for electrode in "${electrodes[@]}"; do
        overlay_rings "$electrode" "$ring_image"
    done
done

echo "Ring overlays for electrode pairs completed. Output saved to $output_image."
