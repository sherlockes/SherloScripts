;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Script Name: .emacs                             ;;
;; Description: Archivo de configuración de Emacs  ;;
;; Args: N/A                                       ;;
;; Creation/Update: 20200225/20200309              ;; 
;; Author: www.sherblog.pro                        ;;                      
;; Email: sherlockes@gmail.com                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Añadir repositorios
(require 'package)
(package-initialize)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(require 'dired+)
(require 'yasnippet)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (tango-dark)))
 '(desktop-save-mode t)
 '(dired-dwim-target t)
 '(dired-listing-switches "-laGh1v --group-directories-first")
 '(inhibit-startup-echo-area-message (user-login-name))
 '(inhibit-startup-screen t)
 '(menu-bar-mode nil)
 '(package-selected-packages
   (quote
    (yasnippet-snippets dired+ ## markdown-mode htmlize gnu-elpa-keyring-update elpy ace-window)))
 '(safe-local-variable-values (quote ((ENCODING . UTF-8) (encoding . utf-8))))
 '(tool-bar-mode nil)
 '(tooltip-mode nil)
 '(yas-global-mode 1))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(put 'dired-find-alternate-file 'disabled nil)    ;; Habilita la "a" en Dired
(put 'erase-buffer 'disabled nil)                 ;; Habilita el comando de borrado del buffer
(global-visual-line-mode t)                       ;; Ajuste de línea

;; Python
(elpy-enable)
(setq python-shell-interpreter "python3")

;; Accesos directos
(global-set-key (kbd "M-o") 'ace-window)

;; Crear la copia de seguridad en la papelera en lugar de en la carpeta del archivo.
(setq backup-directory-alist '((".*" . "~/.emacs_backup")))
