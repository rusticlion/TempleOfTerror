#!/bin/bash

# Script to dump the project structure into an organized Markdown file.

OUTPUT_FILE="project_structure.md"
PROJECT_DIR="CardGame" # Focus on the inner CardGame directory

# Start with a clean output file
echo "# Project Structure for $PROJECT_DIR" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "## Directory Tree" >> "$OUTPUT_FILE"
echo "\`\`\`" >> "$OUTPUT_FILE"
# Use find to list directories and files, then sed to format into a tree-like structure for Markdown
find "$PROJECT_DIR" -print | sed -e 's;[^/]*/;|____;g' -e 's;____|; |;' -e 's;[^./]*\.[[:alnum:]_]\+;\`&\`;g' >> "$OUTPUT_FILE"
echo "\`\`\`" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "## File Contents" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Find all files (excluding .git, node_modules, and the output file itself within the PROJECT_DIR)
# and append their content to the Markdown file.
find "$PROJECT_DIR" -type f \
    -not -path "$PROJECT_DIR/.git/*" \
    -not -path "$PROJECT_DIR/node_modules/*" \
    -not -name "$OUTPUT_FILE" \
    -not -name "*.sh" \
    -print0 | while IFS= read -r -d $'\0' file; do
    echo "### \`$file\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE" # Use three backticks for code blocks
    # Add a newline before file content if file is not empty
    if [ -s "$file" ]; then
        echo "" >> "$OUTPUT_FILE"
    fi
    cat "$file" >> "$OUTPUT_FILE"
    # Add a newline after file content if file is not empty
    if [ -s "$file" ]; then
        echo "" >> "$OUTPUT_FILE"
    fi
    echo "\`\`\`" >> "$OUTPUT_FILE" # Use three backticks for code blocks
    echo "" >> "$OUTPUT_FILE"
done

echo "Markdown file '$OUTPUT_FILE' created successfully for directory '$PROJECT_DIR'." 