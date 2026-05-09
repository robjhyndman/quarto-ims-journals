# Quarto Journal Template: Statistical Science (IMS)

A [Quarto](https://quarto.org) journal extension for
[Statistical Science](https://imstat.org/journals-and-publications/statistical-science/),
published by the Institute of Mathematical Statistics.

## Installation

```bash
quarto use template quarto-journals/sts
```

This will install the extension and create an example `template.qmd` that you can
use as the basis for your article.

## Usage

To use the format in an existing document, add the following to your YAML front matter:

```yaml
format:
  sts-pdf: default
```

## Format options

Authors and affiliations use Quarto's standard schema:

```yaml
title: "Your Article Title"
short-title: "Running Head"
author:
  - name: First Author
    email: first@university.edu
    orcid: 0000-0000-0000-0000
    note: "Optional footnote on this author."
    affiliations:
      - name: University Name
        department: Department of Statistics
        city: City
        country: Country
  - name: Second Author
    email: second@university.edu
    affiliations:
      - name: Another University
        department: Department
        city: City
        country: Country
abstract: |
  Your abstract here (max 200 words).
keywords: [keyword one, keyword two]
bibliography: references.bib
```

The default citation style is numeric (`imsart-number.bst`). For author-year citations,
set `biblio-style: imsart-nameyear` in the format options and load natbib with the
`authoryear` option in `header-includes`.

## Theorem environments

Because the IMS class patches `\theoremstyle`, theorem environments must be defined in
`header-includes` and used as raw LaTeX blocks rather than Quarto's native theorem divs:

````yaml
header-includes: |
  \theoremstyle{plain}
  \newtheorem{theorem}{Theorem}[section]
  \newtheorem{lemma}[theorem]{Lemma}
  \theoremstyle{definition}
  \newtheorem{definition}[theorem]{Definition}
````

Then in the document body:

````markdown
```{=latex}
\begin{theorem}\label{th1}
Statement of the theorem.
\end{theorem}
```
````

## Special environments

Use Quarto divs for IMS-specific end-matter environments:

```markdown
::: {.acks}
Acknowledgment text.
:::

::: {.funding}
Funding information.
:::

::: {.supplement stitle="Supplement Title" sdesc="Brief description."}
:::
```

## Note on column layout

This template renders in single-column mode, which is appropriate for submission.
The journal typesets the final two-column version from your source file.

## License

The LaTeX class and style files (`imsart.cls`, `imsart.sty`) and BibTeX styles
are copyright VTeX Software, distributed under the LaTeX Project Public License.
The Quarto extension wrapper is MIT licensed.
