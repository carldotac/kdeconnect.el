;;; kdeconnect.el --- An interface for KDE Connect

;; Copyright (C) 2016 Carl Lieberman

;; Author: Carl Lieberman <dev@carl.ac>
;; Keywords: kdeconnect, android
;; Version: 1.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides helper functions to use the command line
;; version of KDE Connect, a bridge between Android devices and
;; computers, without leaving the comfort of Emacs.  It requires KDE
;; Connect on your computer(s) and Android device(s).  KDE Connect
;; currently requires Linux on the desktop, but does not require
;; KDE.

;;; Code:

(defvar kdeconnect-device nil
  "The ID of the active device.")

;;;###autoload
(defun kdeconnect-get-active-device ()
  "Display the ID of the active device."
  (interactive)
  (message kdeconnect-device))

;;;###autoload
(defun kdeconnect-list-devices ()
  "Display all available devices."
  (interactive)
  (shell-command "kdeconnect-cli -l"))

;;;###autoload
(defun kdeconnect-ping ()
  "Ping the active device."
  (interactive)
  (shell-command
   (mapconcat 'identity
              (list "kdeconnect-cli" "-d" kdeconnect-device "--ping") " ")))

;;;###autoload
(defun kdeconnect-ping-msg (message)
  "Ping the active device with MESSAGE."
  (interactive "MEnter message: ")
  ;; Wrap MESSAGE in quotation marks to pass to shell
  (setq message (concat "\"" message "\""))
  (shell-command
   (mapconcat 'identity
              (list "kdeconnect-cli" "-d" kdeconnect-device
                    "--ping-msg" message) " ")))

;;;###autoload
(defun kdeconnect-ring ()
  "Ring the active device."
  (interactive)
  (shell-command
   (mapconcat 'identity
              (list "kdeconnect-cli" "-d" kdeconnect-device "--ring") " ")))

;;;###autoload
(defun kdeconnect-send-file (path)
  "Send the file at PATH to the active device."
  (interactive "fSelect file: ")
  (setq path (concat "\"" path "\""))
  (shell-command
   (mapconcat 'identity
              (list "kdeconnect-cli" "-d" kdeconnect-device "--share" path)
              " ")))

;;;###autoload
(defun kdeconnect-select-device ()
  "Choose the active device from all available ones."
  (interactive)
  (if (string= "No devices found\n"
               (shell-command-to-string "kdeconnect-cli -a --id-only"))
      (error "No devices found"))
  (setq kdeconnect-device
        (shell-command-to-string "kdeconnect-cli -a --id-only"))
  (setq kdeconnect-device (split-string kdeconnect-device "\n" t))
  (setq kdeconnect-device
        (completing-read
         "Select a device: "
         kdeconnect-device
         nil t "")))

(provide 'kdeconnect)
;;; kdeconnect.el ends here
