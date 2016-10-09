;;; kdeconnect.el --- An Emacs interface for KDE Connect

;; Copyright (C) 2016 Carl Lieberman

;; Author: Carl Lieberman <dev@carl.ac>
;; Keywords: kdeconnect, android
;; Version: 0.2.4

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

;; This package provides several helper functions to use the
;; excellent KDE Connect program without leaving the comfort of
;; Emacs. It requires KDE Connect on both your computer and phone.
;; It has only been tested on GNU/Linux.

;;; Code:

(defvar kdeconnect-device nil
  "The ID of the active device for KDE Connect")

;;;###autoload
(defun kdeconnect-get-device ()
  "Display ID of active device"
  (interactive)
  (message kdeconnect-device))

;;;###autoload
(defun kdeconnect-list-devices ()
  "Display all available devices"
  (interactive)
  (shell-command
   (mapconcat 'identity (list "kdeconnect-cli" "-l") " ")))

;;;###autoload
(defun kdeconnect-ping ()
  "Ping the active device"
  (interactive)
  (shell-command
   (mapconcat 'identity
              (list "kdeconnect-cli" "-d" kdeconnect-device "--ping") " ")))


;;;###autoload
(defun kdeconnect-ping-msg (message)
  "Ping the active device with a custom message"
  (interactive "MEnter message: ")
  (setq message (concat "\"" message "\""))
  (shell-command
   (mapconcat 'identity
              (list "kdeconnect-cli" "-d" kdeconnect-device "--ping-msg" message) " ")))

;;;###autoload
(defun kdeconnect-ring ()
  "Ring the active device"
  (interactive)
  (shell-command
   (mapconcat 'identity
              (list "kdeconnect-cli" "-d" kdeconnect-device "--ring") " ")))

;;;###autoload
(defun kdeconnect-send-file (path)
  "Send a file to the active device"
  (interactive "fSelect file: ")
  (shell-command
   (mapconcat 'identity
              (list "kdeconnect-cli" "-d" kdeconnect-device "--share" path)
              " ")))

(defun kdeconnect-select-device ()
  "Choose the active device from all available ones"
  (interactive)
  (setq kdeconnect-device
        (shell-command-to-string
         (mapconcat 'identity (list "kdeconnect-cli" "-a" "--id-only") " ")))
  (if (string= "" kdeconnect-device)
      (error "No devices found"))
  (setq kdeconnect-device (split-string kdeconnect-device "\n" t))
  (setq kdeconnect-device
        (completing-read
         "Select a device: "
         kdeconnect-device
         nil t "")))

(provide 'kdeconnect)
;;; kdeconnect.el ends here
