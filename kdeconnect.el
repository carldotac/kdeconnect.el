;;; kdeconnect.el --- An interface for KDE Connect  -*- lexical-binding: t; -*-

;; Copyright (C) 2016-2020 Carl Lieberman

;; Author: Carl Lieberman <dev@carl.ac>
;; Keywords: convenience
;; Version: 1.2.2
;; URL: https://github.com/carldotac/kdeconnect.el
;; Package-Requires: ((emacs "25.1"))

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

(require 'map)
(require 'seq)

(defgroup kdeconnect nil
  "KDEConnect integration"
  :tag "KDEConnect"
  :group 'convenience
  :link '(url-link "https://github.com/carldotac/kdeconnect.el"))

(defcustom kdeconnect-active-device nil
  "The (NAME . ID) of the active device.
This variable can be setted by `kdeconnect-select-active-device',
`setq' or the customization buffer."
  :type '(cons string string)
  :group 'kdeconnect)

(defcustom kdeconnect-devices nil
  "The IDs of your available devices.
An alist of (name . ID) of available devices.  This variable can be
updated with new devices with `kdeconnect-update-kdeconnect-devices'
for the current session only.
It can be modified with `setq' or customized."
  :type '(alist :key-type string :value-type string)
  :group 'kdeconnect)

(defun kdeconnect--ensure-active-device ()
  "Make sure there is an active device, ask user otherwise.
Signal error if there is no active device and the user has not selected
one."
  (cond
   (kdeconnect-active-device
    kdeconnect-active-device)
   ((= (length kdeconnect-devices) 0)
    (message "No devices! Use M-x kdeconnect-update-kdeconnect-devices.")
    nil)
   ((y-or-n-p (format "No active device selected. Use %s?"
                      (caar kdeconnect-devices)))
    (setq kdeconnect-active-device (car kdeconnect-devices))
    kdeconnect-active-device)
   (t
    (message "No active device. Use M-x kdeconnect-select-active-device.")
    nil)))

(defun kdeconnect--new-devices (device-list)
  "Return new devices IDs not in the `kdeconnect-devices' variable.
DEVICE-LIST is an alist with (NAME . ID) elements."
  (let ((saved-device-ids (map-values kdeconnect-devices)))
    (seq-filter (lambda (device)
                  (not (member (cdr device) saved-device-ids)))
                device-list)))

(defun kdeconnect--parse-device-list (output-string)
  "Parse the string into an alist of devices.
Return an alist with (NAME . ID) for each line in the OUTPUT-STRING.
The string must be composed of lines with \"ID NAME\" format."
  (mapcar (lambda (line)
            (string-match "\\([[:alnum:]]+\\) \\(.*\\)" line)
            (cons (match-string 2 line) (match-string 1 line)))
          (split-string output-string "\n" t)))

;;;###autoload
(defun kdeconnect-update-kdeconnect-devices ()
  "Update `kdeconnect-devices' with the current list.
If the a device ID is already present, do not add it.
The update will affect to the curent Emacs session only.  The
`kdeconnect-devices' variable must be saved by customizing it or
adding a `setq' sentence on your init file."
  (interactive)
  (let ((new-devices (kdeconnect--new-devices
                      (kdeconnect--parse-device-list
                       (shell-command-to-string "kdeconnect-cli -l --id-name-only")))))
    (when (y-or-n-p (format "Add new devices: %s?" new-devices))
      (setq kdeconnect-devices
            (append new-devices kdeconnect-devices)))))
              

;;;###autoload
(defun kdeconnect-get-active-device ()
  "Display the ID of the active device."
  (interactive)
  (if kdeconnect-active-device
      (message "Active device: %s (ID: %s)"
               (car kdeconnect-active-device)
               (cdr kdeconnect-active-device))
    (message "No active device. Use M-x kdeconnect-select-active-device")))

;;;###autoload
(defun kdeconnect-list-devices ()
  "Display all visible devices, even unavailable ones."
  (interactive)
  (shell-command "kdeconnect-cli -l"))

;;;###autoload
(defun kdeconnect-ping ()
  "Ping the active device."
  (interactive)
  (when (kdeconnect--ensure-active-device)
    (shell-command
     (mapconcat 'identity
                (list "kdeconnect-cli" "-d"
                      (shell-quote-argument (cdr kdeconnect-active-device))
                      "--ping") " "))))

;;;###autoload
(defun kdeconnect-ping-msg (message)
  "Ping the active device with MESSAGE."
  (interactive "MEnter message: ")
  (when (kdeconnect--ensure-active-device)
    (shell-command
     (mapconcat 'identity
                (list "kdeconnect-cli" "-d"
                      (shell-quote-argument (cdr kdeconnect-active-device))
                      "--ping-msg" (shell-quote-argument message)) " "))))

;;;###autoload
(defun kdeconnect-refresh ()
  "Refresh connections."
  (interactive)
  (shell-command "kdeconnect-cli --refresh"))

;;;###autoload
(defun kdeconnect-ring ()
  "Ring the active device."
  (interactive)
  (when (kdeconnect--ensure-active-device)
    (shell-command
     (mapconcat 'identity
                (list "kdeconnect-cli" "-d"
                      (shell-quote-argument (cdr kdeconnect-active-device))
                      "--ring") " "))))

;;;###autoload
(defun kdeconnect-send-file (path)
  "Send the file at PATH to the active device."
  (interactive "fSelect file: ")
  (when (kdeconnect--ensure-active-device)
    (shell-command
     (mapconcat 'identity
                (list "kdeconnect-cli" "-d"
                      (shell-quote-argument (cdr kdeconnect-active-device))
                      "--share" (shell-quote-argument
                                (expand-file-name path))) " "))))

;;;###autoload
(defun kdeconnect-send-text (text)
  "Send TEXT to the active device."
  (interactive "MEnter a text to share: ")
  (when (kdeconnect--ensure-active-device)
    (shell-command
     (mapconcat 'identity
                (list "kdeconnect-cli" "-d"
                      (shell-quote-argument (cdr kdeconnect-active-device))
                      "--share-text" (shell-quote-argument text)) " "))))

;;;###autoload
(defun kdeconnect-send-text-region-or-prompt ()
  "Send text to the active device interactively.
If the REGION is active send that text, otherwise prompt for what to send"
  (interactive )
  (when (kdeconnect--ensure-active-device)
    (if (use-region-p)
        (kdeconnect-send-text (buffer-substring (region-beginning) (region-end)))
      (call-interactively 'kdeconnect-send-text))))

;;;###autoload
(defun kdeconnect-select-active-device (name)
  "Set the active device to NAME."
  (interactive
   (list (completing-read
          "Select a device: "
          (map-keys (progn (unless kdeconnect-devices
                             (message "No devices found... updating paired devices...")
                             (kdeconnect-update-kdeconnect-devices))
                           kdeconnect-devices))
          nil t "")))
  (setq kdeconnect-active-device
        (assoc name kdeconnect-devices #'string=)))

;;;###autoload
(defun kdeconnect-send-sms (message destination)
  "Send an SMS message through your cellphone.
MESSAGE is a string with the message to send.  DESTINATION is a
number to send (it must be a number value, not string)."
  (interactive "MEnter message: \nnEnter destination: ")
  (when (kdeconnect--ensure-active-device)
    (shell-command
     (mapconcat 'identity
                (list "kdeconnect-cli" "-d"
                      (shell-quote-argument (cdr kdeconnect-active-device))
                      "--destination" (number-to-string destination)
                      "--send-sms" (shell-quote-argument message)) " "))))

(provide 'kdeconnect)
;;; kdeconnect.el ends here
