;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ===============================
;; Tema ve Line Numbers
;; ===============================
(setq doom-theme 'doom-one)
(setq display-line-numbers-type 'relative)

;; ===============================
;; Org files
;; ===============================
(setq org-directory "~/org/")

;; ===============================
;; Treemacs / vterm toggle
;; ===============================
(map! :leader
      :desc "Treemacs Toggle"
      "e" #'treemacs)

(map! :leader
      :desc "VTerm Toggle"
      "j" #'vterm)

;; ===============================
;; Doom Modeline - estetik, küçük, ikonlu ve saatli
;; ===============================
(setq doom-modeline-height 14
      doom-modeline-bar-width 3
      doom-modeline-icon t
      doom-modeline-major-mode-icon t
      doom-modeline-minor-modes nil
      doom-modeline-enable-word-count t
      doom-modeline-buffer-file-name-style 'relative-to-project
      doom-modeline-project-detection 'projectile
      doom-modeline-github nil
      doom-modeline-gnus nil
      doom-modeline-irc nil
      doom-modeline-lsp t
      doom-modeline-buffer-state-icon t
      doom-modeline-buffer-modification-icon t
      doom-modeline-buffer-encoding t
      doom-modeline-major-mode-color-icon t
      doom-modeline-env-enable-time t)

(display-time-mode 1)
(setq display-time-format "%H:%M")
(doom-modeline-mode 1)

;; ===============================
;; Font ayarları - P052
;; ===============================
(setq doom-font (font-spec :family "P052"
                            :size 15
                            :weight 'bold
                            :slant 'italic
                            :width 'normal
                            :scalable t))

;; ===============================
;; Kod renkleri ve font-lock
;; ===============================
(custom-set-faces!
 '(font-lock-builtin-face :foreground "#fd007f" :weight bold :slant italic)
 '(font-lock-function-name-face :foreground "#f6ff00" :weight bold :slant italic)
 '(font-lock-variable-name-face :foreground "#95ff00")
 '(font-lock-string-face :foreground "#ff6fcf")
 '(font-lock-comment-face :foreground "#FFD700" :slant italic)
 '(font-lock-keyword-face :foreground "#fd007f" :weight bold)
 '(font-lock-type-face :foreground "#00fcfc" :weight bold)
 '(default :foreground "#E6D3B8"))

(add-hook 'prog-mode-hook
          (lambda ()
            (rainbow-delimiters-mode 1)
            (font-lock-mode 1)))

;; Satır numaraları renklendirme
(custom-set-faces
 '(line-number ((t (:foreground "#00ff00"))))
 '(line-number-current-line ((t (:foreground "#ff7700" :weight bold)))))

;; Aktif satır
(global-hl-line-mode 1)

;; İmleç renkleri
(setq evil-normal-state-cursor '(box "#ff7700"))
(setq evil-insert-state-cursor '(bar "#ff7700"))
(setq evil-visual-state-cursor '(box "#ff7700"))

;; ===============================
;; Tab ve indent ayarları
;; ===============================
(setq-default tab-width 4
              evil-shift-width 4
              indent-tabs-mode nil
              tab-always-indent 'complete)

(defun my-indent-or-complete ()
  "TAB basınca önce indent yap, gerekiyorsa completion tetikle."
  (interactive)
  (if (looking-at "\\_>")
      (company-indent-or-complete-common)
    (indent-for-tab-command)))

(define-key evil-insert-state-map (kbd "TAB") 'my-indent-or-complete)

;; C/C++ blok girintisi
(add-hook 'c-mode-common-hook
          (lambda ()
            (setq c-basic-offset 4)
            (local-set-key (kbd "TAB") 'c-indent-line-or-region)))

;; ===============================
;; LSP Mode (C/C++)
;; ===============================
(use-package! lsp-mode
  :hook (c-mode . lsp)
  :commands lsp)

;; Flycheck
(use-package! flycheck
  :hook (prog-mode . flycheck-mode)
  :config
  (setq flycheck-highlighting-mode 'lines
        flycheck-indication-mode 'right-fringe))

;; Completion/snippet çakışması
(setq company-idle-delay nil)
(setq yas-trigger-key "C-c y")

;; ===============================
;; Modern Completion: Vertico + Consult + Orderless
;; ===============================
;; Vertico (completion UI)
(use-package! vertico
  :init
  (vertico-mode 1))

;; Orderless (flexible completion style)
(use-package! orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))

;; Consult (gelişmiş arama ve navigation)
(use-package! consult
  :bind (("C-s" . consult-line)       ;; buffer içinde arama
         ("C-r" . consult-line)       ;; geriye arama
         :map minibuffer-local-map
         ("C-r" . consult-history)))  ;; minibuffer history

;; Ripgrep ile proje çapında arama
(map! :leader
      :desc "Ripgrep Search"
      "s r" #'consult-ripgrep)
