;;; init.el --- Configuración limpia Emacs 30.2 -*- lexical-binding: t; -*-

;;; ###################################################################
;;; File Name: init.el
;;; Description: Configuración personal de Emacs
;;; Args: N/A
;;; Creation/Update: 20260424/20260425
;;; Author: www.sherblog.es
;;; Email: sherlockes@gmail.com
;;; ###################################################################

;;; Rendimiento inicial
(setq gc-cons-threshold (* 50 1000 1000))

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 2 1000 1000))
            (message "Emacs cargado en %.2f segundos con %d recolecciones de basura."
                     (float-time
                      (time-subtract after-init-time before-init-time))
                     gcs-done)))

;;; Interfaz básica
(setq inhibit-startup-screen t)

;;; Bootstrap de straight.el
(defvar bootstrap-version)

(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        user-emacs-directory))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent
         'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(message "straight.el cargado correctamente")

;;; use-package
(straight-use-package 'use-package)

(setq straight-use-package-by-default t)

(require 'use-package)

(message "use-package cargado correctamente")

;;; Reiniciar Emacs (Asigna F1 a reiniciar)
(use-package restart-emacs
  :bind
  ("<f1>" . restart-emacs)
  :commands restart-emacs)

;;; Utilidades básicas
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)

(fset 'yes-or-no-p 'y-or-n-p)

(savehist-mode 1)
(recentf-mode 1)
(save-place-mode 1)
(setq save-place-file (expand-file-name ".emacs-places" user-emacs-directory))

(setq history-length 100)
(setq recentf-max-saved-items 100)

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(column-number-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  Rutas personales  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar my/user-dir
  (expand-file-name "~")
  "Directorio personal del usuario.")

(defvar my/script-dir
  (expand-file-name "SherloScripts" my/user-dir)
  "Directorio de scripts personales.")

(defvar my/blog-dir
  (expand-file-name "sherlockes.github.io" my/user-dir)
  "Directorio del blog Hugo.")

(defvar my/brain-dir
  (expand-file-name "brain" my/user-dir)
  "Directorio principal del brain.")

(defvar my/brain-roam-dir
  (expand-file-name "org-files" my/brain-dir)
  "Directorio de notas org-roam.")

(defvar my/emacs-config-dir
  (expand-file-name "~/SherloScripts/emacs/.emacs.d/")
  "Directorio compartido de configuración de Emacs.")

(defvar my/snippets-dir
  (expand-file-name "snippets/" my/emacs-config-dir)
  "Directorio de snippets personales.")

(defvar my/bookmarks-file
  (expand-file-name "bookmarks" my/emacs-config-dir)
  "Archivo de bookmarks de Emacs.")

(setq bookmark-default-file my/bookmarks-file)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  Repositorios personales  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar my/script-repo
  "git@github.com:sherlockes/SherloScripts.git"
  "Repositorio de scripts personales.")

(defvar my/blog-repo
  "git@github.com:sherlockes/sherlockes.github.io.git"
  "Repositorio del blog.")

(defvar my/brain-repo
  "git@github.com:sherlockes/brain.git"
  "Repositorio del brain.")

(defun my/git-clone-if-missing (directory repo)
  "Clona REPO en DIRECTORY si DIRECTORY no existe."
  (unless (file-directory-p directory)
    (let ((default-directory my/user-dir))
      (message "Clonando %s..." repo)
      (shell-command (format "git clone %s" repo)))))

(defun my/setup-personal-repositories ()
  "Comprueba y clona repositorios personales si faltan."
  (interactive)
  (my/git-clone-if-missing my/script-dir my/script-repo)
  (my/git-clone-if-missing my/blog-dir my/blog-repo)
  (my/git-clone-if-missing my/brain-dir my/brain-repo)
  (message "Repositorios personales comprobados."))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Pull inicial de repos personales
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar my/auto-pull-personal-repos-on-startup t
  "Si es no nil, actualiza repos personales al iniciar Emacs.")

(defun my/git-pull-repo-safe (dir)
  "Hace git pull --ff-only en DIR si es un repositorio Git."
  (when (file-directory-p (expand-file-name ".git" dir))
    (let ((default-directory dir))
      (message "Git pull: %s" dir)
      (let ((exit-code
             (call-process "git" nil "*my-git-pull*" t
                           "pull" "--ff-only")))
        (if (= exit-code 0)
            (message "Git pull OK: %s" dir)
          (message "Git pull ERROR en %s. Revisa *my-git-pull*" dir))))))

(defun my/pull-personal-repos ()
  "Actualiza repositorios personales."
  (interactive)
  (get-buffer-create "*my-git-pull*")
  (with-current-buffer "*my-git-pull*"
    (erase-buffer))
  (my/git-pull-repo-safe my/script-dir)
  (my/git-pull-repo-safe my/blog-dir)
  (my/git-pull-repo-safe my/brain-dir)
  (message "Pull de repos personales terminado."))

(add-hook 'emacs-startup-hook
          (lambda ()
            (when my/auto-pull-personal-repos-on-startup
              (my/pull-personal-repos))))

;;;;;;;;;;;;;;;
;;;  Dired  ;;;
;;;;;;;;;;;;;;;

(use-package dired
  :straight (:type built-in)
  :commands (dired dired-jump)
  :config
  (setq dired-listing-switches "-alh --group-directories-first"
        delete-by-moving-to-trash t
        dired-dwim-target t)

  (add-hook 'dired-mode-hook #'dired-hide-details-mode)

  :bind
  (:map dired-mode-map
        ("<f1>" . restart-emacs)
        ("M-<up>" . dired-up-directory)
        ("M-<down>" . dired-find-file)
        ("M-o" . dired-hide-details-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  Ayuda de atajos  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package which-key
  :defer 1
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 0.5))

;;; Minibuffer: Ivy / Counsel / Swiper
(use-package ivy
  :diminish
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t
        ivy-count-format "(%d/%d) "
        enable-recursive-minibuffers t))

(use-package counsel
  :after ivy
  :bind
  (("M-x"     . counsel-M-x)
   ("C-x C-f" . counsel-find-file)
   ("C-c k"   . counsel-rg)
   ("C-c j"   . counsel-git)))

(use-package swiper
  :after ivy
  :bind
  (("C-s" . swiper)))

(global-set-key (kbd "C-c r") #'query-replace-regexp)
(global-set-key (kbd "C-c s") #'counsel-rg)
(setq counsel-rg-base-command
      "rg -S --no-heading --line-number --color never %s .")

;;;;;;;;;;;;;;;;;;;;;
;;;  Tema visual  ;;;
;;;;;;;;;;;;;;;;;;;;;

(use-package doom-themes
  :config
  (load-theme 'doom-one t))

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  Fuente y aspecto  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

(set-face-attribute 'default nil
                    :font "DejaVu Sans Mono"
                    :height 100)

(global-hl-line-mode 1)
(blink-cursor-mode -1)

(setq-default cursor-type 'bar)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  Modos de edición: Markdown / YAML / Web  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package markdown-mode
  :mode ("\\.md\\'" . markdown-mode)
  :hook
  (markdown-mode . outline-minor-mode))

(use-package yaml-mode
  :mode ("\\.ya?ml\\'" . yaml-mode))

(use-package web-mode
  :mode
  (("\\.html?\\'" . web-mode)
   ("\\.css\\'"   . web-mode)
   ("\\.js\\'"    . web-mode)
   ("\\.php\\'"   . web-mode))
  :config
  (setq web-mode-enable-current-element-highlight t))

;;;;;;;;;;;;;;;;;;
;;;  Snippets  ;;;
;;;;;;;;;;;;;;;;;;

(use-package yasnippet
  :config
  (setq yas-snippet-dirs
        (list my/snippets-dir))
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :after yasnippet)

;;;;;;;;;;;;;;;;;;;;;
;;;  Auto-insert  ;;;
;;;;;;;;;;;;;;;;;;;;;

(use-package autoinsert
  :straight (:type built-in)
  :config
  (setq auto-insert-query nil)
  (auto-insert-mode 1))

;; ------------------------------------------------------------
;; Auto insertar snippet YAS en nuevos archivos .sh vacíos
;; ------------------------------------------------------------

(require 'yasnippet)
(yas-global-mode 1)

(defun my/auto-insert-shell-snippet ()
  "Expande el snippet 'script' al crear un .sh vacío."
  (when (and buffer-file-name
             (string-match-p "\\.sh\\'" buffer-file-name)
             (= (buffer-size) 0))
    (sh-mode)
    (yas-minor-mode 1)
    (yas-reload-all)
    (let ((snippet (yas-lookup-snippet "script" 'sh-mode)))
      (if snippet
          (yas-expand-snippet snippet)
        (message "No se encontró el snippet 'script' para sh-mode")))))

(add-hook 'find-file-hook #'my/auto-insert-shell-snippet)

(defun my/make-script-executable ()
  "Hace ejecutables los scripts .sh al guardar."
  (when (and buffer-file-name
             (string-match-p "\\.sh\\'" buffer-file-name))
    (set-file-modes buffer-file-name #o755)))

(add-hook 'after-save-hook #'my/make-script-executable)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Auto-insert posts Markdown blog ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my/file-inside-blog-p ()
  "Devuelve t si el archivo actual está dentro del blog."
  (and buffer-file-name
       (my/file-inside-directory-p buffer-file-name my/blog-dir)))

(defun my/insert-blog-post-template-if-new ()
  "Inserta el snippet 'post' en archivos Markdown nuevos dentro del blog."
  (when (and buffer-file-name
             (my/file-inside-blog-p)
             (string-match-p "\\.md\\'" buffer-file-name)
             (= (buffer-size) 0))
    (markdown-mode)
    (yas-minor-mode 1)
    (let ((snippet (yas-lookup-snippet "post" 'markdown-mode)))
      (if snippet
          (yas-expand-snippet snippet)
        (message "No se encontró el snippet 'post' para markdown-mode")))))

(add-hook 'find-file-hook #'my/insert-blog-post-template-if-new)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Blog: categorías y tags dinámicos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'seq)

(defun my/hugo-posts-path ()
  "Devuelve la ruta de posts del blog Hugo."
  (let ((path1 (expand-file-name "content/post" my/blog-dir))
        (path2 (expand-file-name "content/posts" my/blog-dir)))
    (cond
     ((file-directory-p path1) path1)
     ((file-directory-p path2) path2)
     (t path1))))

(defun my/hugo-extract-metadata (type)
  "Extrae metadatos TYPE de posts Hugo existentes."
  (let* ((posts-path (shell-quote-argument (my/hugo-posts-path)))
         (cmd (format
               "grep -rPh -A 10 '^%s:' %s 2>/dev/null | grep '^  - \"' | sed -n 's/.*\"\\(.*\\)\".*/\\1/p' | tr '[:upper:]' '[:lower:]' | sort -u"
               type posts-path))
         (raw-output (shell-command-to-string cmd))
         (lines (split-string raw-output "\n" t)))
    (seq-filter
     (lambda (line)
       (not (or (string-match-p "bash:" line)
                (string-match-p "ioctl" line)
                (string-match-p "control de trabajos" line))))
     lines)))

(defun my/blog-select-category-dynamic ()
  "Selecciona una categoría existente del blog."
  (completing-read "Categoría: "
                   (my/hugo-extract-metadata "categories")
                   nil nil))

(defun my/blog-select-tags-dynamic ()
  "Selecciona múltiples tags existentes del blog."
  (let ((choices
         (completing-read-multiple
          "Etiquetas separadas por coma: "
          (my/hugo-extract-metadata "tags"))))
    (mapconcat
     (lambda (tag)
       (concat "\n  - \"" tag "\""))
     choices
     "")))

;;;;;;;;;;;;;;;;;;
;;;  Org mode  ;;;
;;;;;;;;;;;;;;;;;;

(use-package org
  :straight (:type built-in)
  :mode ("\\.org\\'" . org-mode)
  :config
  (setq org-directory my/brain-roam-dir
        org-startup-indented t
        org-hide-emphasis-markers t
        org-return-follows-link t
        org-src-fontify-natively t
        org-src-tab-acts-natively t
        org-confirm-babel-evaluate nil)

  (setq org-babel-python-command "python3")

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (shell . t))))

;;;;;;;;;;;;;;;;;
;;; Transient ;;;
;;;;;;;;;;;;;;;;;

(use-package transient
  :straight (:host github
             :repo "magit/transient"
             :tag "v0.3.7")
  :demand t)

;;;;;;;;;;;;;;;;;;
;;;  Org-roam  ;;;
;;;;;;;;;;;;;;;;;;

(use-package org-roam
  :ensure nil
  :straight t
  :demand t
  :init
  (setq org-roam-directory (file-truename my/brain-roam-dir)
        org-roam-completion-everywhere t)
  :bind
  (("C-c n l" . org-roam-buffer-toggle)
   ("C-c n f" . org-roam-node-find)
   ("C-c n g" . org-roam-graph)
   ("C-c n i" . org-roam-node-insert)
   ("C-c n c" . org-roam-capture))
  :config
  (org-roam-db-autosync-mode 1)
  (message "Org-roam cargado correctamente desde %s" org-roam-directory))

;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Org-roam avanzado ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(setq org-roam-db-location
      (expand-file-name "org-roam.db" user-emacs-directory))

(setq org-id-extra-files
      (when (file-directory-p my/brain-roam-dir)
        (directory-files-recursively my/brain-roam-dir "\\.org$")))

(defun my/org-roam-node-is-trash-p (node)
  "Devuelve t si NODE tiene el tag trash."
  (member "trash" (org-roam-node-tags node)))

(setq org-roam-node-include-function
      (lambda (node)
        (not (my/org-roam-node-is-trash-p node))))

(setq org-roam-capture-templates
      '(("d" "default" plain
         "%?"
         :target
         (file+head
          "%<%Y%m%d%H%M%S>-${slug}.org"
          "#+title: ${title}\n#+created: %U\n#+lastmod: %U\n\n")
         :unnarrowed t)))

;;;;;;;;;;;;;;;;;
;;; Org-roam UI
;;;;;;;;;;;;;;;;;

(use-package org-roam-ui
  :after org-roam
  :bind
  ("<f2>" . org-roam-ui-mode)
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

;;;;;;;;;;;;;;;;;
;;; Dashboard ;;;
;;;;;;;;;;;;;;;;;

(use-package page-break-lines
  :config
  (global-page-break-lines-mode 1))

(use-package nerd-icons)

(use-package dashboard
  :after page-break-lines
  :config
  (setq dashboard-startup-banner 'official
        dashboard-center-content t
        dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-init-info
        "F1(Reboot) F2(Org-Roam) F5(Orto) F7(Dicc)
RipGrep(C-c s) Nodo OrgRoam(C-c n f) Mostrar ocultos(M-o) Truncate(C-x x t)"
        dashboard-items '((recents . 10)
                          (bookmarks . 10))
        dashboard-item-names '(("Recent Files:" . "Archivos recientes:")
                               ("Bookmarks:" . "Marcadores:")))

  (dashboard-setup-startup-hook))

(defun my/open-dashboard ()
  "Muestra dashboard a la izquierda y conserva el buffer actual a la derecha."
  (interactive)
  (let ((buf (current-buffer)))
    (unless (= (count-windows) 2)
      (delete-other-windows)
      (split-window-right))

    (let* ((windows (window-list nil 'no-minibuf))
           (left-window (car (sort windows
                                   (lambda (w1 w2)
                                     (< (car (window-edges w1))
                                        (car (window-edges w2)))))))
           (right-window (cadr (sort windows
                                     (lambda (w1 w2)
                                       (< (car (window-edges w1))
                                          (car (window-edges w2))))))))

      (set-window-buffer left-window "*dashboard*")
      (with-current-buffer "*dashboard*"
        (dashboard-refresh-buffer))

      (unless (eq buf (get-buffer "*dashboard*"))
        (set-window-buffer right-window buf))

      (select-window left-window))))

(global-set-key (kbd "C-<escape>") #'my/open-dashboard)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Pantalla inicial: dashboard + mensajes ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my/startup-dashboard-and-messages ()
  "Muestra dashboard a la izquierda y *Messages* a la derecha."
  (delete-other-windows)
  (split-window-right)

  (let* ((windows (window-list nil 'no-minibuf))
         (left-window (car windows))
         (right-window (cadr windows)))
    (set-window-buffer left-window "*dashboard*")
    (with-current-buffer "*dashboard*"
      (dashboard-refresh-buffer))
    (set-window-buffer right-window "*Messages*")
    (select-window left-window)))

(add-hook 'emacs-startup-hook #'my/startup-dashboard-and-messages)

;;;;;;;;;;;;;;;;;;;;;
;;; Edición general
;;;;;;;;;;;;;;;;;;;;;

(use-package whole-line-or-region
  :demand t
  :config
  (whole-line-or-region-global-mode 1))

(global-visual-line-mode 1)
(delete-selection-mode 1)

(global-set-key (kbd "C-x C-b") #'ibuffer)
(global-set-key (kbd "C-c r") #'replace-regexp)

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'erase-buffer 'disabled nil)

(setq ibuffer-expert t)

(defun my/open-shell-same-window ()
  "Abre shell en la misma ventana."
  (interactive)
  (shell (generate-new-buffer-name "*shell*")))

(global-set-key (kbd "C-c t") #'my/open-shell-same-window)

;;;;;;;;;;;;;;;;;
;;; Ortografía ;;;
;;;;;;;;;;;;;;;;;

(setq ispell-dictionary "spanish")

(defun my/toggle-flyspell ()
  "Activa o desactiva flyspell en el buffer actual."
  (interactive)
  (if (bound-and-true-p flyspell-mode)
      (flyspell-mode -1)
    (flyspell-mode 1)))

(defun my/switch-dictionary ()
  "Alterna el diccionario entre español e inglés."
  (interactive)
  (let ((new-dict (if (string= ispell-current-dictionary "spanish")
                      "english"
                    "spanish")))
    (ispell-change-dictionary new-dict)
    (message "Diccionario cambiado a: %s" new-dict)))

(global-set-key (kbd "<f5>") #'my/toggle-flyspell)
(global-set-key (kbd "<f7>") #'my/switch-dictionary)

(add-hook 'org-mode-hook #'flyspell-mode)
(add-hook 'markdown-mode-hook #'flyspell-mode)

;;;; ------------------------------------------------------------------
;;;; Actualización automática de fechas (compatibilidad antigua + nueva)
;;;; ------------------------------------------------------------------

(defun my/update-file-dates ()
  "Actualiza fechas según tipo de archivo manteniendo formatos antiguos y nuevos."
  (when buffer-file-name
    (save-excursion
      (goto-char (point-min))
      (let ((ext (file-name-extension buffer-file-name))
            (today-iso (format-time-string "%Y-%m-%d"))
            (today-compact (format-time-string "%Y%m%d")))

        ;; ------------------------------------------------------------
        ;; Shell scripts
        ;; Antiguo: #Creation/Update: 20240101/20240101
        ;; Nuevo:   # Fecha: 2024-01-01
        ;; ------------------------------------------------------------
        (when (string= ext "sh")
          (goto-char (point-min))
          (when (re-search-forward
                 "^#Creation/Update:[ \t]*\\([0-9]\\{8\\}\\)/\\([0-9]\\{8\\}\\)$"
                 nil t)
            (replace-match
             (concat "#Creation/Update: "
                     (match-string 1)
                     "/"
                     today-compact)
             t t))

          (goto-char (point-min))
          (when (re-search-forward "^# Fecha:[ \t]*.*$" nil t)
            (replace-match (concat "# Fecha: " today-iso) t t)))

        ;; ------------------------------------------------------------
        ;; Markdown
        ;; date: "2024-01-01"
        ;; date: 2024-01-01
        ;; ------------------------------------------------------------
        (when (string= ext "md")
          (goto-char (point-min))
          (when (re-search-forward "^date:[ \t]*\"?[0-9-]+\"?$" nil t)
            (replace-match (concat "date: \"" today-iso "\"") t t)))

	;; ------------------------------------------------------------
	;; Emacs Lisp
	;; Creation/Update: 20260426/20260426
	;; ------------------------------------------------------------
	(when (string= ext "el")
	  (goto-char (point-min))
	  (when (re-search-forward
		 "^;;; Creation/Update:[ \t]*\\([0-9]\\{8\\}\\)/\\([0-9]\\{8\\}\\)$"
		 nil t)
	    (replace-match
	     (concat ";;; Creation/Update: "
		     (match-string 1)
		     "/"
		     today-compact)
	     t t)))

        ;; ------------------------------------------------------------
        ;; Org mode
        ;; #+date: <2024-01-01>
        ;; #+lastmod: 2024-01-01
        ;; ------------------------------------------------------------
        (when (string= ext "org")
          (goto-char (point-min))
          (when (re-search-forward "^#\\+date:[ \t]*<.*>$" nil t)
            (replace-match (concat "#+date: <" today-iso ">") t t))

          (goto-char (point-min))
          (when (re-search-forward "^#\\+lastmod:[ \t]*.*$" nil t)
            (replace-match (concat "#+lastmod: " today-iso) t t)))))))

(add-hook 'before-save-hook #'my/update-file-dates)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Git auto commit / push  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar my/auto-git-push-on-save t
  "Si es no nil, hace commit y push automático al guardar en repos personales.")

(defun my/file-inside-directory-p (file dir)
  "Devuelve t si FILE está dentro de DIR."
  (let ((file (file-truename file))
        (dir (file-name-as-directory (file-truename dir))))
    (string-prefix-p dir file)))

(defun my/current-repo-root ()
  "Devuelve el repo personal al que pertenece el buffer actual."
  (when buffer-file-name
    (cond
     ((my/file-inside-directory-p buffer-file-name my/script-dir) my/script-dir)
     ((my/file-inside-directory-p buffer-file-name my/blog-dir) my/blog-dir)
     ((my/file-inside-directory-p buffer-file-name my/brain-dir) my/brain-dir)
     (t nil))))

(defun my/git-auto-commit-push ()
  "Hace commit y push del repo personal asociado al archivo actual."
  (when (and my/auto-git-push-on-save
             buffer-file-name)
    (let ((repo (my/current-repo-root)))
      (when repo
        (let ((default-directory repo)
              (msg (format "Auto update from Emacs: %s"
                           (file-name-nondirectory buffer-file-name))))
          (call-process "git" nil "*my-git-auto*" t "add" ".")
          (call-process "git" nil "*my-git-auto*" t "commit" "-m" msg)
          (call-process "git" nil "*my-git-auto*" t "push")
          (message "Git push realizado en %s"
                   (file-name-nondirectory repo)))))))

(add-hook 'after-save-hook #'my/git-auto-commit-push)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Auto-insert posts Markdown blog ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my/file-inside-blog-p ()
  "Devuelve t si el archivo actual está dentro del blog."
  (and buffer-file-name
       (my/file-inside-directory-p buffer-file-name my/blog-dir)))

(defun my/auto-insert-blog-post-snippet ()
  "Inserta plantilla Yasnippet para posts Markdown del blog."
  (when (and (my/file-inside-blog-p)
             (derived-mode-p 'markdown-mode))
    (yas-expand-snippet
     (yas-lookup-snippet "post" 'markdown-mode))))

(defun my/insert-blog-post-template-if-new ()
  "Inserta plantilla de post en archivos Markdown nuevos del blog."
  (when (and buffer-file-name
             (my/file-inside-blog-p)
             (= (buffer-size) 0)
             (string-match-p "\\.md\\'" buffer-file-name))
    (markdown-mode)
    (my/auto-insert-blog-post-snippet)))

(add-hook 'find-file-hook #'my/insert-blog-post-template-if-new)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  Configuración de Tramp  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq tramp-default-method "ssh")
(setq tramp-verbose 1)

;; ------------------------------------------------------------
;; Bookmarks SSH dinámicos: LAN / ZeroTier
;; ------------------------------------------------------------

(defvar my/dynamic-ssh-bookmarks
  '(("Uber"
     :local "uber"
     :remote "uberz"
     :path "/home/sherlockes/dockers/")
    ("Rpi"
     :local "rpi"
     :remote "rpiz"
     :path "/home/pi/"))
  "Bookmarks SSH que cambian entre host local y ZeroTier.")

(defun my/ssh-host-available-p (host)
  "Devuelve t si HOST responde por SSH."
  (= 0 (call-process "ssh" nil nil nil
                     "-q"
                     "-o" "BatchMode=yes"
                     "-o" "ConnectTimeout=2"
                     host
                     "exit")))

(defun my/tramp-path-for-dynamic-host (entry)
  "Devuelve la ruta TRAMP adecuada para ENTRY."
  (let* ((local-host (plist-get (cdr entry) :local))
         (remote-host (plist-get (cdr entry) :remote))
         (path       (plist-get (cdr entry) :path))
         (host       (if (my/ssh-host-available-p local-host)
                         local-host
                       remote-host)))
    (format "/ssh:%s:%s" host path)))

(defun my/update-dynamic-ssh-bookmark (entry)
  "Actualiza un bookmark dinámico ENTRY."
  (let ((name (car entry))
        (target (my/tramp-path-for-dynamic-host entry)))
    (bookmark-store
     name
     `((filename . ,target))
     nil)))

(defun my/update-dynamic-ssh-bookmarks ()
  "Actualiza todos los bookmarks SSH dinámicos."
  (interactive)
  (dolist (entry my/dynamic-ssh-bookmarks)
    (my/update-dynamic-ssh-bookmark entry))
  (when (get-buffer "*dashboard*")
    (dashboard-refresh-buffer)))

(add-hook 'emacs-startup-hook #'my/update-dynamic-ssh-bookmarks)


(provide 'init)
;;; init.el ends here
