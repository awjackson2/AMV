#!/bin/bash

# Directory where the ring images are stored
ring_photos_dir="ring photos"

# Directory where the output images will be stored
output_dir="output"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Validation function to check if the input follows the required pattern
validate_input() {
    local input="$1"
    # Regex to validate pairs in the format (E001,E002) (E003,E004)
    if [[ ! $input =~ ^(\([E][0-9]{3},[E][0-9]{3}\)\ ?){1,8}$ ]]; then
        echo "Invalid input format. Please enter pairs in the format: (E001,E002) (E003,E004) ..."
        return 1
    fi
    return 0
}

# Function to prompt user for electrode pairs input
get_electrode_pairs() {
    while true; do
        # Prompt for up to 8 electrode pairs
        echo "Enter up to 8 electrode pairs (in the format (E001,E002) (E003,E004) ...:"
        read electrode_pairs_input
        
        # Call the validation function
        if validate_input "$electrode_pairs_input"; then
            # Split the input into individual pairs by space
            IFS=' ' read -r -a electrode_pairs <<< "$electrode_pairs_input"
            break
        else
            echo "Please try again."
        fi
    done
}

# Call function to get electrode pairs from the user
get_electrode_pairs

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
        return 1  # Return failure if coordinates are not found
    fi

    # Read coordinates into variables
    IFS=' ' read -r x_adjusted y_adjusted <<< "$coords"

    # Use ImageMagick (magick) to overlay the ring image onto the output image at the specified coordinates
    magick "$output_image" "$ring_image" -geometry +${x_adjusted}+${y_adjusted} -composite "$output_image"

    return 0  # Return success if coordinates are found and overlay is done
}

# Main loop to process the electrode pairs and generate the image
while true; do
    output_image=$(generate_output_filename)  # Generate the output image filename

    # Initialize output image to the template image
    cp "256template.png" "$output_image"

    # Set a flag to track missing coordinates
    coordinates_missing=false

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
            if ! overlay_rings "$electrode" "$ring_image"; then
                coordinates_missing=true
                break  # Exit inner loop if coordinates are missing
            fi
        done

        # Exit outer loop if coordinates are missing
        if $coordinates_missing; then
            break
        fi
    done

    # If coordinates are missing, prompt the user to re-enter the electrode pairs
    if $coordinates_missing; then
        echo "Some electrode coordinates were not found. Please re-enter the electrode pairs."
        get_electrode_pairs  # Prompt user for input again
    else
        echo "Ring overlays for electrode pairs completed. Output saved to $output_image."
        break  # Exit the loop once the process is successful
    fi
done

