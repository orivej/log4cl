(cl:defpackage :log4cl-test.compat
  (:use :cl :log4cl :stefil)
  (:import-from :log4cl-test #:test-runtime-logger-of-wrong-type-helper)
  (:export #:test))

(in-package :log4cl-test.compat)

(eval-when (:load-toplevel :compile-toplevel :execute)
  (progn 
    #+sbcl (declaim (sb-ext:muffle-conditions stefil::test-style-warning)) 
    (log4cl:log-setup :dwim-logging-macros nil) 
    (in-suite log4cl-test::test)
    (defsuite* test)
    (export 'test)))

(deftest produces-output-with-explicit-logger ()
  "Test that log statement with explicit logger produce output"
  (with-package-log-hierarchy
    (reset-logging-configuration)
    (is (equal (with-output-to-string (*debug-io*)
                 (log-warn (make-logger)  "Hello World!"))
               "WARN - Hello World!
"))
    (is (equal (with-output-to-string (*debug-io*)
                 (log-warn '(blah test foobar)  "Hello World!"))
               "WARN - Hello World!
"))
    (is (equal (with-output-to-string (*debug-io*)
                 (log-warn :foobar  "Hello World!"))
               "WARN - Hello World!
"))
    (is (equal (with-output-to-string (*debug-io*)
                 (log-warn 'foobar  "Hello World!"))
               "WARN - Hello World!
"))))

(deftest logger-by-variable ()
  "Test logging macros to verify that we can bind logger into a
variable, and that logging macros are correctly handling this
situation"
  (with-package-log-hierarchy
    (reset-logging-configuration)
    (let ((logger (make-logger :foobar)))
      (is (log-warn logger)))))

(defun returns-a-logger ()
  (let ((logger (make-logger)))
    (log-config logger :d)
    logger))

(deftest logger-by-expression ()
  "Test logging macros to verify that we can make a function returning
a logger, and that logging macros are correctly handling this
situation"
  (with-package-log-hierarchy
    (reset-logging-configuration)
    (is (equal (with-output-to-string (*debug-io*)
                 (log-debug (returns-a-logger)  "Hello World!"))
               "DEBUG - Hello World!
"))))

(deftest test-runtime-logger-of-wrong-type ()
  "Test that specifying logger at run time checks its type"
  (with-package-log-hierarchy
    (clear-logging-configuration)
    (log:config :i)
    (let ((e (test-runtime-logger-of-wrong-type-helper)))
      (signals type-error (log:info e))
      (setq e (test-runtime-logger-of-wrong-type-helper (make-condition 'error)))
      (signals type-error (log:info e))))
  (values))
