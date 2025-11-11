#!/bin/bash
# Compile Typst document to PDF using Lucy-Tufte template

set -e

# Default paths
INPUT="${1:-examples/introduction.typ}"
OUTPUT="${2:-output/pdf/$(basename "${INPUT%.typ}.pdf")}"

# Check if input file exists
if [ ! -f "$INPUT" ]; then
    echo "Error: Input file '$INPUT' not found"
    echo "Usage: $0 <input.typ> [output.pdf]"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT")"

# Compile to PDF
# Note: Page config is commented out for HTML compatibility
# PDF will use default page settings (can be customized in template if needed)
echo "Compiling $INPUT to PDF..."
typst compile --root . "$INPUT" "$OUTPUT"

echo "✓ PDF generated: $OUTPUT"

