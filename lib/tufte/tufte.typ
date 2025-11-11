// Lucy-Tufte Template for Typst
// A modern Tufte-inspired template supporting both PDF and HTML output
// Uses official Tufte CSS for web output
// Uses html.elem() for HTML structure (built-in, no import needed)

// Helper function to generate HTML ID from content
// Simple slug generation: lowercase, replace spaces with hyphens, remove non-alphanumeric
#let generate-id(content) = {
  let text-str = repr(content)
  // Convert to lowercase using regex (Typst doesn't have lowercase() method)
  let lower = text-str
    .replace(regex("A"), "a").replace(regex("B"), "b").replace(regex("C"), "c")
    .replace(regex("D"), "d").replace(regex("E"), "e").replace(regex("F"), "f")
    .replace(regex("G"), "g").replace(regex("H"), "h").replace(regex("I"), "i")
    .replace(regex("J"), "j").replace(regex("K"), "k").replace(regex("L"), "l")
    .replace(regex("M"), "m").replace(regex("N"), "n").replace(regex("O"), "o")
    .replace(regex("P"), "p").replace(regex("Q"), "q").replace(regex("R"), "r")
    .replace(regex("S"), "s").replace(regex("T"), "t").replace(regex("U"), "u")
    .replace(regex("V"), "v").replace(regex("W"), "w").replace(regex("X"), "x")
    .replace(regex("Y"), "y").replace(regex("Z"), "z")
  lower
    .replace(regex("\\[|\\]|\"|'"), "")  // Remove brackets and quotes
    .replace(regex(" "), "-")             // Spaces to hyphens
    .replace(regex("[^a-z0-9-]"), "")     // Remove non-alphanumeric except hyphens
}

// Configure document-level settings
#let lucy-tufte-config(output-format: "pdf") = {
  // Typography - matching Tufte style
  // Note: ET Book font registration requires Typst 0.11+ font discovery
  // For now, using system fonts that match Tufte style
  set text(
    font: ("Palatino", "Georgia", "Times New Roman"),
    size: 15pt,
    lang: "en",
    hyphenate: true,
  )
  
  set par(
    justify: true,
    leading: 0.65em,
    first-line-indent: 1.4em,
  )
  
  // Headings - Tufte style (minimal hierarchy)
  if output-format == "html" {
    // HTML: Generate proper HTML structure with IDs using html.elem()
    show heading.where(level: 1): it => {
      let id = generate-id(it.body)
      html.elem("h1", attrs: ("id": id))[#it.body]
    }
    
    show heading.where(level: 2): it => {
      let id = generate-id(it.body)
      html.elem("h2", attrs: ("id": id))[#it.body]
    }
    
    show heading.where(level: 3): it => {
      let id = generate-id(it.body)
      html.elem("h3", attrs: ("id": id))[#it.body]
    }
  } else {
    // PDF: Original styling
    show heading.where(level: 1): it => block(width: 100%)[
      #set text(size: 2.5em, weight: 400)
      #set par(first-line-indent: 0em)
      #v(3em, weak: true)
      #it.body
      #v(1.5em)
    ]
    
    show heading.where(level: 2): it => block(width: 100%)[
      #set text(size: 1.8em, weight: 400, style: "italic")
      #set par(first-line-indent: 0em)
      #v(2em, weak: true)
      #it.body
      #v(0.5em)
    ]
    
    show heading.where(level: 3): it => block(width: 100%)[
      #set text(size: 1.4em, weight: 400, style: "italic")
      #set par(first-line-indent: 0em)
      #v(1.4em, weak: true)
      #it.body
      #v(0.3em)
    ]
  }
  
  // Links - subtle, underlined
  show link: it => underline(text(fill: rgb("#111111"), it))
  
  // Code blocks - remove syntax highlighting for HTML
  if output-format == "html" {
    show raw.where(block: true): it => {
      // Remove syntax highlighting by using plain raw block
      raw.block(it.text)
    }
  }
}

// Page setup for PDF (call this before show rule)
#let lucy-tufte-page() = {
  set page(
    paper: "us-letter",
    margin: (left: 1in, right: 2.5in, top: 1in, bottom: 1in),
    numbering: "1",
    number-align: right,
  )
}

// Counter for sidenote numbering
#let sidenote-counter = counter("sidenote")
#let margin-note-id-counter = counter("margin-note-id")

// Output format state (accessible from functions)
#let output-format-state = state("output-format", "pdf")

// Create format-aware margin note functions
#let create-margin-functions(output-format) = {
  (
    sidenote: (content) => {
      context {
        let output-format = output-format-state.get()
        if output-format == "html" {
          // HTML: Generate proper Tufte CSS structure using html.elem()
          sidenote-counter.step()
          let num = sidenote-counter.display()
          let id-str = "sn-" + str(num)
          
          [
            #html.elem("label", attrs: ("for": id-str, "class": "margin-toggle sidenote-number"))[]
            #html.elem("input", attrs: ("type": "checkbox", id: id-str, "class": "margin-toggle"))[]
            #html.elem("span", attrs: ("class": "sidenote"))[
              #content
            ]
          ]
        } else {
          // PDF: Place in right margin with numbering
          sidenote-counter.step()
          let num = sidenote-counter.display()
          [
            #place(
              right + top,
              dx: 0.5in,
              float: true,
              scope: "parent",
              block(
                width: 2in,
                text(size: 9pt, fill: rgb("#111111"))[#num. #content]
              )
            )
            #super[#num]
          ]
        }
      }
    },
    marginnote: (content) => {
      context {
        let output-format = output-format-state.get()
        if output-format == "html" {
          // HTML: Generate proper Tufte CSS structure using html.elem()
          margin-note-id-counter.step()
          let id-num = margin-note-id-counter.display()
          let id-str = "mn-" + str(id-num)
          
          [
            #html.elem("label", attrs: ("for": id-str, "class": "margin-toggle"))[⊕]
            #html.elem("input", attrs: ("type": "checkbox", id: id-str, "class": "margin-toggle"))[]
            #html.elem("span", attrs: ("class": "marginnote"))[
              #content
            ]
          ]
        } else {
          // PDF: Place in right margin without numbering
          [
            #place(
              right + top,
              dx: 0.5in,
              float: true,
              scope: "parent",
              block(
                width: 2in,
                text(size: 9pt, fill: rgb("#111111"))[#content]
              )
            )
          ]
        }
      }
    },
    marginfigure: (img, caption: none) => {
      context {
        let output-format = output-format-state.get()
        if output-format == "html" {
          // HTML: Wrap in margin note structure using html.elem()
          margin-note-id-counter.step()
          let id-num = margin-note-id-counter.display()
          let id-str = "mn-fig-" + str(id-num)
          
          [
            #html.elem("label", attrs: ("for": id-str, "class": "margin-toggle"))[⊕]
            #html.elem("input", attrs: ("type": "checkbox", id: id-str, "class": "margin-toggle"))[]
            #html.elem("span", attrs: ("class": "marginnote"))[
              #img
              #if caption != none [
                #html.elem("figcaption")[
                  #caption
                ]
              ]
            ]
          ]
        } else {
          // PDF: Place in right margin
          [
            #place(
              right + top,
              dx: 0.5in,
              float: true,
              scope: "parent",
              block(
                width: 2in,
                [
                  #img
                  #if caption != none [
                    #v(0.3em)
                    #text(size: 9pt)[#caption]
                  ]
                ]
              )
            )
          ]
        }
      }
    },
  )
}

// Default functions (PDF mode)
#let margin-funcs = create-margin-functions("pdf")
#let sidenote = margin-funcs.sidenote
#let marginnote = margin-funcs.marginnote
#let marginfigure = margin-funcs.marginfigure

// Main template function
#let lucy-tufte(
  title: none,
  authors: (),
  date: none,
  abstract: none,
  output-format: "pdf",
  body,
) = {
  // Set output format in state (functions will read from this)
  context {
    output-format-state.update(output-format)
  }
  
  // Document metadata
  let author-names = if type(authors) == array {
    authors.map(a => if type(a) == dictionary { a.name } else { a })
  } else if type(authors) == dictionary {
    (authors.name,)
  } else {
    (str(authors),)
  }
  
  set document(title: title, author: author-names)
  
  // Apply typography
  lucy-tufte-config(output-format: output-format)
  
  // Apply page config for PDF
  if output-format == "pdf" {
    lucy-tufte-page()
  }
  
  if output-format == "html" {
    // HTML: Generate proper HTML structure using html.elem()
    // Pre-compute values
    let title-id = if title != none { generate-id(title) } else { "" }
    let author-list = if type(authors) == array { authors } else if authors != () { (authors,) } else { () }
    
    context {
      let title-elem = if title != none {
        html.elem("h1", attrs: ("id": title-id))[#title]
      } else {
        none
      }
      
      let author-elem = if authors != none and authors != () {
        html.elem("p", attrs: ("class": "subtitle"))[
          #for author in author-list [
            #if type(author) == dictionary [
              #author.name
            ] else [
              #author
            ]
          ]
        ]
      } else {
        none
      }
      
      let date-elem = if date != none {
        html.elem("p")[#date]
      } else {
        none
      }
      
      let abstract-elem = if abstract != none {
        html.elem("p")[
          #html.elem("strong")[Abstract: ]
          #abstract
        ]
      } else {
        none
      }
      
      html.elem("article")[
        #if title-elem != none [#title-elem]
        #if author-elem != none [#author-elem]
        #if date-elem != none [#date-elem]
        #if abstract-elem != none [#abstract-elem]
        #html.elem("section")[
          #body
        ] 
      ]
    }
  } else {
    // PDF: Original layout
    // Title
    if title != none {
      set par(first-line-indent: 0em)
      block(width: 100%)[
        #set text(size: 2.5em, weight: 400)
        #title
      ]
      v(0.5em)
    }
    
    // Authors
    if authors != none and authors != () {
      set par(first-line-indent: 0em)
      let author-list = if type(authors) == array { authors } else { (authors,) }
      
      for author in author-list {
        if type(author) == dictionary {
          text(size: 1.2em, style: "italic")[#author.name]
          if "affiliation" in author and author.affiliation != none {
            linebreak()
            text(size: 1em)[#author.affiliation]
          }
        } else {
          text(size: 1.2em, style: "italic")[#author]
        }
        linebreak()
      }
      v(0.5em)
    }
    
    // Date
    if date != none {
      set par(first-line-indent: 0em)
      text(size: 1em)[#date]
      v(1em)
    }
    
    // Abstract
    if abstract != none {
      set par(first-line-indent: 0em)
      block(
        width: 100%,
        inset: (left: 1em, right: 1em, top: 0.5em, bottom: 0.5em),
      )[
        #text(weight: "bold")[Abstract: ]
        #abstract
      ]
      v(1em)
    }
    
    // Main body
    body
  }
}

// Full width figure
#let fullwidth(content) = {
  block(
    width: 100% + 2.5in,
    breakable: false,
    content
  )
}

// Full-width figure with caption
#let fullwidth-figure(img, caption: none) = {
  figure(
    block(width: 100% + 2.5in, img),
    caption: caption,
  )
}

// Epigraph (opening quote)
#let epigraph(content, source: none) = {
  context {
    let output-format = output-format-state.get()
    if output-format == "html" {
      // HTML: Use proper blockquote structure with html.elem()
      [
        #html.elem("blockquote")[
          #set text(style: "italic")
          #set par(first-line-indent: 0em)
          #content
          #if source != none [
            #html.elem("footer")[
              #text(style: "normal")[— #source]
            ]
          ]
        ]
      ]
      v(1em)
    } else {
      // PDF: Original styling
      block(
        inset: (left: 0em, top: 0.5em, bottom: 0.5em),
        [
          #set text(style: "italic")
          #set par(first-line-indent: 0em)
          #content
          #if source != none [
            #linebreak()
            #text(style: "normal")[— #source]
          ]
        ]
      )
      v(1em)
    }
  }
}

// New thought - first few words in small caps
#let newthought(content) = {
  smallcaps[#content]
}
