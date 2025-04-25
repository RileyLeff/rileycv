// formatters/education.typ
// Defines how to format a single education entry.

#let format(entry) = {
  // Use a code block {} as the body argument for the outer 'block'
  block(below: 0.8em, { // <--- Use {} instead of []

    // All the code below is now inside an executable code block

    // Top line: Degree and Years (aligned)
    grid(
      columns: (1fr, auto),
      [*#entry.degree*], // #variable inside [* *] is fine within {}
      [#text(weight: "medium")[#entry.years]] // #text() inside [] is fine within {}
    )
    // Second line: Institution and Location
    text(size: 11pt)[ // #variable inside [] is fine within {}
      #entry.institution, #entry.location
    ]

    // Optional Details (if they exist in the data)
    if "details" in entry and entry.details.len() > 0 {
      // Indent details slightly
      // Inner pad already uses a code block {}, which is correct
      pad(left: 1.5em, {
        // Loop inside the code block
        for detail in entry.details {
          // Generate text for each detail
          text(size: 10pt, "• " + detail)
          // Ensure each bullet is on a new line
          parbreak()
        }
      }) // End code block for pad
    } // End if statement

  }) // <--- End code block for the outer 'block'
}