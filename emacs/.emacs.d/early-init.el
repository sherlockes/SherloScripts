;;; early-init.el --- Configuración temprana -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil)

(setq gc-cons-threshold most-positive-fixnum)

(setq default-frame-alist
      '((fullscreen . maximized)))

(setq initial-frame-alist
      '((fullscreen . maximized)))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq frame-inhibit-implied-resize t)


;;; early-init.el ends here
