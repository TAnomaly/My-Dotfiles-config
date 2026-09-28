;;; personal.el --- personal overrides -*- lexical-binding: t; -*-
;;
;; Loaded LAST from config.el via `(load! "personal")'.  Everything personal
;; lives here so it survives config.el clobbers (this file is never opened/
;; edited, like packages.el).  Loading last also overrides a stale config.el.

;;; --- Theme -----------------------------------------------------------------
;; gits (~/.doom.d/themes/gits-theme.el = Ghost in the Shell paleti, tugmonokai
;; yapısı) is the BASE theme.  It must be `doom-theme' so any theme reload —
;; notably the lsp-ui-doc child frame — reloads it instead of burying it under
;; doom-one.  Önceki Monokai görünümü: ~/.local/share/gits-theme/revert.sh
;; (tugmonokai-theme.el duruyor).  SENTINEL: personal.el.sentinel.bak.
(setq doom-theme 'gits)

;;; --- Font: nvim/alacritty eşleşmesi ------------------------------------------
;; Alacritty (nvim'in gördüğü): FiraCode Nerd Font SemBd, 11pt.  Buradaki aile
;; adı fc-list ile birebir olmalı — "JetBrains Mono Nerd Font" diye bir aile YOK
;; (kurulusu "JetBrainsMono", boşluksuz); eski değer bu yüzden hiç yüklenmiyordu.
;; :size tam sayı = piksel, ondalık = punto; 11.0 = alacritty'nin 11pt'si.
;; Regular taban = ghostty (font-thicken=false) ile aynı kalınlık; tema
;; face'lerindeki :weight bold üstüne gerçek Bold basar.  doom-symbol-font nerd-icons için.
(setq doom-font            (font-spec :family "FiraCode Nerd Font" :size 11.0 :weight 'regular)
      doom-big-font        (font-spec :family "FiraCode Nerd Font" :size 18.0 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "FiraCode Nerd Font" :size 11.0 :weight 'regular)
      doom-symbol-font     (font-spec :family "Symbols Nerd Font Mono"))

;;; --- Icons: nerd-icons (uses the Nerd Font above) --------------------------
;; nerd-icons draws from the installed Nerd Font (NFM.ttf / JetBrains NF), so no
;; separate icon fonts needed (unlike all-the-icons).  Consistent everywhere.
(use-package! nerd-icons
  :config (setq nerd-icons-font-family "Symbols Nerd Font Mono"))
(use-package! nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))
(use-package! nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))
(use-package! nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))
(use-package! treemacs-nerd-icons
  :after (treemacs nerd-icons)
  :config (treemacs-load-theme "nerd-icons"))

;;; --- Dirvish: modern file browser (beyond treemacs / treesitter) -----------
;; Ranger-style file manager with a live preview pane (code/image/pdf), git
;; state and nerd-icons.  Rides on top of dired (overrides it globally).
;; SPC o d = full window, SPC o D = sidebar.  Inside: TAB peek subtree, a attrs.
(use-package! dirvish
  :init (dirvish-override-dired-mode)
  :config
  (setq dirvish-attributes '(nerd-icons file-time file-size collapse subtree-state vc-state git-msg)
        ;; yan panel = nvim explorer: ok işaretli klasörler, `a|b' birleştirme yok
        dirvish-side-attributes '(nerd-icons subtree-state vc-state)
        dirvish-mode-line-height 25
        dirvish-header-line-height 25
        dirvish-use-header-line 'global
        dirvish-default-layout '(0 0.4 0.6))
  ;; yan panelde modeline yok (nvim explorer gibi; treemacs'te de yoktu)
  (add-hook 'dirvish-setup-hook
            (defun my/dirvish-side-no-modeline ()
              (when-let* ((dv (dirvish-curr)) ((eq (dv-type dv) 'side)))
                (setq mode-line-format nil)))))

;; Yan panel genişliği içeriğe uyar (treemacs'teki ile aynı dert: TTY'de sığmayan
;; ad `foo.cp$' diye kırpılıyor).  Alt sınır `dirvish-side-width', üst sınır 60.
(defvar my/dirvish-side-max-width 60 "Dirvish yan panel otomatik genişlik üst sınırı.")
(defvar my/dirvish-side--fit-key nil "Son ölçülen (buffer . tick).")
(defun my/dirvish-side--fit-now ()
  "Yan paneli görünen en uzun satıra göre genişlet/daralt."
  (when-let* ((win (dirvish-side--session-visible-p)))
    (with-selected-window win
      (let ((window-size-fixed nil))
        (cl-flet ((set-width (w) (ignore-errors
                                   (enlarge-window-horizontally (- w (window-width))))))
          ;; Görünen genişlik `window-text-pixel-size' ile ölçülür (gizli `ls'
          ;; sütunlarını saymaz, ikon/ok overlay'lerini sayar) ama kırpılmış
          ;; satırda pencere eninde tıkanır → önce üst sınıra aç, ölç, sonra ayarla.
          ;; İkisi de redisplay'siz art arda; ekrana yalnızca son hali çizilir.
          (set-width my/dirvish-side-max-width)
          (let ((longest (/ (car (window-text-pixel-size win (point-min) (point-max)))
                            (frame-char-width))))
            ;; +2: TTY son sütunu kırpma işaretine ayırır + 1 boşluk
            (set-width (min my/dirvish-side-max-width
                            (max dirvish-side-width (+ longest 2))))))))))
(defun my/dirvish-side-auto-fit ()
  "Panel içeriği değiştiyse genişliği yeniden ayarla.
Ölçüm idle'a ertelenir: komut anında dirvish satırları henüz çizmemiş
(ayrıntılar gizlenmemiş) olabiliyor, erken ölçüm üst sınırda kalıyordu."
  (when-let* (((fboundp 'dirvish-side--session-visible-p))
              (win (dirvish-side--session-visible-p))
              (buf (window-buffer win))
              (key (cons buf (buffer-chars-modified-tick buf)))
              ((not (equal key my/dirvish-side--fit-key))))
    (setq my/dirvish-side--fit-key key)
    (run-with-idle-timer 0.1 nil #'my/dirvish-side--fit-now)))
(after! dirvish-side
  (add-hook 'post-command-hook #'my/dirvish-side-auto-fit))

;;; --- Stop the clobber loop -------------------------------------------------
;; Auto-refresh buffers when their file changes on disk (only when unmodified)
;; so a stale config.el buffer can't silently overwrite changes.
(setq auto-revert-verbose nil)
(global-auto-revert-mode 1)

;;; --- tree-sitter grammars + C++/TS/JS mode wiring --------------------------
;; Doom relocates `user-emacs-directory' to ~/.emacs.d/.local/cache/, so the
;; default grammar search dir misses ~/.emacs.d/tree-sitter/.  Add both paths.
;; Also force full font-lock and auto-install missing grammars (js/ts/tsx).
(after! treesit
  (setq treesit-font-lock-level 4
        treesit-auto-install-grammar 'always)
  (dolist (dir (list (expand-file-name "tree-sitter" doom-emacs-dir)
                     (expand-file-name ".local/etc/tree-sitter" doom-emacs-dir)
                     (expand-file-name "tree-sitter" user-emacs-directory)))
    (when (file-directory-p dir)
      (add-to-list 'treesit-extra-load-path dir)))
  ;; Official sources (Doom modules also register these; keep fallbacks).
  (dolist (entry
           '((c          "https://github.com/tree-sitter/tree-sitter-c" "v0.24.1")
             (cpp        "https://github.com/tree-sitter/tree-sitter-cpp" "v0.23.4")
             ;; Emacs 29 ABI=14 => javascript v0.23.x (v0.25 ABI15 uyumsuz)
             (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "v0.23.1")
             (jsdoc      "https://github.com/tree-sitter/tree-sitter-jsdoc" "v0.23.2")
             (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "v0.23.2" "typescript/src")
             (tsx        "https://github.com/tree-sitter/tree-sitter-typescript" "v0.23.2" "tsx/src")
             (json       "https://github.com/tree-sitter/tree-sitter-json" "v0.24.8")
             (python     "https://github.com/tree-sitter/tree-sitter-python" "v0.23.6")
             (bash       "https://github.com/tree-sitter/tree-sitter-bash" "v0.23.3")
             (html       "https://github.com/tree-sitter/tree-sitter-html" "v0.23.2")
             (css        "https://github.com/tree-sitter/tree-sitter-css" "v0.23.2")
             (yaml       "https://github.com/tree-sitter-grammars/tree-sitter-yaml" "v0.7.0")))
    (cl-pushnew entry treesit-language-source-alist :test #'eq :key #'car)))

;; Header / C++ extensions -> c++-mode (cc +tree-sitter remaps to c++-ts-mode)
(dolist (pair '(("\\.hpp\\'" . c++-mode)
                ("\\.hh\\'"  . c++-mode)
                ("\\.hxx\\'" . c++-mode)
                ("\\.h\\+\\+\\'" . c++-mode)
                ("\\.cc\\'"  . c++-mode)
                ("\\.cxx\\'" . c++-mode)
                ("\\.c\\+\\+\\'" . c++-mode)
                ("\\.ipp\\'" . c++-mode)
                ("\\.tpp\\'" . c++-mode)))
  (add-to-list 'auto-mode-alist pair))

;; TS/JS: +tree-sitter açıkken *-ts-mode kullanılır (typescript-mode paketi yüklenmez)
(add-to-list 'auto-mode-alist '("\\.mjs\\'" . js-mode))
(add-to-list 'auto-mode-alist '("\\.cjs\\'" . js-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'"  . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . tsx-ts-mode))

;;; --- Treesit: default renkte (beyaz) kalan token'lar → Monokai --------------
;; Emacs 29 ts/js modlarında `operator' kuralı var ama feature listesinde yok;
;; değişken kullanımı, namespace, `::', ternary `?' için hiç kural yok → hepsi
;; default fg ile beyaz kalıyordu.  Kurallar SONA eklenir: override'sız olanlar
;; yalnızca modun boyamadığı token'ları boyar.  Her sorgu dile karşı doğrulanır
;; (gramerde olmayan node → o kural atlanır).  Biçim: (OVERRIDE . SORGU).
(defconst my/treesit-ecma-extras
  '(;; JSX < > </ /> : operator pembesi değil bracket grisi
    (t   . ((jsx_opening_element ["<" ">"] @font-lock-bracket-face)))
    (t   . ((jsx_closing_element ["</" ">"] @font-lock-bracket-face)))
    (t   . ((jsx_self_closing_element ["<" "/>"] @font-lock-bracket-face)))
    (nil . ((this) @font-lock-keyword-face))
    (nil . ("=>" @font-lock-operator-face))
    (nil . ("?" @font-lock-operator-face))
    (nil . ("?." @font-lock-operator-face))
    (nil . ((optional_chain) @font-lock-operator-face))
    (nil . ((property_identifier) @font-lock-property-use-face))
    (nil . ((identifier) @font-lock-variable-use-face))
    (nil . ((shorthand_property_identifier) @font-lock-variable-use-face))))
(defconst my/treesit-c-extras
  '((nil . ((namespace_identifier) @font-lock-type-face))
    (nil . ("::" @font-lock-delimiter-face))
    (nil . ((conditional_expression "?" @font-lock-operator-face)))
    (nil . ((preproc_arg) @font-lock-constant-face))
    (nil . ((identifier) @font-lock-variable-use-face))))
(defconst my/treesit-extras
  `((tsx . ,my/treesit-ecma-extras) (typescript . ,my/treesit-ecma-extras)
    (javascript . ,my/treesit-ecma-extras)
    (cpp . ,my/treesit-c-extras) (c . ,my/treesit-c-extras)))

(defun my/treesit-monokai-extras ()
  "Modun boyamadığı token'lar için `my/treesit-extras' kurallarını ekle."
  (when-let* ((parser (car (treesit-parser-list)))
              (lang (treesit-parser-language parser))
              (specs (alist-get lang my/treesit-extras)))
    (dolist (spec specs)
      (when (ignore-errors (treesit-query-compile lang (cdr spec) t))
        (setq-local treesit-font-lock-settings
                    (append treesit-font-lock-settings
                            (treesit-font-lock-rules
                             :language lang :feature 'my-extras
                             :override (car spec)
                             (cdr spec))))))
    ;; son (4.) seviyeye ekle: `treesit-font-lock-level' 4'te etkin olsun
    (setq-local treesit-font-lock-feature-list
                (append (butlast treesit-font-lock-feature-list)
                        (list (delete-dups
                               (append (car (last treesit-font-lock-feature-list))
                                       '(operator my-extras))))))
    (treesit-font-lock-recompute-features)))
(dolist (hook '(c-ts-base-mode-hook typescript-ts-base-mode-hook js-ts-mode-hook))
  (add-hook hook #'my/treesit-monokai-extras))

;;; --- PATH: user-local tools (clang-format, etc.) ----------------------------
;; doom env bazen taze degil; ~/.local/bin her zaman exec-path'te olsun.
(let ((local-bin (expand-file-name "~/.local/bin")))
  (when (file-directory-p local-bin)
    (add-to-list 'exec-path local-bin)
    (setenv "PATH" (concat local-bin path-separator (or (getenv "PATH") "")))))

;;; --- Format on save (apheleia / :editor format +onsave) ---------------------
;; C/C++: clang-format binary yolu. Cift format olmasin diye onceki
;; before-save clang-format-buffer hook'u KALDIRILDI; apheleia yonetiyor.
(after! clang-format
  (setq clang-format-executable
        (or (executable-find "clang-format")
            (executable-find "clang-format-18")
            (let ((p (expand-file-name "~/.local/bin/clang-format")))
              (and (file-executable-p p) p)))))

(after! apheleia
  ;; Binary yoksa C/C++ format sessizce atlanir (apheleia fail-safe).
  (when-let ((cf (or (bound-and-true-p clang-format-executable)
                     (executable-find "clang-format")
                     (executable-find "clang-format-18"))))
    (setf (alist-get 'clang-format apheleia-formatters)
          (list cf "-assume-filename" filepath)))
  ;; Manuel: SPC c f
  (setq +format-on-save-disabled-modes
        '(sql-mode          ; tehlikeli
          org-msg-edit-mode)))

;;; --- Indent guides (indent-bars) --------------------------------------------
(after! indent-bars
  ;; TTY: bitmap yavaş/yok → karakter; monokai gri ton
  (setq indent-bars-prefer-character (not (display-graphic-p))
        indent-bars-starting-column 0
        indent-bars-width-frac 0.2
        indent-bars-color-by-depth nil
        indent-bars-color '(font-lock-comment-face :face-bg nil :blend 0.5)
        indent-bars-highlight-current-depth nil
        indent-bars-display-on-blank-lines 'least)
  (when (not (display-graphic-p))
    (setq indent-bars-prefer-character t)))

;;; --- Zen (odak modu) — TTY'de görünür, basit, güvenilir --------------------
;; Önceki sürüm writeroom/modeline yarışında bozulabiliyordu.
;; Bu sürüm: header-line banner + sekmeler/modeline/linum/pencereler.

(defvar-local my/zen--restore nil
  "Buffer-local snapshot to restore after zen.")

(defun my/zen--kill-side-margins ()
  "Remove left/right empty margins (writeroom / visual-fill-column)."
  ;; Writeroom / visual-fill-column metni ortalar → yanlarda dev boşluk.
  (when (bound-and-true-p writeroom-mode)
    (writeroom-mode -1))
  (when (bound-and-true-p visual-fill-column-mode)
    (visual-fill-column-mode -1))
  (when (bound-and-true-p visual-fill-column-adjust)
    (ignore-errors (visual-fill-column-mode -1)))
  (setq-local visual-fill-column-width nil
              visual-fill-column-center-text nil
              left-margin-width 0
              right-margin-width 0)
  (set-window-margins (selected-window) 0 0)
  (set-window-fringes (selected-window) 0 0)
  (dolist (win (get-buffer-window-list (current-buffer) nil t))
    (set-window-margins win 0 0)
    (set-window-fringes win 0 0)))

(defun my/zen--enter ()
  "Enter zen: hide ALL chrome (no banner), full width, optional Ghostty FS."
  (setq my/zen--restore
        (list :wconf (current-window-configuration)
              :header header-line-format
              :mode-line mode-line-format
              :linum display-line-numbers
              :linum-mode (bound-and-true-p display-line-numbers-mode)
              :tabs-local (bound-and-true-p centaur-tabs-local-mode)
              :indent (bound-and-true-p indent-bars-mode)
              :hide-ml (bound-and-true-p hide-mode-line-mode)
              :truncate truncate-lines
              :visual-line (bound-and-true-p visual-line-mode)
              :vfc (bound-and-true-p visual-fill-column-mode)
              :writeroom (bound-and-true-p writeroom-mode)
              :lm left-margin-width
              :rm right-margin-width
              :fringes (window-fringes)
              :tab-line tab-line-format))
  (delete-other-windows)
  (my/zen--kill-side-margins)
  ;; Üstte HİÇBİR şey: banner yok, tab-line yok, header-line yok
  (setq header-line-format nil
        tab-line-format nil
        mode-line-format nil)
  (when (fboundp 'hide-mode-line-mode)
    (hide-mode-line-mode +1))
  (when (fboundp 'centaur-tabs-local-mode)
    (centaur-tabs-local-mode +1))
  (when (fboundp 'centaur-tabs-mode)
    ;; global tab bar da bu frame'de görünmesin
    (centaur-tabs-local-mode +1))
  (when (fboundp 'display-line-numbers-mode)
    (display-line-numbers-mode -1))
  (setq display-line-numbers nil)
  (when (fboundp 'indent-bars-mode)
    (indent-bars-mode -1))
  (setq truncate-lines nil)
  (visual-line-mode +1)
  (my/zen--kill-side-margins)
  (run-with-timer 0.05 nil #'my/zen--kill-side-margins)
  (force-mode-line-update t)
  (redraw-display)
  (message "ZEN — kapat: SPC z"))

(defun my/zen--exit ()
  "Leave zen and restore previous UI."
  (let ((r my/zen--restore))
    (setq header-line-format (plist-get r :header))
    (setq tab-line-format (plist-get r :tab-line))
    (setq mode-line-format (plist-get r :mode-line))
    (setq display-line-numbers (plist-get r :linum))
    (setq truncate-lines (plist-get r :truncate))
    (setq left-margin-width (or (plist-get r :lm) 0)
          right-margin-width (or (plist-get r :rm) 0))
    (when (fboundp 'hide-mode-line-mode)
      (hide-mode-line-mode (if (plist-get r :hide-ml) 1 -1)))
    (when (fboundp 'display-line-numbers-mode)
      (display-line-numbers-mode (if (plist-get r :linum-mode) 1 -1)))
    (when (fboundp 'centaur-tabs-local-mode)
      (centaur-tabs-local-mode (if (plist-get r :tabs-local) 1 -1)))
    (when (fboundp 'indent-bars-mode)
      (indent-bars-mode (if (plist-get r :indent) 1 -1)))
    (visual-line-mode (if (plist-get r :visual-line) 1 -1))
    (when (fboundp 'visual-fill-column-mode)
      (visual-fill-column-mode (if (plist-get r :vfc) 1 -1)))
    (when (fboundp 'writeroom-mode)
      (writeroom-mode (if (plist-get r :writeroom) 1 -1)))
    (when-let ((w (plist-get r :wconf)))
      (set-window-configuration w))
    (when-let ((f (plist-get r :fringes)))
      (apply #'set-window-fringes (selected-window) f))
    (set-window-margins (selected-window)
                        (or (plist-get r :lm) 0)
                        (or (plist-get r :rm) 0))
    ;; Ghostty fullscreen'deysek çık
    (when (and (plist-get r :ghostty-fs)
               (fboundp 'my/tty-toggle-fullscreen))
      (my/tty-toggle-fullscreen))
    (setq my/zen--restore nil)
    (force-mode-line-update t)
    (redraw-display)
    (message "ZEN KAPALI")))

(defun my/zen-toggle ()
  "Toggle zen (no banner). Does not toggle Ghostty fullscreen."
  (interactive)
  (if my/zen--restore
      (my/zen--exit)
    (my/zen--enter)))

(defun my/zen-fullscreen ()
  "Zen + Ghostty native fullscreen (no titlebar/tabs, no emacs banner)."
  (interactive)
  (if my/zen--restore
      (my/zen--exit)
    (my/zen--enter)
    ;; flag: exit'te fullscreen'i de kapat
    (setq my/zen--restore (plist-put my/zen--restore :ghostty-fs t))
    (when (fboundp 'my/tty-toggle-fullscreen)
      (my/tty-toggle-fullscreen))))

;; Birden fazla yol — biri mutlaka tutsun
(map! :leader
      :desc "Zen mode"         "z"   #'my/zen-toggle
      (:prefix ("t" . "toggle")
       :desc "Zen mode"        "z"   #'my/zen-toggle
       :desc "Zen fullscreen"  "Z"   #'my/zen-fullscreen))
;; NOT: evil ZZ = kaydet-çık — ona dokunma
(map! :g "<f12>" #'my/zen-toggle
      :g "C-c z" #'my/zen-toggle
      :n "g z"   #'my/zen-toggle)  ; normal mode: g z

;; Doom'un kendi +zen/toggle'ını da bizimkine yönlendir
(defalias '+zen/toggle #'my/zen-toggle)
(defalias '+zen/toggle-fullscreen #'my/zen-fullscreen)

;;; --- Direnv -----------------------------------------------------------------
;; Projede .envrc varsa otomatik (direnv kurulu olmali: apt install direnv)
(after! envrc
  (envrc-global-mode +1))

;;; --- Org: journal + roam + capture ------------------------------------------
(setq org-directory (expand-file-name "~/org/")
      org-roam-directory (expand-file-name "roam" org-directory)
      org-journal-dir (expand-file-name "journal" org-directory)
      org-agenda-files (list org-directory
                            (expand-file-name "roam" org-directory)))

(dolist (d (list org-directory org-roam-directory org-journal-dir
                 (expand-file-name "inbox" org-directory)))
  (unless (file-directory-p d)
    (make-directory d t)))

(after! org
  (setq org-startup-indented t
        org-startup-folded 'content
        org-ellipsis " …"
        org-log-done 'time
        org-return-follows-link t
        org-hide-emphasis-markers t
        org-catch-invisible-edits 'show-and-error
        org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAIT(w)" "|" "DONE(d)" "CANCEL(c)"))
        org-capture-templates
        '(("t" "Todo" entry
           (file+headline "~/org/inbox.org" "Tasks")
           "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")
          ("n" "Note" entry
           (file+headline "~/org/inbox.org" "Notes")
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n%i\n")
          ("j" "Journal" entry
           (file+olp+datetree "~/org/journal/journal.org")
           "* %<%H:%M> %?\n"))))

(after! org-journal
  (setq org-journal-file-type 'monthly
        org-journal-date-format "%A, %d %B %Y"
        org-journal-file-format "%Y-%m.org"
        org-journal-enable-agenda-integration t))

(after! org-roam
  (setq org-roam-completion-everywhere t
        org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n\n")
           :unnarrowed t)
          ("p" "project" plain "%?"
           :target (file+head "projects/${slug}.org"
                              "#+title: ${title}\n#+filetags: :project:\n\n")
           :unnarrowed t)))
  (org-roam-db-autosync-mode))

(map! :leader
      (:prefix ("n" . "notes")
       :desc "Org agenda"           "a" #'org-agenda
       :desc "Org capture"          "c" #'org-capture
       :desc "Journal new entry"    "j" #'org-journal-new-entry
       :desc "Roam find node"       "f" #'org-roam-node-find
       :desc "Roam insert node"     "i" #'org-roam-node-insert
       :desc "Roam buffer"          "r" #'org-roam-buffer-toggle
       :desc "Roam capture"         "n" #'org-roam-capture
       :desc "Open org inbox"       "I" (cmd! (find-file "~/org/inbox.org"))
       :desc "Open org directory"   "o" (cmd! (dired org-directory))))

;;; --- LSP: imza/eldoc + TTY uyumu + clangd ----------------------------------
;; config.el imza yardimini aciyordu; burada kapat (echo area susar).
;; emacs -nw: lsp-ui-doc child-frame kullanir => TTY'de bozulur/calismaz.
;; TTY'de doc kapali, sideline diagnostics acik kalsin.
(after! lsp-mode
  (setq lsp-signature-auto-activate nil
        lsp-signature-render-documentation nil
        lsp-eldoc-enable-hover nil
        lsp-eldoc-render-all nil
        lsp-enable-snippet t
        lsp-headerline-breadcrumb-enable (display-graphic-p)
        ;; clangd: compile_commands.json workspace root'ta aransin
        lsp-clients-clangd-args
        '("--clang-tidy"
          "--completion-style=detailed"
          "--header-insertion=iwyu"
          "--function-arg-placeholders=0"
          "--background-index"
          "--pch-storage=memory"
          "--log=error")))

(after! lsp-ui
  (setq lsp-ui-sideline-show-hover nil)
  (unless (display-graphic-p)
    ;; TTY (-nw): popup/doc frame yok — sadece sideline + modeline
    (setq lsp-ui-doc-enable nil
          lsp-ui-doc-show-with-cursor nil
          lsp-ui-doc-show-with-mouse nil
          lsp-ui-sideline-enable t
          lsp-ui-sideline-show-diagnostics t
          lsp-ui-sideline-show-code-actions t
          lsp-ui-sideline-show-hover nil)))
;; Eat/eshell/vterm gibi terminal buffer'larda eldoc zaten gereksiz.

;;; --- vterm: `M-x vterm' bulunduğun pencerede açılsın ------------------------
;; Doom `^\*vterm' buffer'ını alttaki popup'a zorluyordu → :sp/:vsp ile bölüp
;; oraya terminal açılamıyordu.  `SPC t v' (+vterm/toggle) ayrı adlı buffer
;; kullanır (*doom:vterm-popup:*), o alttan açılıp kapanmaya devam eder.
(after! vterm
  (set-popup-rule! "^\\*vterm" :ignore t)
  ;; TUI uygulamalarında copy/paste: terminalin kendi clipboard'ını kullan
  ;; Emacs müdahalesi OLMAZ → Ctrl+Shift+C/V Ghostty'ye gider
  (setq vterm-copy-exclude-prompt t
        vterm-max-scrollback 100000)
  ;; Mouse seçimi terminal programına GİTSİN (Emacs'e almıyoruz)
  (add-hook 'vterm-mode-hook
            (lambda ()
              ;; TUI'ler kendi seçimini yapsın, Emacs mouse'ı）
              (setq-local mouse-yank-at-point t)))
  ;; vterm'de Emacs剪贴板介入lerini DEVRE DIŞI bırak
  ;; Böylece Ctrl+Shift+C/V → Ghostty terminal clipboard → TUI uygulaması
  (map! :map vterm-mode-map
        ;; Bu tuşları Emacs'e DEĞIL, terminale ilet
        "C-S-c" nil
        "C-S-v" nil))

;;; --- AI CLIs in eat (claude / opencode) ------------------------------------
;; eat yerine vterm kullaniyorduk; vterm tam-ekran TUI'de yukari/asagi kaydirmayi
;; bozuyordu.  eat ciktiyi Emacs buffer'ina yazar => fare tekeri dogrudan kaydirir,
;; klavye ile okumak icin `C-c C-e' (Emacs modu) -> normal/evil hareket -> `C-c C-j'
;; ile yaziya don.

;; Daemon systemd/gnome-session'dan baslar (INVOCATION_ID var) => PATH'te node YOK,
;; eat "claude"/"opencode" komutunu bulamaz.  nvm'in EN YENI node bin'ini exec-path'e
;; ekle (sürüm degisince kendi bulur; hard-code yok).
(let* ((nvm-node-dir (expand-file-name "~/.config/nvm/versions/node/"))
       (versions (and (file-directory-p nvm-node-dir)
                      (sort (directory-files nvm-node-dir nil "^v[0-9]") #'string<)))
       (bin (and versions
                 (expand-file-name (concat (car (last versions)) "/bin") nvm-node-dir))))
  (when (and bin (file-directory-p bin))
    (add-to-list 'exec-path bin)
    (setenv "PATH" (concat bin path-separator (getenv "PATH")))))
;; opencode CLI'ı ~/.opencode/bin altında; daemon PATH'i kaynaklamadığından
;; burada da eklememiz gerekiyor.
(let ((opencode-bin (expand-file-name "~/.opencode/bin")))
  (when (file-directory-p opencode-bin)
    (add-to-list 'exec-path opencode-bin)
    (setenv "PATH" (concat opencode-bin path-separator (getenv "PATH")))))

(after! eat
  (setq eat-kill-buffer-on-exit t          ; komut cikinca buffer'i temizle
        eat-term-scrollback-size 400000    ; bol scrollback
        eat-enable-yank-to-terminal t      ; terminal programi kill-ring'i OKUYABILIR (OSC 52 izni; keybinding DEGIL)
        eat-enable-kill-from-terminal t    ; terminalde secilen kill-ring'e gider
        eat-term-fast-prefix-prefix t)     ; hizli terminal cikti isleme
  ;; eat buffer'inda evil'i KAPAT (emacs state)
  (evil-set-initial-state 'eat-mode 'emacs)
  ;; TERM: eat-truecolor'i programlar tanimaz → xterm-256color
  (setq eat-term-name "xterm-256color")
  ;; Paste: eat'in kendi yank'i (bracketed paste modu ile TUI uyumlu)
  (define-key eat-semi-char-mode-map (kbd "C-S-v") #'eat-yank)
  ;; :q ile çıkış
  (evil-define-key 'normal eat-mode-map
    (kbd ":q") (lambda () (interactive) (kill-buffer-and-window))))

(defun my/eat-cli (bufname cmd &rest args)
  "Pop to an eat terminal BUFNAME running CMD with ARGS; reuse the buffer if it exists.
Deterministik vsp: CLI zaten görünüyorsa o pencereye ODAKLAN (tekrar bölme);
değilse sağa TEK dikey bölme aç ve eat buffer'ını oraya koy.  Eski `pop-to-buffer'
bazen kod penceresini yeniden kullanıp aynı kodu ikinci kez gösteriyordu."
  (require 'eat)
  (let ((buf (get-buffer bufname)))
    (unless (buffer-live-p buf)
      (setq buf (get-buffer-create bufname))
      (with-current-buffer buf
        (unless (eq major-mode 'eat-mode) (eat-mode))
        (eat-exec buf bufname cmd nil args)))
    (let ((win (get-buffer-window buf)))
      (if win
          (select-window win)                       ; zaten açık => sadece odaklan
        (select-window (split-window (selected-window) nil 'right))
        (set-window-buffer (selected-window) buf))))) ; sağ vsp'ye eat buffer'ı

(defun claude ()
  "Open Claude Code in an eat terminal."
  (interactive)
  ;; ~/.claude/settings.json `tui = fullscreen' (alt-screen renderer) eat'te teker
  ;; kaydirmayi bozar: scrollback buffer'a yazilmaz (buffer = ekran kadar) ve eat
  ;; fareyi claude'a iletir (eat--mouse-grabbing-type = :all) => teker Emacs
  ;; buffer'ini kaydirmaz.  eat icinde klasik renderer'a zorla; Ghostty/tmux'ta
  ;; dogrudan acilan claude fullscreen kalir.
  (my/eat-cli "*claude*" "claude" "--settings" "{\"tui\":\"default\"}"))

(defun opencode ()
  "Open opencode in an eat terminal."
  (interactive)
  (my/eat-cli "*opencode*" "opencode"))

(defun codex ()
  "Open OpenAI Codex in an eat terminal."
  (interactive)
  (my/eat-cli "*codex*" "codex"))

;; Vim alışkanlığı `:claude` M-x'e DÜŞMEZ — evil ex komutları ayrı tabloda
;; yaşar ("Unknown command" sebebi buydu).  İkisi de çalışsın.
(after! evil
  (evil-ex-define-cmd "claude"   #'claude)
  (evil-ex-define-cmd "opencode" #'opencode)
  (evil-ex-define-cmd "codex"    #'codex))

;;; --- TUI: clipboard + mouse --------------------------------------------------
;; gnome-terminal hissi: evil yank/delete doğrudan X panosuna, `p`/C-y panodan
;; okur (xclip; OSC 52'ye güvenme — VTE desteklemez).  xterm-mouse: tıkla/seç/
;; tekerlek Emacs'e gider; terminalin KENDİ seçimi gerekirse Shift+drag +
;; Ctrl+Shift+C hâlâ çalışır.
(defun my/tty-extras ()
  (xterm-mouse-mode 1)
  (when (executable-find "xclip")
    (xclip-mode 1)))
(add-hook 'tty-setup-hook #'my/tty-extras)

;;; --- Split pencere: fareyle büyüt/küçült ------------------------------------
;; Sorun: doom-modeline her segmentte local-map koyuyor → mode-line
;; `down-mouse-1' = mouse-drag-mode-line hiç tetiklenmiyor.
;; Çözüm: modeline sonunda turuncu "tutamaç" + dikey çizgi bağları.
(defun my/bind-window-mouse-resize ()
  "Ensure mouse can drag window edges (mode-line / vertical bar)."
  (global-set-key [mode-line down-mouse-1]     #'mouse-drag-mode-line)
  (global-set-key [mode-line mouse-1]          #'mouse-select-window)
  (global-set-key [mode-line S-down-mouse-1]   #'mouse-drag-mode-line)
  (global-set-key [bottom-divider down-mouse-1] #'mouse-drag-mode-line)
  (global-set-key [vertical-line down-mouse-1] #'mouse-drag-vertical-line)
  (global-set-key [vertical-line mouse-1]      #'mouse-select-window)
  (global-set-key [vertical-line S-down-mouse-1] #'mouse-drag-vertical-line)
  (global-set-key [right-divider down-mouse-1] #'mouse-drag-vertical-line)
  (global-set-key [left-divider down-mouse-1]  #'mouse-drag-vertical-line))
(my/bind-window-mouse-resize)
(add-hook 'doom-after-init-hook #'my/bind-window-mouse-resize)

;; Dikey/yatay ayırıcılar (GUI + TTY kenar tıklaması)
(setq window-divider-default-places t
      window-divider-default-right-width 2
      window-divider-default-bottom-width 1)
(window-divider-mode 1)

(after! doom-modeline
  (doom-modeline-def-segment resize-grip
    "Mode-line tutamacı: sürükleyerek pencere yüksekliğini değiştir."
    (propertize
     (if (char-displayable-p ?↕) " ↕ " " = ")
     'help-echo "Sürükle: pencere yüksekliğini değiştir (yatay split)\nDikey split için pencereler arasındaki | çizgisini sürükle"
     'face '(:foreground "#00f0e0" :weight bold)
     'mouse-face 'mode-line-highlight
     'local-map (let ((map (make-sparse-keymap)))
                  (define-key map [mode-line down-mouse-1] #'mouse-drag-mode-line)
                  (define-key map [mode-line mouse-1] #'ignore)
                  (define-key map [mode-line S-down-mouse-1] #'mouse-drag-mode-line)
                  map)))
  ;; Ana modeline'ların sağına tutamacı ekle
  (doom-modeline-add-segment 'resize-grip 'time :after 'main)
  (doom-modeline-add-segment 'resize-grip 'time :after 'special)
  (doom-modeline-add-segment 'resize-grip 'time :after 'vcs)
  (doom-modeline-add-segment 'resize-grip 'time :after 'info)
  ;; time yoksa major-mode'dan sonra dene
  (doom-modeline-add-segment 'resize-grip 'major-mode :after 'minimal))

;; Klavye ile resize (fare yoksa / TTY)
(map! :leader
      (:prefix ("w" . "windows")
       :desc "Shrink window height"  "-" #'shrink-window
       :desc "Enlarge window height" "+" #'enlarge-window
       :desc "Shrink window width"   "<" #'shrink-window-horizontally
       :desc "Enlarge window width"  ">" #'enlarge-window-horizontally
       :desc "Balance windows"       "=" #'balance-windows))

;;; --- TUI: fullscreen (Ghostty native — üst titlebar GİZER) -----------------
;; F11 → Ghostty toggle_fullscreen (titlebar/tab yok).
;; Emacs F11'i yutmasın; yutarsa bile Ghostty key'ine çevir.
(defun my/tty-toggle-fullscreen ()
  "Toggle Ghostty-native fullscreen (hides titlebar), or GUI frame fullscreen."
  (interactive)
  (cond
   ((display-graphic-p)
    (toggle-frame-fullscreen))
   ((executable-find "xdotool")
    ;; Alt+Enter = Ghostty toggle_fullscreen (F11 ile çift-toggle olmasın)
    (call-process "xdotool" nil nil nil "key" "--clearmodifiers" "alt+Return"))
   (t
    (user-error "TTY fullscreen: xdotool yok"))))

;; F11: SADECE Ghostty fullscreen — split'ler/modeline aynen kalır.
;; (Zen + fullscreen istersen SPC t F; zen tek başına F12 / SPC z.)
(map! :g "<f11>" #'my/tty-toggle-fullscreen
      :leader
      :desc "Zen + fullscreen" "t F" #'my/zen-fullscreen)

;;; --- TUI: imleç rengi + şekil (evil state) --------------------------------
;; Terminalde imleci Emacs değil terminal çizer; `cursor' face'i sadece GUI'de
;; geçerli — TUI'de bu yüzden beyaz kalıyordu.  OSC 12 ile terminale rengi
;; gönder (ghostty/alacritty/kitty/xterm); çıkışta OSC 112 ile sıfırla.
;;
;; Shape: Doom zaten evil-insert-state-cursor = bar set eder, ama
;; evil-terminal-cursor-changer Ghostty'yi tanımıyor (sadece xterm/kitty/...).
;; Override → DECSCUSR (CSI Ps SP q) gönderilsin: insert=bar, normal=box.
(after! evil
  (setq evil-normal-state-cursor 'box
        evil-insert-state-cursor 'bar   ; ⎸ — blok değil
        evil-visual-state-cursor 'box
        evil-replace-state-cursor 'hbar
        evil-operator-state-cursor 'hollow
        evil-emacs-state-cursor 'bar
        evil-motion-state-cursor 'box))

(after! evil-terminal-cursor-changer
  ;; ghostty / alacritty / wezterm: xterm DECSCUSR yeterli
  (setq etcc-term-type-override 'xterm
        etcc-use-blink nil)             ; sabit bar (yanıp sönmesin)
  (unless (display-graphic-p)
    (evil-terminal-cursor-changer-activate)))

(defun my/tty-cursor-color ()
  (send-string-to-terminal "\e]12;#00f0e0\a"))
(add-hook 'tty-setup-hook #'my/tty-cursor-color 90)
(add-hook 'kill-emacs-hook
          (lambda ()
            (unless (display-graphic-p)
              (ignore-errors
                ;; şekli de sıfırla (block) + rengi reset
                (send-string-to-terminal "\e[0 q")
                (send-string-to-terminal "\e]112\a")))))

;;; --- GUI: pencere ekranı kaplayarak açılsın ---------------------------------
;; Varsayılan çerçeve 88x39 (816x756 px) açılıyordu → 1920x1080'de minik.
;; initial = ilk pencere, default = sonradan açılanlar (`emacsclient -c').
;; TTY'de etkisiz.  Gerçek tam ekran (başlık çubuksuz) hâlâ F11.
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;;; --- GUI: frameless window with comfortable inner spacing ------------------
(defun my/apply-gui-window-style (&optional frame)
  "Hide decorations and add 12px padding to top-level graphical FRAME."
  (let ((frame (or frame (selected-frame))))
    (when (and (display-graphic-p frame)
               (not (frame-parent frame))
               (not (eq (frame-parameter frame 'minibuffer) 'only)))
      (modify-frame-parameters frame
                               '((undecorated . t)
                                 (internal-border-width . 12))))))
(add-hook 'after-make-frame-functions #'my/apply-gui-window-style)
(add-hook 'window-setup-hook #'my/apply-gui-window-style)
(dolist (frame (frame-list))
  (my/apply-gui-window-style frame))

;;; --- Background transparency (GTK/X11 daemon) ------------------------------
;; ARGB visual is chosen at frame creation, so the value must live in
;; `default-frame-alist'; setting it on an existing opaque frame is a no-op.
;; New frames (`emacsclient -c') or a daemon restart pick it up.
(defvar my/alpha-bg 90 "Background opacity (percent); alacritty'den (96) biraz daha şeffaf.")
(add-to-list 'default-frame-alist `(alpha-background . ,my/alpha-bg))
(defun my/apply-alpha-bg (&optional frame)
  (set-frame-parameter frame 'alpha-background my/alpha-bg))
(add-hook 'after-make-frame-functions #'my/apply-alpha-bg)
(defun my/toggle-transparency ()
  "Toggle background transparency on the current frame."
  (interactive)
  (let ((a (frame-parameter nil 'alpha-background)))
    (set-frame-parameter nil 'alpha-background
                         (if (and a (< a 100)) 100 my/alpha-bg))))

;;; --- Keybindings -----------------------------------------------------------
(map! :leader
      (:prefix ("t" . "toggle")
       :desc "Toggle transparency" "T" #'my/toggle-transparency
       :desc "Clear syntax glow borders" "g" #'my/toggle-syntax-glow
       ;; explorer = dirvish yan panel (config.el'de treemacs'ti; o hâlâ SPC o p)
       :desc "Toggle explorer (dirvish)" "f" #'dirvish-side)
      (:prefix ("o" . "open here")
       :desc "opencode (eat)"       "i" #'opencode
       :desc "Codex (eat)"          "x" #'codex
       :desc "Dirvish (fullscreen)" "d" #'dirvish
       :desc "Dirvish sidebar"      "D" #'dirvish-side)
      (:prefix "c"
       :desc "Claude Code (eat)" "i" #'claude))

;; Vim-style window navigation (LazyVim): C-h/j/k/l move between windows.
;; Normal/visual/motion only, so help (C-h ...) still works in insert/minibuffer.
(map! :nvm "C-h" #'evil-window-left
      :nvm "C-j" #'evil-window-down
      :nvm "C-k" #'evil-window-up
      :nvm "C-l" #'evil-window-right)

;;; --- Ctrl + fare tekeri = zoom (buyut/kucult) ------------------------------
;; Standart zoom hareketi: Ctrl basiliyken tekerlek => yazi olcegi.  control =>
;; text-scale, wheel dogrudan lsp-ui-doc/echo degil buffer fontunu buyutur.
;; C-0 sifirlar.  GUI'de kesin calisir.  TTY'de terminalin KENDISI Ctrl+wheel'i
;; kapabilir (alacritty/gnome-terminal kendi fontunu zoomlar) — o zaman terminal
;; ayarindan devre disi birak ya da C-+/C-- kullan.
(setq mouse-wheel-scroll-amount '(1 ((shift) . 5) ((control) . text-scale)))
(global-set-key (kbd "C-<wheel-up>")   #'text-scale-increase)
(global-set-key (kbd "C-<wheel-down>") #'text-scale-decrease)
(global-set-key (kbd "C-<mouse-4>")    #'text-scale-increase)  ; TTY tekerlek yukari
(global-set-key (kbd "C-<mouse-5>")    #'text-scale-decrease)  ; TTY tekerlek asagi
(global-set-key (kbd "C-0")            #'text-scale-adjust)     ; sifirla

;;; --- Modeline: NvChad-style modal indicator with TEXT letters --------------
;; modal-icon nil => show evil state as text tag instead of a single nerd-font
;; glyph.  Tag = lualine `mode' fmt str:sub(1,1): tek harf (N/I/V/R/O/M/E).
(after! doom-modeline
  (setq doom-modeline-modal t
        doom-modeline-modal-icon nil))
(after! evil
  (setq evil-normal-state-tag   " N "
        evil-insert-state-tag   " I "
        evil-visual-state-tag   " V "
        evil-replace-state-tag  " R "
        evil-operator-state-tag " O "
        evil-motion-state-tag   " M "
        evil-emacs-state-tag    " E "))

;;; --- nvim-look: LazyVim görünümü TUI'de -------------------------------------
;; Spec: docs/superpowers/specs/2026-09-17-nvim-look-design.md
;; snacks explorer / lualine / gitsigns / bufferline / dashboard eşlenikleri.

;; 1) Explorer — treemacs ≈ snacks explorer: │ indent guide, git durumu, panelde
;;    mode-line yok.  (Git harf sütunu treemacs'te yok; renk yeterli.)
(after! treemacs
  (setq treemacs-indent-guide-style 'line
        treemacs-user-mode-line-format 'none
        treemacs-width 32
        treemacs-show-cursor nil
        treemacs-move-forward-on-expand t)
  (treemacs-indent-guide-mode 1)
  (treemacs-git-mode 'deferred))

;;    Genişlik içeriğe uyar: sabit 32 sütunda sığmayan ad TTY kırpma işaretiyle
;;    `foo.cp$' görünüyordu.  Alt sınır `treemacs-width', üst sınır aşağıda.
(defvar my/treemacs-max-width 60 "Treemacs otomatik genişlik üst sınırı (sütun).")
(defvar my/treemacs--fit-tick nil "Son ölçülen (buffer . tick); değişmediyse ölçme.")
(defun my/treemacs-auto-fit ()
  "Treemacs penceresini en uzun satıra göre genişlet/daralt."
  (when-let* (((fboundp 'treemacs-get-local-window))
              (win (treemacs-get-local-window))
              (buf (window-buffer win))
              (key (cons buf (buffer-chars-modified-tick buf)))
              ((not (equal key my/treemacs--fit-tick))))
    (setq my/treemacs--fit-tick key)
    (with-selected-window win
      (let ((longest 0))
        (save-excursion
          (goto-char (point-min))
          (while (not (eobp))
            (end-of-line)
            (setq longest (max longest (current-column)))
            (forward-line 1)))
        ;; +2: TTY son sütunu kırpma/devam işaretine ayırır + 1 boşluk
        (treemacs--set-width (min my/treemacs-max-width
                                  (max treemacs-width (+ longest 2))))))))
(after! treemacs
  (add-hook 'post-command-hook #'my/treemacs-auto-fit))

;; 2) Statusline — doom-modeline `main' lualine düzeninde:
;;    [mod] branch +N ~N -N  ⚠  │ dosya ●   …   ft  satır:sütun %  saat  ↕
;;    İnce + flat (radius face ile yok; çalışma alanı sekmeleri native üst şeritte).
(defun my/slim-modeline-faces (&rest _)
  "Statusline'ı küçült + flat tut; tema reload'da (lsp-ui doc) yeniden uygula."
  (dolist (f '(mode-line mode-line-active mode-line-inactive))
    (when (facep f)
      (set-face-attribute f nil :box nil :height 0.9))))
(my/slim-modeline-faces)
(add-hook 'doom-load-theme-hook #'my/slim-modeline-faces 95)
(after! doom-modeline
  (setq doom-modeline-height 20
        doom-modeline-bar-width 2
        doom-modeline-window-width-limit 100
        doom-modeline-buffer-encoding nil
        doom-modeline-enable-word-count nil
        doom-modeline-buffer-file-name-style 'relative-to-project
        doom-modeline-vcs-max-length 24
        doom-modeline-time-icon nil)
  ;; Eski XPM bar cache'ini at; yeni yükseklik/genişlikte yeniden çiz.
  (doom-modeline-refresh-bars)
  ;; Doom size-indication'ı init sonunda açar → en sona bizim -1 (matches segmenti "9.8k" basıyordu)
  (add-hook 'doom-after-init-hook (lambda () (size-indication-mode -1)) 100)
  ;; gitsigns/lualine "diff": diff-hl overlay'lerini say (ucuz, her redisplay'de OK)
  (doom-modeline-def-segment git-diff
    "Git hunk sayaçları: +ekleme ~değişiklik -silme (diff-hl)."
    (when (and (bound-and-true-p diff-hl-mode) buffer-file-name)
      (let ((add 0) (chg 0) (del 0))
        (dolist (ov (overlays-in (point-min) (point-max)))
          (pcase (overlay-get ov 'diff-hl-hunk-type)
            ('insert (cl-incf add))
            ('change (cl-incf chg))
            ('delete (cl-incf del))))
        (when (> (+ add chg del) 0)
          (concat " "
                  (and (> add 0) (propertize (format "+%d " add) 'face '(:foreground "#00ff9f" :weight bold)))
                  (and (> chg 0) (propertize (format "~%d " chg) 'face '(:foreground "#ff7a00" :weight bold)))
                  (and (> del 0) (propertize (format "-%d " del) 'face '(:foreground "#ff2b2b" :weight bold))))))))
  ;; Tab-bar (çalışma alanı) sekmeleri: statusline'da değil — native üst şerit (§6).
  (doom-modeline-def-modeline 'main
    '(eldoc bar window-number modals matches follow vcs git-diff check buffer-info remote-host selection-info)
    '(compilation objed-state misc-info persp-name grip debug repl lsp process major-mode buffer-position time resize-grip)))

;; 3) Transparanlık (TTY) — t: arka planı terminale bırak (ghostty bg #081014,
;;    `background-opacity' düşürülürse cam efekti).  nil: opak `my/tty-bg'
;;    (ghostty bg #081014 ile birebir).  SPC t T: `my/toggle-transparency'.
(defvar my/tty-bg "#081014" "TTY opak zemin; ghostty `background' (#081014) ve gits-theme `bg' ile aynı olmalı.")
(defvar my/tty-transparent nil "TTY'de Emacs arka planı terminalden mi devralınsın.")
(defun my/tty-transparent-faces (&rest _)
  "TTY: `my/tty-transparent' ise ilgili face'lerin arka planını terminale bırak."
  (unless (display-graphic-p)
    (dolist (f '(default line-number line-number-current-line fringe vertical-border
                 solaire-default-face solaire-fringe-face solaire-line-number-face
                 diff-hl-margin-insert diff-hl-margin-delete diff-hl-margin-change))
      (when (facep f)
        (set-face-background f (if my/tty-transparent "unspecified-bg" my/tty-bg))))))
(add-hook 'tty-setup-hook #'my/tty-transparent-faces 95)
(add-hook 'doom-load-theme-hook #'my/tty-transparent-faces 95)
(defun my/toggle-transparency ()
  "GUI: alpha-background toggle.  TTY: arka planı terminale bırak / opak yap."
  (interactive)
  (if (display-graphic-p)
      (let ((a (frame-parameter nil 'alpha-background)))
        (set-frame-parameter nil 'alpha-background
                             (if (and a (< a 100)) 100 my/alpha-bg)))
    (setq my/tty-transparent (not my/tty-transparent))
    (my/tty-transparent-faces)
    (message "TTY transparency: %s" (if my/tty-transparent "on" "off"))))

;; 3b) Keep the neon syntax colors configured below, without literal `:box'
;; borders.  Font-lock faces are shared by code, dashboard and recent-file
;; lists, so boxing them also draws borders in those unrelated views.
(defvar my/syntax-glow-faces
  '(font-lock-keyword-face font-lock-operator-face font-lock-preprocessor-face
    font-lock-function-name-face font-lock-function-call-face
    font-lock-type-face font-lock-type-definition-face font-lock-builtin-face
    font-lock-string-face font-lock-constant-face font-lock-number-face
    font-lock-variable-name-face font-lock-property-name-face)
  "Syntax faces whose box borders should stay disabled.")

(defun my/clear-syntax-glow (&optional frame)
  "Remove box borders from syntax faces, optionally only on FRAME."
  (dolist (fr (frame-list))
    (when (or (null frame) (eq fr frame))
      (dolist (face my/syntax-glow-faces)
        (when (facep face)
          (set-face-attribute face fr :box nil))))))

;; Keep the old command name safe for existing keymaps and sessions.  Neon
;; foreground colors stay enabled; this command only clears literal borders.
(defun my/toggle-syntax-glow (&optional frame)
  (interactive)
  (my/clear-syntax-glow frame)
  (message "Neon syntax colors on; box borders cleared"))

(defun my/apply-syntax-glow (&optional frame)
  "Compatibility entry point: retain neon colors and clear glow boxes."
  (my/clear-syntax-glow frame))

(remove-hook 'doom-load-theme-hook #'my/apply-syntax-glow)
(remove-hook 'after-make-frame-functions #'my/apply-syntax-glow)
(add-hook 'doom-load-theme-hook #'my/clear-syntax-glow 95)
(add-hook 'after-make-frame-functions #'my/clear-syntax-glow)


;; 4) Gutter + numaralar — gitsigns: sol margin'de ▎ (TTY'de fringe yok);
;;    nvim `number relativenumber'.
(setq display-line-numbers-type 'relative)
(defun my/tty-diff-hl-margin ()
  (unless (display-graphic-p)
    (after! diff-hl
      (require 'diff-hl-margin)            ; margin face'leri burada tanımlı
      (setq diff-hl-margin-symbols-alist
            '((insert . "▎") (delete . "▁") (change . "▎")
              (unknown . "▎") (ignored . " ") (reference . " "))
            diff-hl-margin-spec-cache nil)  ; setq :set'i atlar → cache sıfırla
      (set-face-attribute 'diff-hl-margin-insert nil :foreground "#00ff9f" :background 'unspecified :inherit nil)
      (set-face-attribute 'diff-hl-margin-change nil :foreground "#ff7a00" :background 'unspecified :inherit nil)
      (set-face-attribute 'diff-hl-margin-delete nil :foreground "#ff2b2b" :background 'unspecified :inherit nil)
      (diff-hl-margin-mode 1))))
(add-hook 'tty-setup-hook #'my/tty-diff-hl-margin)

;; 5) Kenarlar — nvim WinSeparator: ince │, soluk.
(defun my/tty-borders ()
  (unless (display-graphic-p)
    (unless standard-display-table
      (setq standard-display-table (make-display-table)))
    (set-display-table-slot standard-display-table 'vertical-border
                            (make-glyph-code ?│ 'vertical-border))
    ;; Kırpılan satır sonundaki `$' ve sarılan satırdaki `\' işaretini gizle
    ;; (nvim nowrap gibi: sağ kenarda işaret yok).
    (set-display-table-slot standard-display-table 'truncation (make-glyph-code ?\s))
    (set-display-table-slot standard-display-table 'wrap (make-glyph-code ?\s))
    (set-face-attribute 'vertical-border nil :foreground "#344242" :background 'unspecified)))
(add-hook 'tty-setup-hook #'my/tty-borders)

;; 6) Sekmeler — bufferline: nerd ikon + ● modified, "+" düğmesi yok.
;;    Çalışma alanı (workflow): native üst şerit (tab-bar-show t).
;;    Kod/buffer sekmeleri: editörün üstünde ayrı çubuk (tab-line, §6b).
(require 'tab-bar)
(tab-bar-mode 1)
(customize-set-variable 'tab-bar-show t) ; :set → tab-bar--update-tab-bar-lines → üst şerit görünür

;; 6b) Buffer/kod sekmeleri editörün üstündeki ayrı tab-line çubuğunda.
(defun my/ctab-setup ()
  "Show buffer tabs above the editor, separate from the status line."
  ;; Remove the previous status-line injection in an already running session.
  (advice-remove 'doom-modeline-set-main-modeline #'my/ctab-inject-mode-line)
  (advice-remove 'doom-modeline-set-modeline #'my/ctab-inject-mode-line)
  (let ((segment '(:eval (my/ctab-ml))))
    (setq-default mode-line-format
                  (remove segment (default-value 'mode-line-format)))
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (and (local-variable-p 'mode-line-format)
                   (listp mode-line-format))
          (setq mode-line-format (remove segment mode-line-format))))))
  (when (bound-and-true-p centaur-tabs-mode)
    (centaur-tabs-mode -1))
  (setq centaur-tabs-display-line-format 'tab-line-format)
  (centaur-tabs-mode 1)
  (force-mode-line-update t))
(after! centaur-tabs
  (setq centaur-tabs-set-icons t
        centaur-tabs-icon-type 'nerd-icons
        centaur-tabs-show-new-tab-button nil
        centaur-tabs-modified-marker "●")
  (my/ctab-setup))

;; 7) Dashboard — snacks dashboard: amber EMACS banner + tek tuş menü.
(when (modulep! :ui doom-dashboard)
  ;; config.el eshell'i açar; nil = Doom'un kendi hook'u dashboard'u gösterir
  ;; (`emacs -nw dosya' → sadece dosya; erken set edilirse ikiye bölüyor).
  (setq initial-buffer-choice nil
        +doom-dashboard-banner-padding '(1 . 2)
        +doom-dashboard-functions '(doom-dashboard-widget-banner
                                    doom-dashboard-widget-shortmenu
                                    doom-dashboard-widget-loaded))
  (defun my/dashboard-banner ()
    (let ((banner '("███████╗███╗   ███╗ █████╗  ██████╗███████╗"
                    "██╔════╝████╗ ████║██╔══██╗██╔════╝██╔════╝"
                    "█████╗  ██╔████╔██║███████║██║     ███████╗"
                    "██╔══╝  ██║╚██╔╝██║██╔══██║██║     ╚════██║"
                    "███████╗██║ ╚═╝ ██║██║  ██║╚██████╗███████║"
                    "╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝")))
      (dolist (line banner)
        (insert (+doom-dashboard--center +doom-dashboard--width
                                         (propertize line 'face '(:foreground "#00f0e0" :weight bold)))
                "\n"))))
  (setq +doom-dashboard-ascii-banner-fn #'my/dashboard-banner)
  (setq +doom-dashboard-menu-sections
        '(("Find file"        :icon (nerd-icons-faicon "nf-fa-search" :face 'doom-dashboard-menu-title) :action find-file)
          ("New file"         :icon (nerd-icons-faicon "nf-fa-file" :face 'doom-dashboard-menu-title) :action evil-buffer-new)
          ("Find text"        :icon (nerd-icons-octicon "nf-oct-search" :face 'doom-dashboard-menu-title) :action +default/search-project)
          ("Recent files"     :icon (nerd-icons-octicon "nf-oct-history" :face 'doom-dashboard-menu-title) :action recentf-open-files)
          ("Projects"         :icon (nerd-icons-octicon "nf-oct-briefcase" :face 'doom-dashboard-menu-title) :action projectile-switch-project)
          ("Config"           :icon (nerd-icons-octicon "nf-oct-tools" :face 'doom-dashboard-menu-title) :action doom/open-private-config)
          ("Restore session"  :icon (nerd-icons-octicon "nf-oct-clock" :face 'doom-dashboard-menu-title)
           :when (and (modulep! :ui workspaces) (file-exists-p (expand-file-name persp-auto-save-fname persp-save-dir)))
           :action doom/quickload-session)
          ("Quit"             :icon (nerd-icons-faicon "nf-fa-power_off" :face 'doom-dashboard-menu-title) :action save-buffers-kill-terminal)))
  (map! :map +doom-dashboard-mode-map
        :ng "f" #'find-file
        :ng "n" #'evil-buffer-new
        :ng "g" #'+default/search-project
        :ng "r" #'recentf-open-files
        :ng "p" #'projectile-switch-project
        :ng "c" #'doom/open-private-config
        :ng "s" #'doom/quickload-session
        :ng "q" #'save-buffers-kill-terminal))

;; 9) Echo area — büyüyünce hemen geri küçülsün (Doom: grow-only → boşluk kalıyordu),
;;    eldoc tek satır.
(setq resize-mini-windows t
      max-mini-window-height 0.25
      eldoc-echo-area-use-multiline-p nil
      eldoc-echo-area-prefer-doc-buffer t)

;;; --- Faces -----------------------------------------------------------------
;; custom-set-faces! (bang) re-applies on `doom-load-theme-hook', so LSP /
;; semantic-tokens / theme reloads never revert these to the base theme.
(custom-set-faces!
 '(default :background "#081014" :foreground "#c8e6e6") ; ghostty config.ghostty background
 ;; These dashboard faces inherit syntax faces; keep the coding-mode glow
 ;; boxes from leaking onto the startup menu and Restore session entry.
 '(doom-dashboard-menu-title :inherit font-lock-function-name-face :box nil)
 '(doom-dashboard-menu-desc :inherit font-lock-string-face :box nil)
 ;; nvim tugmonokai Bold Edition — treesit level-4 yüzleri
 '(font-lock-keyword-face :foreground "#ff2b2b" :weight bold)
 '(font-lock-function-name-face :foreground "#00ff9f" :weight bold)
 '(font-lock-function-call-face :foreground "#00ff9f" :weight bold)
 ;; param/def/member → turuncu; kullanım → şeftali (krem #c8e6e6 beyaz duruyordu)
 '(font-lock-variable-name-face :foreground "#ff7a00" :weight bold)
 '(font-lock-variable-use-face  :foreground "#ffcc33" :weight bold)
 '(font-lock-property-name-face :foreground "#ff7a00" :weight bold)
 '(font-lock-property-use-face  :foreground "#ff7a00" :weight bold)
 '(font-lock-constant-face :foreground "#c07dff" :weight bold)
 '(font-lock-number-face   :foreground "#c07dff" :weight bold)
 '(font-lock-type-face :foreground "#00d4ff" :slant italic :weight bold)
 '(font-lock-builtin-face :foreground "#00d4ff" :weight bold)
 '(font-lock-string-face :foreground "#ff4df0" :weight bold)
 '(font-lock-comment-face :foreground "#e8f2f2" :slant italic :weight bold)
 '(font-lock-operator-face :foreground "#ff2b2b" :weight bold)
 '(font-lock-preprocessor-face :foreground "#ff2b2b" :slant italic :weight bold)
 '(font-lock-escape-face :foreground "#ff7a00" :weight bold)
 '(font-lock-delimiter-face :foreground "#7ed8f7" :weight bold)
 '(font-lock-bracket-face :foreground "#7ed8f7" :weight bold)
 '(font-lock-punctuation-face :foreground "#7ed8f7" :weight bold)
 '(font-lock-misc-punctuation-face :foreground "#ff7a00" :weight bold)
 '(hl-line :background "#202b2b")
 '(cursor :background "#00f0e0")
 '(region :background "#2a4848")
 '(line-number :foreground "#b39ddb" :weight bold) ; pastel mor (önce cyan #00f0e0, Monokai'de tok mor #7e57c2)
 '(line-number-current-line :foreground "#ff5f00" :weight bold) ; doygun neon turuncu
 '(show-paren-match :foreground "#00f0e0" :background "#2c3535" :weight bold)
 '(lsp-inlay-hint-face :foreground "#e8f2f2" :background "#081014" :slant italic :height 0.9)
 ;; NvChad pill mode boxes
 '(doom-modeline-evil-normal-state   :foreground "#081014" :background "#00ff9f" :weight bold :box (:line-width (6 . 2) :color "#00ff9f"))
 '(doom-modeline-evil-insert-state   :foreground "#081014" :background "#00d4ff" :weight bold :box (:line-width (6 . 2) :color "#00d4ff"))
 '(doom-modeline-evil-visual-state   :foreground "#081014" :background "#c07dff" :weight bold :box (:line-width (6 . 2) :color "#c07dff"))
 '(doom-modeline-evil-replace-state  :foreground "#081014" :background "#ff2b2b" :weight bold :box (:line-width (6 . 2) :color "#ff2b2b"))
 '(doom-modeline-evil-emacs-state    :foreground "#081014" :background "#ff7a00" :weight bold :box (:line-width (6 . 2) :color "#ff7a00"))
 '(doom-modeline-evil-motion-state   :foreground "#081014" :background "#ff4df0" :weight bold :box (:line-width (6 . 2) :color "#ff4df0"))
 '(doom-modeline-evil-operator-state :foreground "#081014" :background "#ff7a00" :weight bold :box (:line-width (6 . 2) :color "#ff7a00"))
 '(treemacs-directory-face     :foreground "#00d4ff" :weight bold)
 '(treemacs-root-face          :foreground "#c07dff" :weight bold :height 1.1)
 '(treemacs-file-face          :foreground "#c8e6e6")
 '(treemacs-git-modified-face  :foreground "#ff7a00")
 '(treemacs-git-untracked-face :foreground "#00ff9f")
 '(treemacs-git-added-face     :foreground "#00ff9f")
 '(treemacs-git-conflict-face  :foreground "#ff2b2b")
 '(dired-directory :foreground "#00d4ff" :weight bold)
 '(dired-symlink   :foreground "#00d4ff" :slant italic)
 '(dired-header    :foreground "#c07dff" :weight bold)
 ;; web / html (beyaz kalan tag/attr)
 '(web-mode-html-tag-face :foreground "#ff7a00" :weight bold)
 '(web-mode-html-attr-name-face :foreground "#00ff9f" :weight bold)
 '(web-mode-html-attr-value-face :foreground "#ff4df0" :weight bold)
 '(web-mode-keyword-face :foreground "#ff2b2b" :weight bold)
 '(web-mode-function-name-face :foreground "#00ff9f" :weight bold)
 '(web-mode-string-face :foreground "#ff4df0" :weight bold)
 '(web-mode-type-face :foreground "#00d4ff" :slant italic :weight bold)
 '(web-mode-variable-name-face :foreground "#ff7a00" :weight bold)
 '(web-mode-constant-face :foreground "#c07dff" :weight bold))

;;; --- GITS: config.el'deki sabit (Monokai/Material) renkleri ez ---------------
;; config.el, config.org'dan yeniden tangle ediliyor (literate) → oradaki hex'ler
;; elle değiştirilince geri dönüyor.  Bu dosya en son yüklendiği için burada ezilir.
(custom-set-faces!
 '(centaur-tabs-default :background "#111515" :foreground "#111515")
 '(centaur-tabs-unselected :background "#111515" :foreground "#e8f2f2" :height 0.9)
 '(centaur-tabs-selected :background "#2c3535" :foreground "#ffb86b" :weight bold :height 0.9)
 '(centaur-tabs-unselected-modified :background "#111515" :foreground "#ff7a00" :height 0.9)
 '(centaur-tabs-selected-modified :background "#2c3535" :foreground "#ff7a00" :weight bold :height 0.9)
 '(centaur-tabs-active-bar-face :background "#ff7a00")
 '(header-line :background "#111515" :foreground "#e8f2f2" :box nil :underline nil :overline nil)
 '(tab-line :background "#111515" :foreground "#e8f2f2" :box nil :underline nil :overline nil :height 0.9)
 '(doom-modeline-bar :background "#ff7a00")
 '(doom-modeline-buffer-file :foreground "#e6ffff" :weight bold)
 '(doom-modeline-buffer-modified :foreground "#ff2b2b" :weight bold)
 '(doom-modeline-buffer-major-mode :foreground "#00d4ff" :weight bold)
 '(doom-modeline-git-added :foreground "#00ff9f")
 '(doom-modeline-git-removed :foreground "#ff2b2b")
 '(doom-modeline-git-modified :foreground "#ff7a00"))
;; config.el bunları `after!' içinde set ediyor → aynı yerde, ondan sonra ez.
(after! lsp-ui
  (custom-set-faces!
   '(lsp-ui-doc-background :background "#222929")
   '(lsp-ui-doc-header :foreground "#ff2b2b" :weight bold)))
(after! lsp-inlay-hints
  (custom-set-faces!
   '(lsp-inlay-hint-face :foreground "#e8f2f2" :background "#081014" :slant italic :height 0.9)))


;;; Terminal ergonomics: vterm + eat
(defun my/terminal-kill-buffer-and-window ()
  "Kill the current terminal buffer and its window, like Vim q."
  (interactive)
  (kill-buffer-and-window))

(defun my/terminal-copy-region ()
  "Copy the active terminal selection to the kill ring and clipboard."
  (interactive)
  (unless (use-region-p)
    (user-error "Once fareyle veya klavyeyle bir metin secin"))
  (kill-ring-save (region-beginning) (region-end))
  (deactivate-mark)
  (message "Secim panoya kopyalandi"))

(defun my/terminal-colon-or-quit ()
  "Close on :q; forward other colon-prefixed input to the live terminal."
  (interactive)
  (let ((event (read-event)))
    (if (eq event ?q)
        (my/terminal-kill-buffer-and-window)
      (let ((text (concat ":" (if (characterp event)
                                    (string event)
                                  (key-description (vector event))))))
        (cond ((derived-mode-p (quote vterm-mode)) (vterm-send-string text))
              ((derived-mode-p (quote eat-mode))
               (eat-term-send-string eat-terminal text)))))))

(after! eat
  ;; TUI normalde char map kullanir; iki harita da ayni kisayollari alir.
  (dolist (map (list eat-char-mode-map eat-semi-char-mode-map))
    (define-key map (kbd "C-S-v") (function eat-yank))
    (define-key map (kbd "C-S-c") (function my/terminal-copy-region))
    (define-key map (kbd ":") (function my/terminal-colon-or-quit))))

(defun my/vterm-mouse-scroll (event)
  "Enter Vterm copy mode on scrolling, then scroll normally."
  (interactive "e")
  (unless vterm-copy-mode
    (vterm-copy-mode 1))
  (mwheel-scroll event))

(defun my/vterm-exit-copy-mode ()
  "Return to the live Vterm without copying text."
  (interactive)
  (vterm-copy-mode -1))

(after! vterm
  ;; Vterm scrollback copy mode da kaydirilabilir; tekerlek onu otomatik acar.
  (dolist (map (list vterm-mode-map vterm-copy-mode-map))
    (define-key map [wheel-up] (function my/vterm-mouse-scroll))
    (define-key map [wheel-down] (function my/vterm-mouse-scroll))
    (define-key map (kbd "C-S-v") (function vterm-yank))
    (define-key map (kbd "C-S-c") (function my/terminal-copy-region))
    (define-key map (kbd ":") (function my/terminal-colon-or-quit)))
  (define-key vterm-copy-mode-map [escape] (function my/vterm-exit-copy-mode)))

(provide 'personal)
;;; personal.el ends here
