#!/bin/bash
# Compile Typst document to HTML using Lucy-Tufte template with Tufte CSS

set -e

# Default paths
INPUT="${1:-examples/introduction.typ}"
OUTPUT="${2:-output/html/$(basename "${INPUT%.typ}.html")}"

# Check if input file exists
if [ ! -f "$INPUT" ]; then
    echo "Error: Input file '$INPUT' not found"
    echo "Usage: $0 <input.typ> [output.html]"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT")"

# Compile to HTML (requires Typst with HTML export support)
# Page config is already commented out in source for HTML compatibility
echo "Compiling $INPUT to HTML..."

# Create a temporary file with output-format set to html
# Use same directory as input to ensure it's in project root
TEMP_FILE="$(dirname "$INPUT")/.$(basename "$INPUT").html.tmp"
trap "rm -f $TEMP_FILE" EXIT

# Inject output-format parameter into the show rule
sed 's/#show: lucy-tufte\.with(/#show: lucy-tufte.with(\
  output-format: "html",/' "$INPUT" > "$TEMP_FILE"

typst compile --root . --features html --format html "$TEMP_FILE" "$OUTPUT"

# Inject Tufte CSS from CDN into HTML head
if command -v sed &> /dev/null; then
    sed -i.bak '/<head>/a\
  <meta name="viewport" content="width=device-width, initial-scale=1">\
  <link rel="stylesheet" href="https://edwardtufte.github.io/tufte-css/tufte.css"/>
' "$OUTPUT"
    rm "${OUTPUT}.bak"
fi

echo "✓ HTML generated: $OUTPUT"
echo "✓ Using Tufte CSS from CDN"

