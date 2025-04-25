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
    formatter_file: "formatters/education.typ"
  ),
  ( // Computing Skills / Profile - UPDATED ENTRY
    title: "Computational Profile & Projects", // More descriptive title
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
    formatter_file: "formatters/awards.typ"
  )
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
  align: bottom,
  [
    #block[ 
      #grid(
        columns: (auto, auto),
        column-gutter: 1.0em,
        align: center, 
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

#for section_meta in cv_sections {

  // --- 1. Load Data ---
  let loader = data_loaders.at(section_meta.data_format, default: none)
  if loader == none {
    panic("Unsupported data format specified: " + section_meta.data_format + " for section '" + section_meta.title + "'.")
  }
  let raw_data = loader(section_meta.data_file) // Panics if file not found/invalid

  // --- Define section_data HERE, BEFORE the if/else ---
  let section_data = if section_meta.data_key != none {
    raw_data.at(section_meta.data_key, default: none)
  } else {
    raw_data // Use the whole loaded object if no key specified
  }

  // --- Basic validation of the retrieved data ---
  if section_data == none {
     // Use the original data_key value here in the message
     panic("Data key '" + str(section_meta.data_key) + "' not found or invalid in " + section_meta.data_file + " for section '" + section_meta.title + "'.")
     // Note: Using str() here IS correct because section_meta.data_key could be 'none' or a string.
  }

  // --- Determine if we should process as a list ---
  let process_as_list = section_meta.at("is_list", default: false)

  // --- Skip rendering if data is empty (handle list or object case) ---
  if process_as_list and type(section_data) == array and section_data.len() == 0 {
    continue
  }
  if not process_as_list and type(section_data) == dictionary and section_data.len() == 0 {
      continue
  }


  // --- 2. Import Formatter Module --- (Using original numbering for consistency)
  import section_meta.formatter_file as formatter_module // Panics if file not found/invalid

  // --- 3. Get Formatter Function (by Convention) ---
  let formatter_func = formatter_module.format
  if formatter_func == none {
     panic("Function 'format' not found in " + section_meta.formatter_file + ".")
  }
  if type(formatter_func) != function {
     panic("'format' exported by " + section_meta.formatter_file + " is not a function.")
  }

  // --- 4. Render Heading ---
  heading(section_meta.title)

  // --- 5. Apply Formatter (Conditional Logic) ---
  // Now 'section_data' is definitely defined before this block
  if process_as_list {
      // EXPECTING A LIST
      if type(section_data) != array {
         panic("Section '" + section_meta.title + "' is configured with is_list: true, but the loaded data is not an array. Check data_file structure.")
      }
      for item in section_data {
        formatter_func(item)
      }
  } else {
      // EXPECTING A SINGLE OBJECT
      formatter_func(section_data) // Use section_data here
  }

} // End of the main loop