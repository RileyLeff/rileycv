// formatters/leadership.typ
// "Leadership, Service & Mentorship", in three subsections: Leadership,
// Service & Outreach, and Mentorship. Receives
// (leadership: <leadership.toml>, outreach: <outreach.toml>,
//  mentorship: <mentorship.toml>).

#import "mentorship.typ": format as format_mentee
#import "outreach.typ": format as format_outreach

#let subsection(title, entries, format_entry) = {
  if entries.len() == 0 { return }
  v(0.5em)
  text(weight: "bold", size: 12pt)[#title]
  v(0.4em)
  pad(left: 1.5em, { for entry in entries { format_entry(entry) } })
}

#let format_role(entry) = {
  block(below: 1.0em, {
    grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      align: top,
      text(weight: "bold")[#entry.role],
      text(weight: "regular")[#entry.dates],
    )

    let org = entry.organization
    let url = entry.at("link", default: "")
    text(size: 10pt)[#if url != "" { link(url, org) } else { org }]

    let details = entry.at("details", default: "")
    if details != "" {
      v(0.3em)
      pad(left: 1.5em, text(size: 10pt)[#details])
    }
  })
}

#let format(data) = {
  subsection("Leadership", data.leadership.at("entry", default: ()), format_role)
  subsection("Service & Outreach", data.outreach.at("entry", default: ()), format_outreach)
  subsection("Mentorship", data.mentorship.at("entry", default: ()), format_mentee)
}
