#!/bin/bash
# Compile Typst document to HTML using Lucy-Tufte template with Tufte CSS

set -e

# Check if input is provided
if [ -z "$1" ]; then
    echo "Error: Input file is required"
    echo "Usage: $0 <input.typ> [output.html]"
    exit 1
fi

INPUT="$1"
# Output defaults to same directory as input with .html extension
OUTPUT="${2:-$(dirname "$INPUT")/$(basename "${INPUT%.typ}.html")}"

# Check if input file exists
if [ ! -f "$INPUT" ]; then
    echo "Error: Input file '$INPUT' not found"
    echo "Usage: $0 <input.typ> [output.html]"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT")"

echo "Compiling $INPUT to HTML..."



typst compile --root . --features html --format html "$INPUT" "$OUTPUT"

# Inject Tufte CSS from CDN into HTML head
if command -v sed &> /dev/null; then
    sed -i.bak '/<head>/a\
  <meta name="viewport" content="width=device-width, initial-scale=1">\
  <link rel="stylesheet" href="https://edwardtufte.github.io/tufte-css/tufte.css"/>
' "$OUTPUT"
    rm "${OUTPUT}.bak"
fi

echo "✓ HTML generated: $OUTPUT"
echo "✓ Using Tufte CSS from CDN. Inject and changing the head of the generated html file"

