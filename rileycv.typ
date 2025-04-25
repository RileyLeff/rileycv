#set document(author: ("Riley Leff"), title: "Riley Leff CV")

#set page(
  paper: "us-letter",
  margin: (x: 1.5cm, top: 1.5cm, bottom: 1.5cm),
)
#set text(
  font: "New Computer Modern",
  size: 12pt,
  lang: "en"
)

#set par(
  leading: 0.65em,
  spacing: 0.5em
)

#set heading(numbering: none)
#show heading: it => block(above: 1em, below: 0.5em)[
  #set text(weight: "bold", size: 14pt)
  #it.body
]

// --- CV Section Definitions ---
#let cv_sections = (
  (
    title: "Education & Research Roles",
    data_file: "data/education.toml",
    data_format: "toml",
    data_key: "entry",
    formatter_file: "formatters/education.typ",
    is_list: true
  ),
  ( // Computing Skills / Profile - UPDATED ENTRY
    title: "Software Development", // More descriptive title
    data_file: "data/computing.toml",
    data_format: "toml",
    data_key: none, // Process whole file
    formatter_file: "formatters/computing.typ", // Point to the new formatter
    is_list: false // Not a list of items
  ),
  ( // Awards Section - NEW ENTRY
    title: "Awards",
    data_file: "data/awards.toml",
    data_format: "toml",
    data_key: "entry",
    formatter_file: "formatters/awards.typ",
    is_list: true
  ),
  ( // Publications & Datasets - Make sure this is correct
    title: "Publications & Datasets", // Main heading for the section
    data_file: "data/publications.toml", // Points to the generated TOML
    data_format: "toml",
    data_key: none, // Formatter handles the whole object
    formatter_file: "formatters/publications.typ", // Points to the new formatter
    is_list: false // Process the whole file data at once
  ),
  ( // Presentations Section - NEW ENTRY
    title: "Presentations",
    data_file: "data/presentations.toml",
    data_format: "toml",
    data_key: none, // Formatter handles the whole object (talks and posters)
    formatter_file: "formatters/presentations.typ",
    is_list: false // Process the whole file data at once
  ),
)

// --- Data Loading Helper ---
#let data_loaders = (
  toml: toml,
  json: json,
  yaml: yaml,
  csv: (path) => csv(path, header: true)
)


#grid(
  columns: (1fr, auto),
  column-gutter: 1em,
  align: (bottom, bottom),
  [
    #block[ 
      #grid(
        columns: (auto, auto),
        column-gutter: 1.0em,
        align: bottom, 
        [
          #set text(weight: "bold", size: 24pt)
          Riley Leff
        ],
        [
          #set text(weight: "regular", size: 12pt)
          PhD Candidate, Biological Sciences
        ]
      )
      

      #v(1em)

      #set text(weight: "regular", size: 11pt)
      #grid(
        columns: (auto, auto, auto),
        column-gutter: 0.8em,
        align: bottom,
        [Washington, DC],
        [#link("https://scholar.google.com/citations?user=h02IDTwAAAAJ&hl=en&oi=ao")[Google Scholar]],
        [rileyleff\@gmail.com],
      )
    ]
  ],
  [
    #set align(right)
    #image("assets/rileypic.png", width: 35%)
  ]
)

#v(1em)
#line(length: 100%, stroke: 0.5pt)
// --- Dynamic Section Rendering ---

// --- Dynamic Section Rendering ---

#for section_meta in cv_sections {

  // ... (Steps 1-4: loading, getting formatter, heading) ...
  // --- 1. Load Data ---
  let loader = data_loaders.at(section_meta.data_format, default: none)
  if loader == none {
    panic("Unsupported data format specified: " + section_meta.data_format + " for section '" + section_meta.title + "'.")
  }
  let raw_data = loader(section_meta.data_file)

  // --- Define section_data ---
  let section_data = if section_meta.data_key != none {
    raw_data.at(section_meta.data_key, default: none)
  } else {
    raw_data
  }

  // --- Basic validation ---
  if section_data == none {
     panic("Data key '" + str(section_meta.data_key) + "' not found or invalid in " + section_meta.data_file + " for section '" + section_meta.title + "'.")
  }

  // --- Determine if list ---
  let process_as_list = section_meta.at("is_list", default: false)

  // --- Skip empty ---
  if process_as_list and type(section_data) == array and section_data.len() == 0 { continue }
  if not process_as_list and type(section_data) == dictionary and section_data.len() == 0 { continue }

  // --- 2. Import Formatter ---
  import section_meta.formatter_file as formatter_module

  // --- 3. Get Formatter Function ---
  let formatter_func = formatter_module.format
  if formatter_func == none { panic("Function 'format' not found...") }
  if type(formatter_func) != function { panic("'format' is not a function...") }

  // --- 4. Render Heading ---
  heading(section_meta.title)

  // --- 5. Apply Formatter (Conditional Logic) ---
  if process_as_list {
      if type(section_data) != array {
         panic("Section '" + section_meta.title + "' is configured with is_list: true, but the loaded data is not an array.")
      }
      // Loop through the data array
      for item in section_data {
    

        formatter_func(item) // Call formatter for each list item
      }
  } else {
      formatter_func(section_data)
  }

} // End of the main loop