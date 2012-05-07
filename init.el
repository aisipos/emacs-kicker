;; emacs kicker --- kick start emacs setup
;; Copyright (C) 2010 Dimitri Fontaine
;;
;; Author: Dimitri Fontaine <dim@tapoueh.org>
;; URL: https://github.com/dimitri/emacs-kicker
;; Created: 2011-04-15
;; Keywords: emacs setup el-get kick-start starter-kit
;; Licence: WTFPL, grab your copy here: http://sam.zoy.org/wtfpl/
;;
;; This file is NOT part of GNU Emacs.

;; use ido for minibuffer completion
(require 'ido)
(ido-mode t)
(setq ido-save-directory-list-file "~/.emacs.d/.ido.last")
(setq ido-enable-flex-matching t)
(setq ido-use-filename-at-point 'guess)
;;(setq ido-show-dot-for-dired t)
;;ido's definition of "everywhere" is somewhat limited
(ido-everywhere t)

;; on to the visual settings
(setq inhibit-splash-screen t)		; no splash screen, thanks
(line-number-mode 1)			; have line numbers and
(column-number-mode 1)			; column numbers in the mode line
(global-hl-line-mode)			; highlight current line
(global-linum-mode 1)			; add line numbers on the left

(tool-bar-mode -1)			; no tool bar with icons
;; (scroll-bar-mode -1)			; no scroll bars
(unless (string-match "apple-darwin" system-configuration)
  ;; on mac, there's always a menu bar drown, don't have it empty
  (menu-bar-mode -1))

;; choose your own fonts, in a system dependant way
(if (string-match "apple-darwin" system-configuration)
    (set-face-font 'default "Inconsolata-14")
  (set-face-font 'default "Monospace-10"))


;; avoid compiz manager rendering bugs
(add-to-list 'default-frame-alist '(alpha . 100))

;; copy/paste with C-c and C-v and C-x, check out C-RET too
;; (cua-mode)

;; under mac, have Command as Meta and keep Option for localized input
(when (string-match "apple-darwin" system-configuration)
  (setq mac-allow-anti-aliasing t)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'none))

;; Use the clipboard, pretty please, so that copy/paste "works"
(setq x-select-enable-clipboard t)

;; Navigate windows with M-<arrows>
(windmove-default-keybindings 'meta)
(setq windmove-wrap-around t)

;;parens
(show-paren-mode t)

(setq visible-bell t)

;;backup files
(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))

;;Set frame title to full path, and turn graphical tooltips off
(when window-system
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (tooltip-mode -1)
  (mouse-wheel-mode t)
)

;;Show trailing whitespace
(setq-default show-trailing-whitespace t)
(set-face-attribute 'trailing-whitespace nil
 :background "gold"
)

(require 'cl)				; common lisp goodies, loop

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

;; Add /usr/local/bin to exec-path
(if (eq system-type 'darwin)
    (setq exec-path
          (append 
           '("/usr/local/bin"
             "~/bin"
            )
           exec-path)))

(unless (require 'el-get nil t)
  (url-retrieve
   "https://raw.github.com/dimitri/el-get/master/el-get-install.el"
   (lambda (s)
     (let (el-get-master-branch)
       (goto-char (point-max))
       (eval-print-last-sexp)))))

;; now either el-get is `require'd already, or have been `load'ed by the
;; el-get installer.

;; set local recipes
(setq
 el-get-sources
 '((:name buffer-move			; have to add your own keys
	  :after (lambda ()
		   (global-set-key (kbd "<C-S-up>")     'buf-move-up)
		   (global-set-key (kbd "<C-S-down>")   'buf-move-down)
		   (global-set-key (kbd "<C-S-left>")   'buf-move-left)
		   (global-set-key (kbd "<C-S-right>")  'buf-move-right)))

   (:name smex				; a better (ido like) M-x
	  :after (lambda ()
		   (setq smex-save-file "~/.emacs.d/.smex-items")
		   (global-set-key (kbd "M-x") 'smex)
		   (global-set-key (kbd "M-X") 'smex-major-mode-commands)))

   (:name magit				; git meet emacs, and a binding
	  :after (lambda ()
		   (global-set-key (kbd "C-x C-z") 'magit-status)))

   (:name goto-last-change		; move pointer back to last change
	  :after (lambda ()
		   ;; when using AZERTY keyboard, consider C-x C-_
		   (global-set-key (kbd "C-x C-/") 'goto-last-change)))))

;; now set our own packages
(setq
 my:el-get-packages
 '(;;el-get				; el-get is self-hosting
   escreen            			; screen for emacs, C-\ C-h
   switch-window			; takes over C-x o
   auto-complete			; complete as you type with overlays
   auto-complete-css
   auto-complete-yasnippet
   zencoding-mode			; http://www.emacswiki.org/emacs/ZenCoding
   color-theme		                ; nice looking emacs
   color-theme-tango                    ; check out color-theme-solarized
   color-theme-solarized
   markdown-mode
   full-ack
   highlight-parentheses
   js2-mode
   php-mode-improved
   ;; pymacs
   python-pep8
   ;; ruby-mode
   smart-tab
   textmate
   yaml-mode
   dired-plus
   nav ; need to ensure hg is installed
   nxhtml
   python-mode
   ipython
   ;; ropemacs
   rect-mark
   django-mode
   multi-term
   flymake-point
))

;;
;; Some recipes require extra tools to be installed
;;
;; Note: el-get-install requires git, so we know we have at least that.
;;
(when (el-get-executable-find "cvs")
  (add-to-list 'my:el-get-packages 'emacs-goodies-el)) ; the debian addons for emacs

(when (el-get-executable-find "svn")
  (loop for p in '(psvn    		; M-x svn-status
		   yasnippet		; powerful snippet mode
		   )
	do (add-to-list 'my:el-get-packages p)))

(setq my:el-get-packages
      (append
       my:el-get-packages
       (loop for src in el-get-sources collect (el-get-source-name src))))

;; install new packages and init already installed packages
(el-get 'sync my:el-get-packages)

; winner-mode provides C-<left> to get back to previous window layout
(winner-mode 1)

;; whenever an external process changes a file underneath emacs, and there
;; was no unsaved changes in the corresponding buffer, just revert its
;; content to reflect what's on-disk.
(global-auto-revert-mode 1)

;; M-x shell is a nice shell interface to use, let's make it colorful.  If
;; you need a terminal emulator rather than just a shell, consider M-x term
;; instead.
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; If you do use M-x term, you will notice there's line mode that acts like
;; emacs buffers, and there's the default char mode that will send your
;; input char-by-char, so that curses application see each of your key
;; strokes.
;;
;; The default way to toggle between them is C-c C-j and C-c C-k, let's
;; better use just one key to do the same.
(require 'term)
(define-key term-raw-map  (kbd "C-'") 'term-line-mode)
(define-key term-mode-map (kbd "C-'") 'term-char-mode)

;; Have C-y act as usual in term-mode, to avoid C-' C-y C-'
;; Well the real default would be C-c C-j C-y C-c C-k.
(define-key term-raw-map  (kbd "C-y") 'term-paste)

;; default key to switch buffer is C-x b, but that's not easy enough
;;
;; when you do that, to kill emacs either close its frame from the window
;; manager or do M-x kill-emacs.  Don't need a nice shortcut for a once a
;; week (or day) action.
(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)
(global-set-key (kbd "C-x C-c") 'ido-switch-buffer)
(global-set-key (kbd "C-x B") 'ibuffer)

;; C-x C-j opens dired with the cursor right on the file you're editing
(require 'dired-x)

;; full screen
(defun fullscreen ()
  (interactive)
  (set-frame-parameter nil 'fullscreen
		       (if (frame-parameter nil 'fullscreen) nil 'fullboth)))
(global-set-key [f11] 'fullscreen)

;; keys
(global-set-key [(control return)] 'hippie-expand)
(global-set-key (kbd "M-n") 'forward-paragraph)
(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key (kbd "C-x r RET") 'revert-buffer)

;;colors
(color-theme-deep-blue)

;;uniquify
(require 'uniquify)
(setq uniquify-buffer-name-style 'reverse)

;;Allow y/n instead of yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;;pymacs and ropemacs
;; (autoload 'pymacs-apply "pymacs")
;; (autoload 'pymacs-call "pymacs")
;; (autoload 'pymacs-eval "pymacs" nil t)
;; (autoload 'pymacs-exec "pymacs" nil t)
;; (autoload 'pymacs-load "pymacs" nil t)
;; (pymacs-load "ropemacs" "rope-")
;; (setq ropemacs-enable-autoimport t)

;;flymake and pyflakes
(when (load "flymake" t)
  (defun flymake-pyflakes-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
               'flymake-create-temp-inplace))
       (local-file (file-relative-name
            temp-file
            (file-name-directory buffer-file-name))))
      (list "pycheckers"  (list local-file))))
   (add-to-list 'flymake-allowed-file-name-masks
             '("\\.py\\'" flymake-pyflakes-init)))
(require 'flymake-point)

(defun ac-python-mode-setup ()
  (add-to-list 'ac-sources 'ac-source-yasnippet))


(add-hook 'python-mode-hook 'ac-python-mode-setup)
(add-hook 'python-mode-hook 'flymake-mode)
;; (add-hook 'rope-open-project-hook 'ac-nropemacs-setup)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Increase/Decrease font size on the fly
;;; Taken from: http://is.gd/iaAo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ryan/increase-font-size ()
  (interactive)
  (set-face-attribute 'default
                      nil
                      :height
                      (ceiling (* 1.10
                                  (face-attribute 'default :height)))))
(defun ryan/decrease-font-size ()
  (interactive)
  (set-face-attribute 'default
                      nil
                      :height
                      (floor (* 0.9
                                  (face-attribute 'default :height)))))
(global-set-key (kbd "C-+") 'ryan/increase-font-size)
(global-set-key (kbd "C--") 'ryan/decrease-font-size)

;;ack
(if (eq system-type 'gnu/linux)
    (setq ack-command "ack-grep --nocolor --nogroup ")
)
(require 'full-ack)
(if (eq system-type 'gnu/linux)
    (setq ack-executable (executable-find "ack-grep"))
)
;;Set frame title to full path, and turn graphical tooltips off
(when window-system
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (tooltip-mode -1)
  (mouse-wheel-mode t)
)

;;Show trailing whitespace
(setq-default show-trailing-whitespace t)
(set-face-attribute 'trailing-whitespace nil
 :background "gold"
)

;;nxhtml
(load "nxhtml/autostart.el")
(setq mumamo-background-colors nil)
;;This doesn't work unless you call django-html-mumamo-mode explicitly
;;;(add-hook 'django-html-mumamo-mode-hook #'(lambda ()  (setq yas/mode-symbol 'django-mode)))
;;Instead we'll cheat and associate html mode with django mode for yasnippet, and 
;;make django mode a child of html mode
(add-hook 'html-mode-hook #'(lambda ()  (setq yas/mode-symbol 'django-mode)))
;;For my development, default html mode is django-html-mumamo-mode
(add-to-list 'auto-mode-alist '("\\.html\\'" .  django-html-mumamo-mode))

;;Hippie expand
(setq hippie-expand-try-functions-list
      '(
        yas/hippie-try-expand
        try-expand-dabbrev
        try-expand-dabbrev-visible
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-complete-file-name
        try-complete-file-name-partially
        try-complete-lisp-symbol
        try-complete-lisp-symbol-partially
        try-expand-line
        try-expand-line-all-buffers
        try-expand-list
        try-expand-list-all-buffers
        try-expand-whole-kill))

;;YASnippet
(yas/initialize)
;;(yas/load-directory "~/.emacs.d/snippets")
(setq yas/prompt-functions '(yas/ido-prompt))

;;recentf
(require 'recentf)
;; get rid of `find-file-read-only' and replace it with something
;; more useful.
(global-set-key (kbd "C-x C-r") 'ido-recentf-open)
(recentf-mode t)
(setq recentf-max-saved-items 100)
(defun ido-recentf-open ()
  "Use `ido-completing-read' to \\[find-file] a recent file"
  (interactive)
  (if (find-file (ido-completing-read "Find recent file: " recentf-list))
      (message "Opening file...")
    (message "Aborting")))

;;Seems to be needed for search-at-point
;;Found at http://www.emacswiki.org/emacs/CompilationMode
(defun delete-this-overlay(overlay is-after begin end &optional len)
  (delete-overlay overlay)
)

;;See http://blog.bookworm.at/2007/03/pretty-print-xml-with-emacs.html
(defun bf-pretty-print-xml-region (begin end)
  "Pretty format XML markup in region. You need to have nxml-mode
http://www.emacswiki.org/cgi-bin/wiki/NxmlMode installed to do
this.  The function inserts linebreaks to separate tags that have
nothing but whitespace between them.  It then indents the markup
by using nxml's indentation rules."
  (interactive "r")
  (save-excursion
      (nxml-mode)
      (goto-char begin)
      (while (search-forward-regexp "\>[ \\t]*\<" nil t) 
        (backward-char) (insert "\n"))
      (indent-region begin end))
    (message "Ah, much better!"))

(defun whack-whitespace (arg)
      "Delete all white space from point to the next word.  With prefix ARG
    delete across newlines as well.  The only danger in this is that you
    don't have to actually be at the end of a word to make it work.  It
    skips over to the next whitespace and then whacks it all to the next
    word."
      (interactive "P")
      (let ((regexp (if arg "[ \t\n]+" "[ \t]+")))
        (re-search-forward regexp nil t)
        (replace-match "" nil nil)))

;;from emacs starter kit
(defun eval-and-replace (value)
  "Evaluate the sexp at point and replace it with its value"
  (interactive (list (eval-last-sexp nil)))
  (kill-sexp -1)
  (insert (format "%S" value)))

(defvar ska-isearch-occur-opened nil)
(defvar ska-isearch-window-configuration nil)

(defun ska-isearch-occur ()
  (interactive)
  (when (fboundp 'occur)
    (setq ska-isearch-occur-opened t)
    (let ((case-fold-search isearch-case-fold-search))
      (occur (if isearch-regexp isearch-string
               (regexp-quote isearch-string))))))

;;http://www.emacswiki.org/emacs/?OccurFromIsearch
(defun ska-isearch-maybe-remove-occur-buffer ()
  "Restore window-configuration when quitting isearch.

This function is meant to be used together with a function storing the
window configuration into a variable and together with a setup opening
the occur buffer from within isearch.

This function ...

-  will do nothing if you you did not cancel the search,

- will kill the occur buffer if occur buffer was opened from
  isearch,

- will restore your old window configuration when you saved it in
  `isearch-mode-hook'."

  (interactive)
  (let ((occ-buffer (get-buffer "*Occur*")))
    (when (and ska-isearch-occur-opened
               isearch-mode-end-hook-quit
               (buffer-live-p occ-buffer))
      (kill-buffer occ-buffer)
      (when (and ska-isearch-window-configuration
                 (window-configuration-p (car ska-isearch-window-configuration)))
        (set-window-configuration (car ska-isearch-window-configuration))
        (goto-char (cadr ska-isearch-window-configuration))))))

(add-hook 'isearch-mode-hook 
          '(lambda ()
             (setq ska-isearch-window-configuration
                   (list (current-window-configuration) (point-marker)))))

(add-hook 'isearch-mode-end-hook 
          '(lambda ()
             (ska-isearch-maybe-remove-occur-buffer)
             (setq ska-isearch-occur-opened nil)))

(define-key isearch-mode-map (kbd "M-o") 'ska-isearch-occur)

;;https://github.com/kylpo/.emacs.d/blob/master/init.el
(defun isearch-exit-at-opposite-end ()
  "by default isearch forward ends at end and isearch backward
  ends at beginning. this makes it do the opposite."
  (interactive)
  (add-hook 'isearch-mode-end-hook 'isearch-move-point-to-opposite-end)
  (isearch-exit))

(defun isearch-move-point-to-opposite-end ()
  (funcall (if isearch-forward #'backward-char #'forward-char)
           (length isearch-string))
  (remove-hook 'isearch-mode-end-hook 'isearch-move-point-to-opposite-end))

(define-key isearch-mode-map (kbd "<C-return>") 'isearch-exit-at-opposite-end)

