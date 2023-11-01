;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Script Name: init.el                            ;;
;; Description: Archivo de configuración de Emacs  ;;
;; Args: N/A                                       ;;
;; Creation/Update: 20200225/20231031              ;; 
;; Author: www.sherblog.pro                        ;;                      
;; Email: sherlockes@gmail.com                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Archivo ubicado en "~/.emacs" ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (setq user-dir (expand-file-name "~"))                                                   ;; Variable para el directorio de usuario
;; (setq user-init-file (concat user-dir "/dotfiles/emacs/.emacs.d/init.el"))               ;; Ubicación del archivo de configuración
;; (load user-init-file)                                                                    ;; Carga el archivo de configuración

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ubicación de directorios ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq user-emacs-directory (concat user-dir "/.emacs.d/"))                                  ;; Directorio de configuración
(setq default-directory user-dir)                                                           ;; Directorio por defecto
(setenv "HOME" user-dir)                                                                    ;; Directorio HOME
(setq brain-dir (concat user-dir "/sherlockes.gitlab.io/"))                                 ;; Directorio para la exportación de Org-Roam
(setq blog-dir (concat user-dir "/sherlockes.github.io/"))                                  ;; Directorio para la Actualizacion del Blog
(setq blog-repo "git@github.com:sherlockes/sherlockes.github.io.git")
(setq brain-roam-dir (concat brain-dir "content-org"))                                      ;; Directorio para las notas en Org-Roam
(setq brain-repo "git@gitlab.com:sherlockes/sherlockes.gitlab.io.git")                      ;; Repo de la web en gitlab


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuración externa ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(load-file (concat user-dir "/dotfiles/emacs/.emacs.d/functions.el"))                       ;; Carga el archivo externo de funciones
(setq shell-command-switch "-ic")                                                           ;; Configura shell-command para permitir alias
(setq byte-compile-warnings '(cl-functions))                                                ;; Elimina el warning cl obsoleto

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Añadir repositorios ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'package)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)                    ;; Melpa, no es la versión estable
;;(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/") t)     ;; Melpa estable
;;(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)                       ;; Problemas al instalar Org-Roam
(add-to-list 'package-archives '("nongnu"   . "https://elpa.nongnu.org/nongnu/") t)
;;(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/") t)               ;; Cambiado por la versión nongnu
(add-to-list 'package-archives '( "jcs-elpa" . "https://jcs-emacs.github.io/jcs-elpa/packages/") t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Inicializar y actualizar paquetes ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(package-initialize)
(setq package-enable-at-startup nil)

(when (not package-archive-contents)
  (package-refresh-contents))

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuración interna ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
 '(org-link-elisp-skip-confirm-regexp ".*")
 '(org-roam-capture-templates
   '(("d" "default" plain "%?" :target
      (file+head "%<%Y%m%d>-${slug}.org" "#+title: ${title}
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
   '(gptel page-break-lines dashboard ox-hugo wgrep ivy vertico whole-line-or-region markdown-mode htmlize gnu-elpa-keyring-update elpy))
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

;;;;;;;;;;;;;;;;;;;;;;;;
;; Archivos recientes ;;
;;;;;;;;;;;;;;;;;;;;;;;;

(recentf-mode 1)                                                                            ;; Activa el modo recentf para guardar y cargar archivos recientes.
(setq recentf-max-saved-items 10)                                                           ;; Cantidad de archivos recientes a mostrar

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ocultar barras y pantalla de inicio ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(tool-bar-mode -1)                                                                          ;; Oculta la barra de herramientas superior
(tooltip-mode -1)                                                                           ;; Mostrar consejos en la barra inferior
(menu-bar-mode -1)                                                                          ;; Oculta la barra de menús superior
(setq inhibit-startup-screen t)                                                             ;; No mostrar la pantalla de bienvenida

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Arrancar maximizado ;;
;;;;;;;;;;;;;;;;;;;;;;;;;
;;(add-hook 'window-setup-hook 'toggle-frame-maximized t)                                   ;; Arrancar emacs maximizado
;;(add-hook 'window-setup-hook 'maximizar)                                                  ;; Arrancar emacs maximizado
;; Crear un archivo "earty-init.el" en ".emacs.d" con el siguiente contenido
;; (push '(fullscreen . maximized) default-frame-alist)

;;;;;;;;;;;;;;;
;; Saveplace ;;
;;;;;;;;;;;;;;;
(my-install-package-if-not-installed 'saveplace)
(save-place-mode 1)
(setq save-place-file (expand-file-name ".emacs-places" user-emacs-directory))

;;;;;;;;;;;;;;;;;;;
;; All-the-icons ;;
;;;;;;;;;;;;;;;;;;;
(my-install-package-if-not-installed 'all-the-icons)
(my-install-package-if-not-installed 'all-the-icons-dired)                                  ;; Instala el paquete para mostrar iconos en dired
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)                                       ;; Habilita el modo cuando entramos en Dired

;;;;;;;;;;;;;;;
;; Dashboard ;;
;;;;;;;;;;;;;;;
(my-install-package-if-not-installed 'dashboard)
(my-install-package-if-not-installed 'page-break-lines)

(setq dashboard-icon-type 'all-the-icons)
(setq dashboard-set-heading-icons t)
(setq dashboard-set-file-icons t)

(setq dashboard-items '((recents  . 10)
                        (bookmarks . 10)))

(setq dashboard-init-info "C-ESC(Dashboard)  F1(Reiniciar)  F2(Org-Roam)  F4(HugoServer)  F5(Ortografía)  F7(Diccionario)
RipGrep(C-c s)    Nodo OrgRoam(C-c n f)  Mostrar ocultos(M-o) Truncate(C-x x t)")


(setq dashboard-set-navigator t)
;; Format: "(icon title help action face prefix suffix)"

;; Format: "(icon title help action face prefix suffix)"
(setq dashboard-navigator-buttons
      `(;; line1
        (
	 ("" "Sherblog" "" (lambda (&rest _) (browse-url "http://www.sherblog.pro")))
	 ("" "Brainblog" "" (lambda (&rest _) (browse-url "http://www.sherlockes.gitlab.io")))
         ("★" "Star" "Show stars" (lambda (&rest _) (show-stars)) warning)
         ("?" "" "?/h" #'show-help nil "<" ">")
	)
         ;; line 2
        (
	 ("" "F1(Reiniciar)" "" reiniciar)
         ("⚑" nil "Show flags" (lambda (&rest _) (message "flag")) error)
	)
       )
)


;;;;;;;;;
;; Ivy ;;
;;;;;;;;;
(my-install-package-if-not-installed 'wgrep)                                                ;; Requiere tener instalado "wgrep"
(my-install-package-if-not-installed 'ivy)                                                  ;; Instalación del paquete "Ivy"
(ivy-mode t)                                                                                ;; Activa el modo de autocompletado de Ivy

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Actualización del Blog ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(if (file-exists-p blog-dir)                                                                ;; Actualiza el repositorio brain o lo clona si no existe
    (let ((default-directory blog-dir))(shell-command "git pull"))
  (let ((default-directory "~/"))(shell-command (concat "git clone " blog-repo)))
)

(add-hook 'after-save-hook (lambda () (when (and buffer-file-name (string-prefix-p blog-dir buffer-file-name))(funcion-al-guardar))))

;;;;;;;;;;;;;
;; ox-hugo ;;
;;;;;;;;;;;;;

(my-install-package-if-not-installed 'ox-hugo)
(with-eval-after-load 'ox
  (require 'ox-hugo))

;;;;;;;;;;;;;
;; Counsel ;;
;;;;;;;;;;;;;

(my-install-package-if-not-installed 'counsel)                                              ;; Requiere tener instalado ripgrep
(require 'counsel)
(setq counsel-rg-base-command "rg -S --no-heading --line-number --color never %s .")        ;; Configura el comando rg ejecutable

;;;;;;;;;;;;;;
;; Org-roam ;;
;;;;;;;;;;;;;;

(my-install-package-if-not-installed 'org-roam)                                             ;; Instala paquete Org-Roam

(if (file-exists-p brain-dir)                                                               ;; Actualiza el repositorio brain o lo clona si no existe
    (let ((default-directory brain-dir))(shell-command "git pull"))
  (let ((default-directory "~/"))(shell-command (concat "git clone " brain-repo)))
)

(setq org-roam-directory (file-truename brain-roam-dir))                                    ;; Establece el directorio para ORGRoam
(org-roam-db-autosync-mode)                                                                 ;; Sincronizar cache automáticamente
(setq org-roam-completion-system 'ivy)                                                      ;; Define ivy como sistema de completado
(setq org-roam-completion-everywhere t)                                                     ;; Completa en cualquier lugar
(setq org-id-extra-files (directory-files-recursively org-roam-directory "\\.org$"))        ;; Habilita la exportación de enlaces hacia Ox-hugo

(defun funcion-al-guardar-brain ()                                                          ;; Función que se ejecuta al guardar archivo de brain-dir
  (interactive)
  (if (string= (file-name-extension buffer-file-name) "org")
    (org-hugo-export-wim-to-md :all-subtrees))                                              ;; Exporta el archivo si es de tipo *.org

  (let ((default-directory brain-dir))
    (shell-command "gitup")                                                                 ;; Actualiza el repositorio git
  )
)

(add-hook 'after-save-hook (lambda () (when (and buffer-file-name (string-prefix-p brain-dir buffer-file-name))(funcion-al-guardar))))

;;;;;;;;;;;;;;;;;
;; Org-roam-ui ;;
;;;;;;;;;;;;;;;;;

(my-install-package-if-not-installed 'org-roam-ui)                                        ;; Paquete estandar de org-roam-ui
;;(add-to-list 'load-path "/home/sherlockes/Descargas/org-roam-ui")                           ;; Paquete con capacidad de exportar
(require 'org-roam-ui)

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
(setq yas-snippet-dirs (list(concat user-dir "/dotfiles/emacs/.emacs.d/snippets")))
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
(add-hook 'org-mode-hook 'flyspell-mode)                                                    ;; Habilita la correción ortográfica para archivos Org-mode
(add-hook 'flyspell-mode-hook 'flyspell-buffer)                                             ;; Corrige el buffer cuando se habilita la corrección


;;;;;;;;;;;
;; Otros ;;
;;;;;;;;;;;
(put 'downcase-region 'disabled nil)                                                        ;; Habilita el comando para pasar a minúsculas
(put 'upcase-region 'disabled nil)                                                          ;; Habilita el comando para pasar a mayúsculas
(put 'erase-buffer 'disabled nil)                                                           ;; Habilita el comando de borrado del buffer
(global-visual-line-mode t)                                                                 ;; Ajuste de línea
(add-to-list 'display-buffer-alist '("^\\*shell\\*" . (display-buffer-same-window . nil)))  ;; Mostrar la sesión de terminal en el mismo buffer

;;;;;;;;;;;;;;;;;;;;;;;
;; Ajatos de teclado ;;
;;;;;;;;;;;;;;;;;;;;;;;

;; generales
(global-set-key (kbd "<f1>") 'reiniciar)                                                    ;; Reiniciar emacs
(global-set-key (kbd "<f2>") (lambda() (interactive)(org-roam-ui-mode t)))                  ;; Lanza Org-roam-ui
(global-set-key (kbd "<f4>") 'brainblog)                                                    ;; Modo de edición del blog
(global-set-key (kbd "<f5>") 'flyspell-mode)
(global-set-key (kbd "<f6>") (kbd "C-u C-c C-c"))                                           ;; Exportar de nuevo
(global-set-key (kbd "<f7>") 'fd-switch-dictionary)                                         ;; Cambio de diccionario

(global-set-key (kbd "C-x C-b") 'ibuffer)                                                   ;; Cambio de buffer
(global-set-key (kbd "C-c r") 'query-replace-regexp)                                        ;; Buscar y reemplazar
(global-set-key (kbd "C-c s") 'counsel-rg)                                                  ;; Buscar mediante counsel y ripgrep
(global-set-key (kbd "C-<escape>") 'mostrar-dashboard)

;; Org-Roam
(global-set-key (kbd "C-c n f") 'org-roam-node-find)                                        ;; Buscar o crear un Nodo
(global-set-key (kbd "C-c n l") 'org-roam-buffer-toggle)                                    ;; Mostrar/Ocultar el Buffer Org-Roam
(global-set-key (kbd "C-c n i") 'org-roam-node-insert)                                      ;; Insertar un enlace
(global-set-key (kbd "C-c n t") 'org-roam-tag-add)                                          ;; Añadir un Tag
(global-set-key (kbd "C-c n a") 'org-roam-alias-add)                                        ;; Añadir un Alias
(global-set-key (kbd "C-c n o") 'org-id-get-create)                                         ;; Convertir encabezado en nodo

;;
(split-window-right)
(dashboard-open)

