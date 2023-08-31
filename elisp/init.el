;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Script Name: init.el                            ;;
;; Description: Archivo de configuración de Emacs  ;;
;; Args: N/A                                       ;;
;; Creation/Update: 20200225/20230815              ;; 
;; Author: www.sherblog.pro                        ;;                      
;; Email: sherlockes@gmail.com                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Archivo ubicado en "~/.emacs" ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (setq user-dir (expand-file-name "~"))                                       ;; Variable para el directorio de usuario
;; (setq user-init-file (concat user-dir "/dotfiles/emacs/.emacs.d/init.el"))   ;; Ubicación del archivo de configuración
;; (load user-init-file)                                                        ;; Carga el archivo de configuración


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ubicación de directorios ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq user-emacs-directory (concat user-dir "/.emacs.d/"))                       ;; Directorio de configuración
(setq default-directory user-dir)                                                ;; Directorio por defecto
(setenv "HOME" user-dir)                                                         ;; Directorio HOME

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuración externa ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(load-file (concat user-dir "/dotfiles/emacs/.emacs.d/functions.el"))           ;; Carga el archivo externo de funciones
                                                                                           
(setq explicit-shell-file-name "/bin/bash")                                     ;; Configura shell-command para permitir alias
(setq shell-file-name "bash")                                                                 
(setq explicit-bash.exe-args '("--noediting" "--login" "-ic"))                                                                                        
(setq shell-command-switch "-ic")                                                                                    
(setenv "SHELL" shell-file-name)

(setq byte-compile-warnings '(cl-functions))                                    ;; Elimina el warning cl obsoleto

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Añadir repositorios ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'package)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)                  ;; Melpa, no es la versión estable
;;(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/") t)       ;; Melpa estable
;;(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)                       ;; Problemas al instalar Org-Roam
(add-to-list 'package-archives '("nongnu"   . "https://elpa.nongnu.org/nongnu/") t)
;;(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/") t)               ;; Cambiado por la versión nongnu


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Inicializar y actualizar paquetes ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(package-initialize)
(setq package-enable-at-startup nil)


(when (not package-archive-contents)
  (package-refresh-contents))

;;;;;;;;;
;; Ivy ;;
;;;;;;;;;
(my-install-package-if-not-installed 'wgrep)                                                ;; Requiere tener instalado "wgrep"
(my-install-package-if-not-installed 'ivy)                                                  ;; Instalación del paquete "Ivy"
(ivy-mode t)                                                                                ;; Activa el modo de autocompletado de Ivy

(my-install-package-if-not-installed 'ox-hugo)
(with-eval-after-load 'ox
  (require 'ox-hugo))

;;;;;;;;;;;;;;
;; Org-roam ;;
;;;;;;;;;;;;;;

(my-install-package-if-not-installed 'org-roam)
(my-install-package-if-not-installed 'org-roam-ui)


;;(add-to-list 'load-path "/home/sherlockes/Descargas/org-roam-ui")
;;(require 'org-roam-ui)

(if (file-exists-p "~/org-roam/")                                                           ;; Actualiza el repositorio org-roam o lo clona si no existe
    (let ((default-directory "~/org-roam"))(shell-command "git pull"))
  (let ((default-directory "~/"))(shell-command "git clone git@github.com:sherlockes/org-roam.git"))
)

(if (file-exists-p "~/brain/")                                                              ;; Actualiza el repositorio brain o lo clona si no existe
    (let ((default-directory "~/brain"))(shell-command "git pull"))
  (let ((default-directory "~/"))(shell-command "git clone git@gitlab.com:sherlockes/brain.git"))
)

(setq org-roam-directory (file-truename "~/org-roam"))                                      ;; Establece el directorio para ORGRoam
(org-roam-db-autosync-mode)                                                                 ;; Sincronizar cache automáticamente
(setq org-roam-completion-system 'ivy)
(setq org-roam-completion-everywhere t)
(setq org-id-extra-files (directory-files-recursively org-roam-directory "\\.org$"))       ;; Habilita la exportación de enlaces hacia Ox-hugo

(defun org-roam-update()                                                                    ;; Actualizar repositorio Org-Roam
    (interactive)
    (org-hugo-export-wim-to-md :all-subtrees)                                               ;; Exportar el artículo a md para la web
    (let ((default-directory "~/org-roam"))
        (shell-command "git add --all")
        (shell-command "git commit -m 'Update'")
        (shell-command "git push")
    )
    (let ((default-directory "~/brain"))
        (shell-command "git add --all")
        (shell-command "git commit -m 'Update'")
        (shell-command "git push")
    )
)

(defun funcion-al-guardar ()
  (let ((directorio-org-roam (expand-file-name "org-roam" (getenv "HOME"))))
    (when (string-prefix-p directorio-org-roam buffer-file-name)
      (org-roam-update))))

;;(add-hook 'after-save-hook 'funcion-al-guardar)

(add-hook 'after-save-hook (lambda () (when (and (string= (file-name-extension buffer-file-name) "org") (funcion-al-guardar))) nil t))


(global-set-key (kbd "C-c n f") 'org-roam-node-find)                                        ;; Buscar o crear un Nodo
(global-set-key (kbd "C-c n l") 'org-roam-buffer-toggle)                                    ;; Mostrar/Ocultar el Buffer Org-Roam
(global-set-key (kbd "C-c n i") 'org-roam-node-insert)                                      ;; Insertar un enlace
(global-set-key (kbd "C-c n t") 'org-roam-tag-add)                                          ;; Añadir un Tag
(global-set-key (kbd "C-c n a") 'org-roam-alias-add)                                        ;; Añadir un Alias
(global-set-key (kbd "C-c n o") 'org-id-get-create)                                         ;; Convertir encabezado en nodo


;;;;;;;;;;;;;;;;;;;
;; Añadir Dired+ ;;
;;;;;;;;;;;;;;;;;;;

(let ((url "https://www.emacswiki.org/emacs/download/dired+.el"))
  (my-download-file-if-not-exists url (concat user-dir "/.emacs.d/dired+/dired+.el")))
(add-to-list 'load-path (concat user-dir "/.emacs.d/dired+/"))
(load "dired+.el")
(require 'dired+)

;;;;;;;;;;;;;;;;;;;;;;
;; Añadir Yasnippet ;;
;;;;;;;;;;;;;;;;;;;;;;

(my-install-package-if-not-installed 'yasnippet)
(require 'yasnippet)
(yas-global-mode 1)

;;;;;;;;;;;;;;;;;;;;;
;; Añadir Markdown ;;
;;;;;;;;;;;;;;;;;;;;;

(my-install-package-if-not-installed 'markdown-mode)
(require 'markdown-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Crear la copia de seguridad en la papelera en lugar de en la carpeta del archivo ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))
;;(setq temporary-file-directory "~/.emacs_backup")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ocultar barras y pantalla de inicio ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(tool-bar-mode -1)                                                                          ;; Oculta la barra de herramientas superior
(tooltip-mode -1)                                                                           ;; Mostrar consejos en la barra inferior
(menu-bar-mode -1)                                                                          ;; Oculta la barra de menús superior
(setq inhibit-startup-screen t)                                                             ;; No mostrar la pantalla de bienvenida

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Modo para copiar la línea completa ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(my-install-package-if-not-installed 'whole-line-or-region)
(whole-line-or-region-global-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuración de Dired ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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


;;;;;;;;;;;;
;; Python ;;
;;;;;;;;;;;;

(my-install-package-if-not-installed 'elpy)
(elpy-enable)
(setq python-shell-interpreter "python3")
(setq elpy-rpc-python-command "python3")
(setq elpy-rpc-virtualenv-path (quote system))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Plantillas con Auto-insert ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Corrección ortográfica ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq ispell-dictionary "español")                                                          ;; Establece el diccionario Español pr defecto
(add-hook 'markdown-mode-hook 'flyspell-mode)                                               ;; Habilita la correción ortográfica para archivos Markdown
(add-hook 'flyspell-mode-hook 'flyspell-buffer)                                             ;; Corrige el buffer cuando se habilita la corrección

;;;;;;;;;;;
;; Otros ;;
;;;;;;;;;;;
(put 'upcase-region 'disabled nil)                                                          ;; Habilita el comando para pasar a mayúsculas
(put 'erase-buffer 'disabled nil)                                                           ;; Habilita el comando de borrado del buffer
(global-visual-line-mode t)                                                                 ;; Ajuste de línea
(add-hook 'window-setup-hook 'toggle-frame-maximized t)                                     ;; Arrancar emacs maximizado
;; (add-to-list 'initial-frame-alist '(fullscreen . maximized))                             ;; Arrancar emacs maximizado
(add-to-list 'display-buffer-alist '("^\\*shell\\*" . (display-buffer-same-window . nil)))  ;; Mostrar la sesión de terminal en el mismo buffer

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(custom-enabled-themes '(wombat))
 '(debug-on-error nil)
 '(delete-selection-mode 1)
 '(ibuffer-formats
   '((mark modified read-only locked " "
	   (name 48 48 :left :elide)
	   " "
	   (size 9 -1 :right)
	   " "
	   (mode 16 16 :left :elide))
     (mark " "
	   (name 16 -1)
	   " " filename)))
 '(org-roam-capture-templates
   '(("d" "default" plain "%?" :target
      (file+head "%<%Y%m%d>-${slug}.org"
        "#+title: ${title}
#+STARTUP: overview
#+date: %<%Y-%m-%d>
#+hugo_custom_front_matter: :thumbnail \"images/image.jpg\"
#+setupfile: ./setup.conf
#+hugo_tags: nemo
#+hugo_categories: apps
#+hugo_draft: false
Resumen de la nota
#+BEGIN_export html
<!--more-->
#+END_export
")
      :unnarrowed t)))
 '(org-tags-column -60)
 '(package-selected-packages
   '(ox-hugo wgrep ivy vertico whole-line-or-region markdown-mode htmlize gnu-elpa-keyring-update elpy))
 '(remote-shell-program "ssh")
 '(safe-local-variable-values '((ENCODING . UTF-8) (encoding . utf-8)))
 '(tramp-default-method "ssh")
 '(tramp-encoding-shell "/bin/bash"))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;; Accesos directos
(global-set-key (kbd "<f1>") 'reiniciar)
;;(global-set-key (kbd "<f2>") (lambda() (interactive)(find-file "~/Google_Drive/SherloScripts/mi_diario.org")))
;;(global-set-key (kbd "<f2>") (lambda() (interactive)(browse-url-emacs "https://raw.githubusercontent.com/sherlockes/SherloScripts/master/mi_diario.org")))
(global-set-key (kbd "<f2>") (lambda() (interactive)(org-roam-ui-mode t)))
(global-set-key (kbd "<f4>") 'sherblog_edit)
(global-set-key (kbd "<f5>") 'flyspell-mode)
(global-set-key (kbd "<f6>") (kbd "C-u C-c C-c"))
(global-set-key (kbd "<f7>") 'fd-switch-dictionary)    ;; Cambio de diccionario
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



