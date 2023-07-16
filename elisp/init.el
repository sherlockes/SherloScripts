;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Script Name: init.el                            ;;
;; Description: Archivo de configuración de Emacs  ;;
;; Args: N/A                                       ;;
;; Creation/Update: 20200225/20220427              ;; 
;; Author: www.sherblog.pro                        ;;                      
;; Email: sherlockes@gmail.com                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Añadir repositorios
(require 'package)

;;(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)                  ;; No es la versión estable
;;(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)                       ;; Problemas al instalar Org-Roam
(add-to-list 'package-archives '("nongnu"   . "https://elpa.nongnu.org/nongnu/") t)
;;(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/") t)               ;; Cambiado por la versión nongnu
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/") t)

;; Añadir Dired+
(add-to-list 'load-path "~/dotfiles/emacs/.emacs.d/dired+/")
(load "dired+.el")
(require 'dired+)


;; Inicializar y actualizar paquetes
(package-initialize)
;;(package-refresh-contents)
(when (not package-archive-contents)
  (package-refresh-contents))

;; Añadir Yasnippet
(require 'yasnippet)
(yas-global-mode 1)

;; Directorios por defecto
(setq user-emacs-directory "/home/sherlockes/dotfiles/emacs/.emacs.d/")                     ;; Directorio de configuración
(setq default-directory "/home/sherlockes")                                                 ;; Directorio por defecto
(setenv "HOME" "/home/sherlockes")                                                          ;; Directorio HOME

;; Crear la copia de seguridad en la papelera en lugar de en la carpeta del archivo.
(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))
;;(setq temporary-file-directory "~/.emacs_backup")

;; Ocultar barras y pantalla de inicio
(tool-bar-mode -1)                                                                          ;; Oculta la barra de herramientas superior
(tooltip-mode -1)                                                                           ;; Mostrar consejos en la barra inferior
(menu-bar-mode -1)                                                                          ;; Oculta la barra de menús superior
(setq inhibit-startup-screen t)                                                             ;; No mostrar la pantalla de bienvenida

;; Modo para copiar la línea completa
(whole-line-or-region-global-mode 1)

;; Configuración de Dired
(setq dired-dwim-target t)                                                                  ;; Fija como objetivo el otro buffer con Dired
(setq dired-listing-switches "-laGh1v --group-directories-first")                           ;; Configuración ls defecto
(put 'dired-find-alternate-file 'disabled nil)                                              ;; Habilita la "a" en Dired
;;(add-hook 'dired-mode-hook (lambda()(dired-hide-details-mode)))                           ;; Ocultar detalles al ejecutar el modo dired

(setq my-dired-ls-switches-show "-laGh1v --group-directories-first")                        ;; Modo para mostrar detalles
(setq my-dired-ls-switches-hide "-lGh1v --group-directories-first")                         ;; Modo para ocultar detalles
(setq my-dired-switch 1)                                                                    ;; Variable para alternar modo

(add-hook 'dired-mode-hook                                                                  ;; Hook al activar el Modo Dired
 (lambda ()
  (dired-hide-details-mode)
  (if (= my-dired-switch 1)(dired-sort-other my-dired-ls-switches-hide))
  (define-key dired-mode-map (kbd "M-<up>") (                                               ;; Ir a directorio superior "Alt-arriba"
    lambda () (interactive) (find-alternate-file ".."))
  )
  (define-key dired-mode-map (kbd "M-<down>") 'dired-find-alternate-file)                   ;; Entrar en directorio "Alt-abajo"
  (define-key dired-mode-map (kbd "<f1>") 'restart-emacs)                                   ;; Atajo para reiniciar Emacs desde Dired
  (define-key dired-mode-map (kbd "M-o")                                                    ;; Función Mostrar/Ocultar detalles "Alt-o"
   (lambda ()
    "Alterna entre mostrar y ocultar"
    (interactive)
    (setq my-dired-switch (- my-dired-switch))
    (if (= my-dired-switch 1)
      (dired-sort-other my-dired-ls-switches-hide)
      (dired-sort-other my-dired-ls-switches-show))))))

;; Org-roam
(make-directory "~/org-roam" t)                                                             ;; Crea el directori sino existe
(setq org-roam-directory (file-truename "~/org-roam"))                                      ;; Establece el directorio para ORGRoam
(org-roam-db-autosync-mode)                                                                 ;; Sincronizar cache automáticamente
(setq org-roam-completion-system 'ivy)
(setq org-roam-completion-everywhere t)

;; Python
(elpy-enable)
(setq python-shell-interpreter "python3")
(setq elpy-rpc-python-command "python3")
(setq elpy-rpc-virtualenv-path (quote system))

;; Plantillas con Auto-insert
(auto-insert-mode)                                                                          ;; Habilitar el modo Auto-insert
(setq auto-insert 'other)                                                                   ;; Lanzar el modo en otra ventana
(setq auto-insert-directory "~/dotfiles/templates/")                                        ;; Directorio de plantillas
(setq auto-insert-query nil)                                                                ;; No preguntar sobre la inserción

(defun autoinsert-yas-expand()
    "Reemplaza el texto en una plantilla de yasnippet."
    
    ;; Caso si es un Script
    (if (string-match "\.sh" (file-name-nondirectory buffer-file-name))
            (shell-command (concat "chmod u+x " buffer-file-name))
    )
    
    (yas/expand-snippet (buffer-string) (point-min) (point-max))
    (save-buffer)
)

;; Lanzadores de plantillas con Auto-insert
(setq auto-insert-alist '(
    (("\\.sh\\'" . "Shell script") . ["template.sh" autoinsert-yas-expand])                 ;; Lanzador para reación de scripts en Bash
    (("20[0-9]\\{6\\}_.+\\.md\\'" . "Markdown") . ["template.md" autoinsert-yas-expand])    ;; Lanzador para post del blog en markdown
))

;; Otros
(put 'upcase-region 'disabled nil)                                                          ;; Habilita el comando para pasar a mayúsculas
(put 'erase-buffer 'disabled nil)                                                           ;; Habilita el comando de borrado del buffer
(global-visual-line-mode t)                                                                 ;; Ajuste de línea
(add-hook 'window-setup-hook 'toggle-frame-maximized t)                                     ;; Arrancar emacs maximizado
;; (add-to-list 'initial-frame-alist '(fullscreen . maximized))                             ;; Arrancar emacs maximizado
(add-to-list 'display-buffer-alist '("^\\*shell\\*" . (display-buffer-same-window . nil)))  ;; Mostrar la sesión de terminal en el mismo buffer
(add-hook 'markdown-mode-hook 'flyspell-mode)                                               ;; Habilita la correción ortográfica para archivos Markdown
(add-hook 'flyspell-mode-hook 'flyspell-buffer)                                             ;; Corrige el buffer cuando se habilita la corrección


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
 '(package-selected-packages
   (quote
    (ivy vertico whole-line-or-region markdown-mode htmlize gnu-elpa-keyring-update elpy)))
 '(remote-shell-program "ssh")
 '(safe-local-variable-values (quote ((ENCODING . UTF-8) (encoding . utf-8))))
 '(tramp-default-method "ssh")
 '(tramp-encoding-shell "/bin/bash"))

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
  (mapc 'kill-buffer (buffer-list))                                                         ;; Cierra todos los bufers activos
  (delete-other-windows nil)                                                                ;; Cierra todas las ventanas
  (split-window-right 80)                                                                   ;; Parte la pantalla verticalmente en dos
  (split-window-below)                                                                      ;; Parte la ventana derecha horizontalmente en dos
  (setq default-directory "/ssh:pi@192.168.10.202:/home/pi/sherblog/")                      ;; Cambia el directorio por defecto a la Raspberry
  (comint-send-string (shell) "hugoser\n")                                                  ;; Lanza el servidor de Hugo en la Raspberry
  (other-window 1)                                                                          ;; Cambia el foco a la otra ventana
  (dired "/ssh:pi@192.168.10.202:/home/pi/sherblog/content/post/")                          ;; Abre el directorio de los Post del Blog
  (enlarge-window 10)                                                                       ;; Hace un poco mas alta la ventana de los post
  (browse-url "http://192.168.10.202:1313")                                                 ;; Abre el Blog en el navegador
)

(defun reiniciar ()
    (interactive)
    (mapcar 'kill-buffer (buffer-list))
    (delete-other-windows)
    (load-file user-init-file)
)

(defun emacs-terminal ()                                                                    ;; Función para volver a abrir Emacs en la terminal
  (suspend-emacs "fg ; emacs -nw")
)

(defun emacs-x11 ()                                                                         ;; Función para volver a abrir Emacs en escritorio
  (call-process "sh" nil nil nil "-c" "emacs &")
)

(defun reiniciar ()                                                                         ;; Función para reiniciar Emacs
  (interactive)
  (let ((kill-emacs-hook (
    append kill-emacs-hook (list
      (if (display-graphic-p)
          #'emacs-x11
        #'emacs-terminal)
    ))))
    (save-buffers-kill-emacs)
  )
)

;; Accesos directos
(global-set-key (kbd "<f1>") 'reiniciar)
;;(global-set-key (kbd "<f2>") (lambda() (interactive)(find-file "~/Google_Drive/SherloScripts/mi_diario.org")))
(global-set-key (kbd "<f2>") (lambda() (interactive)(browse-url-emacs "https://raw.githubusercontent.com/sherlockes/SherloScripts/master/mi_diario.org")))
(global-set-key (kbd "<f4>") 'sherblog_edit)
(global-set-key (kbd "<f5>") 'flyspell-mode)
(global-set-key (kbd "<f6>") (kbd "C-u C-c C-c"))
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "C-c r") 'query-replace-regexp)


;; -----------------------------------
(require 'org)
(require 'org-element)

(defvar yt-iframe-format
  ;; You may want to change your width and height.
  (concat "<iframe width=\"440\""
          " height=\"335\""
          " src=\"https://www.youtube.com/embed/%s\""
          " frameborder=\"0\""
          " allowfullscreen>%s</iframe>"))

(org-add-link-type
 "yt"
 (lambda (handle)
   (browse-url
    (concat "https://www.youtube.com/embed/"
            handle)))
 (lambda (path desc backend)
   (cl-case backend
     (html (format yt-iframe-format
                   path (or desc "")))
     (latex (format "\href{%s}{%s}"
                    path (or desc "video"))))))


(put 'downcase-region 'disabled nil)



