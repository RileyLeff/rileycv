// formatters/mentorship.typ
// Defines how to format a single mentorship entry.

#let format(entry) = {
  block(below: 1.0em, { // Space after each mentee block

    // --- Name and Dates ---
    grid(
      columns: (1fr, auto), // Name stretches, dates take needed space
      column-gutter: 1em,
      align: top,
      // Column 1: Student Name (Bold)
      {
        text(weight: "bold")[#entry.student_name]
      },
      // Column 2: Dates
      {
        let start = entry.at("start_year", default: "")
        let end = entry.at("end_year", default: "")
        let date_str = if end == "" or end == start {
           start
        } else {
           start + " – " + end
        }
        text(weight: "regular")[#date_str]
      }
    )

    // --- Level, Affiliation, Funding ---
    // Combine these into one line below the name
    let level = entry.at("level", default: "")
    let affiliation = entry.at("affiliation", default: "")
    let funding = entry.at("funding_award", default: "")
    let has_funding = funding != ""

    text(size: 10pt)[
      #level, #affiliation #if has_funding { " (" + funding + ")" }
    ]

    // --- Project Description and Outcome ---
    // Indent these details
    let project = entry.at("project_description", default: "")
    let outcome = entry.at("outcome", default: "")
    let has_project = project != ""
    let has_outcome = outcome != ""

    if has_project or has_outcome {
      v(0.3em) // Add space before indented block
      pad(left: 1.5em, {
        if has_project {
          text(size: 10pt)[• Project: #project]
          if has_outcome { parbreak() } // Newline if outcome also exists
        }
        if has_outcome {
          text(size: 10pt)[• Outcome: #outcome]
        }
      }) // End pad
    } // End if has_project or has_outcome

  }) // End block
}