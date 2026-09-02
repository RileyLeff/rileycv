// formatters/awards.typ
// Style: Name (11pt, regular), Org (smaller, italic), Date (right-aligned)
// An entry may carry `links = [{ text, url }, ...]`; each `text` is a substring
// of `name` that gets rendered as a hyperlink, in order.

#let linked_name(name, links) = {
  let parts = ()
  let rest = name
  for l in links {
    let pos = rest.position(l.text)
    if pos == none { continue }
    if pos > 0 { parts.push(rest.slice(0, pos)) }
    parts.push(link(l.url, l.text))
    rest = rest.slice(pos + l.text.len())
  }
  if rest != "" { parts.push(rest) }
  parts.join()
}

#let format(entry) = {
  grid(
    columns: (1fr, auto),
    align: (left, right),

    // --- Column 1: Award Name and Organization ---
    {
      let links = entry.at("links", default: ())
      let name_content = if links.len() > 0 { linked_name(entry.name, links) } else { entry.name }
      let name_part = text(size: 11pt, weight: "regular", name_content)

      let org_part = {
        let org = entry.at("organization", default: "")
        if org != "" {
          h(0.4em) + text(size: 9pt, emph(org))
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
