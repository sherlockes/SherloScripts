;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Script Name: init.el                            ;;
;; Description: Archivo de configuración de Emacs  ;;
;; Args: N/A                                       ;;
;; Creation/Update: 20200225/20260421              ;; 
;; Author: www.sherblog.es                         ;;                      
;; Email: sherlockes@gmail.com                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Antes de arrancar emacs con esta configuración hay que copiar las llaves ssh del puesto donde se esté arrancando emacs a Gitlab y Github

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Archivo ubicado en "~/.emacs" ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (setq user-dir (expand-file-name "~"))
;; (setq user-init-file (concat user-dir "/dotfiles/emacs/.emacs.d/init.el"))
;; (load user-init-file)

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Añadir repositorios ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'package)

(setq package-enable-at-startup nil)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("nongnu"   . "https://elpa.nongnu.org/nongnu/") t)
(add-to-list 'package-archives '( "jcs-elpa" . "https://jcs-emacs.github.io/jcs-elpa/packages/") t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Inicializar y actualizar paquetes ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(package-initialize)

(setq package-archive-priorities
      '(("melpa" . 20)
        ("nongnu" . 10)
        ("gnu" . 5)
        ("jcs-elpa" . 0)))

(unless package-archive-contents
  (package-refresh-contents))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ubicación de directorios ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Directorios de configuración, por defecto y HOME
(setq user-emacs-directory (concat user-dir "/.emacs.d/"))
(setq default-directory user-dir)
(setenv "HOME" user-dir)

;; Directorio para repo SherloScripts
(setq script-dir (concat user-dir "/SherloScripts/"))
(setq script-repo "git@github.com:sherlockes/SherloScripts.git")

;; Directorio para la Actualizacion del Blog
(setq blog-dir (concat user-dir "/sherlockes.github.io/"))
(setq blog-repo "git@github.com:sherlockes/sherlockes.github.io.git")

;; Directorio para la exportación de Org-Roam
(setq brain-dir (concat user-dir "/brain/"))
(setq brain-repo "git@github.com:sherlockes/brain.git")
(setq brain-roam-dir (concat brain-dir "org-files"))

;; Ubicación del archivo de favoritos
(setq bookmark-default-file "~/dotfiles/emacs/.emacs.d/bookmarks")

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuración externa ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Carga el archivo externo de funciones
(load-file (concat user-dir "/dotfiles/emacs/.emacs.d/functions.el"))

;; Configura shell-command para permitir alias y elimina el warning cl obsoleto
(setq shell-command-switch "-ic")
(setq byte-compile-warnings '(cl-functions))



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
 '(exec-path
   '("/home/sherlockes/.local/bin" "/usr/local/sbin" "/usr/local/bin" "/usr/sbin" "/usr/bin" "/sbin" "/bin" "/usr/games" "/usr/local/games" "/snap/bin" "/usr/lib/emacs/28.1/x86_64-linux-gnu" "/usr/bin/python"))
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
 '(org-babel-load-languages '((shell . t) (python . t) (emacs-lisp . t)))
 '(org-link-elisp-skip-confirm-regexp ".*")
 '(org-roam-capture-templates
   '(("d" "default" plain "%?" :target
      (file+head "${slug}.org" "#+title: ${title}\12#+STARTUP: overview\12#+date: %<%Y-%m-%d>\12#+filetags: :tag_1:tag_2:")
      :unnarrowed t)))
 '(org-tags-column -60)
 '(package-selected-packages
   '(web-mode org-roam counsel swiper yaml-mode all-the-icons spaceline-all-the-icons yasnippet org-roam-ui gptel page-break-lines dashboard ox-hugo wgrep ivy vertico whole-line-or-region markdown-mode htmlize gnu-elpa-keyring-update))
 '(python-shell-interpreter "/usr/bin/python3\12")
 '(remote-shell-program "ssh")
 '(safe-local-variable-values '((ENCODING . UTF-8) (encoding . utf-8)))
 '(tramp-default-method "ssh")
 '(tramp-encoding-shell "/bin/bash"))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(web-mode-current-element-highlight-face ((t (:background "#e2e8f0" :foreground "#000000" :weight bold)))))

;;;;;;;;;;;;;;;;;;;;;;;;
;; Archivos recientes ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Activa modo y nº de archivos a mostrar
(recentf-mode 1)
(setq recentf-max-saved-items 10)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ocultar barras y pantalla de inicio ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(setq inhibit-startup-screen t)

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Arrancar maximizado ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;;;;;;;;;;;;;;;
;; Saveplace ;;
;;;;;;;;;;;;;;;

(my-install-package-if-not-installed 'saveplace)
(save-place-mode 1)
(setq save-place-file (expand-file-name ".emacs-places" user-emacs-directory))

;;;;;;;;;;;;;;
;; Web-mode ;;
;;;;;;;;;;;;;;

(my-install-package-if-not-installed 'web-mode)

;; Asociar extensiones de archivo
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))

;; Configurar el resaltado que tú quieres
(setq web-mode-enable-current-element-highlight t)

;; Opcional: Cambiar el color del resaltado para que se vea claro
;; Aquí lo ponemos con un fondo gris suave, puedes cambiar el color


;;;;;;;;;;;;;;;
;; Dashboard ;;
;;;;;;;;;;;;;;;

(my-install-package-if-not-installed 'dashboard)
(my-install-package-if-not-installed 'page-break-lines)

(setq dashboard-set-navigator t)

(setq dashboard-items '((recents  . 10)
                        (bookmarks . 10)))

(setq dashboard-init-info "F1(Reboot) F2(Org-Roam) F4(HugoSer) F5(Orto) F7(Dicc) F8(Eval-Py)
RipGrep(C-c s) Nodo OrgRoam(C-c n f) Mostrar ocultos(M-o) Truncate(C-x x t)")

(setq dashboard-navigator-buttons
      `(;; line1
        (
	        ("" "C-Esc (Init)" "" (lambda (&rest _) (mostrar-dashboard)))
            ("" "Sherblog" "" (lambda (&rest _) (browse-url "http://www.sherblog.es")))
	        ("" "My Brain" "" (lambda (&rest _) (browse-url "http://www.sherblog.es/brain")))
	    )
       )
)

(with-eval-after-load 'dashboard
  (advice-add 'widget-backward :around
              (lambda (orig-fun &rest args)
                (ignore-errors (apply orig-fun args)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ivy + Swiper (Requieren wgrep) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(my-install-package-if-not-installed 'wgrep)
(my-install-package-if-not-installed 'ivy)
(my-install-package-if-not-installed 'swiper)

(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)
(global-set-key "\C-s" 'swiper)
(setq swiper-stay-on-quit t)
(ivy-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Actualización del Blog ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Actualiza el directorio o lo clona si no existe
(if (file-exists-p blog-dir)
    (let ((default-directory blog-dir))(call-process "git" nil nil nil "pull"))
  (let ((default-directory "~/"))(shell-command (concat "git clone " blog-repo)))
)

(add-hook 'after-save-hook (lambda () (when (and buffer-file-name (string-prefix-p blog-dir buffer-file-name))(funcion-al-guardar))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Actualización del SherloScripts ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(if (file-exists-p script-dir)                                                                ;; Actualiza el repositorio brain o lo clona si no existe
    (let ((default-directory script-dir))(call-process "git" nil nil nil "pull"))
  (let ((default-directory "~/"))(shell-command (concat "git clone " script-repo)))
)

(add-hook 'after-save-hook (lambda () (when (and buffer-file-name (string-prefix-p script-dir buffer-file-name))(funcion-al-guardar))))

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CONFIGURACIÓN ORG-ROAM  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq org-roam-database-connector 'sqlite)

;; Actualiza el directorio o lo clona si no existe
(if (file-exists-p blog-dir)
    (let ((default-directory brain-dir))(call-process "git" nil nil nil "pull"))
  (let ((default-directory "~/"))(shell-command (concat "git clone " brain-repo)))
)

;; 1. Instalación
(unless (package-installed-p 'org-roam)
  (package-install 'org-roam))

;; Gestión del repositorio Brain (Rutas relativas a tu usuario)
(setq brain-dir (expand-file-name "~/brain" user-emacs-directory))
(setq brain-roam-dir (concat brain-dir "/org-files"))



;; Directorios y DB
(setq org-roam-directory (file-truename brain-roam-dir))
(setq org-roam-db-location (expand-file-name "org-files/org-roam.db" brain-dir))

;; Modos y Completado
(org-roam-db-autosync-mode)
(setq org-id-extra-files (directory-files-recursively org-roam-directory "\.org$"))
(setq org-roam-completion-everywhere t)
(setq org-id-link-to-org-use-id t)
(setq org-export-with-broken-links 'mark)

;; Hook al guardar
(defun my/org-roam-push-changes ()
  "Sincroniza la DB, añade, hace commit y sube los cambios automáticamente."
  (when (and (buffer-file-name)
             (string-prefix-p (expand-file-name org-roam-directory) (buffer-file-name)))
    (let ((default-directory org-roam-directory))
      ;; 1. Sincronizamos la base de datos primero
      (org-roam-db-sync)
      ;; 2. Ejecutamos Git (incluyendo el .db actualizado)
      (shell-command "git add . && git commit -m 'Auto-update notas y DB' && git push")
      (message "Notas y DB sincronizadas con GitHub"))))

(add-hook 'after-save-hook #'my/org-roam-push-changes)

;;;;;;;;;;;;;;;;;;;;
;; Añadir htmlize ;;
;;;;;;;;;;;;;;;;;;;;
(my-install-package-if-not-installed 'htmlize)

;;;;;;;;;;;;;;;;;;;
;; Añadir Dired+ ;;
;;;;;;;;;;;;;;;;;;;

(let ((url "https://raw.githubusercontent.com/emacsmirror/dired-plus/master/dired+.el"))
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

;; Activar outline-minor-mode
(add-hook 'markdown-mode-hook 'outline-minor-mode)
;; Actualizar fecha al guardar
;;(add-hook 'markdown-mode-hook #'add-markdown-save-hook)

;;;;;;;;;;;;;;;;;;;;;;
;; Añadir Yaml-Mode ;;
;;;;;;;;;;;;;;;;;;;;;;

(my-install-package-if-not-installed 'yaml-mode)
(require 'yaml-mode)

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
(my-install-package-if-not-installed 'eglot)
(add-hook 'python-mode-hook 'eglot-ensure)
;; NECESARIO npm install -g pyright

;;(my-install-package-if-not-installed 'elpy)
;;(elpy-enable)
;;(setq python-shell-interpreter "/usr/local/bin/python3")
;;(setq python-shell-interpreter "python3")
;;(setq elpy-rpc-python-command "/usr/local/bin/python3")
;;(setq elpy-rpc-virtualenv-path (quote system))
(setq org-src-fontify-natively t)
(setq org-confirm-babel-evaluate nil)
;;(setq python-shell-interpreter "ipython" python-shell-interpreter-args "-i --simple-prompt")
(setq org-babel-python-command "python3")
(setq python-shell-interpreter "python3" python-shell-interpreter-args "-i")

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Funciones para categorías y tags de los artículos del blog ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-hugo-extract-metadata (type)
  "Busca metadatos (categories o tags) en Hugo, silencia errores y unifica en minúsculas."
  (let* ((posts-path (expand-file-name "content/post" blog-dir))
         ;; 1. tr '[:upper:]' '[:lower:]' convierte todo a minúsculas
         ;; 2. 2>/dev/null intenta silenciar errores de shell
         (cmd (format "grep -rPh -A 10 '^%s:' %s 2>/dev/null | grep '^  - \"' | sed -n 's/.*\"\\(.*\\)\".*/\\1/p' | tr '[:upper:]' '[:lower:]' | sort -u" 
                      type posts-path))
         (raw-output (shell-command-to-string cmd))
         (lines (split-string raw-output "\n" t)))
    ;; Filtro extra de seguridad: eliminar cualquier línea que contenga "bash:" 
    ;; o que empiece por mensajes de error conocidos.
    (seq-filter (lambda (line) 
                  (not (or (string-match-p "bash:" line)
                           (string-match-p "ioctl" line)
                           (string-match-p "control de trabajos" line))))
                lines)))

(defun my-blog-select-categories-dynamic ()
  "Selector dinámico de categorías."
  (completing-read "Categoría: " (my-hugo-extract-metadata "categories")))

(defun my-blog-select-tags-dynamic ()
  "Selector múltiple dinámico de etiquetas."
  (let ((choices (completing-read-multiple "Etiquetas (SEP CON COMA): " (my-hugo-extract-metadata "tags"))))
    (mapconcat (lambda (x) (concat "\n  - \"" x "\"")) choices "")))

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

;; No exportar subindices en ORG-Mode
(setq org-export-with-sub-superscripts '{})

;; Compatibilidad de ivy con tags de org-roam
(setq org-roam-completion-everywhere t)
(setq org-roam-db-node-include-function 
      (lambda () 
        (not (member "trash" (org-get-tags)))))

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
(global-set-key (kbd "<f8>") 'eval_or_close_python)
(global-set-key (kbd "<f9>") 'org-babel-execute-buffer)

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


