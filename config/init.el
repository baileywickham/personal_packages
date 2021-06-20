(require 'package)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(setq initial-buffer-choice "~/todo.org")

(require 'use-package)

(use-package org
  :init
  (when (fboundp 'electric-indent-mode) (electric-indent-mode -1)))


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;; (unless package-archive-contents    ;; Refresh the packages descriptions
;;  (package-refresh-contents))
(setq package-load-list '(all))     ;; List of packages to load
(package-initialize)

;;(when (not (package-installed-p 'use-package))
;;  (package-refresh-contents)
;;  (package-install 'use-package))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(markdown-mode clojure-mode evil-org which-key use-package)))


(load-file "~/.emacs.d/configs/sensible-defaults.el")
(sensible-defaults/use-all-settings)
(sensible-defaults/use-all-keybindings)

(use-package evil
  :init
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1))

(use-package org
  :init
  (setq truncate-lines 'nil))


(use-package undo-tree
  :config
  (global-undo-tree-mode))
(use-package dracula-theme
  :config
  (load-theme 'dracula t))
(use-package which-key
  :init
  (which-key-mode))

(setq visible-bell nil)

(use-package evil-org
  :ensure t
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package clojure-mode)
(add-to-list 'auto-mode-alist '("\\.fusion\\'" . clojure-mode))

(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))
