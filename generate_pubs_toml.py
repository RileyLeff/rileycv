#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = [
#   "tomli-w", "Pyzotero", "python-dotenv", "tomli",
# ]
# ///
"""
Generates publications.toml from Zotero API using content='csljson'.
Preserves the [stats] section if it exists.

Setup/Usage: See previous versions.
"""

import json
import tomli_w
import tomli
import re
import argparse
import sys
import os
from pathlib import Path
from pyzotero import zotero
from dotenv import load_dotenv

# --- Load Env Vars, Config, Helpers (Unchanged) ---
load_dotenv()
DEFAULT_OUTPUT_TOML_FILE = Path('data/publications.toml')
ZOTERO_USER_ID = os.environ.get("ZOTERO_USER_ID")
ZOTERO_API_KEY = os.environ.get("ZOTERO_API_KEY")
ZOTERO_COLLECTION_KEY = os.environ.get("ZOTERO_COLLECTION_KEY")
GOOGLE_SCHOLAR_ID = os.environ.get("GOOGLE_SCHOLAR_ID", "YOUR_ID_HERE")

def format_authors(authors_list):
    # ... (same as before) ...
    formatted_authors = []
    for author in authors_list:
        name = ""
        if 'literal' in author: name = author['literal']
        elif 'family' in author:
            name = author['family']
            if 'given' in author: name = author['given'] + " " + name
        if name: formatted_authors.append(name)
    num_authors = len(formatted_authors)
    if num_authors == 0: return ""
    if num_authors == 1: return formatted_authors[0]
    if num_authors == 2: return f"{formatted_authors[0]} and {formatted_authors[1]}"
    return ', '.join(formatted_authors[:-1]) + ', and ' + formatted_authors[-1]

def get_year(issued_data):
    # ... (same as before) ...
    try:
        if 'date-parts' in issued_data and issued_data['date-parts'] and issued_data['date-parts'][0]:
            return str(issued_data['date-parts'][0][0])
        for field in ['raw', 'literal']:
             if field in issued_data and issued_data[field] is not None:
                 match = re.search(r'\b(19|20)\d{2}\b', str(issued_data[field]))
                 if match: return match.group(0)
    except Exception: pass
    return "N.D."

# --- Main Execution Logic ---
def main():
    parser = argparse.ArgumentParser(description="Generate publications.toml from Zotero API (using content='csljson'), preserving stats.")
    # ... (argparse setup unchanged) ...
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
        sys.exit(1)

    # --- Read Existing Stats (Unchanged) ---
    existing_stats = {'scholar_link': f"https://scholar.google.com/citations?user={GOOGLE_SCHOLAR_ID}&hl=en&oi=ao",'citations': 0, 'h_index': 0}
    if output_path.exists() and output_path.is_file():
        print(f"Attempting to read existing stats from: {output_path}")
        try:
            with output_path.open('rb') as f: existing_data = tomli.load(f)
            if isinstance(existing_data, dict) and 'stats' in existing_data:
                existing_stats = existing_data['stats']; print("  Successfully loaded existing stats.")
            else: print("  Warning: Existing file found but no '[stats]' section detected.")
        except Exception as e: print(f"  Warning: Error reading existing file '{output_path}': {e}. Using default stats.", file=sys.stderr)
    else: print(f"Output file '{output_path}' not found. Will create with default stats.")


    # --- Fetch CSL JSON Data Directly using 'content' parameter ---
    csl_data = []
    try:
        print(f"Connecting to Zotero API for user {user_id}, collection {collection_key}...")
        zot = zotero.Zotero(user_id, 'user', api_key)

        # ** Use content='csljson' here **
        # Pyzotero should parse this into a list of dicts automatically
        print(f"Fetching items from collection {collection_key} as CSL JSON...")
        # Using zot.everything to handle potential pagination (limit > 100)
        csl_data = zot.everything(zot.collection_items(collection_key, itemType='-attachment', content='csljson', limit=None))
        # Note: limit=None tells zot.everything to fetch all pages.

        # Debugging check: See if we get dictionaries now
        print(f"DEBUG: Retrieved {len(csl_data)} items from API.")
        if csl_data and isinstance(csl_data[0], dict):
            print("DEBUG: First item type:", type(csl_data[0]))
            print("DEBUG: First item keys:", list(csl_data[0].keys())) # See if it has CSL keys
        elif csl_data:
             print("DEBUG: First item type:", type(csl_data[0])) # If not dict, what is it?
             print("DEBUG: First item value:", repr(csl_data[0])[:200])

        if not csl_data:
             print(f"Warning: No items found in collection '{collection_key}' or failed to fetch.", file=sys.stderr)

    except Exception as e:
        print(f"Error fetching data from Zotero API: {e}", file=sys.stderr)
        print("Check credentials, collection key, and internet connection.", file=sys.stderr)
        sys.exit(1)


    papers = []
    datasets = []
    print(f"Processing {len(csl_data)} items retrieved from API...")
    # --- Process Items ---
    for item in csl_data:
        # Check if item is actually a dictionary before processing
        if not isinstance(item, dict):
            print(f"  Warning: Skipping item that is not a dictionary: {repr(item)[:100]}")
            continue

        # --- Proceed with processing the CSL JSON dictionary 'item' ---
        entry_type = item.get('type', 'article-journal').lower()
        entry_data = {
            'title': item.get('title', 'Untitled'),
            'authors': format_authors(item.get('author', [])),
            'year': get_year(item.get('issued', {})),
            'link': item.get('URL', None),
            'doi': item.get('DOI', None),
        }

        if not entry_data['authors'] or not entry_data['title'] or entry_data['title'] == 'Untitled':
             print(f"  Skipping item due to missing title or authors: {item.get('id', 'N/A')}") # CSL uses 'id' not 'key'
             continue

        if entry_type in ['article-journal', 'paper-conference', 'chapter', 'report', 'thesis']:
            entry_data['journal'] = item.get('container-title', item.get('publisher', 'Unknown Journal/Venue'))
            papers.append({k: v for k, v in entry_data.items() if v is not None})
        elif entry_type == 'dataset':
            entry_data['venue'] = item.get('publisher', item.get('archive', 'Unknown Repository'))
            datasets.append({k: v for k, v in entry_data.items() if v is not None})
        # else: print(f"  Skipping item type '{entry_type}' - {entry_data['title'][:30]}...")


    # --- Prepare Final TOML Structure (Unchanged) ---
    final_data = {
        'stats': existing_stats,
        'papers': sorted(papers, key=lambda x: x.get('year', '0'), reverse=True),
        'datasets': sorted(datasets, key=lambda x: x.get('year', '0'), reverse=True)
    }

    # --- Write Output (Unchanged) ---
    try:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        print(f"Writing TOML output to: {output_path}")
        with output_path.open('wb') as f: tomli_w.dump(final_data, f)
        print(f"Successfully generated '{output_path}' with {len(papers)} papers and {len(datasets)} datasets.")
        if existing_stats['citations'] > 0 or existing_stats['h_index'] > 0 : print("  Preserved existing [stats] section.")
        else: print("  Used default [stats] section (Update manually if needed).")
    except Exception as e: print(f"Error writing TOML file '{output_path}': {e}", file=sys.stderr); sys.exit(1)


if __name__ == "__main__":
    main()