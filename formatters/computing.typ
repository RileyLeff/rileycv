// formatters/computing.typ
// Formats the computing skills section with structured language categories and indentation.

// Helper function to format a single language entry (name, description, examples)
#let format_language_entry(lang_entry) = {
  // Increase spacing below the entire block if needed (e.g., to 1.0em)
  block(below: 1.0em, { // Increased from 0.8em to 1.0em
    // Language Name (Sub-heading within the category)
    text(weight: "bold", size: 11pt)[#lang_entry.name]
    parbreak() // Ensure description is on a new line

    // Description (if present)
    if "description" in lang_entry {
      text(size: 10pt)[#lang_entry.description]
    }

    // Examples list (if present)
    if "examples" in lang_entry and lang_entry.examples.len() > 0 {
      // Ensure spacing between description (or name) and list
      v(0.3em)

      // Indent relative to the name/description baseline
      pad(left: 1.0em, {
        list(
          marker: sym.bullet,
          tight: true,
          // Map each example dictionary to formatted content WITH SIZE SET
          ..lang_entry.examples.map(ex => {
            let example_text = ex.at("text", default: "")
            let example_link = ex.at("link", default: none)
            let is_valid_link = (
                example_link != none and
                example_link != "optional-link-to-repo-or-blog-post" and
                example_link != "optional-link-to-game-or-repo"
            )

            // Create the core content (link or text)
            let core_content = if is_valid_link {
              link(example_link)[#example_text]
            } else {
              example_text
            }

            // ***** APPLY TEXT SIZE HERE *****
            text(size: 10pt, core_content) // Set example text size to 10pt

          }) // End map()
        ) // End list()
      }) // End pad() for examples list
    } // End if examples exist
  }) // End block() for the language entry
}


// Main format function for the whole computing section data
#let format(data) = {

  // --- Favorite Languages Section ---
  if "primary_languages" in data and data.primary_languages.len() > 0 {
    text(weight: "bold", size: 12pt)[Primary Languages]
    v(0.5em) // Space below heading
    for lang_entry in data.primary_languages {
      pad(left: 1.5em, { format_language_entry(lang_entry) })
    }
    // Removed extra v() here - rely on block(below:...)
  }

  // --- Other Languages Section ---
  if "other_languages" in data and data.other_languages.len() > 0 {
    text(weight: "bold", size: 12pt)[Other Languages]
    v(0.5em) // Space below heading
    for lang_entry in data.other_languages {
      pad(left: 1.5em, { format_language_entry(lang_entry) })
    }
    // Removed extra v() here - rely on block(below:...)
  }

  // --- Familiar With Section ---
  if "familiar_with_list" in data and data.familiar_with_list.len() > 0 {
    let title = data.at("familiar_with_title", default: "Familiar With")
    text(weight: "bold", size: 12pt)[#title] // Consistent heading style
    v(0.5em) // Consistent space below heading
    pad(left: 1.5em)[#text(size: 10pt)[#data.familiar_with_list.join(", ")]]
    // Add final spacing if needed after this last section
    v(0.5em)
  }

} // End main format function