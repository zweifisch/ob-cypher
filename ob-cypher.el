;;; ob-cypher.el --- query neo4j using cypher in org-mode blocks

;; Copyright (C) 2015 ZHOU Feng

;; Author: ZHOU Feng <zf.pascal@gmail.com>
;; URL: http://github.com/zweifisch/ob-cypher
;; Keywords: org babel cypher neo4j
;; Version: 0.0.1
;; Created: 8th Feb 2015
;; Package-Requires: ((s "1.9.0") (cypher "0.0.6") (dash "2.10.0") (dash-functional "1.2.0"))

;;; Commentary:
;;
;; query neo4j using cypher in org-mode blocks
;;

;;; Code:
(require 'org)
(require 'ob)
(require 's)
(require 'dash)

(defun ob-cypher/parse-result (output)
  (->> (s-lines output)
    (-filter (-partial 's-starts-with? "|"))
    (-map (-partial 's-chop-suffix "|"))
    (-map (-partial 's-chop-prefix "|"))
    (-map (-partial 's-split " | "))))

(defun ob-cypher/table (output)
  (org-babel-script-escape (ob-cypher/parse-result output)))

(defun org-babel-execute:cypher (body params)
  (let* ((host (or (assoc :host params) "127.0.0.1"))
         (port (or (assoc :host params) 1337))
         (result-type (cdr (assoc :result-type params)))
         (body (if (s-ends-with? ";" body) body (s-append ";" body)))
         (tmp (org-babel-temp-file "cypher-"))
         (cmd (s-format "neo4j-shell -host ${host} -port ${port} -file ${file}" 'aget
                        `(("host" . ,host)
                          ("port" . ,(int-to-string port))
                          ("file" . ,tmp))))
         (result (progn
                   (with-temp-file tmp (insert body))
                   (shell-command-to-string cmd))))
    (message cmd)
    (if (string= "output" result-type) result (ob-cypher/table result))))

(provide 'ob-cypher)
;;; ob-cypher.el ends here
