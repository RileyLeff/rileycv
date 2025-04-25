// formatters/publications.typ
// Formats the publications and datasets section.

// Helper function 'format_publication_entry' remains unchanged
#let format_publication_entry(entry, entry_type: "paper", item_number: none) = {
  block(below: 1.0em, {
    text(weight: "bold")[
      #if item_number != none { // <-- #if IS needed here (inside content block [])
        str(item_number) + ". " + entry.title
      } else {
        entry.title
      }
    ]
    parbreak()
    text(size: 10pt)[#entry.authors] // <-- #authors IS needed here
    parbreak()
    let venue_text = if entry_type == "paper" { // <-- if WITHOUT # here (code block)
      emph(entry.at("journal", default: "[Unknown Journal]"))
    } else {
      emph(entry.at("venue", default: "[Unknown Venue]"))
    }
    text(size: 10pt)[#venue_text, #entry.year] // <-- #venue_text IS needed here
    let doi = entry.at("doi", default: none)
    let link_url = entry.at("link", default: none)
    let has_doi = doi != none and doi != ""
    let has_link = link_url != none and link_url != ""
    if has_doi or has_link { // <-- if WITHOUT # here (code block)
      h(1em)
      if has_doi { // <-- if WITHOUT # here (code block)
        link("https://doi.org/" + doi, emph("[DOI]"))
        if has_link { h(0.5em) } // <-- if WITHOUT # here (code block)
      }
      if has_link { // <-- if WITHOUT # here (code block)
        let is_doi_link = has_doi and link_url == "https://doi.org/" + doi
        if not is_doi_link { // <-- if WITHOUT # here (code block)
          link(link_url, emph("[Link]"))
        }
      }
    }
  })
}


// Main format function for the whole publications section data
#let format(data) = { // Start of main code block
  v(0.5em)
  // --- Stats Section (Inline Layout using #if) ---
  if "stats" in data { // <-- if WITHOUT # here (code block)
    let s = data.stats
    let scholar_link_url = s.at("scholar_link", default: none)
    let citation_count = s.at("citations", default: 0)
    let h_index_val = s.at("h_index", default: 0)

    if citation_count > 0 or h_index_val > 0 or scholar_link_url != none { // <-- if WITHOUT # here

      // Conditionally generate each piece of content
      // Use regular 'if' because we are in a code block
      if citation_count > 0 { // <-- NO # needed
        [
          *Citations: #citation_count #h(1.5em)*] // <-- # needed inside []
      }
      if h_index_val > 0 { // <-- NO # needed
        [ *h-index: #h_index_val #h(1.5em)* ] // <-- # needed inside []
      }
      if scholar_link_url != none { // <-- NO # needed
        link(scholar_link_url)[*Link to Google Scholar*]
      }

      // Add vertical space after the stats line(s)
      v(0.8em)
    }
  } // end if "stats" in data


  // --- Papers Section ---
  if "papers" in data and data.papers.len() > 0 { // <-- if WITHOUT # here
    // Use text() matching title style, changed text
    text(weight: "bold")[Journal Articles]
    v(0.5em)

    let paper_counter = 1
    // Use regular 'for' because we are in a code block
    for entry in data.papers { // <-- NO # needed
      format_publication_entry(entry, entry_type: "paper", item_number: paper_counter)
      paper_counter += 1
    }
    if "datasets" in data and data.datasets.len() > 0 { v(0.8em) } // <-- if WITHOUT # here
  }


  // --- Datasets Section ---
  if "datasets" in data and data.datasets.len() > 0 { // <-- if WITHOUT # here
    // Use text() matching title style
    text(weight: "bold")[Published Datasets]
    v(0.5em)

    // Use regular 'for' because we are in a code block
    for entry in data.datasets { // <-- NO # needed
      format_publication_entry(entry, entry_type: "dataset")
    }
  }

} // End main format function