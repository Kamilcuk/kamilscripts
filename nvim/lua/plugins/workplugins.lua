---@type LazySpec
return {
  {
    "huggingface/llm.nvim",
    enabled = function() return vim.env.LLM_NVIM_URL ~= nil and vim.env.LLM_NVIM_HF_API_TOKEN ~= nil end,
    opts = {
      model = "qwen2.5-coder",
      backend = "openai",
      tokens_to_clear = {
        "<|fim_middle|>",
        "<|fim_pad|>",
        "<|cursor|>",
        "<|fim_prefix|>",
        "<|file_sep|>",
      },
      fim = {
        prefix = "<|fim_prefix|>",
        middle = "<|fim_middle|>",
        suffix = "<|fim_suffix|>",
      },
      -- lsp = { cmd_env = { LLM_LOG_LEVEL = "DEBUG" } },
      -- lsp = { cmd_env = { LLM_LOG_LEVEL = "INFO" } },
      -- debounce_ms = 500,
      request_body = {
        temperature = 0.2,
        top_p = 0.95,
        repetition_penalty = 1.05,
        max_tokens = 60,
      },
      accept_keymap = "<C-e>",
      dismiss_keymap = nil,
    },
  },
}
