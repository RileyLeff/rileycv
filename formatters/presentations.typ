// formatters/presentations.typ
// Formats the presentations section with Talks and Posters subheadings.

// Helper function to format a single presentation entry
#let format_presentation_entry(entry) = {
  block(below: 0.8em, {
    // Presentation Title
    text(weight: "bold")[#entry.title]
    parbreak() // Ensure event/date is on a new line

    // Event and Date
    text(size: 10pt)[
      #entry.event, #entry.date
    ]

    // Optional Link
    let link_url = entry.at("link", default: none)
    let has_link = link_url != none and link_url != "" and link_url != "abstract-link-placeholder" // Check for non-empty, non-placeholder link
    if has_link { // <-- if WITHOUT # here (code block)
      h(1em) // Add horizontal space before the link
      link(link_url, emph("[Link]"))
    }
     // Add placeholder text if link is missing but expected
     else if link_url == "abstract-link-placeholder" {
        h(1em)
        text(size: 9pt, fill: gray)[(Link needed)]
     }
  })
}

// Main format function for the whole presentations section data
#let format(data) = {
  v(0.5em) // Add some space below the main section heading

  // --- Talks Section ---
  if "talks" in data and data.talks.len() > 0 {
    // Subheading for Talks
    text(weight: "bold", size: 12pt)[Talks]
    v(0.4em) // Space below subheading

    // Indent the list of talks
    pad(left: 1.5em, {
      for entry in data.talks {
        format_presentation_entry(entry)
      }
    })
    // Add space before posters if both exist
    if "posters" in data and data.posters.len() > 0 {
       v(0.8em)
    }
  }

  // --- Posters Section ---
  if "posters" in data and data.posters.len() > 0 {
     // Subheading for Posters
    text(weight: "bold", size: 12pt)[Posters]
    v(0.4em) // Space below subheading

    // Indent the list of posters
    pad(left: 1.5em, {
      for entry in data.posters {
        format_presentation_entry(entry)
      }
    })
  }

} // End main format function