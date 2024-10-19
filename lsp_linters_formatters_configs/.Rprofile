## Default repo
local({
  r <- getOption("repos")
  r["CRAN"] <- "https://cran.r-project.org"
  options(repos = r)
})

# Disable completion from the language server
options(
  languageserver.server_capabilities = list(
    completionProvider = FALSE,
    completionItemResolve = FALSE
  )
)
