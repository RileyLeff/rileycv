// formatters/outreach.typ
// Defines how to format a single outreach entry.

#let format(entry) = {
  block(below: 1.0em, { // Add space below each entry block

    // --- Title and Date ---
    grid(
      columns: (1fr, auto), // Title stretches, date takes needed space
      column-gutter: 1em,
      align: top,
      // Column 1: Title
      {
        text(weight: "bold")[#entry.title]
      },
      // Column 2: Date
      {
        text(weight: "regular")[#entry.date]
      }
    )

    // --- Event/Description ---
    // Placed below the title/date grid
    text(size: 10pt)[#entry.event_or_description]

    // --- Optional Details/Link ---
    let details_text = entry.at("details", default: "")
    let link_url = entry.at("link", default: none)
    let has_details = details_text != ""
    let has_link = link_url != none and link_url != ""

    // Check if there are details OR a link to display
    if has_details or has_link {
      // Add a small vertical space before details/link
      v(0.3em)
      // Indent the details/link section
      pad(left: 1.5em, {
        if has_details {
          text(size: 10pt)[#details_text]
          // Add a line break if there's also a link
          if has_link { parbreak() }
        }
        if has_link {
           link(link_url, emph("[Link]"))
        }
      }) // End pad
    } // End if has_details or has_link

  }) // End block
}