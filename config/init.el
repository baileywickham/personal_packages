(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))


(straight-use-package 'use-package)
(setq straight-use-package-by-default t)


(setq initial-buffer-choice "~/todo.org")

(require 'use-package)
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))


(load-file "~/.emacs.d/configs/sensible-defaults.el")
(sensible-defaults/use-all-settings)
(sensible-defaults/use-all-keybindings)

(straight-use-package 'helm)
(helm-mode 1)
(setq org-confirm-babel-evaluate 'nil)
(setq org-babel-python-command "python3")
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)))

(straight-use-package 'company-mode)
(add-hook 'after-init-hook 'global-company-mode)

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
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package clojure-mode)
(add-to-list 'auto-mode-alist '("\\.fusion\\'" . clojure-mode))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))
