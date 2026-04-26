;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Función para ejecutar un script en python o cerrar la consola ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun eval_or_close_python ()
  "Ejecuta C-u C-c C-c si el buffer activo tiene extensión 'py' o C-c C-c si el buffer activo es '*Python*'."
  (interactive)
  (if (string= (buffer-name) "*Python*")
      (progn
        (execute-kbd-macro (kbd "C-c C-c"))
	(sit-for 1) ; Espera un segundo para asegurarse de que se ejecute el comando
        (comint-send-string (get-buffer-process (current-buffer)) "exit()\n")
	(sit-for 1)
	(kill-buffer (current-buffer))
	(sit-for 1)
	(other-window 1)
      )
    (if (string= (file-name-extension (buffer-file-name)) "py")
        (progn
	  (execute-kbd-macro (kbd "C-x C-s C-u C-c C-c"))
        )
      (message "Not in a Python or .py buffer"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Función para mostrar pantalla partida con Dashboard a la izquierda ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun mostrar-dashboard ()
  "Si el buffer activo no es '*dashboard*', deja una sola ventana con el buffer activo, luego divide la pantalla en dos mitades y muestra el buffer '*dashboard*' a la izquierda. Abre '*dashboard*' si no está abierto."
  (interactive)
  (if (not (string= (buffer-name (current-buffer)) "*dashboard*"))
      (progn
        (delete-other-windows) ; Cierra todas las otras ventanas
        (let ((dashboard-buffer (get-buffer "*dashboard*")))
          (if dashboard-buffer
              (progn
                (split-window-horizontally)
                (switch-to-buffer dashboard-buffer)
	      )
            (progn
              (dashboard-open)
              (split-window-horizontally)
	    )
	  )
	(other-window 1)  
	)
      )
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Función para comprobar si un archivo existe y descargarlo si no está ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-download-file-if-not-exists (url target-path)
  "Download a file from URL and save it to TARGET-PATH if it does not exist."
  (unless (file-exists-p target-path)
    (let ((dir (file-name-directory target-path)))
      (unless (file-exists-p dir)
        (make-directory dir t))
      (message "Downloading file from %s..." url)
      (url-copy-file url target-path)
      (message "Download complete: %s" target-path))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Función para comprobar e instalar paquetes ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-install-package-if-not-installed (package)
  "Instala el paquete PACKAGE si no está instalado."
  (unless (featurep package)
    (unless (package-installed-p package)
      (message "Instalando el paquete '%s'..." package)
      (package-refresh-contents)
      (package-install package)
      (message "Paquete '%s' instalado." package))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Función al abrir archivos de Brain o Blog  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun brainblog ()
  (interactive)
  (when buffer-file-name
    (if (string-prefix-p brain-dir buffer-file-name)
        (setq carpeta brain-dir)
      )
    (if (string-prefix-p blog-dir buffer-file-name)
        (setq carpeta blog-dir)
      )

    (delete-other-windows nil)
    
    (mapc 'kill-buffer 
          (delq (current-buffer) 
                (remove-if-not 'buffer-file-name (buffer-list))))
    

    (split-window-right 80)

    (let ((default-directory carpeta))                                       ;; Establece el directorio por defecto
      (comint-send-string (shell) "hugo server -D --navigateToChanged --disableFastRender\n")    ;; Lanza el servidor de Hugo
    )
    
    (split-window-below)

    (other-window 1)                                                         ;; Cambia el foco a la otra ventana
    (dired carpeta)                                                          ;; Abre el directorio de los Post del Blog
    (enlarge-window 10)
    

    (browse-url "http://localhost:1313")
    
   ) 
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Función al guardar archivos de Brain o Blog  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun funcion-al-guardar ()
  (when buffer-file-name
    (message "Se ha guardado el archivo %s" buffer-file-name)

    (cond
     ((string-prefix-p brain-dir buffer-file-name)  (setq carpeta brain-dir))
     ((string-prefix-p blog-dir  buffer-file-name)  (setq carpeta blog-dir))
     ((string-prefix-p script-dir buffer-file-name) (setq carpeta script-dir)))

    (let ((default-directory carpeta))
      ;; git add .
      (call-process "git" nil nil nil "add" ".")

      ;; si hay cambios, commit y push
      (unless (eq (call-process "git" nil nil nil "diff-index" "--quiet" "HEAD" "--") 0)
        (call-process "git" nil nil nil "commit" "-m" "Update")
        (call-process "git" nil nil nil "push")
        (message "Repositorio actualizado ✔"))
      )))


(defun funcion-al-guardar_bak ()
  (when buffer-file-name
    (message "Se ha guardado el archivo %s" buffer-file-name)
    (if (string-prefix-p brain-dir buffer-file-name)
        (setq carpeta brain-dir)
    )
    (if (string-prefix-p blog-dir buffer-file-name)
        (setq carpeta blog-dir)
    )
    (if (string-prefix-p script-dir buffer-file-name)
        (setq carpeta script-dir)
    )

    (interactive)
    (let ((default-directory carpeta))
      (shell-command "gitup")                                                        ;; Actualiza el repositorio git
    )
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Entorno de desarrollo para sherblog ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun sherblog_edit ()
  (interactive)
  
  (unless (zerop (shell-command "ping -c 1 192.168.10.202"))                                ;; Activa la vpn en caso de conexión remota
    (shell-command "vpnon"))

  (mapc 'kill-buffer (buffer-list))                                                         ;; Cierra todos los bufers activos
  (delete-other-windows nil)                                                                ;; Cierra todas las ventanas
  (split-window-right 80)                                                                   ;; Parte la pantalla verticalmente en dos
  (split-window-below)                                                                      ;; Parte la ventana derecha horizontalmente en dos
  (setq default-directory "/ssh:pi@192.168.10.202:/home/pi/sherblog/")                      ;; Cambia el directorio por defecto a la Raspberry
  ;;(comint-send-string (shell) "hugoser\n")                                                  ;; Lanza el servidor de Hugo en la Raspberry
  (comint-send-string (shell) "hugo server -D --bind=192.168.10.202 --baseURL=http://192.168.10.202\n")
  (other-window 1)                                                                          ;; Cambia el foco a la otra ventana
  (dired "/ssh:pi@192.168.10.202:/home/pi/sherblog/content/post/")                          ;; Abre el directorio de los Post del Blog
  (enlarge-window 10)                                                                       ;; Hace un poco mas alta la ventana de los post
  (browse-url "http://192.168.10.202:1313")                                                 ;; Abre el Blog en el navegador
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Funciones para reiniciar Emacs ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun emacs-terminal ()                                                                    ;; Función para volver a abrir Emacs en la terminal
  (suspend-emacs "fg ; emacs -nw")
)

(defun emacs-x11 ()                                                                         ;; Función para volver a abrir Emacs en escritorio
  (call-process "sh" nil nil nil "-c" "emacs --maximized &")
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Función para cambio entre diccionarios y configuración de corrección ortográfica ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun fd-switch-dictionary()
  (interactive)
  (let* ((dic ispell-current-dictionary)
	 (change (if (string= dic "español") "english" "español")))
    (ispell-change-dictionary change)
    ))

(defun org-hugo-export-folder ()
  "Export all Org files in the folder of the currently open file to Markdown using ox-hugo."
  (interactive)
  (let* ((current-file (buffer-file-name))
         (folder (file-name-directory current-file)))
    (if (not (file-exists-p folder))
        (message "La carpeta actual no existe.")
      (dolist (file (directory-files folder t "\\.org$"))
        (with-current-buffer (find-file-noselect file)
          (org-hugo-export-wim-to-md :all-subtrees)))))
  (message "Exportación de todos los archivos Org en la carpeta actual completada."))
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Función para actualizar la fecha antes de guardar archivos Markdown ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun update-markdown-date ()
  "Actualizar la fecha en una línea 'date: \"YYYY-MM-DD\"' al guardar archivos Markdown."
  (when (and (eq major-mode 'markdown-mode)
             (buffer-file-name))
    (save-excursion
      (goto-char (point-min))
      (when (re-search-forward "^date: \"[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\"" nil t)
        (replace-match (format "date: \"%s\"" (format-time-string "%Y-%m-%d")))))))

(defun add-markdown-save-hook ()
  "Añadir un hook para actualizar la fecha en archivos Markdown al guardarlos."
  (add-hook 'before-save-hook #'update-markdown-date nil t))


;; Función para acutqalizar la fecha antes de guardar ;;

(defun update-file-date ()
  "Actualizar la fecha de modificación según la extensión del archivo,
salvo si la fecha existente es posterior a hoy."
  (let ((ext (file-name-extension (buffer-file-name)))
        (current-date (format-time-string "%Y-%m-%d"))
        (current-date-compact (format-time-string "%Y%m%d")))
    (save-excursion
      (goto-char (point-min))
      (cond
       ;; Para archivos .sh: #Creation/Update: YYYYMMDD/YYYYMMDD
       ((string= ext "sh")
        (when (re-search-forward "^#Creation/Update: \\([0-9]+\\)/\\([0-9]+\\)$" nil t)
          (let ((existing (match-string 2))) ;; fecha de Update
            ;; solo actualizar si existing <= hoy (formato YYYYMMDD)
            (when (or (string= existing current-date-compact)
                      (string< existing current-date-compact))
              (replace-match
               (format "#Creation/Update: %s/%s"
                       (match-string 1)
                       current-date-compact))))))

       ;; Para archivos .md: date: "YYYY-MM-DD"
       ((string= ext "md")
        (when (re-search-forward "^date: \"\\([0-9-]+\\)\"$" nil t)
          (let ((existing (match-string 1)))
            ;; solo actualizar si existing <= hoy (formato YYYY-MM-DD)
            (when (or (string= existing current-date)
                      (string< existing current-date))
              (replace-match
               (format "date: \"%s\"" current-date))))))

       ;; Para archivos .org: #+date: <YYYY-MM-DD>
       ((string= ext "org")
        (when (re-search-forward "^#\\+date: <\\([0-9-]+\\)>$" nil t)
          (let ((existing (match-string 1)))
            ;; solo actualizar si existing <= hoy
            (when (or (string= existing current-date)
                      (string< existing current-date))
              (replace-match
               (format "#+date: <%s>" current-date))))))))))



(defun update-file-date_bak ()
  "Actualizar la fecha de modificación según la extensión del archivo."
  (let ((ext (file-name-extension (buffer-file-name)))
        (current-date (format-time-string "%Y-%m-%d"))
        (current-date-compact (format-time-string "%Y%m%d")))
    (save-excursion
      (goto-char (point-min))
      (cond
       ;; Para archivos .sh: #Creation/Update: YYYYMMDD/YYYYMMDD
       ((string= ext "sh")
        (when (re-search-forward "^#Creation/Update: \\([0-9]+\\)/\\([0-9]+\\)$" nil t)
          (replace-match (format "#Creation/Update: %s/%s" (match-string 1) current-date-compact))))

       ;; Para archivos .md: date: "YYYY-MM-DD"
       ((string= ext "md")
        (when (re-search-forward "^date: \"\\([0-9-]+\\)\"$" nil t)
          (replace-match (format "date: \"%s\"" current-date))))

       ;; Para archivos .org: #+date: <YYYY-MM-DD>
       ((string= ext "org")
        (when (re-search-forward "^#\\+date: <\\([0-9-]+\\)>$" nil t)
          (replace-match (format "#+date: <%s>" current-date))))))))

(add-hook 'before-save-hook 'update-file-date)



