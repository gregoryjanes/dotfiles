-- Jupyter in Neovim. One-time setup per machine:
--   uv venv ~/.virtualenvs/neovim
--   uv pip install --python ~/.virtualenvs/neovim pynvim jupyter_client ipykernel nbformat
--   uv tool install jupytext
-- Per project: activate its venv, then run `mkkernel` (zshrc). Keymaps live in which-key.lua.

return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_wrap_output = true
      -- Kernels inherit nvim's env. Make pyvista open its normal interactive VTK window
      -- instead of a notebook widget Molten can't display. Per plot: show(jupyter_backend="static") for inline.
      vim.env.PYVISTA_JUPYTER_BACKEND = "none"
    end,
  },
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      processor = "magick_cli", -- uses the `magick` binary, no luarock needed
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },
  {
    -- opens .ipynb as a `# %%` python file, writes back to .ipynb on save
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = { style = "percent", output_extension = "auto", force_ft = nil },
  },
}
