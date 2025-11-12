# Web-Tufte-Typst

Write Tufte handouts in Typst and export in HTML.

Must see
- [`examples/introduction/introduction.typ`](examples/introduction/introduction.typ) - A short introduction demonstrating all features (sidenotes, margin notes, figures, epigraphs, typography).
- [`examples/tufte-css-reproduce/tufte-css-reproduce.typ`](examples/tufte-css-reproduce/tufte-css-reproduce.typ) - reproduction of the [Tufte CSS documentation](https://edwardtufte.github.io/tufte-css/), showcasing the template's capabilities. This is intented to be a faithful reproduction.

## Features

So far I am using it for my blog writing. Should you want some feature, open an issue or discussion—suggestion me at `luxxxlucy@gmail.com` 

- [x] basic markup with the `tufte.css`
- [x] margin note, side note, figures (margin and full-width)
- [ ] citation and bibliography
- [ ] provide also PDF export that is consistent and faithful (there are other crates that does it but it might be a good idea to have the two export option both supported here)

## Quick Start

Import the template:

```typst
#import "lib/web-tufte-typst.typ": *

#show: web-tufte-typst.with(
  title: [Your Title],
  authors: ((name: "Author Name"),),
)

Your content here...
```

Compile to HTML:

```bash
./compile-html.sh your-document.typ output.html
```

**Important:** For now you must use `compile-html.sh` to generate HTML output. The script compiles your Typst document and automatically injects the Tufte CSS stylesheet into the HTML. Using `typst compile` directly will produce HTML without the required CSS styling. (But I think typst would graudally get there so we can use it as a simple package)

## Requirements

- Typst 0.13+ (for typst's experimental HTML export)

## Known Issues

- **Section structure**: The original Tufte CSS wraps each logical section of content inside individual `<section>` tags. Due to Typst's structure, the current implementation wraps all content inside a single `<section>` tag. This doesn't affect functionality but differs from the original Tufte CSS structure.

- **Some example missingn**: Some example from the original Tufte CSS documentation is not presented in the `tufte-css-reproduce.typ`

- **toggle button not working** in mobile mode the sidenote would be only popping up when it is toggled.
