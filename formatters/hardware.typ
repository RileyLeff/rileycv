// formatters/hardware.typ
// Formats a single hardware entry as a bulleted line, matching the software section style.

#let format(item) = {
  let entry_text = item.at("text", default: "")
  let entry_link = item.at("link", default: none)
  let core_content = if entry_link != none and entry_link != "" {
    link(entry_link)[#entry_text]
  } else {
    entry_text
  }

  pad(left: 1.0em, block(below: 0.4em, {
    list(
      marker: sym.bullet,
      tight: true,
      text(size: 10pt, core_content)
    )
  }))
}
