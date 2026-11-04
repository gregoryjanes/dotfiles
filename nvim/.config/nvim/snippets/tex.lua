-- LaTeX environment templates. They expand automatically as soon as you finish
-- typing `\begin{name}`. <C-f>/<C-b> jump between the fields.
local ls = require("luasnip")
local f = ls.function_node
local fmta = require("luasnip.extras.fmt").fmta
local parse = ls.parser.parse_snippet

local function env(name, body)
  return parse({ trig = "\\begin{" .. name .. "}", snippetType = "autosnippet" },
    "\\begin{" .. name .. "}" .. body .. "\n\\end{" .. name .. "}")
end

return {
  env("equation", "\n\t$1\n\t\\label{eq:$2}"),
  env("align", "\n\t$1 &= $2 \\\\\\\\\n\t\\label{eq:$3}"),
  env("figure", "[htbp]\n\t\\centering\n\t\\includegraphics[width=${1:0.8}\\textwidth]{$2}\n\t\\caption{$3}\n\t\\label{fig:$4}"),
  env("table", "[htbp]\n\t\\centering\n\t\\caption{$1}\n\t\\label{tab:$2}\n\t\\begin{tabular}{${3:c c}}\n\t\t\\hline\n\t\t$0\n\t\t\\hline\n\t\\end{tabular}"),
  env("itemize", "\n\t\\item $0"),
  env("enumerate", "\n\t\\item $0"),

  -- Any other environment: just close it.
  ls.snippet({ trig = "\\begin{([%a%*]+)}", trigEngine = "pattern", snippetType = "autosnippet", priority = 500 },
    fmta("\\begin{<>}\n\t<>\n\\end{<>}", {
      f(function(_, snip) return snip.captures[1] end),
      ls.insert_node(0),
      f(function(_, snip) return snip.captures[1] end),
    })),
}
