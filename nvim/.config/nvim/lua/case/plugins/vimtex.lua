return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    -- Set your PDF viewer
    vim.g.vimtex_view_method = "zathura"

    -- Set the main compiler to latexmk
    vim.g.vimtex_compiler_method = "latexmk"

    -- Configure latexmk to use lualatex as its engine
    vim.g.vimtex_compiler_latexmk_engines = {
      _ = "-lualatex"
    }

    -- CORRECT WAY to pass options to latexmk in Vimtex.
    -- We removed the bibtex override so latexmk can auto-detect biber.
    vim.g.vimtex_compiler_latexmk = {
      options = {
        "-pdf",
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
      }
    }

    -- Define files to be removed by :VimtexClean
    vim.g.vimtex_clean_exts = {
      "aux", "bbl", "bcf", "blg", "idx", "ind", "ilg", "log", "out",
      "run.xml", "synctex.gz", "toc", "nav", "snm", "vrb",
    }
    vim.g.vimtex_clean_patterns = { "*-blx.bib", "_minted*" }
    
    vim.g.vimtex_mappings_enabled = 0
  end,
}
