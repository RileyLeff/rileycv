// formatters/computing.typ
// Formats the computing skills section with structured language categories and indentation.

// Helper function to format a single language entry (name, description, examples)
#let format_language_entry(lang_entry) = {
  // The outer block provides spacing below the entry, BUT NO PADDING HERE
  block(below: 0.8em, {
    // Language Name (Sub-heading within the category)
    text(weight: "bold", size: 11pt)[#lang_entry.name]

    // ***** ADD EXPLICIT BREAK HERE *****
    parbreak() // Or use '\ ' for a line break, or v(0.1em) for tiny space + break

    // Description (if present) - will now start on the next line
    if "description" in lang_entry {
      // The text will naturally follow the language name's indentation level
      text(size: 10pt)[#lang_entry.description]
      // Remove the v() here, as parbreak() adds space controlled by #set par(spacing: ...)
      // v(0.2em)
    }

    // Examples list (if present) - ADJUSTED PADDING
    if "examples" in lang_entry and lang_entry.examples.len() > 0 {
      // Ensure spacing between description (or name if no desc) and list
      v(0.3em) // Add space before the list starts

      // Indent relative to the name/description baseline
      pad(left: 1.0em, {
        list(
          marker: sym.bullet,
          tight: true,
          ..lang_entry.examples.map(ex => {
            let example_text = ex.at("text", default: "")
            let example_link = ex.at("link", default: none)
            let is_valid_link = (
                example_link != none and
                example_link != "optional-link-to-repo-or-blog-post" and
                example_link != "optional-link-to-game-or-repo"
            )
            if is_valid_link { link(example_link)[#example_text] } else { example_text }
          }) // End map()
        ) // End list()
      }) // End pad() for examples list
    } // End if examples exist
  }) // End block() for the language entry
}


// Main format function for the whole computing section data
#let format(data) = {
  // ... (rest of the main format function remains the same) ...
  // --- Favorite Languages Section ---
  if "primary_languages" in data and data.primary_languages.len() > 0 {
    text(weight: "bold", size: 12pt)[Primary Languages]
    v(0.5em)
    for lang_entry in data.primary_languages {
      pad(left: 1.5em, { format_language_entry(lang_entry) })
    }
  }
  // --- Other Languages Section ---
  if "other_languages" in data and data.other_languages.len() > 0 {
    text(weight: "bold", size: 12pt)[Other Languages]
    v(0.5em)
    for lang_entry in data.other_languages {
      pad(left: 1.5em, { format_language_entry(lang_entry) })
    }
  }
  // --- Familiar With Section ---
  if "familiar_with_list" in data and data.familiar_with_list.len() > 0 {
    let title = data.at("familiar_with_title", default: "Familiar With")
    text(weight: "bold", size: 12pt)[#title]
    v(0.5em)
    pad(left: 1.5em)[#text(size: 10pt)[#data.familiar_with_list.join(", ")]]
  }
} // End main format function