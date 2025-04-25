// formatters/computing.typ
// Formats the computing skills section with structured language categories.

// Helper function to format a single language entry (name, description, examples)
#let format_language_entry(lang_entry) = {
  block(below: 0.8em, { // Space after each language block
    // Language Name
    text(weight: "bold", size: 11pt)[#lang_entry.name]

    // Description (if present), indented slightly
    if "description" in lang_entry {
      pad(left: 1.5em)[#text(size: 10pt)[#lang_entry.description]]
      v(0.2em) // Space between description and examples
    }

    // Examples list (if present), indented further
    if "examples" in lang_entry and lang_entry.examples.len() > 0 {
      // Use pad() for indentation, NOT .inset()
      pad(left: 2.5em, { // Adjust indent as needed
        // Generate the list inside the pad's content block
        list(
          marker: sym.bullet,
          tight: true, // Adjust list item spacing if needed
          // Map each example dictionary to formatted content
          ..lang_entry.examples.map(ex => {
            let example_text = ex.at("text", default: "")
            let example_link = ex.at("link", default: none)

            // CORRECTED: Check for valid, non-placeholder links (wrapped in parentheses)
            let is_valid_link = (
                example_link != none and
                example_link != "optional-link-to-repo-or-blog-post" and
                example_link != "optional-link-to-game-or-repo"
            )

            // If a valid link exists, make the text the link
            if is_valid_link {
              link(example_link)[#example_text]
            } else {
              // Otherwise, just display the text
              example_text
            }
          }) // End map()
        ) // End list()
      }) // End pad()
    } // End if examples exist
  }) // End block() for the language entry
}


// Main format function for the whole computing section data
#let format(data) = {

  // --- Favorite Languages Section ---
  if "favorite_languages" in data and data.favorite_languages.len() > 0 {
    // Optional Subheading
    // text(weight: "bold", size: 12pt)[Core Languages]
    // v(0.5em)

    // Loop through favorite languages and apply the helper function
    for lang_entry in data.favorite_languages {
      format_language_entry(lang_entry)
    }
    v(0.5em) // Space before the next section
  }

  // --- Other Languages Section ---
  if "other_languages" in data and data.other_languages.len() > 0 {
    // Subheading for this group
    text(weight: "bold", size: 12pt)[Other Languages]
    v(0.5em)

    // Loop through other languages and apply the helper function
    for lang_entry in data.other_languages {
      format_language_entry(lang_entry)
    }
    v(0.5em) // Space before the next section
  }

  // --- Familiar With Section ---
  if "familiar_with_list" in data and data.familiar_with_list.len() > 0 {
    let title = data.at("familiar_with_title", default: "Familiar With")
    text(weight: "bold", size: 11pt)[#title] // Style like language names
    v(0.2em)

    // Display as a simple comma-separated string
    text(size: 10pt)[#data.familiar_with_list.join(", ")]
  }

} // End main format function