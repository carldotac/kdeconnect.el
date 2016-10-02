;;; kdeconnect.el --- An Emacs interface for KDE Connect

;; Copyright (C) 2016 Carl Lieberman

;; Author: Carl Lieberman
;; Keywords: kdeconnect, android
;; Version: 0.2.2

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

(defvar kdeconnect-base "kdeconnect-cli"
  "The root of all KDE Connect commands")

(defvar kdeconnect-device
  "The ID of the active device")

(defvar kdeconnect-command
  "The action to execute via KDE Connect")

;;;###autoload
(defun kdeconnect-get-device ()
  "Display ID of active device"
  (interactive)
  (message kdeconnect-device))

;;;###autoload
(defun kdeconnect-list-devices ()
  "Display all available devices"
  (interactive)
  (setq kdeconnect-command
        (mapconcat 'identity (list kdeconnect-base "-l") " "))
  (shell-command kdeconnect-command))

;;;###autoload
(defun kdeconnect-ping ()
  "Ping the active device"
  (interactive)
  (setq kdeconnect-command
        (mapconcat 'identity
                   (list kdeconnect-base "-d" kdeconnect-device "--ping") " "))
  (shell-command kdeconnect-command))

;;;###autoload
(defun kdeconnect-ping-msg (message)
  "Ping the active device with a custom message"
  (interactive "MEnter message: ")
  (setq message (concat "\"" message "\""))
  (setq kdeconnect-command
        (mapconcat 'identity
                   (list kdeconnect-base "-d" kdeconnect-device "--ping-msg"
                         message) " "))
  (shell-command kdeconnect-command))

;;;###autoload
(defun kdeconnect-ring ()
  "Ring the active device"
  (interactive)
  (setq kdeconnect-command
        (mapconcat 'identity
                   (list kdeconnect-base "-d" kdeconnect-device "--ring") " "))
  (shell-command kdeconnect-command))

;;;###autoload
(defun kdeconnect-send-file (path)
  "Send a file to the active device"
  (interactive "fSelect file: ")
  (setq kdeconnect-command
        (mapconcat 'identity
         (list kdeconnect-base "-d" kdeconnect-device "--share" path) " "))
  (shell-command kdeconnect-command))

(defun kdeconnect-select-device ()
  "Choose the active device from all available ones"
  (interactive)
  (setq kdeconnect-command
        (mapconcat 'identity (list kdeconnect-base "-a" "--id-only") " "))
  (setq devices (shell-command-to-string kdeconnect-command))
  (if (string= "" devices)
      (error "No devices found"))
  (setq devices (split-string devices "\n" t))
  (setq device
        (completing-read
         "Select a device: "
         devices
         nil t ""))
  (setq kdeconnect-device device))

(provide 'kdeconnect)
;;; kdeconnect.el ends here
