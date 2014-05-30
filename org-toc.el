;; ,()%

;; https://github.com/snosov1/dot-emacs#c-s,-c-r-(%D0%BD%D0%B5-%D0%B7%D0%B0%D0%B1%D1%8B%D1%82%D1%8C,-%D1%87%D1%82%D0%BE-%D0%BC%D0%BE%D0%B6%D0%BD%D0%BE-%D0%B2%D1%8B%D0%B4%D0%B5%D0%BB%D0%B8%D1%82%D1%8C-%D0%B8-%D0%BD%D0%B0%D0%B6%D0%B0%D1%82%D1%8C-%D0%B8-%D0%BE%D0%BD%D0%BE-%D0%B5%D0%B3%D0%BE-%D0%B1%D1%83%D0%B4%D0%B5%D1%82-%D0%B8%D1%81%D0%BA%D0%B0%D1%82%D1%8C),-m-s-o,-m-%-(c-q-c-j)
;; https://github.com/snosov1/dot-emacs#m-&
;; https://github.com/snosov1/dot-emacs#dired-(%D0%BE%D1%82%D0%BA%D1%80%D1%8B%D1%82%D1%8C-%D0%B4%D0%B8%D1%80%D0%B5%D0%BA%D1%82%D0%BE%D1%80%D0%B8%D1%8E-%D0%B2-ido)
;; https://github.com/snosov1/dot-emacs#%D0%BF%D0%B8%D1%88%D0%B5%D0%BC-%D0%BF%D1%80%D0%BE%D0%B3%D1%80%D0%B0%D0%BC%D0%BC%D1%83---%D0%BA%D0%BE%D0%BC%D0%BC%D0%B5%D0%BD%D1%82%D0%B0%D1%80%D0%B8%D0%B8,-m-q
;; https://github.com/snosov1/dot-emacs#m-%7C

(defvar toc-regexp "^*.*:toc:\\($\\|[^ ]*:$\\)")
(defvar max-depth 2)

(defun raw-toc ()
  (let ((content (buffer-substring-no-properties
                  (point-min) (point-max))))
    (with-temp-buffer
      (insert content)
      (beginning-of-buffer)
      (keep-lines "^\*")

      (beginning-of-buffer)
      (re-search-forward toc-regexp)
      (beginning-of-line)
      (delete-region (point) (progn (forward-line 1) (point)))

      (buffer-substring-no-properties
       (point-min) (point-max)))))

(defun hrefify-github (str)
  (let* ((spc-fix (replace-regexp-in-string " " "-" str))
         (slash-fix (replace-regexp-in-string "/" "" spc-fix))
         (upcase-fix (replace-regexp-in-string "[A-Z]" 'downcase slash-fix t))
         (comma-fix (replace-regexp-in-string "," "" upcase-fix t))
         (open-paren-fix (replace-regexp-in-string "\(" "" comma-fix t))
         (close-paren-fix (replace-regexp-in-string "\)" "" open-paren-fix t))
         (percent-fix (replace-regexp-in-string "%" "" close-paren-fix t))
         )
    (concat "#" percent-fix)))



(defun hrefify-toc (toc hrefify)
  (with-temp-buffer
    (insert toc)
    (beginning-of-buffer)

    (while
        (progn
          (when (looking-at "\\*")
            (delete-char 1)
            (replace-string "*" "    " nil (line-beginning-position) (line-end-position))
            (skip-chars-forward " ")
            (insert "- ")

            (let* ((beg (point))
                   (end (line-end-position))
                   (heading (buffer-substring-no-properties
                             beg end)))
              (insert "[[")
              (insert (funcall hrefify heading))
              (insert "][")
              (end-of-line)
              (insert "]]"))
            (= 0 (forward-line 1)))))

    (buffer-substring-no-properties
     (point-min) (point-max))))

(defun flush-subheadings (toc max-stars)
  (with-temp-buffer
    (insert toc)
    (beginning-of-buffer)

    (let ((re "^"))
      (dotimes (i (1+ max-stars))
        (setq re (concat re "\\*")))
      (flush-lines re))

    (buffer-substring-no-properties
     (point-min) (point-max))))

(defun insert-toc ()
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (let ((case-fold-search t))
      ;; find the first heading with the :TOC: tag
      (re-search-forward toc-regexp)
      (forward-line 1)

      ;; remove previous TOC
      (while (looking-at "\\*\\*")
        (delete-region (point) (progn (forward-line 1) (point))))

      (insert (hrefify-toc (flush-subheadings (raw-toc) max-depth) 'hrefify-github))
      )))
