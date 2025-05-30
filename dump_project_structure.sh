#!/bin/bash

# Script to dump the project structure into an organized Markdown file.

OUTPUT_FILE="project_structure.md"
PROJECT_DIR="CardGame" # Focus on the inner CardGame directory
CONTENT_DIR="Content"  # Additional directory to include
DOCS_DIR="Docs"        # Directory for documentation

# Start with a clean output file
echo "# Project, Content, and Documentation Structure" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# --- Directory Tree for PROJECT_DIR ---
echo "## Directory Tree for $PROJECT_DIR" >> "$OUTPUT_FILE"
if [ -d "$PROJECT_DIR" ]; then
    echo "\`\`\`" >> "$OUTPUT_FILE"
    find "$PROJECT_DIR" -print | sed -e 's;[^/]*/;|____;g' -e 's;____|; |;' -e 's;[^./]*\.[[:alnum:]_]\+;\`&\`;g' >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
else
    echo "Directory '$PROJECT_DIR' not found." >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# --- Directory Tree for CONTENT_DIR ---
if [ -d "$CONTENT_DIR" ]; then
    echo "## Directory Tree for $CONTENT_DIR" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    find "$CONTENT_DIR" -print | sed -e 's;[^/]*/;|____;g' -e 's;____|; |;' -e 's;[^./]*\.[[:alnum:]_]\+;\`&\`;g' >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

# --- Directory Tree for DOCS_DIR ---
if [ -d "$DOCS_DIR" ]; then
    echo "## Directory Tree for $DOCS_DIR" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    find "$DOCS_DIR" -print | sed -e 's;[^/]*/;|____;g' -e 's;____|; |;' -e 's;[^./]*\.[[:alnum:]_]\+;\`&\`;g' >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

echo "## File Contents" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# --- File Contents for PROJECT_DIR ---
if [ -d "$PROJECT_DIR" ]; then
    find "$PROJECT_DIR" -type f \
        -not -path "$PROJECT_DIR/.git/*" \
        -not -path "$PROJECT_DIR/node_modules/*" \
        -not -path "$PROJECT_DIR/AssetPlaceholders/*" \
        -not -path "$PROJECT_DIR/Assets.xcassets/*" \
        -not -path "$PROJECT_DIR/.DS_Store" \
        -not -name "$OUTPUT_FILE" \
        -not -name "*.sh" \
        -print0 | while IFS= read -r -d $'\0' file; do
        echo "### \`$file\`" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo "\`\`\`" >> "$OUTPUT_FILE"
        if [ -s "$file" ]; then echo "" >> "$OUTPUT_FILE"; fi
        cat "$file" >> "$OUTPUT_FILE"
        if [ -s "$file" ]; then echo "" >> "$OUTPUT_FILE"; fi
        echo "\`\`\`" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    done
fi

# --- File Contents for CONTENT_DIR ---
if [ -d "$CONTENT_DIR" ]; then
    find "$CONTENT_DIR" -type f \
        -not -path "$CONTENT_DIR/.git/*" \
        -not -path "$CONTENT_DIR/node_modules/*" \
        -not -name "$OUTPUT_FILE" \
        -not -name "*.sh" \
        -print0 | while IFS= read -r -d $'\0' file; do
        echo "### \`$file\`" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo "\`\`\`" >> "$OUTPUT_FILE"
        if [ -s "$file" ]; then echo "" >> "$OUTPUT_FILE"; fi
        cat "$file" >> "$OUTPUT_FILE"
        if [ -s "$file" ]; then echo "" >> "$OUTPUT_FILE"; fi
        echo "\`\`\`" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    done
fi

# --- File Contents for DOCS_DIR ---
if [ -d "$DOCS_DIR" ]; then
    find "$DOCS_DIR" -type f \
        -not -path "$DOCS_DIR/.git/*" \
        -not -path "$DOCS_DIR/node_modules/*" \
        -not -name "$OUTPUT_FILE" \
        -not -name "*.sh" \
        -print0 | while IFS= read -r -d $'\0' file; do
        echo "### \`$file\`" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo "\`\`\`" >> "$OUTPUT_FILE"
        if [ -s "$file" ]; then echo "" >> "$OUTPUT_FILE"; fi
        cat "$file" >> "$OUTPUT_FILE"
        if [ -s "$file" ]; then echo "" >> "$OUTPUT_FILE"; fi
        echo "\`\`\`" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    done
fi

echo "Markdown file '$OUTPUT_FILE' created successfully." 