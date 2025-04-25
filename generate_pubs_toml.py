#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = [
#   "tomli-w",      # For writing TOML
#   "Pyzotero",
#   "python-dotenv",
#   "tomli",        # For reading TOML
# ]
# ///
"""
Generates publications.toml, fetching papers/datasets from Zotero API
and preserving the [stats] section if it exists in the output file.

Reads API credentials from a .env file or environment variables.

Setup:
1. Install 'uv'.
2. Create '.env' file with ZOTERO_USER_ID, ZOTERO_API_KEY, ZOTERO_COLLECTION_KEY.
3. (Optional) Manually edit the [stats] section in data/publications.toml after first run.

Usage:
1. Make executable: chmod +x generate_pubs_toml.py
2. Run: ./generate_pubs_toml.py [--output data/publications.toml]
"""

import json
import tomli_w
import tomli # Import tomli for reading
import re
import argparse
import sys
import os
from pathlib import Path
from pyzotero import zotero
from dotenv import load_dotenv

# --- Load Environment Variables ---
load_dotenv()

# --- Configuration ---
DEFAULT_OUTPUT_TOML_FILE = Path('data/publications.toml')
ZOTERO_USER_ID = os.environ.get("ZOTERO_USER_ID")
ZOTERO_API_KEY = os.environ.get("ZOTERO_API_KEY")
ZOTERO_COLLECTION_KEY = os.environ.get("ZOTERO_COLLECTION_KEY")
GOOGLE_SCHOLAR_ID = os.environ.get("GOOGLE_SCHOLAR_ID", "YOUR_ID_HERE")

# --- Helper Functions ---

def format_authors(authors_list):
    """Formats CSL JSON author list to 'First Last' style."""
    formatted_authors = []
    for author in authors_list:
        name = "" # Initialize name for the current author
        if 'literal' in author:
            # Handle organizational authors first
            name = author['literal']
        elif 'family' in author:
            # Handle personal authors
            name = author['family']
            if 'given' in author:
                # Prepend given name if available
                name = author['given'] + " " + name
        # Only append if a name was actually constructed
        if name:
            formatted_authors.append(name)

    num_authors = len(formatted_authors)
    if num_authors == 0:
        return ""
    elif num_authors == 1:
        return formatted_authors[0]
    elif num_authors == 2:
        return f"{formatted_authors[0]} and {formatted_authors[1]}"
    else: # More than 2 authors
        # Oxford comma style
        return ', '.join(formatted_authors[:-1]) + ', and ' + formatted_authors[-1]

def get_year(issued_data):
    """Extracts year from CSL JSON 'issued' structure."""
    try:
        if 'date-parts' in issued_data and issued_data['date-parts']:
            # Ensure it's not empty before accessing index 0
            if issued_data['date-parts'][0]:
                return str(issued_data['date-parts'][0][0])
        # Check other fields if date-parts is missing/malformed
        for field in ['raw', 'literal']:
             if field in issued_data and issued_data[field] is not None:
                 # Look for 4-digit year, handle potential non-string values
                 match = re.search(r'\b(19|20)\d{2}\b', str(issued_data[field]))
                 if match:
                     return match.group(0)
    except Exception:
        # Ignore errors during extraction, proceed to fallback
        pass
    return "N.D." # Not Dated

# --- Main Execution Logic ---
def main():
    parser = argparse.ArgumentParser(description="Generate publications.toml from Zotero API, preserving stats.")
    parser.add_argument("-o", "--output", type=Path, default=DEFAULT_OUTPUT_TOML_FILE, help=f"Output TOML (default: {DEFAULT_OUTPUT_TOML_FILE})")
    parser.add_argument("-c", "--collection", default=ZOTERO_COLLECTION_KEY, help="Zotero Collection Key")
    parser.add_argument("-u", "--user", default=ZOTERO_USER_ID, help="Zotero User ID")
    parser.add_argument("-k", "--key", default=ZOTERO_API_KEY, help="Zotero API Key")
    args = parser.parse_args()

    output_path = args.output
    user_id = args.user
    api_key = args.key
    collection_key = args.collection

    if not all([user_id, api_key, collection_key]):
        print("Error: Zotero User ID, API Key, and Collection Key are required.", file=sys.stderr)
        sys.exit(1) # Exit after printing error

    # --- Read Existing Stats ---
    existing_stats = {
         'scholar_link': f"https://scholar.google.com/citations?user={GOOGLE_SCHOLAR_ID}&hl=en&oi=ao",
         'citations': 0, 'h_index': 0,
    }
    if output_path.exists() and output_path.is_file():
        print(f"Attempting to read existing stats from: {output_path}")
        try:
            with output_path.open('rb') as f:
                existing_data = tomli.load(f)
            if isinstance(existing_data, dict) and 'stats' in existing_data:
                existing_stats = existing_data['stats']
                print("  Successfully loaded existing stats.")
            else:
                print("  Warning: Existing file found but no '[stats]' section detected.")
        except tomli.TOMLDecodeError:
            print(f"  Warning: Could not decode existing TOML file '{output_path}'.", file=sys.stderr)
        except Exception as e:
            print(f"  Warning: Error reading existing file '{output_path}': {e}.", file=sys.stderr)
    else:
        print(f"Output file '{output_path}' not found. Will create with default stats.")

    # --- Fetch Data from Zotero API ---
    try:
        print(f"Connecting to Zotero API for user {user_id}, collection {collection_key}...")
        zot = zotero.Zotero(user_id, 'user', api_key)
        items_generator = zot.collection_items(collection_key, itemType='-attachment', format='csljson')
        csl_data = list(items_generator)

        # --- START DEBUGGING ---
        print(f"DEBUG: Retrieved {len(csl_data)} items from API.")
        if csl_data:
            print("DEBUG: First item type:", type(csl_data[0]))
            print("DEBUG: First item value (first 500 chars):", repr(csl_data[0])[:500])
        # --- END DEBUGGING ---


        if not csl_data:
            print(f"Warning: No items found in collection '{collection_key}'.", file=sys.stderr)
    except Exception as e:
        print(f"Error fetching data from Zotero API: {e}", file=sys.stderr)
        sys.exit(1) # Exit after printing error

    papers = []
    datasets = []
    print(f"Processing {len(csl_data)} items retrieved from API...")
    # --- Process Items ---
    for item in csl_data:
        entry_type = item.get('type', 'article-journal').lower()
        entry_data = {
            'title': item.get('title', 'Untitled'),
            'authors': format_authors(item.get('author', [])),
            'year': get_year(item.get('issued', {})),
            'link': item.get('URL', None),
            'doi': item.get('DOI', None),
        }
        # Filter out empty author lists or titles before proceeding
        if not entry_data['authors'] or not entry_data['title'] or entry_data['title'] == 'Untitled':
             print(f"  Skipping item due to missing title or authors: {item.get('key', 'N/A')}")
             continue

        if entry_type in ['article-journal', 'paper-conference', 'chapter', 'report', 'thesis']:
            entry_data['journal'] = item.get('container-title', item.get('publisher', 'Unknown Journal/Venue'))
            papers.append({k: v for k, v in entry_data.items() if v is not None})
        elif entry_type == 'dataset':
            entry_data['venue'] = item.get('publisher', item.get('archive', 'Unknown Repository'))
            datasets.append({k: v for k, v in entry_data.items() if v is not None})
        # else: # Optionally log skipped types
            # print(f"  Skipping item type '{entry_type}' - {entry_data['title'][:30]}...")

    # --- Prepare Final TOML Structure ---
    final_data = {
        'stats': existing_stats,
        'papers': sorted(papers, key=lambda x: x.get('year', '0'), reverse=True),
        'datasets': sorted(datasets, key=lambda x: x.get('year', '0'), reverse=True)
    }

    # --- Write Output ---
    try:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        print(f"Writing TOML output to: {output_path}")
        with output_path.open('wb') as f:
            tomli_w.dump(final_data, f)
        print(f"Successfully generated '{output_path}' with {len(papers)} papers and {len(datasets)} datasets.")
        if existing_stats['citations'] > 0 or existing_stats['h_index'] > 0 :
             print("  Preserved existing [stats] section.")
        else:
             print("  Used default [stats] section (Update manually if needed).")
    except Exception as e:
        print(f"Error writing TOML file '{output_path}': {e}", file=sys.stderr)
        sys.exit(1) # Exit after printing error

if __name__ == "__main__":
    main()