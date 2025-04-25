// formatters/publications.typ
// Formats the publications and datasets section.

// Helper function 'format_publication_entry' remains the same as the previous correct version
#let format_publication_entry(entry, entry_type: "paper", item_number: none) = {
  block(below: 1.0em, {
    text(weight: "bold")[
      #if item_number != none {
        str(item_number) + ". " + entry.title
      } else {
        entry.title
      }
    ]
    parbreak()
    text(size: 10pt)[#entry.authors]
    parbreak()
    let venue_text = if entry_type == "paper" {
      emph(entry.at("journal", default: "[Unknown Journal]"))
    } else {
      emph(entry.at("venue", default: "[Unknown Venue]"))
    }
    text(size: 10pt)[#venue_text, #entry.year]
    let doi = entry.at("doi", default: none)
    let link_url = entry.at("link", default: none)
    let has_doi = doi != none and doi != ""
    let has_link = link_url != none and link_url != ""
    if has_doi or has_link {
      h(1em)
      if has_doi {
        link("https://doi.org/" + doi, emph("[DOI]"))
        if has_link { h(0.5em) }
      }
      if has_link {
        let is_doi_link = has_doi and link_url == "https://doi.org/" + doi
        if not is_doi_link {
          link(link_url, emph("[Link]"))
        }
      }
    }
  })
}


// Main format function for the whole publications section data
#let format(data) = {

  // --- Stats Section ---
  if "stats" in data {
    let s = data.stats
    let scholar_link_url = s.at("scholar_link", default: none)
    let citation_count = s.at("citations", default: 0)
    let h_index_val = s.at("h_index", default: 0)

    // Only proceed if there's something meaningful
    if citation_count > 0 or h_index_val > 0 or scholar_link_url != none {

      // ** Build the list of grid cells conditionally **
      let stat_cells = () // Start with an empty array

      // Add citation row if count > 0
      if citation_count > 0 {
        stat_cells.push(align(right)[Citations:]) // Cell 1: Label
        stat_cells.push([#citation_count])       // Cell 2: Value
      }

      // Add h-index row if value > 0
      if h_index_val > 0 {
        stat_cells.push(align(right)[h-index:]) // Cell 3: Label
        stat_cells.push([#h_index_val])        // Cell 4: Value
      }

      // Add profile link row if URL exists
      if scholar_link_url != none {
        stat_cells.push(align(right)[Profile:])       // Cell 5: Label
        stat_cells.push(link(scholar_link_url)[Google Scholar]) // Cell 6: Link
      }

      // ** Call grid with the constructed cells using spread operator '..' **
      grid(
        columns: (auto, 1fr), // Labels left, values/link right
        align: left,
        row-gutter: 0.2em,
        ..stat_cells // Spread the contents of the 'stat_cells' array here
      )
      v(1.2em) // Add space after the stats block
    } // end if stats are meaningful
  } // end if "stats" in data


  // --- Papers Section --- (remains the same)
  if "papers" in data and data.papers.len() > 0 {
    heading(level: 2)[Peer-Reviewed Publications]
    v(0.5em)
    let paper_counter = 1
    for entry in data.papers {
      format_publication_entry(entry, entry_type: "paper", item_number: paper_counter)
      paper_counter += 1
    }
    if "datasets" in data and data.datasets.len() > 0 { v(0.8em) }
  }

  // --- Datasets Section --- (remains the same)
  if "datasets" in data and data.datasets.len() > 0 {
    heading(level: 2)[Published Datasets]
    v(0.5em)
    for entry in data.datasets {
      format_publication_entry(entry, entry_type: "dataset") // No item_number
    }
  }

} // End main format function