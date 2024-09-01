#!/bin/bash

DIST=$1
HTML_FILE=index.html

while IFS= read -r -d '' file; do
    hash=$(md5sum "$file" | cut -d ' ' -f 1 | head -c 8)
    
    file_name=$(basename "$file")
    file_dir=$(dirname "$file")
    mv "$file" "$file_dir/$hash-$file_name"
    sed -i "s/$file_name/$hash-$file_name/g" "$DIST"/$HTML_FILE
done < <(find "$DIST" -type f ! -name "*.html" -print0)
