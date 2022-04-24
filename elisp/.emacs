;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Script Name: .emacs                             ;;
;; Description: Archivo de configuración de Emacs  ;;
;; Args: N/A                                       ;;
;; Creation/Update: 20200225/20220314              ;; 
;; Author: www.sherblog.pro                        ;;                      
;; Email: sherlockes@gmail.com                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Añadir repositorios
(require 'package)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/") t)

;; Añadir Dired+
(add-to-list 'load-path "~/dotfiles/emacs/.emacs.d/dired+/")
(load "dired+.el")
(require 'dired+)

;; Añadir Icicles
(add-to-list 'load-path "~/dotfiles/emacs/.emacs.d/icicles/")
(require 'icicles)
(icy-mode 1)

;; Inicializar y actualizar paquetes
(package-initialize)
;;(package-refresh-contents)

;; Ocultar barras y pantalla de inicio
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(setq inhibit-startup-screen t)
(setq inhibit-startup-echo-area-message (user-login-name))

;; Crear la copia de seguridad en la papelera en lugar de en la carpeta del archivo.
(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; Configuración de Dired
(setq dired-dwim-target t) ;; Fija como objetivo el otro buffer con Dired
(setq dired-listing-switches "-laGh1v --group-directories-first") ;; Configuración ls defecto
(put 'dired-find-alternate-file 'disabled nil)    ;; Habilita la "a" en Dired
;;(add-hook 'dired-mode-hook (lambda()(dired-hide-details-mode))) ;; Ocultar detalles

(setq my-dired-ls-switches-show "-laGh1v --group-directories-first")
(setq my-dired-ls-switches-hide "-lGh1v --group-directories-first")
(setq my-dired-switch 1)

(add-hook 'dired-mode-hook
 (lambda ()
  (dired-hide-details-mode)
  (if (= my-dired-switch 1)(dired-sort-other my-dired-ls-switches-hide))
  (define-key dired-mode-map (kbd "M-<up>") (lambda () (interactive) (find-alternate-file "..")))
  (define-key dired-mode-map (kbd "M-<down>") 'dired-find-alternate-file)
  (define-key dired-mode-map (kbd "M-o")
   (lambda ()
    "Alterna entre mostrar y ocultar"
    (interactive)
    (setq my-dired-switch (- my-dired-switch))
    (if (= my-dired-switch 1)
      (dired-sort-other my-dired-ls-switches-hide)
     (dired-sort-other my-dired-ls-switches-show))))))

;; Configuración Yasnippet
(require 'yasnippet)
(yas-global-mode 1)

;; Python
(elpy-enable)
(setq python-shell-interpreter "python3")
(setq elpy-rpc-python-command "python3")
(setq elpy-rpc-virtualenv-path (quote system))

;; Otros
(put 'erase-buffer 'disabled nil)                 ;; Habilita el comando de borrado del buffer
(global-visual-line-mode t)                       ;; Ajuste de línea
(add-hook 'window-setup-hook 'toggle-frame-maximized t)  ;; Arrancar emacs maximizado

;; Mostrar la sesión de terminal en el mismo buffer
(add-to-list 'display-buffer-alist '("^\\*shell\\*" . (display-buffer-same-window . nil)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(custom-enabled-themes (quote (wombat)))
 '(debug-on-error nil)
 '(delete-selection-mode 1)


 '(ibuffer-formats
   (quote
    ((mark modified read-only locked " "
	   (name 48 48 :left :elide)
	   " "
	   (size 9 -1 :right)
	   " "
	   (mode 16 16 :left :elide))
     (mark " "
	   (name 16 -1)
	   " " filename))))


 '(org-tags-column -60)
 '(package-selected-packages(quote(markdown-mode htmlize gnu-elpa-keyring-update elpy)))
 '(safe-local-variable-values (quote ((ENCODING . UTF-8) (encoding . utf-8))))
 '(temporary-file-directory "~/.emacs_backup")
 '(tramp-default-method "ssh"))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;; Funciones

;; Entorno de desarrollo para sherblog
(defun sherblog_edit ()
  (interactive)
  (mapc 'kill-buffer (buffer-list))
  (delete-other-windows nil)
  (split-window-right 80)
  (split-window-below)
  (setq default-directory "/ssh:pi@192.168.10.202:/home/pi/sherblog/")
  (comint-send-string (shell) "hugoser\n")
  (other-window 1)
  (dired "/ssh:pi@192.168.10.202:/home/pi/sherblog/content/post/")
  (enlarge-window 10)
  (browse-url "http://192.168.10.202:1313")
)

;; Accesos directos
(global-set-key (kbd "<f1>") (lambda() (interactive)(load-file user-init-file)))
(global-set-key (kbd "<f2>") (lambda() (interactive)(find-file "~/Google_Drive/SherloScripts/mi_diario.org")))
(global-set-key (kbd "<f4>") 'sherblog_edit)
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "C-c r") 'query-replace-regexp)













