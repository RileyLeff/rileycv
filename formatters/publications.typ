// formatters/publications.typ
// Formats the entire publications and datasets section.

// Helper function to format a single paper or dataset entry
#let format_publication_entry(entry, entry_type: "paper") = {
  // Block for spacing below each entry
  block(below: 1.0em, {

    // 1. Title (e.g., medium weight)
    text(weight: "medium")[#entry.title]
    parbreak()

    // 2. Authors (smaller font)
    text(size: 10pt)[#entry.authors]
    parbreak()

    // 3. Journal/Venue (italicized) and Year
    // Use .at() for safety in case journal/venue key is missing
    let venue_text = if entry_type == "paper" {
      #emph(entry.at("journal", default: "[Unknown Journal]"))
    } else { // "dataset"
      i(entry.at("venue", default: "[Unknown Venue]"))
    }
    text(size: 10pt)[#venue_text, #entry.year]

    // 4. Links (DOI and/or general link)
    let doi = entry.at("doi", default: none)
    let link_url = entry.at("link", default: none)
    let has_doi = doi != none and doi != "" // Check for non-empty string too
    let has_link = link_url != none and link_url != ""

    // Only add link section if at least one link exists
    if has_doi or has_link {
      // Add space before the links
      h(1em)

      if has_doi {
        // Create DOI link
        link("https://doi.org/" + doi, emph("[DOI]")) // Emphasize link text
        // Add space between DOI and Link if both exist
        if has_link { h(0.5em) }
      }
      if has_link {
        // Avoid duplicate link if 'link' is just the DOI URL
        let is_doi_link = has_doi and link_url == "https://doi.org/" + doi
        if not is_doi_link {
          link(link_url, emph("[Link]")) // Emphasize link text
        }
      }
    } // end if has_doi or has_link

    // Contribution note removed as requested earlier
    // If you wanted to add it back, you would put it here, potentially after a parbreak()

  }) // End block
}


// Main format function for the whole publications section data
#let format(data) = {

  // --- Stats Section ---
  if "stats" in data {
    let s = data.stats
    let scholar_link_url = s.at("scholar_link", default: none)
    let citation_count = s.at("citations", default: 0)
    let h_index_val = s.at("h_index", default: 0)

    // Only display stats if there's something meaningful
    if citation_count > 0 or h_index_val > 0 or scholar_link_url != none {
      grid(
        columns: (auto, 1fr), // Labels left, values/link right (aligned right within cell)
        //align: baseline,
        row-gutter: 0.2em, // Small space between stat lines if wrapped

        // Citations
        if citation_count > 0 { align(right)[Citations:] },
        if citation_count > 0 { [#citation_count] },

        // H-Index
        if h_index_val > 0 { align(right)[h-index:] },
        if h_index_val > 0 { [#h_index_val] },

        // Scholar Link
        if scholar_link_url != none { align(right)[Profile:] },
        if scholar_link_url != none { link(scholar_link_url)[Google Scholar] },
      )
      v(1.2em) // Add space after the stats block
    }
  }


  // --- Papers Section ---
  if "papers" in data and data.papers.len() > 0 {
    // Use a level 2 heading for visual hierarchy within the section
    heading(level: 2)[Peer-Reviewed Publications]
    v(0.5em) // Space below heading

    // Loop through papers and apply the helper function
    for entry in data.papers {
      format_publication_entry(entry, entry_type: "paper")
    }
    // Space after the last paper, before the next heading (if datasets exist)
    if "datasets" in data and data.datasets.len() > 0 {
        v(0.8em)
    }
  }


  // --- Datasets Section ---
  if "datasets" in data and data.datasets.len() > 0 {
    // Use a level 2 heading
    heading(level: 2)[Published Datasets]
    v(0.5em) // Space below heading

    // Loop through datasets and apply the helper function
    for entry in data.datasets {
      format_publication_entry(entry, entry_type: "dataset")
    }
    // No extra space needed at the very end
  }

} // End main format function