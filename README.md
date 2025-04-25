# Riley Leff's CV - Typst Source

This repository contains the source code for generating my CV (curriculum vitae) using [Typst](https://typst.app/). It employs a modular, data-driven approach, making updates easier and separating content from presentation.

The final output is generated at `rileycv.pdf`.

## Features

*   **Modular Design:** Each major CV section (Education, Awards, Publications, etc.) is defined by its own data file and formatting rules.
*   **Data-Driven:** Content is stored in simple `.toml` files within the `data/` directory, making updates straightforward.
*   **Zotero Integration:** Publications and Datasets are automatically pulled from a specified Zotero collection using the Zotero API via a Python script. Citation stats are preserved during updates, requiring manual refresh. I might update this to pull from semantic scholar's API in the future, but right now they think I am two different people for some reason.
*   **Customizable Formatters:** The appearance of each section is controlled by corresponding `.typ` files in the `formatters/` directory.
*   **Reproducible Builds:** Uses Typst for consistent PDF generation and `uv` for managing the Python script's dependencies.

## Setup

To compile this CV (or one that looks suspiciously like it but with your information in it) yourself, you'll need a few prerequisites and some setup steps.

### Prerequisites

1.  **Typst:** Install the Typst compiler. Follow the instructions on the [official Typst installation guide](https://github.com/typst/typst#installation).
2.  **Python:** Ensure you have Python 3.8 or newer installed.
3.  **uv:** Install `uv`, the fast Python package installer and resolver used to run the Zotero script. Follow the instructions on the [official uv installation guide](https://github.com/astral-sh/uv#installation).

### Getting the Code

Clone this repository:
```bash
git clone github.com/rileyleff/rileycv # Replace with your actual repo URL
cd rileycv # Or your repository directory name
```

### Zotero API Setup (for Publications)

To automatically fetch publications and datasets:

1.  **Get Zotero Credentials:**
    *   **User ID:** Find this on your Zotero Feeds/API settings page: [zotero.org/settings/feeds/api](https://www.zotero.org/settings/feeds/api)
    *   **API Key:** Create a new private key on the same page. Grant it **read-only** access to your library. **Copy the key immediately** as it won't be shown again.
    *   **Collection Key:** Navigate to the specific Zotero collection in your web library. The key is the alphanumeric string at the end of the URL (e.g., `ABC123XYZ` in `.../collections/ABC123XYZ`).
2.  **Create `.env` File:** In the root directory of this project, create a file named `.env` and add your credentials like this:
    ```dotenv
    # .env - Zotero API Credentials
    # IMPORTANT: Ensure this file is listed in .gitignore!

    ZOTERO_USER_ID="YOUR_USER_ID_HERE"
    ZOTERO_API_KEY="YOUR_SECRET_API_KEY_HERE"
    ZOTERO_COLLECTION_KEY="YOUR_PUBLICATION_COLLECTION_KEY_HERE"

    # Optional: Add your Google Scholar ID if desired for the link
    # GOOGLE_SCHOLAR_ID="YOUR_ID_HERE"
    ```
    *(Note: The included `.gitignore` file should already prevent this file from being committed.)*

## Usage

1.  **Sync Publications from Zotero:**
    *   Make the Python script executable (only needed once):
        ```bash
        chmod +x generate_pubs_toml.py
        ```
    *   Run the script to fetch data from Zotero and update `data/publications.toml`. It uses the credentials from your `.env` file.
        ```bash
        ./generate_pubs_toml.py
        ```
    *   **(Manual Step):** After running the script, manually edit the `[stats]` section within `data/publications.toml` to update your citation count and h-index if desired. The script preserves these values on subsequent runs.

2.  **Compile the CV:**
    *   Use the Typst CLI to compile the main `.typ` file into a PDF:
        ```bash
        typst compile rileycv.typ rileycv.pdf
        ```
    *   Alternatively, use watch mode for automatic recompilation on changes:
        ```bash
        typst watch rileycv.typ rileycv.pdf
        ```
        Press `Ctrl+C` to stop watch mode.

## Customization

*   **Content:**
    *   Edit the `.toml` files in the `data/` directory for most sections (Education, Awards, Computing Profile).
    *   For Publications/Datasets, manage the entries in your designated Zotero collection and re-run `./generate_pubs_toml.py`. Remember to manually update the `[stats]` in `data/publications.toml`.
*   **Appearance/Layout:**
    *   Modify the corresponding `.typ` files in the `formatters/` directory to change how specific sections are styled.
    *   Edit `rileycv.typ` to change global settings (margins, fonts, main structure, section order).

## License
Your choice of MIT or Apache