--[[
  ims-environments.lua

  Converts Pandoc Divs with IMS-specific classes to raw LaTeX environments
  for PDF output. For HTML output, the content is wrapped in a simple
  <section> with an appropriate heading.

  Supported div classes:
    .acks       → \begin{acks}[Acknowledgments]...\end{acks}
    .funding    → \begin{funding}...\end{funding}
    .supplement → \begin{supplement}
                    \stitle{<stitle attr>}
                    \sdescription{<sdesc attr>}
                  \end{supplement}

  Usage in .qmd:
    ::: {.acks}
    The authors thank the referees.
    :::

    ::: {.supplement stitle="Code" sdesc="R code for simulations."}
    :::
--]]

local function div_to_latex(env, before_content, after_content, content)
  local blocks = {}
  table.insert(blocks, pandoc.RawBlock('latex', '\\begin{' .. env .. '}'))
  if before_content and before_content ~= '' then
    table.insert(blocks, pandoc.RawBlock('latex', before_content))
  end
  for _, b in ipairs(content) do
    table.insert(blocks, b)
  end
  if after_content and after_content ~= '' then
    table.insert(blocks, pandoc.RawBlock('latex', after_content))
  end
  table.insert(blocks, pandoc.RawBlock('latex', '\\end{' .. env .. '}'))
  return blocks
end

local function div_to_html_section(heading, content)
  local blocks = {}
  table.insert(blocks, pandoc.Header(2, pandoc.Str(heading)))
  for _, b in ipairs(content) do
    table.insert(blocks, b)
  end
  return blocks
end

function Div(div)
  local cls = div.classes

  if cls:includes('acks') then
    if quarto.doc.is_format('pdf') then
      local blocks = {}
      table.insert(blocks, pandoc.RawBlock('latex', '\\begin{acks}[Acknowledgments]'))
      for _, b in ipairs(div.content) do table.insert(blocks, b) end
      table.insert(blocks, pandoc.RawBlock('latex', '\\end{acks}'))
      return blocks
    else
      return div_to_html_section('Acknowledgments', div.content)
    end

  elseif cls:includes('funding') then
    if quarto.doc.is_format('pdf') then
      local blocks = {}
      table.insert(blocks, pandoc.RawBlock('latex', '\\begin{funding}'))
      for _, b in ipairs(div.content) do table.insert(blocks, b) end
      table.insert(blocks, pandoc.RawBlock('latex', '\\end{funding}'))
      return blocks
    else
      return div_to_html_section('Funding', div.content)
    end

  elseif cls:includes('supplement') then
    local stitle = div.attributes['stitle'] or ''
    local sdesc  = div.attributes['sdesc']  or ''
    if quarto.doc.is_format('pdf') then
      local before = ''
      if stitle ~= '' then before = before .. '\\stitle{' .. stitle .. '}\n' end
      if sdesc  ~= '' then before = before .. '\\sdescription{' .. sdesc .. '}' end
      local blocks = {}
      table.insert(blocks, pandoc.RawBlock('latex', '\\begin{supplement}'))
      if before ~= '' then
        table.insert(blocks, pandoc.RawBlock('latex', before))
      end
      for _, b in ipairs(div.content) do table.insert(blocks, b) end
      table.insert(blocks, pandoc.RawBlock('latex', '\\end{supplement}'))
      return blocks
    else
      local heading = 'Supplement'
      if stitle ~= '' then heading = 'Supplement: ' .. stitle end
      return div_to_html_section(heading, div.content)
    end
  end
end
