Timelapse.sh - Screen Capture Timelapse Tool

Overview
Timelapse.sh is a versatile Bash script that creates timelapses from screenshots of your desktop or specific windows. It captures screenshots at regular intervals and combines them into either MP4 videos or animated GIFs. The script now features both command-line options and an interactive menu for easy configuration, along with two capture modes: timed recording and continuous recording.

Features

Capture Modes
•  Timed Recording: Captures screenshots for a specified duration
•  Continuous Recording: Captures screenshots until manually stopped (Ctrl+C)

Configuration Options
•  Duration: Length of the timelapse capture (for timed mode only)
•  Interval: Time between screenshots (in seconds)
•  Output Format: Choose between MP4 video or animated GIF
•  Filename: Custom output filename
•  Quality: JPEG quality for screenshots (1-100)
•  Framerate: FPS setting for the output video/GIF
•  Capture Selection:
•  Full screen capture
•  Specific window capture (interactive selection)
•  Specific display capture (for multi-monitor setups)

User Interface
•  Interactive Menu: User-friendly menu for setting all options
•  Command-line Arguments: For advanced users and automation
•  Progress Display: Shows progress with percentage and time remaining
•  Screenshot Management: Option to keep or delete screenshot files after timelapse creation

Usage

Interactive Menu Mode

./timelapse.sh --menu

This presents an easy-to-use menu where you can:
1. Select capture mode (timed or continuous)
2. Set duration, interval, format, and other parameters
3. Choose what to capture (full screen, specific window, or display)

Command-line Mode

./timelapse.sh [options]

#### Available Options:
•  -d, --duration SECONDS: Duration of capture in seconds (default: 60)
•  -i, --interval SECONDS: Interval between screenshots (default: 5)
•  -f, --format FORMAT: Output format: mp4 or gif (default: mp4)
•  -o, --output FILENAME: Output filename without extension (default: timelapse)
•  -q, --quality QUALITY: JPEG quality (1-100) (default: 95)
•  -r, --framerate FPS: Frames per second for output (default: 10)
•  -w, --select-window: Interactively select a window to capture
•  -W, --window-id ID: Specify a window ID to capture
•  -D, --display NUMBER: Specify which display to capture in multi-monitor setup
•  -c, --continuous: Record until manually stopped (Ctrl+C)
•  -m, --menu: Show interactive menu
•  -h, --help: Show help message

Examples

Basic Timed Recording
./timelapse.sh --duration 300 --interval 2
Creates a 5-minute timelapse with screenshots every 2 seconds.

Continuous Recording with Window Selection
./timelapse.sh --continuous --select-window --format gif
Starts a continuous recording of a selected window, saving as a GIF. Press Ctrl+C to stop recording.

Creating a High-quality Timelapse
./timelapse.sh --duration 600 --interval 1 --framerate 30 --quality 100 --output my_project
Creates a 10-minute, high-quality timelapse at 30fps named "my_project.mp4".

Technical Details

•  The script uses ImageMagick's import tool or gnome-screenshot for capturing screenshots
•  For MP4 output, it requires FFmpeg
•  For GIF output, it requires ImageMagick's convert utility
•  Window selection requires xdotool
•  Display selection requires xrandr
•  Screenshots are temporarily stored in /tmp/timelapse_[timestamp]/ before being combined
•  After timelapse creation, you can optionally keep the individual screenshots

Signal Handling

The script properly handles interruption signals (Ctrl+C):
•  In timed mode: Cancels the operation
•  In continuous mode: Stops capturing and proceeds to create the timelapse with captured frames

Requirements

•  Bash shell
•  ImageMagick (for import and convert) or gnome-screenshot
•  FFmpeg (for MP4 output)
•  xdotool (for window selection)
•  x11-xserver-utils (for display selection via xrandr)
