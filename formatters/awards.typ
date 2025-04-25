// formatters/awards.typ
// Style: Name (11pt, regular), Org (smaller, italic), Date (right-aligned)

#let format(entry) = {
  grid(
    columns: (1fr, auto),
    align: (left, right),

    // --- Column 1: Award Name and Organization ---
    {
      let name_part = text(size: 11pt, weight: "regular", entry.name)

      let org_part = {
        let org = entry.at("organization", default: "")
        if org != "" {
          // Add space + styled organization
          h(0.4em) + text(size: 9pt, emph(org)) // Set size to 9pt (or 10pt)
        } else {
          content()
        }
      }
      name_part + org_part
    },

    // --- Column 2: Date ---
    [
      #text(weight: "regular", entry.dates)
    ]
  )
}

