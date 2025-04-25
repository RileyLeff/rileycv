// formatters/teaching.typ
// Defines how to format a single teaching entry.

#let format(entry) = {
  // Use a grid for alignment: Left column for info, Right column for date.
  grid(
    columns: (1fr, auto), // Content stretches, date takes needed space
    column-gutter: 1em,   // Space between content and date
    align: top,           // Align items to the top within their grid cells

    // --- Column 1: Role, Course, Institution ---
    { // Use a block for multi-line content in the first column
      // Line 1: Role (bold) and Course (if applicable)
      text(weight: "bold")[#entry.role]
      // Conditionally add the course name if it's not empty
      if "course" in entry and entry.course != "" {
        ": " + entry.course // Add colon separator and course name
      }

      parbreak() // Move to the next line

      // Line 2: Institution (italic, smaller font)
      text(size: 10pt, style: "italic")[#entry.institution]
    },

    // --- Column 2: Date ---
    [ // Content block for the date column
      #text(weight: "regular")[#entry.date]
    ]
  )

  // Add some vertical space after each entry
  v(0.8em)
}