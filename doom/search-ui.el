;;; search-ui.el --- Top search panels for GUI and terminal -*- lexical-binding: t; -*-
;; Use real minibuffer input, preserving Evil search history, preview and n/N.

(after! vertico
  (require 'vertico-buffer)
  (require 'vertico-multiform)
  (setq vertico-buffer-hide-prompt t
        vertico-buffer-display-action
        '(display-buffer-in-side-window
          (side . top) (slot . 0) (window-height . 10)
          (window-parameters . ((no-other-window . t)))))
  (dolist (entry '(("\\`consult-" buffer)
                   ("\\`\\+default/\\(?:search\\|find\\)" buffer)
                   ("\\`\\+vertico/" buffer)))
    (add-to-list 'vertico-multiform-commands entry))
  (add-to-list 'vertico-multiform-categories '(file buffer))
  (vertico-multiform-mode 1))

(defun my/top-evil-search-prompt (&rest _)
  "Display Evil's / or ? input in a compact panel at the top.
Reuse the installed Vertico buffer renderer without enabling completion
for search patterns. Its exit hook restores the layout on RET or cancel."
  (require 'vertico-buffer)
  (when (and (minibufferp) (= (minibuffer-depth) 1))
    (setq-local vertico--candidates-ov (make-overlay (point-min) (point-min))
                vertico--count-ov nil
                mode-line-format nil)
    (let ((vertico-buffer-display-action
           '(display-buffer-in-side-window
             (side . top) (slot . 0) (window-height . 3)
             (window-parameters . ((no-other-window . t)))))
          (vertico-buffer-hide-prompt t))
      (vertico-buffer--setup))))

(after! evil
  (advice-add 'evil-ex-search-start-session :after #'my/top-evil-search-prompt))

(provide 'search-ui)
;;; search-ui.el ends here
