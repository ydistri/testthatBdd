;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((ess-r-mode
  (flycheck-lintr-linters . "with_defaults(camel_case_linter = NULL, single_quotes_linter, line_length_linter(120), object_usage_linter = NULL)")
  (ft-source-to-test-mapping . ((:path "/R/" :prefix "") . (:path "/tests/testthat/" :prefix "test-")))
  (compilation-search-path . "/home/matus/dev/ydistri/testthatBdd")
  (compilation-directory . "/home/matus/dev/ydistri/testthatBdd")
  ))
