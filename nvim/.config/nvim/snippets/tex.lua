-- Environment menu: type `\begin{`, pick a name with Shift+Up/Down (or type a few letters),
-- press Enter, and the whole `\begin{..}` is replaced by the full environment.
-- Nothing expands on its own, so moving the cursor around never adds an \end{}.
-- <Tab>/<S-Tab> (or <C-f>/<C-b>) jump between the fields.
local ls = require("luasnip")
local parse = ls.parser.parse_snippet

local BEGIN = "\\begin{[%a%*]*$"

-- Clear from `\begin{` through autopairs' closing `}` so the template replaces all of it.
local function resolve(_, line_to_cursor)
  local s = line_to_cursor:find(BEGIN)
  if not s then return nil end
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  if vim.api.nvim_get_current_line():sub(col + 1, col + 1) == "}" then col = col + 1 end
  return { clear_region = { from = { row - 1, s - 1 }, to = { row - 1, col } } }
end

local function env(name, body)
  return parse({
    trig = name,
    wordTrig = false,
    show_condition = function(line) return line:find(BEGIN) ~= nil end,
    resolveExpandParams = resolve,
  }, "\\begin{" .. name .. "}" .. (body or "\n\t$0") .. "\n\\end{" .. name .. "}")
end

return {
  env("equation", "\n\t$1\n\t\\label{eq:$2}"),
  env("equation*"),
  env("align", "\n\t$1 &= $2 \\\\\\\\\n\t\\label{eq:$3}"),
  env("align*", "\n\t$1 &= $2 \\\\\\\\"),
  env("gather"),
  env("gather*"),
  env("split"),
  env("cases", "\n\t${1:0} & \\text{${2:if} \\$${3:x<0}\\$} \\\\\\\\\n\t${4:1} & \\text{${5:if} \\$${6:x>0}\\$}"),
  env("pmatrix", "\n\t$1 & $2 \\\\\\\\\n\t$3 & $4"),
  env("bmatrix", "\n\t$1 & $2 \\\\\\\\\n\t$3 & $4"),
  env("figure", "[htbp]\n\t\\centering\n\t\\includegraphics[width=0.9\\linewidth]{${1:filename}}\n\t\\caption{\n\t\t\\textbf{${2:captionBold}}\n\t\t${3:captionText}\n\t}\n\t\\label{fig:${4:figureLabel}}"),
  env("subfigure", "{${1:0.45}\\textwidth}\n\t\\centering\n\t\\includegraphics[width=\\linewidth]{$2}\n\t\\caption{$3}\n\t\\label{fig:$4}"),
  env("table", "[htbp]\n\t\\centering\n\t\\caption{$1}\n\t\\label{tab:$2}\n\t\\begin{tabular}{${3:c c}}\n\t\t\\hline\n\t\t$0\n\t\t\\hline\n\t\\end{tabular}"),
  env("tabular", "{${1:c c}}\n\t$0"),
  env("itemize", "\n\t\\item $0"),
  env("enumerate", "\n\t\\item $0"),
  env("description", "\n\t\\item[$1] $0"),
  env("center"),
  env("minipage", "{${1:0.45}\\textwidth}\n\t$0"),
  env("theorem"),
  env("lemma"),
  env("definition"),
  env("proof"),
  env("abstract"),
  env("frame", "{$1}\n\t$0"),
  env("verbatim"),
}
