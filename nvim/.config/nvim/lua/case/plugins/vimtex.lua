

return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    -- Set your PDF viewer (e.g., "skim", "zathura", "okular")
    vim.g.vimtex_view_method = "skim"

    -- Set the main compiler to latexmk
    vim.g.vimtex_compiler_method = "latexmk"

    -- Configure latexmk to use lualatex as its engine
    vim.g.vimtex_compiler_latexmk_engines = {
      _ = "-lualatex"
    }
      
    -- Set the bibliography tool for biblatex
    vim.g.vimtex_bibtex_engine = "biber"
    vim.g.vimtex_compiler_latexmk_options = '-pdf -bibtex-use=2'

    -- Define files to be removed by :VimtexClean
    vim.g.vimtex_clean_exts = {
      "aux", "bbl", "bcf", "blg", "idx", "ind", "ilg", "log", "out",
      "run.xml", "synctex.gz", "toc", "nav", "snm", "vrb",
    }
    
    vim.g.vimtex_clean_patterns = { "*-blx.bib", "_minted*" }
  end,
}
