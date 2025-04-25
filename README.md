# Riley Leff's CV - Typst Source

This repository contains the source code for generating my Curriculum Vitae (CV) using [Typst](https://typst.app/). It employs a modular, data-driven approach, making updates easier and separating content from presentation.

The final output is generated as `rileycv.pdf` and is automatically compiled and included in commits via a pre-commit hook.

## Features

*   **Modular Design:** Each major CV section (Education, Awards, Publications, etc.) is defined by its own data file and formatting rules.
*   **Data-Driven:** Content is stored in simple `.toml` files within the `data/` directory, making updates straightforward.
*   **Zotero Integration:** Publications and Datasets are automatically pulled from a specified Zotero collection using the Zotero API via a Python script (`scripts/generate_pubs_toml.py`). Citation stats are preserved during updates, requiring manual refresh.
*   **Customizable Formatters:** The appearance of each section is controlled by corresponding `.typ` files in the `formatters/` directory.
*   **Reproducible Builds:** Uses Typst for consistent PDF generation.
*   **Automated PDF Compilation:** A pre-commit hook automatically compiles `rileycv.typ` to `rileycv.pdf` and stages the result, ensuring the PDF in the repository stays up-to-date with the source files.

## Setup

To compile this CV yourself, you'll need a few prerequisites and some setup steps.

### Prerequisites

1.  **Typst:** Install the Typst compiler. Follow the instructions on the [official Typst installation guide](https://github.com/typst/typst#installation).
2.  **Python:** Ensure you have Python 3.8 or newer installed.
3.  **uv:** Install `uv`, the fast Python package installer and resolver used to run the Zotero script. Follow the instructions on the [official uv installation guide](https://github.com/astral-sh/uv#installation).
4.  **pre-commit:** Install the `pre-commit` framework used to manage Git hooks. Typically:
    ```bash
    pip install pre-commit
    # or using pipx
    pipx install pre-commit
    ```

### Getting the Code

Clone this repository:
```bash
git clone <repository_url> # Replace with your actual repo URL
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

### Install Git Hooks

After cloning and setting up your `.env` file, install the pre-commit hooks defined in `.pre-commit-config.yaml`:
```bash
pre-commit install
```
This only needs to be run once per clone of the repository.

## Usage

1.  **Sync Publications from Zotero (Optional):**
    *   If you need to update your publication list from Zotero, make the Python script executable (only needed once):
        ```bash
        chmod +x scripts/generate_pubs_toml.py
        ```
    *   Run the script:
        ```bash
        ./scripts/generate_pubs_toml.py
        ```
    *   **(Manual Step):** After running the script, manually edit the `[stats]` section within `data/publications.toml` to update your citation count and h-index if desired.

2.  **Edit CV Content:**
    *   Modify `.toml` files in `data/` or `.typ` files in `formatters/` as needed.
    *   Edit `rileycv.typ` for global changes or section structure.

3.  **Commit Changes:**
    *   Stage your changes using `git add <file>...`.
    *   Run `git commit -m "Your commit message"`.
    *   The pre-commit hook will automatically run `scripts/compile_and_stage.sh`.
    *   This script compiles `rileycv.typ` to `rileycv.pdf`.
    *   If compilation succeeds, it automatically stages `rileycv.pdf`.
    *   The commit will then proceed, including both your source changes and the updated PDF.
    *   If compilation fails, the commit will be aborted, and you will see the Typst error message. Fix the error and try committing again.

## Customization

*   **Content:**
    *   Edit the `.toml` files in the `data/` directory for most sections.
    *   For Publications/Datasets, manage the entries in your Zotero collection and re-run `./scripts/generate_pubs_toml.py`. Remember to manually update the `[stats]` in `data/publications.toml`.
*   **Appearance/Layout:**
    *   Modify the corresponding `.typ` files in the `formatters/` directory.
    *   Edit `rileycv.typ` to change global settings (margins, fonts, main structure, section order).
*   **Pre-commit Hook:** Modify `scripts/compile_and_stage.sh` or `.pre-commit-config.yaml` to change compilation behavior.

## License
MIT or Apache both work big dawg have fun