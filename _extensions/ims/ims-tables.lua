--[[
  ims-tables.lua

  Pandoc always emits \begin{longtable}...\end{longtable} for markdown
  tables. This filter intercepts each Table AST node, renders it to LaTeX
  via pandoc.write, then rewrites the longtable body as a plain tabular.

  Quarto always wraps Table elements in \begin{table}...\end{table} itself
  (for both labeled and unlabeled tables), so this filter emits only the
  \begin{tabular}...\end{tabular} content — no extra float wrapper.

  Pandoc's longtable skeleton:
    \begin{longtable}[<pos>]{<spec>}
    \caption{...}\label{...}\tabularnewline  ← stripped (Quarto owns it)
    \toprule\noalign{}
    header cols \\
    \midrule\noalign{}
    \endhead
    \bottomrule\noalign{}                    ← "last footer"
    \endlastfoot
    body rows...
    \end{longtable}

  The \bottomrule appears BEFORE body rows (longtable footer definition),
  so we extract it and move it to after the body rows.
--]]

local function rewrite_longtable(s)
  -- Extract column spec from \begin{longtable}[<pos>]{<spec>}
  local col_spec
  s = s:gsub('\\begin%{longtable%}%b[](%b{})\n?', function(spec)
    col_spec = spec:sub(2, -2)   -- strip outer { }
    return ''
  end, 1)
  if not col_spec then return s end

  -- Drop caption line: Quarto generates \caption{} for the outer float
  s = s:gsub('^%s*\\caption(%b{})(.-)\\tabularnewline%s*\n?', '', 1)

  -- Remove \endhead (header rows above it stay in place)
  s = s:gsub('\\endhead%s*\n?', '', 1)

  -- Extract \bottomrule...\endlastfoot and move it to after the body rows
  local footer_str = ''
  s = s:gsub('(\\bottomrule[^\n]*)\n?\\endlastfoot%s*\n?', function(br)
    footer_str = br
    return ''
  end, 1)

  -- Defensive: strip any remaining longtable-only markers
  s = s:gsub('\\endfirsthead%s*\n?', '')
  s = s:gsub('\\endfoot%s*\n?', '')

  -- Replace \end{longtable} with footer rule + \end{tabular}
  local close = (footer_str ~= '' and footer_str .. '\n' or '') .. '\\end{tabular}'
  s = s:gsub('\\end%{longtable%}', close, 1)

  return '\\begin{tabular}{' .. col_spec .. '}\n' .. s
end

function Table(tbl)
  if not quarto.doc.is_format('pdf') then return nil end
  -- pandoc.write produces a full standalone document; extract just the table.
  local full = pandoc.write(pandoc.Pandoc({tbl}), 'latex')
  local latex = full:match('(\\begin%{longtable%}.-\\end%{longtable%})')
  if not latex then return nil end
  return pandoc.RawBlock('latex', rewrite_longtable(latex))
end
