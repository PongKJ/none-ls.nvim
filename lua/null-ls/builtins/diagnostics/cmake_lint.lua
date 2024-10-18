local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local get_severity = function(severity)
    if severity == "E" then
        return h.diagnostics.severities.error
    elseif severity == "W" then
        return h.diagnostics.severities.warning
    elseif severity == "C" or severity == "R" or severity == "I" then
        return h.diagnostics.severities.information
    end
    return h.diagnostics.severities.warning
end

return h.make_builtin({
    name = "cmake_lint",
    meta = {
        url = "https://github.com/cheshirekow/cmake_format",
        description = "Check cmake listfiles for style violations, common mistakes, and anti-patterns.",
    },
    method = methods.internal.DIAGNOSTICS_ON_SAVE,
    filetypes = { "cmake" },
    generator_opts = {
        command = "cmake-lint",
        args = {
            "$FILENAME",
        },
        format = "line",
        to_stdin = false,
        from_stderr = true,
        on_output = function(line, params)
            if not vim.startswith(line, params.bufname) or line == params.bufname then
                return
            end
            local row, col, code, sev, msg = string.match(line, "(%d+),?([0-9]*): %[((%w)[%d]+)%] (.+)")

            if col == "" then
                col = "1"
            end
            local ret = {
                row = row,
                col = col,
                message = msg,
                code = code,
                severity = get_severity(sev),
            }
            return ret
        end,
    },
    factory = h.generator_factory,
})
