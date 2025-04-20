;;; log-timestamps.el --- Highlight epoch timestamps in human-readable form -*- lexical-binding: t; -*-

;;; Commentary:
;; Minor mode to detect and overlay 13-digit millisecond timestamps with human-readable UTC dates.
;; Integrated with Doom Emacs keybindings using SPC t.

;;; Code:

(defgroup log-timestamps nil
  "Overlay millisecond timestamps with human-readable time."
  :group 'convenience)

(defcustom log-timestamps-regex "\\b1[0-9]\\{12\\}\\b"
  "Regular expression to match millisecond timestamps."
  :type 'regexp
  :group 'log-timestamps)

(defun log-timestamps--millis-to-date (s)
  "Convert millisecond timestamp S (string) to human-readable date."
  (let ((ts (/ (string-to-number s) 1000)))
    (format-time-string " → %Y-%m-%d %H:%M:%S" (seconds-to-time ts))))

(defun log-timestamps--apply-overlays ()
  "Apply overlays to all matching timestamps in the current buffer."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward log-timestamps-regex nil t)
      (let* ((start (match-beginning 0))
             (end (match-end 0))
             (text (match-string 0))
             (ov (make-overlay end end)))
        (overlay-put ov 'after-string
                     (propertize (log-timestamps--millis-to-date text)
                                 'face 'font-lock-comment-face))
        (overlay-put ov 'log-timestamps t)))))

(defun log-timestamps-clear-overlays ()
  "Clear all overlays added by log-timestamps."
  (interactive)
  (remove-overlays (point-min) (point-max) 'log-timestamps t))

(defun log-timestamps-refresh ()
  "Refresh overlays by clearing and reapplying them."
  (interactive)
  (log-timestamps-clear-overlays)
  (log-timestamps--apply-overlays))

(defun log-timestamps--after-change (_beg _end _len)
  "Hook to refresh overlays after buffer changes."
  (when log-timestamps-mode
    (log-timestamps-refresh)))

;;;###autoload
(define-minor-mode log-timestamps-mode
  "Minor mode to overlay 13-digit millisecond timestamps with readable dates."
  :lighter " ⏱"
  (if log-timestamps-mode
      (progn
        (log-timestamps--apply-overlays)
        (add-hook 'after-change-functions #'log-timestamps--after-change nil t))
    (log-timestamps-clear-overlays)
    (remove-hook 'after-change-functions #'log-timestamps--after-change t)))

;;;###autoload
(defun log-timestamps-enable-in-buffer ()
  "Enable log-timestamps mode in the current buffer."
  (log-timestamps-mode 1))

;;;autoload
(defun log-timestamps-replace-in-buffer ()
  "Replace 13-digit millisecond timestamps with human-readable dates in the current buffer."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((regex "\\b1[0-9]\\{12\\}\\b"))
      (while (re-search-forward regex nil t)
        (let* ((raw (match-string 0))
               (secs (/ (string-to-number raw) 1000))
               (date (format-time-string "%Y-%m-%d %H:%M:%S" (seconds-to-time secs))))
          (replace-match date t t))))))

;; Auto-enable in common modes
(dolist (hook '(json-mode-hook
                org-mode-hook
                logview-mode-hook
                prog-mode-hook))
  (add-hook hook #'log-timestamps-enable-in-buffer))

(add-hook 'csv-mode-hook
          (lambda ()
            (when (y-or-n-p "Reemplazar timestamps por fechas legibles?")
              (log-timestamps-replace-in-buffer))))

;; Doom Emacs keybindings (SPC t)
(when (featurep 'evil) ; Only define if Doom/general.el is available
  (with-eval-after-load 'general
    (general-define-key
     :states '(normal visual)
     :prefix "SPC"
     :non-normal-prefix "M-SPC"
     :keymaps 'override
     "t T" '(log-timestamps-mode :which-key "toggle timestamp overlay")
     "t r" '(log-timestamps-refresh :which-key "refresh overlays")
     "t c" '(log-timestamps-clear-overlays :which-key "clear overlays"))))

(provide 'log-timestamps)
;;; log-timestamps.el ends here

;; Activar automáticamente en ciertos modos
(dolist (hook '(json-mode-hook
                logview-mode-hook
                prog-mode-hook
                org-mode-hook))
  (add-hook hook #'log-timestamps-mode))

(add-hook 'csv-mode-hook
          (lambda ()
            (when (y-or-n-p "Replace timestamps with human readable dates?")
              (log-timestamps-replace-in-buffer))))
(map! :mode csv-mode
      :leader
      :desc "Replace timestamps with date"
      "t R" #'log-timestamps-replace-in-buffer)
