// formatters/computing.typ
// Formats the computing skills section with structured language categories.

// Helper function to format a single language entry (name, description, examples)
// This remains the same as before.
#let format_language_entry(lang_entry) = {
  block(below: 0.8em, { // Space after each language block
    // Language Name (Sub-heading within the category)
    text(weight: "bold", size: 11pt)[#lang_entry.name]

    // Description (if present), indented slightly
    if "description" in lang_entry {
      pad(left: 1.5em)[#text(size: 10pt)[#lang_entry.description]]
      v(0.2em) // Space between description and examples
    }

    // Examples list (if present), indented further
    if "examples" in lang_entry and lang_entry.examples.len() > 0 {
      pad(left: 2.5em, { // Indent the list
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
      }) // End pad()
    } // End if examples exist
  }) // End block() for the language entry
}


// Main format function for the whole computing section data
#let format(data) = {

  // --- Favorite Languages Section ---
  if "favorite_languages" in data and data.favorite_languages.len() > 0 {
    // Top-level heading for this category
    text(weight: "bold", size: 12pt)[Favorite Languages] // Use consistent heading style
    v(0.5em) // Space below heading

    // Loop through favorite languages and apply the helper function
    for lang_entry in data.favorite_languages {
      format_language_entry(lang_entry)
    }
    // Removed extra v() here, spacing is handled by the block in the helper
  }

  // --- Other Languages Section ---
  if "other_languages" in data and data.other_languages.len() > 0 {
    // Top-level heading for this category
    text(weight: "bold", size: 12pt)[Other Languages] // Use consistent heading style
    v(0.5em) // Space below heading

    // Loop through other languages and apply the helper function
    for lang_entry in data.other_languages {
      format_language_entry(lang_entry)
    }
    // Removed extra v() here
  }

  // --- Familiar With Section ---
  if "familiar_with_list" in data and data.familiar_with_list.len() > 0 {
    let title = data.at("familiar_with_title", default: "Familiar With")
    // Top-level heading for this category
    text(weight: "bold", size: 12pt)[#title] // Use consistent heading style (size 12pt)
    v(0.5em) // Consistent space below heading

    // Display the list as a simple comma-separated string
    // Indent this list slightly for visual grouping under the heading
    pad(left: 1.5em)[#text(size: 10pt)[#data.familiar_with_list.join(", ")]]
  }

} // End main format function