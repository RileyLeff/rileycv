// formatters/leadership.typ
// "Leadership, Service & Mentorship": leadership roles first, then the
// mentees under a "Mentorship" subheading. Receives
// (leadership: <leadership.toml>, mentorship: <mentorship.toml>).

#import "mentorship.typ": format as format_mentee

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
  for entry in data.leadership.at("entry", default: ()) {
    format_role(entry)
  }

  let mentees = data.mentorship.at("entry", default: ())
  if mentees.len() > 0 {
    v(0.5em)
    text(weight: "bold", size: 12pt)[Mentorship]
    v(0.4em)
    pad(left: 1.5em, {
      for entry in mentees {
        format_mentee(entry)
      }
    })
  }
}
