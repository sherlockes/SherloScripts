(defun my-split-screen ()
  "Divide la pantalla en dos mitades y muestra 'Dashboard' a la izquierda y el buffer activo a la derecha."
  (interactive)
  (let ((dashboard-buffer (get-buffer "Dashboard")))
    (if dashboard-buffer
        (progn
          (split-window-horizontally)
          (switch-to-buffer dashboard-buffer)
          (other-window 1))
      (message "El buffer 'Dashboard' no está abierto."))))

(global-set-key (kbd "ESC") 'my-split-screen)



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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Entorno de desarrollo para sherblog ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Funciones para reiniciar Emacs ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;(defun reiniciar2 ()
;;    (interactive)
;;    (mapcar 'kill-buffer (buffer-list))
;;    (delete-other-windows)
;;    (load-file user-init-file)
;;)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Función para cambio entre diccionarios y configuración de corrección ortográfica ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun fd-switch-dictionary()
  (interactive)
  (let* ((dic ispell-current-dictionary)
	 (change (if (string= dic "español") "english" "español")))
    (ispell-change-dictionary change)
    ))
