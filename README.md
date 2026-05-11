# Quarto Journal Template: IMS Journals

A [Quarto](https://quarto.org) journal extension for journals published by the
[Institute of Mathematical Statistics](https://imstat.org), including
*Statistical Science*, *Annals of Statistics*, *Annals of Applied Statistics*,
and others.

## Installation

```bash
quarto use template robjhyndman/quarto-ims-journals
```

This will install the extension and create an example `template.qmd` that you can
use as the basis for your article.

## Usage

To use the format in an existing document, add the following to your YAML front matter:

```yaml
format:
  ims-pdf: default
```

## Format options

Set the `ims-journal` field to the code for your target journal, then add authors
and affiliations using Quarto's standard schema:

```yaml
title: "Your Article Title"
short-title: "Running Head"
ims-journal: sts
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

### Journal codes

Possible values of `ims-journal`:

| Code   | Journal                                         |
|--------|-------------------------------------------------|
| `aap`  | Annals of Applied Probability                   |
| `aihp` | Annales de l'Institut Henri Poincaré            |
| `aoas` | Annals of Applied Statistics                    |
| `aop`  | Annals of Probability                           |
| `aos`  | Annals of Statistics                            |
| `ba`   | Bayesian Analysis                               |
| `bj`   | Bernoulli                                       |
| `bjps` | Brazilian Journal of Probability and Statistics |
| `ejs`  | Electronic Journal of Statistics                |
| `ps`   | Probability Surveys                             |
| `ss`   | Statistics Surveys                              |
| `sts`  | Statistical Science                             |

## Theorem environments

Because the IMS class patches `\theoremstyle`, theorem environments must be defined in `header-includes` and used as raw LaTeX blocks rather than Quarto's native theorem divs:

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

This template renders in single-column mode, which is appropriate for submission. The journal typesets the final two-column version from your source file.

## License

The LaTeX class and style files (`imsart.cls`, `imsart.sty`) and BibTeX styles are copyright VTeX Software, distributed under the LaTeX Project Public License at <http://www.e-publications.org/ims/support>. The Quarto extension is MIT licensed.
