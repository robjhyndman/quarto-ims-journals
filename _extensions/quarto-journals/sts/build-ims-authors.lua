--[[
  build-ims-authors.lua

  Generates the IMS STS \begin{aug}...\end{aug} block content from
  Quarto's normalised author metadata, storing it in meta['ims-aug-block']
  for use in the Pandoc template via $ims-aug-block$.

  Author labels: 1→A, 2→B, ..., 26→Z

  Quarto represents author notes as {text = MetaInlines, number = int},
  where number is the global note index used for footnote marks.
--]]

local function label(n)
  return string.char(64 + n)
end

local function stringify(v)
  if v == nil then return nil end
  if type(v) == 'string' then return v end
  return pandoc.utils.stringify(v)
end

-- Extract note text and number from Quarto's note structure
local function parse_note(note)
  if note == nil then return nil, nil end
  -- Quarto stores note as {text = MetaInlines, number = int}
  if type(note) == 'table' and note.text then
    return stringify(note.text), note.number
  end
  -- Fallback for plain string notes
  return stringify(note), nil
end

function Meta(meta)
  -- Only generate LaTeX in PDF output
  if not quarto.doc.is_format('pdf') then return meta end

  local authors = meta['by-author']
  if not authors or #authors == 0 then return meta end

  local lines = {}

  -- First pass: \author commands
  for i, author in ipairs(authors) do
    local lbl = label(i)
    local given  = stringify(author.name and author.name.given)  or ''
    local family = stringify(author.name and author.name.family) or ''
    local email  = stringify(author.email)
    local orcid  = stringify(author.orcid)
    local note_text, note_num = parse_note(author.note)

    local cmd = string.format('\\author[%s]{\\fnms{%s}~\\snm{%s}', lbl, given, family)

    if note_text and note_text ~= '' then
      local ref_id = note_num or i
      cmd = cmd .. string.format('\\thanksref{t%d}', ref_id)
    end

    if email and email ~= '' then
      cmd = cmd .. string.format('\\ead[label=e%d]{%s}', i, email)
    end

    if orcid and orcid ~= '' then
      cmd = cmd .. string.format('\\orcid{%s}', orcid)
    end

    cmd = cmd .. '}'
    table.insert(lines, cmd)
  end

  -- \thankstext definitions (one per author that has a note)
  for i, author in ipairs(authors) do
    local note_text, note_num = parse_note(author.note)
    if note_text and note_text ~= '' then
      local ref_id = note_num or i
      table.insert(lines, string.format('\\thankstext{t%d}{%s}', ref_id, note_text))
    end
  end

  -- Blank separator
  table.insert(lines, '')

  -- Second pass: \address commands
  for i, author in ipairs(authors) do
    local lbl  = label(i)
    local name = stringify(author.name and author.name.literal) or ''
    local email = stringify(author.email)

    local aff_parts = {}
    if author.affiliations then
      for _, aff in ipairs(author.affiliations) do
        local parts = {}
        local dept    = stringify(aff.department)
        local inst    = stringify(aff.name)
        local city    = stringify(aff.city)
        local country = stringify(aff.country)
        if dept    and dept    ~= '' then table.insert(parts, dept)    end
        if inst    and inst    ~= '' then table.insert(parts, inst)    end
        if city    and city    ~= '' then table.insert(parts, city)    end
        if country and country ~= '' then table.insert(parts, country) end
        if #parts > 0 then
          table.insert(aff_parts, table.concat(parts, ', '))
        end
      end
    end

    local addr = name
    if #aff_parts > 0 then
      addr = addr .. ', ' .. table.concat(aff_parts, '; ')
    end

    local email_cmd = ''
    if email and email ~= '' then
      email_cmd = string.format('\\printead[presep={\\ }]{e%d}', i)
    end

    table.insert(lines, string.format('\\address[%s]{%s%s.}', lbl, addr, email_cmd))
  end

  meta['ims-aug-block'] = pandoc.MetaInlines({
    pandoc.RawInline('latex', table.concat(lines, '\n'))
  })

  return meta
end
