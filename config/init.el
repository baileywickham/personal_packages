(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(setq show-paren-delay 0)
(show-paren-mode 1)
(set-default 'truncate-lines t)

(setq select-enable-clipboard t)


(use-package helm
  :ensure t
  :config
  (helm-mode 1))

(setq vc-follow-symlinks t)
(setq make-backup-files nil)

(setq org-confirm-babel-evaluate 'nil)
(setq org-babel-python-command "python3")
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (shell . t)))


(use-package evil
  :ensure t
  :init
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1))

(use-package org
  :ensure t
  :init
  (setq truncate-lines t))
  ;(setq truncate-lines 'nil))


(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode))

(use-package dracula-theme
  :ensure t
  :config
  (load-theme 'dracula t))
(use-package which-key
  :ensure t
  :init
  (which-key-mode))

(setq visible-bell nil)
(setq show-paren-delay 0)
(show-paren-mode 1)

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(which-key dracula-theme undo-tree evil helm)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
