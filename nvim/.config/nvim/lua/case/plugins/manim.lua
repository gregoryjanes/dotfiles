return {
    "yeasin50/manim.nvim",
    cmd = { "ManimCheck", "ManimPlay", "ManimExport", "ManimExportProject", "ManimPlayFrom" },
    ft = "python",
    keys = {
        -- { "<leader>c", "<cmd>ManimCheck<cr>", desc = "Check Manim availability" },
        { "<leader>m", "<cmd>ManimPlay<cr>", desc = "Play Manim class" },
    },

    config = function()
        require("manim").setup({
            manim_path = "manim",
            venv_path = "/home/gregoryjanes/004-python/presentations/.venv", 
            play_args = { "-pql" }, 
            export_args = {
                "-qk",
                "--media_dir=/home/gregoryjanes/004-python/manim_output", 
                "--transparent",
            },
            
            project_config = {
                resolution = { 3840, 2160 },
                fps = 60,
                transparent = true,
                export_dir = "/home/gregoryjanes/Videos/manim_exports",
                max_workers = 3,
                ignore_files = { "common.py", "export.py" },
                failed_list_file = "failed_files.txt",
            },
        })
  end,
}
