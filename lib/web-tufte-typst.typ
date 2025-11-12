//-------------------------------------------------------------------------------
// Web-Tufte-Typst: Tufte handout for Typst HTML output
// Generates HTML compatible with Tufte CSS (https://edwardtufte.github.io/tufte-css/)
//-------------------------------------------------------------------------------

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

// Note: We are targeting HTML output styled by Tufte CSS, not PDF export, so 
// some precise font and formatting aspects only matter in print/PDF, but are 
// handled by the CSS.
// Configure document-level settings
#let web-tufte-typst-config(output-format: "html") = {
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
#let web-tufte-typst-page() = {
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
#let output-format-state = state("output-format", "html")

// Create format-aware margin note functions
#let create-margin-functions(output-format) = {
  (
    sidenote: (note) => {
      context {
        let output-format = output-format-state.get()
        if output-format == "html" {
          // HTML: Generate proper Tufte CSS structure using html.elem()
          sidenote-counter.step()
          let num = sidenote-counter.display()
          let id-str = "sn-" + str(num)
          
          box[
            #html.elem("label", attrs: ("for": id-str, "class": "margin-toggle sidenote-number"))[]
            #html.elem("input", attrs: ("type": "checkbox", id: id-str, "class": "margin-toggle"))[]
          ]
          html.elem("span", attrs: ("class": "sidenote"))[
            #note
          ]
        } else {
          // PDF: Place in right margin with numbering
          sidenote-counter.step()
          let num = sidenote-counter.display()
          
          [
            #super[#num]
            #place(
              right + top,
              dx: 0.5in,
              float: true,
              scope: "parent",
              block(
                width: 2in,
                text(size: 9pt, fill: rgb("#111111"))[#num. #note]
              )
            )
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
          
          box[
            #html.elem("label", attrs: ("for": id-str, "class": "margin-toggle"))[⊕]
            #html.elem("input", attrs: ("type": "checkbox", id: id-str, "class": "margin-toggle"))[]
          ]
          html.elem("span", attrs: ("class": "marginnote"))[
            #content
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
  )
}

// Default functions (HTML mode)
#let margin-funcs = create-margin-functions("html")
#let sidenote = margin-funcs.sidenote
#let marginnote = margin-funcs.marginnote

// Main template function
#let web-tufte-typst(
  title: none,
  author: none,
  date: none,
  abstract: none,
  output-format: "html",
  body,
) = {
  // Set output format in state (functions will read from this)
  context {
    output-format-state.update(output-format)
  }
  
  // Document metadata
  let author-name = if type(author) == dictionary {
    author.name
  } else if author != none {
    str(author)
  } else {
    none
  }
  
  set document(title: title, author: if author-name != none { (author-name,) } else { () })
  
  // Apply typography
  web-tufte-typst-config(output-format: output-format)
  
  // Apply page config for PDF
  if output-format == "pdf" {
    web-tufte-typst-page()
  }
  
  if output-format == "html" {
    // HTML: Generate proper HTML structure using html.elem()
    // Pre-compute values
    let title-id = if title != none { generate-id(title) } else { "" }
    
    context {
      let title-elem = if title != none {
        html.elem("h1", attrs: ("id": title-id))[#title]
      } else {
        none
      }
      
      let author-elem = if author != none {
        html.elem("p", attrs: ("class": "subtitle"))[
          #if type(author) == dictionary [
            #author.name
            #if "email" in author and author.email != none [
              #text[ <]#link("mailto:" + author.email)[#author.email]#text[>]
            ]
          ] else [
            #author
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
    
    // Author
    if author != none {
      set par(first-line-indent: 0em)
      if type(author) == dictionary {
        text(size: 1.2em, style: "italic")[#author.name]
        if "affiliation" in author and author.affiliation != none {
          linebreak()
          text(size: 1em)[#author.affiliation]
        }
      } else {
        text(size: 1.2em, style: "italic")[#author]
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

// Figure function - handles both PDF and HTML
// Note: Uses a different name (tufte-figure) to avoid recursion with Typst's built-in figure()
// Users should use #tufte-figure() in their documents
#let tufte-figure(path, caption: none, caption-as-marginnote: false) = {
  context {
    let output-format = output-format-state.get()
    if output-format == "html" {
      // HTML: Generate proper figure structure with img tag
      let img-tag = html.elem("img", attrs: (
        "src": path,
        "alt": ""
      ))[]
      
      if caption-as-marginnote and caption != none {
        // Use margin note structure inside figure (matching Tufte CSS reference implementation)
        margin-note-id-counter.step()
        let id-num = margin-note-id-counter.display()
        let id-str = "mn-fig-" + str(id-num)
        
        [
          #html.elem("figure")[
            #html.elem("label", attrs: ("for": id-str, "class": "margin-toggle"))[⊕]
            #html.elem("input", attrs: ("type": "checkbox", id: id-str, "class": "margin-toggle"))[]
            #html.elem("span", attrs: ("class": "marginnote"))[
              #caption
            ]
            #img-tag
          ]
        ]
      } else {
        [
          #html.elem("figure")[
            #img-tag
            #if caption != none [
              #html.elem("figcaption")[
                #caption
              ]
            ]
          ]
        ]
      }
    } else {
      // PDF: Use Typst's built-in figure function
      figure(
        path,
        caption: caption,
      )
    }
  }
}

// Margin figure - figure in margin note
#let marginfigure(path, caption: none) = {
  context {
    let output-format = output-format-state.get()
    if output-format == "html" {
      // HTML: Generate margin figure structure with img tag
      margin-note-id-counter.step()
      let id-num = margin-note-id-counter.display()
      let id-str = "mn-fig-" + str(id-num)
      
      let img-tag = html.elem("img", attrs: (
        "src": path,
        "alt": ""
      ))[]
      
      [
        #html.elem("label", attrs: ("for": id-str, "class": "margin-toggle"))[⊕]
        #html.elem("input", attrs: ("type": "checkbox", id: id-str, "class": "margin-toggle"))[]
        #html.elem("span", attrs: ("class": "marginnote"))[
          #box[
            #img-tag
          ]
          #caption
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
              #image(path)
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
}

// Full width figure wrapper
#let fullwidth(content) = {
  context {
    let output-format = output-format-state.get()
    if output-format == "html" {
      // HTML: Wrap in div with fullwidth class
      html.elem("div", attrs: ("class": "fullwidth"))[
        #content
      ]
    } else {
      // PDF: Use block with extended width
      block(
        width: 100% + 2.5in,
        breakable: false,
        content
      )
    }
  }
}

// Full-width figure with caption
#let tufte-fullwidth-figure(path, caption: none) = {
  context {
    let output-format = output-format-state.get()
    if output-format == "html" {
      // HTML: Generate figure with fullwidth class and img tag
      let img-tag = html.elem("img", attrs: (
        "src": path,
        "alt": ""
      ))[]
      
      [
        #html.elem("figure", attrs: ("class": "fullwidth"))[
          #img-tag
          #if caption != none [
            #html.elem("figcaption")[
              #caption
            ]
          ]
        ]
      ]
    } else {
      // PDF: Use block with extended width
      figure(
        block(width: 100% + 2.5in, image(path)),
        caption: caption,
      )
    }
  }
}

// Epigraph (opening quote) - single epigraph
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

// Epigraphs - multiple epigraphs wrapped in div.epigraph
// Takes an array of dictionaries with 'content' and optional 'source' keys
#let epigraphs(items) = {
  context {
    let output-format = output-format-state.get()
    if output-format == "html" {
      // HTML: Wrap all epigraphs in div.epigraph
      [
        #html.elem("div", attrs: ("class": "epigraph"))[
          #for item in items [
            #html.elem("blockquote")[
              #set text(style: "italic")
              #set par(first-line-indent: 0em)
              #item.content
              #if "source" in item and item.source != none [
                #html.elem("footer")[
                  #text(style: "normal")[— #item.source]
                ]
              ]
            ]
          ]
        ]
      ]
    } else {
      // PDF: Render each epigraph separately
      for item in items {
        epigraph(item.content, source: item.get("source", none))
      }
    }
  }
}

// New thought - first few words in small caps
#let newthought(content) = {
  context {
    let output-format = output-format-state.get()
    if output-format == "html" {
      html.elem("span", attrs: ("class": "newthought"))[
        #smallcaps[#content]
      ]
    } else {
      // PDF: Apply small caps styling
      smallcaps[#content]
    }
  }
}

// Sans-serif paragraph - applies the "sans" class in HTML mode
#let sans(content) = {
  context {
    let output-format = output-format-state.get()
    if output-format == "html" {
      // HTML: Wrap in paragraph with class="sans"
      html.elem("p", attrs: ("class": "sans"))[
        #content
      ]
    } else {
      // PDF: Render content with sans-serif font
      set text(font: ("Gill Sans", "Arial", "Helvetica", "sans-serif"))
      content
    }
  }
}
