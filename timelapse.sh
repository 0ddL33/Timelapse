#!/bin/bash

# timelapse.sh - Create a timelapse from screenshots
# Usage: ./timelapse.sh [options]

# Default values
DURATION=60        # Total duration in seconds
INTERVAL=5         # Interval between screenshots in seconds
FORMAT="mp4"       # Output format (mp4 or gif)
OUTPUT_FILE="timelapse" # Output filename without extension
QUALITY=95         # JPEG quality for screenshots (1-100)
FRAMERATE=10       # Frames per second for the output video/gif
SELECT_WINDOW=false # Whether to select a window interactively
WINDOW_ID=""       # Window ID to capture (empty for full screen)
DISPLAY_NUM=""     # Display number to capture (empty for all displays)
CAPTURE_MODE="timed" # Capture mode: "timed" or "continuous"
INTERACTIVE=false  # Whether to show the interactive menu

# Function to display help
show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -d, --duration SECONDS    Duration of the timelapse capture in seconds (default: $DURATION)"
    echo "  -i, --interval SECONDS    Interval between screenshots in seconds (default: $INTERVAL)"
    echo "  -f, --format FORMAT       Output format: mp4 or gif (default: $FORMAT)"
    echo "  -o, --output FILENAME     Output filename without extension (default: $OUTPUT_FILE)"
    echo "  -q, --quality QUALITY     JPEG quality for screenshots, 1-100 (default: $QUALITY)"
    echo "  -r, --framerate FPS       Frames per second for output video/gif (default: $FRAMERATE)"
    echo "  -w, --select-window       Interactively select a window to capture"
    echo "  -W, --window-id ID        Specify a window ID to capture (use xwininfo or xdotool to find IDs)"
    echo "  -D, --display NUMBER      Specify which display to capture (e.g., 0, 1) in a multi-monitor setup"
    echo "  -c, --continuous          Record until manually stopped (Ctrl+C)"
    echo "  -m, --menu                Show interactive menu for selecting options"
    echo "  -h, --help                Show this help message"
    echo
    echo "Example:"
    echo "  $0 --duration 300 --interval 2 --format gif --output desktop_activity"
    exit 0
}

# Function to display interactive menu
show_interactive_menu() {
    clear
    echo "===== Timelapse Screenshot Tool ====="
    echo
    echo "Please select your options:"
    echo

    # Capture mode
    echo "Capture mode:"
    echo "1) Timed recording (specific duration)"
    echo "2) Continuous recording (until Ctrl+C is pressed)"
    read -p "Select mode [1/2] (default: 1): " mode_choice
    case "$mode_choice" in
        2) CAPTURE_MODE="continuous" ;;
        *) CAPTURE_MODE="timed" ;;
    esac
    echo

    # Duration (only for timed mode)
    if [[ "$CAPTURE_MODE" == "timed" ]]; then
        read -p "Enter duration in seconds (default: $DURATION): " duration_input
        if [[ -n "$duration_input" ]]; then
            DURATION="$duration_input"
        fi
        echo
    fi

    # Interval
    read -p "Enter interval between screenshots in seconds (default: $INTERVAL): " interval_input
    if [[ -n "$interval_input" ]]; then
        INTERVAL="$interval_input"
    fi
    echo

    # Output format
    echo "Output format:"
    echo "1) MP4 video"
    echo "2) Animated GIF"
    read -p "Select format [1/2] (default: 1): " format_choice
    case "$format_choice" in
        2) FORMAT="gif" ;;
        *) FORMAT="mp4" ;;
    esac
    echo

    # Output filename
    read -p "Enter output filename without extension (default: $OUTPUT_FILE): " output_input
    if [[ -n "$output_input" ]]; then
        OUTPUT_FILE="$output_input"
    fi
    echo

    # Quality
    read -p "Enter JPEG quality (1-100) (default: $QUALITY): " quality_input
    if [[ -n "$quality_input" ]]; then
        QUALITY="$quality_input"
    fi
    echo

    # Framerate
    read -p "Enter framerate for output video/GIF (default: $FRAMERATE): " framerate_input
    if [[ -n "$framerate_input" ]]; then
        FRAMERATE="$framerate_input"
    fi
    echo

    # Window capture
    echo "Capture options:"
    echo "1) Full screen"
    echo "2) Select a window to capture"
    echo "3) Specify a display number"
    read -p "Select option [1/2/3] (default: 1): " capture_choice
    case "$capture_choice" in
        2) 
            SELECT_WINDOW=true
            WINDOW_ID=""
            DISPLAY_NUM=""
            ;;
        3)
            SELECT_WINDOW=false
            WINDOW_ID=""
            read -p "Enter display number: " DISPLAY_NUM
            ;;
        *)
            SELECT_WINDOW=false
            WINDOW_ID=""
            DISPLAY_NUM=""
            ;;
    esac
    echo

    echo "Settings configured. Press Enter to continue..."
    read
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--duration)
            DURATION="$2"
            shift 2
            ;;
        -i|--interval)
            INTERVAL="$2"
            shift 2
            ;;
        -f|--format)
            FORMAT="$2"
            if [[ "$FORMAT" != "mp4" && "$FORMAT" != "gif" ]]; then
                echo "Error: Format must be 'mp4' or 'gif'"
                exit 1
            fi
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -q|--quality)
            QUALITY="$2"
            shift 2
            ;;
        -r|--framerate)
            FRAMERATE="$2"
            shift 2
            ;;
        -w|--select-window)
            SELECT_WINDOW=true
            shift
            ;;
        -W|--window-id)
            WINDOW_ID="$2"
            shift 2
            ;;
        -D|--display)
            DISPLAY_NUM="$2"
            shift 2
            ;;
        -c|--continuous)
            CAPTURE_MODE="continuous"
            shift
            ;;
        -m|--menu)
            INTERACTIVE=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

# Show interactive menu if requested
if [[ "$INTERACTIVE" == true ]]; then
    show_interactive_menu
fi

# Check if required tools are installed
if ! command -v import &> /dev/null && ! command -v gnome-screenshot &> /dev/null; then
    echo "Error: No screenshot utility found. Please install ImageMagick or gnome-screenshot."
    exit 1
fi

if [[ "$FORMAT" == "mp4" ]] && ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install it to create MP4 videos."
    exit 1
fi

if [[ "$FORMAT" == "gif" ]] && ! command -v convert &> /dev/null; then
    echo "Error: convert (ImageMagick) is not installed. Please install it to create GIFs."
    exit 1
fi

# Check for xdotool when window selection is enabled
if [[ "$SELECT_WINDOW" == true ]] && ! command -v xdotool &> /dev/null; then
    echo "Error: xdotool is not installed. Please install it to use window selection."
    echo "On Ubuntu/Debian, run: sudo apt install xdotool"
    exit 1
fi

# Check for xrandr when display selection is enabled
if [[ -n "$DISPLAY_NUM" ]] && ! command -v xrandr &> /dev/null; then
    echo "Error: xrandr is not installed. Please install it to use display selection."
    echo "On Ubuntu/Debian, run: sudo apt install x11-xserver-utils"
    exit 1
fi

# Set up window selection
WINDOW_PARAM=""
if [[ "$SELECT_WINDOW" == true ]]; then
    if ! command -v xdotool &> /dev/null; then
        echo "Error: xdotool is required for window selection."
        exit 1
    fi
    
    echo "Click on the window you want to capture..."
    WINDOW_ID=$(xdotool selectwindow 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo "Window selection failed. Reverting to full screen capture."
    else
        echo "Selected window ID: $WINDOW_ID"
        WINDOW_PARAM="-window $WINDOW_ID"
    fi
fi

# If window ID was provided directly, set the parameter
if [[ -n "$WINDOW_ID" && "$SELECT_WINDOW" != true ]]; then
    # Check if the window ID exists
    if ! xdotool getwindowname "$WINDOW_ID" &>/dev/null; then
        echo "Warning: Window ID $WINDOW_ID might not exist. Continuing anyway."
    fi
    WINDOW_PARAM="-window $WINDOW_ID"
fi

# Handle display selection
DISPLAY_PARAM=""
if [[ -n "$DISPLAY_NUM" ]]; then
    if ! command -v xrandr &> /dev/null; then
        echo "Error: xrandr is required for display selection."
        exit 1
    fi
    
    # Get display geometry for the selected display
    DISPLAY_INFO=$(xrandr --current | grep "^Screen $DISPLAY_NUM" 2>/dev/null)
    if [[ -z "$DISPLAY_INFO" ]]; then
        echo "Warning: Display $DISPLAY_NUM not found. Using primary display."
        # Get primary display
        DISPLAY_INFO=$(xrandr --current | grep primary)
        if [[ -z "$DISPLAY_INFO" ]]; then
            echo "Error: Could not determine display information."
            exit 1
        fi
    fi
    
    # Extract geometry information for import command
    DISPLAY_PARAM="-screen"
fi

# Create timestamped directory for screenshots
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SCREENSHOT_DIR="/tmp/timelapse_${TIMESTAMP}"
mkdir -p "$SCREENSHOT_DIR"

echo "Timelapse screenshot session started:"
if [[ "$CAPTURE_MODE" == "timed" ]]; then
    echo "- Mode: Timed recording"
    echo "- Duration: $DURATION seconds"
else
    echo "- Mode: Continuous recording (press Ctrl+C to stop)"
fi
echo "- Interval: $INTERVAL seconds"
echo "- Output format: $FORMAT"
echo "- Output file: $OUTPUT_FILE.$FORMAT"
echo "- Screenshots stored in: $SCREENSHOT_DIR"
if [[ -n "$WINDOW_PARAM" ]]; then
    echo "- Capturing specific window: ID $WINDOW_ID"
elif [[ -n "$DISPLAY_PARAM" ]]; then
    echo "- Capturing display: $DISPLAY_NUM"
else
    echo "- Capturing full screen"
fi
echo 

# Calculate number of screenshots to take for timed mode
if [[ "$CAPTURE_MODE" == "timed" ]]; then
    NUM_SCREENSHOTS=$(( DURATION / INTERVAL ))
    if [ "$NUM_SCREENSHOTS" -lt 2 ]; then
        echo "Error: Duration too short for interval. Need at least 2 screenshots."
        exit 1
    fi
    echo "Will take $NUM_SCREENSHOTS screenshots."
    echo "Starting in 3 seconds... Press Ctrl+C to cancel."
    sleep 3
fi

# Setup trap for continuous mode
if [[ "$CAPTURE_MODE" == "continuous" ]]; then
    # Initialize counter
    COUNTER=1
    
    # Function to handle Ctrl+C for continuous mode
    cleanup() {
        echo -e "\n\nCapture stopped. Creating $FORMAT file..."
        # Check if we have at least 2 screenshots
        NUM_FILES=$(ls "${SCREENSHOT_DIR}/screenshot_"*.jpg 2>/dev/null | wc -l)
        if [ "$NUM_FILES" -lt 2 ]; then
            echo "Error: At least 2 screenshots are needed to create a timelapse."
            rm -rf "$SCREENSHOT_DIR"
            exit 1
        fi
        create_timelapse
        exit 0
    }
    
    # Set up trap to catch Ctrl+C
    trap cleanup SIGINT SIGTERM
    
    echo "Starting continuous capture. Press Ctrl+C to stop and create timelapse."
    echo "Starting in 3 seconds..."
    sleep 3
fi

# Function to create the timelapse
create_timelapse() {
    echo "Creating $FORMAT file..."
    
    # Create the timelapse based on the chosen format
    if [[ "$FORMAT" == "mp4" ]]; then
        ffmpeg -framerate "$FRAMERATE" -pattern_type glob -i "${SCREENSHOT_DIR}/screenshot_*.jpg" \
               -c:v libx264 -pix_fmt yuv420p -crf 23 "${OUTPUT_FILE}.${FORMAT}" -y -loglevel error
        echo "Video saved as ${OUTPUT_FILE}.${FORMAT}"
    else
        convert -delay $(( 100 / FRAMERATE )) "${SCREENSHOT_DIR}/screenshot_*.jpg" -loop 0 "${OUTPUT_FILE}.${FORMAT}"
        echo "GIF saved as ${OUTPUT_FILE}.${FORMAT}"
    fi
    
    # Ask if user wants to keep the screenshots
    read -p "Do you want to keep the screenshot files? (y/N): " KEEP_FILES
    if [[ "$KEEP_FILES" =~ ^[Yy]$ ]]; then
        # Move screenshots to a directory in the current path
        NEW_DIR="./timelapse_screenshots_${TIMESTAMP}"
        mkdir -p "$NEW_DIR"
        cp "${SCREENSHOT_DIR}"/* "$NEW_DIR"/
        echo "Screenshots copied to $NEW_DIR"
    fi
    
    # Clean up
    rm -rf "$SCREENSHOT_DIR"
    
    echo "Timelapse creation completed successfully!"
    exit 0
}

# Function to display progress bar
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percent=$(( current * 100 / total ))
    local completed=$(( width * current / total ))
    
    # Calculate estimated time remaining
    if [ "$current" -gt 0 ]; then
        local elapsed_time=$(( current * INTERVAL ))
        local total_time=$(( total * INTERVAL ))
        local remaining_time=$(( total_time - elapsed_time ))
        local time_str="$(( remaining_time / 60 ))m $(( remaining_time % 60 ))s remaining"
    else
        local time_str="calculating..."
    fi
    
    printf "\r[%-${width}s] %d%% %d/%d %s" "$(printf '#%.0s' $(seq 1 $completed))" "$percent" "$current" "$total" "$time_str"
}

# Function to take a screenshot
take_screenshot() {
    local index=$1
    local filename=$(printf "%s/screenshot_%04d.jpg" "$SCREENSHOT_DIR" "$index")
    
    # Take screenshot using available tool
    if command -v import &> /dev/null; then
        if [[ -n "$WINDOW_PARAM" ]]; then
            # Capture specific window
            import $WINDOW_PARAM -quality "$QUALITY" "$filename"
        elif [[ -n "$DISPLAY_PARAM" ]]; then
            # Capture specific display
            import $DISPLAY_PARAM -quality "$QUALITY" "$filename"
        else
            # Capture entire screen
            import -window root -quality "$QUALITY" "$filename"
        fi
    else
        # gnome-screenshot doesn't support capturing specific windows via command line
        # parameters in the same way as import, so we provide a warning if needed
        if [[ -n "$WINDOW_PARAM" || -n "$DISPLAY_PARAM" ]]; then
            if [[ "$index" -eq 1 ]]; then
                echo "Warning: Window/display selection is not fully supported with gnome-screenshot."
                echo "Falling back to full screen capture. Consider installing ImageMagick for window selection."
            fi
        fi
        gnome-screenshot -f "$filename"
    fi
    
    return 0
}

# Handle different capture modes
if [[ "$CAPTURE_MODE" == "timed" ]]; then
    # Take screenshots at regular intervals for timed mode
    for (( i=1; i<=NUM_SCREENSHOTS; i++ ))
    do
        take_screenshot "$i"
        
        # Show progress
        show_progress "$i" "$NUM_SCREENSHOTS"
        
        # Sleep for the interval (if not the last screenshot)
        if [ "$i" -lt "$NUM_SCREENSHOTS" ]; then
            sleep "$INTERVAL"
        fi
    done
    
    echo -e "\n\nCapture complete. Creating $FORMAT file..."
    create_timelapse
else
    # Continuous mode - take screenshots until Ctrl+C is pressed
    i=1
    while true; do
        take_screenshot "$i"
        
        # Show simple progress for continuous mode
        echo -ne "\rScreenshots taken: $i"
        
        # Sleep for the interval
        sleep "$INTERVAL"
        
        # Increment counter
        ((i++))
    done
fi

