;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start of xbindkeys guile configuration ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This configuration is guile based.
;;   http://www.gnu.org/software/guile/guile.html
;; any functions that work in guile will work here.
;; see EXTRA FUNCTIONS:

;; Version: 1.8.7

;; If you edit this file, do not forget to uncomment any lines
;; that you change.
;; The semicolon(;) symbol may be used anywhere for comments.

;; To specify a key, you can use 'xbindkeys --key' or
;; 'xbindkeys --multikey' and put one of the two lines in this file.

;; A list of keys is in /usr/include/X11/keysym.h and in
;; /usr/include/X11/keysymdef.h
;; The XK_ is not needed.

;; List of modifier:
;;   Release, Control, Shift, Mod1 (Alt), Mod2 (NumLock),
;;   Mod3 (CapsLock), Mod4, Mod5 (Scroll).


;; The release modifier is not a standard X modifier, but you can
;; use it if you want to catch release instead of press events

;; By defaults, xbindkeys does not pay attention to modifiers
;; NumLock, CapsLock and ScrollLock.
;; Uncomment the lines below if you want to use them.
;; To dissable them, call the functions with #f


;;;;EXTRA FUNCTIONS: Enable numlock, scrolllock or capslock usage
;;(set-numlock! #t)
;;(set-scrolllock! #t)
;;(set-capslock! #t)

;;;;; Scheme API reference
;;;;
;; Optional modifier state:
;; (set-numlock! #f or #t)
;; (set-scrolllock! #f or #t)
;; (set-capslock! #f or #t)
;; 
;; Shell command key:
;; (xbindkey key "foo-bar-command [args]")
;; (xbindkey '(modifier* key) "foo-bar-command [args]")
;; 
;; Scheme function key:
;; (xbindkey-function key function-name-or-lambda-function)
;; (xbindkey-function '(modifier* key) function-name-or-lambda-function)
;; 
;; Other functions:
;; (remove-xbindkey key)
;; (run-command "foo-bar-command [args]")
;; (grab-all-keys)
;; (ungrab-all-keys)
;; (remove-all-keys)
;; (debug)

;; Examples of commands:

;; (xbindkey '(control shift q) "xbindkeys_show")
;; 
;; ;; set directly keycode (here control + f with my keyboard)
;; (xbindkey '("m:0x4" "c:41") "xterm")
;; 
;; ;; specify a mouse button
;; (xbindkey '(control "b:2") "xterm")
;; 
;; ;;(xbindkey '(shift mod2 alt s) "xterm -geom 50x20+20+20")
;; 
;; ;; set directly keycode (control+alt+mod2 + f with my keyboard)
;; (xbindkey '(alt "m:4" mod2 "c:0x29") "xterm")
;; 
;; ;; Control+Shift+a  release event starts rxvt
;; ;;(xbindkey '(release control shift a) "rxvt")
;; 
;; ;; Control + mouse button 2 release event starts rxvt
;; ;;(xbindkey '(releace control "b:2") "rxvt")
;; 
;; 
;; ;; Extra features
;; (xbindkey-function '(control a)
;; 		   (lambda ()
;; 		     (display "Hello from Scheme!")
;; 		     (newline)))
;; 
;; (xbindkey-function '(shift p)
;; 		   (lambda ()
;; 		     (run-command "xterm")))
;; 
;; 
;; ;; Double click test
;; (xbindkey-function '(control w)
;; 		   (let ((count 0))
;; 		     (lambda ()
;; 		       (set! count (+ count 1))
;; 		       (if (> count 1)
;; 			   (begin
;; 			    (set! count 0)
;; 			    (run-command "xterm"))))))
;; 
;; ;; Time double click test:
;; ;;  - short double click -> run an xterm
;; ;;  - long  double click -> run an rxvt
;; (xbindkey-function '(shift w)
;; 		   (let ((time (current-time))
;; 			 (count 0))
;; 		     (lambda ()
;; 		       (set! count (+ count 1))
;; 		       (if (> count 1)
;; 			   (begin
;; 			    (if (< (- (current-time) time) 1)
;; 				(run-command "xterm")
;; 				(run-command "rxvt"))
;; 			    (set! count 0)))
;; 		       (set! time (current-time)))))
;; 
;; 
;; ;; Chording keys test: Start differents program if only one key is
;; ;; pressed or another if two keys are pressed.
;; ;; If key1 is pressed start cmd-k1
;; ;; If key2 is pressed start cmd-k2
;; ;; If both are pressed start cmd-k1-k2 or cmd-k2-k1 following the
;; ;;   release order
;; (define (define-chord-keys key1 key2 cmd-k1 cmd-k2 cmd-k1-k2 cmd-k2-k1)
;;     "Define chording keys"
;;   (let ((k1 #f) (k2 #f))
;;     (xbindkey-function key1 (lambda () (set! k1 #t)))
;;     (xbindkey-function key2 (lambda () (set! k2 #t)))
;;     (xbindkey-function (cons 'release key1)
;; 		       (lambda ()
;; 			 (if (and k1 k2)
;; 			     (run-command cmd-k1-k2)
;; 			     (if k1 (run-command cmd-k1)))
;; 			 (set! k1 #f) (set! k2 #f)))
;;     (xbindkey-function (cons 'release key2)
;; 		       (lambda ()
;; 			 (if (and k1 k2)
;; 			     (run-command cmd-k2-k1)
;; 			     (if k2 (run-command cmd-k2)))
;; 			 (set! k1 #f) (set! k2 #f)))))
;; 
;; 
;; ;; Example:
;; ;;   Shift + b:1                   start an xterm
;; ;;   Shift + b:3                   start an rxvt
;; ;;   Shift + b:1 then Shift + b:3  start gv
;; ;;   Shift + b:3 then Shift + b:1  start xpdf
;; 
;; (define-chord-keys '(shift "b:1") '(shift "b:3")
;;   "xterm" "rxvt" "gv" "xpdf")
;; 
;; ;; Here the release order have no importance
;; ;; (the same program is started in both case)
;; (define-chord-keys '(alt "b:1") '(alt "b:3")
;;   "gv" "xpdf" "xterm" "xterm")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-modules (ice-9 regex))
(use-modules (srfi srfi-1))
(use-modules (srfi srfi-98))

; https://en.wikibooks.org/wiki/Scheme_Programming/Looping#Iterative_recursion
(define-syntax foreach
 (syntax-rules ()
  ((_ ((variables lists) ...)
    body ...)
   (for-each (lambda (variables ...) body ...) lists ...))))

; Regex replace
(define (kc-replace str what for)
  (regexp-substitute/global
    #f
    what
    str
    'pre
    for
    'post))
; Quote the argument
(define (kc-shell-quote-in str)
  (kc-replace str "'" "'\\''"))
(define (kc-shell-quote . strs)
  (string-append
    "'"
    (string-join (map kc-shell-quote-in strs) "")
    "'"))

; Quote all arguments separate
(define (kc-quote-in str)
  (string-append
    "'"
    (kc-replace str "'" "'\\''")
    "'"))
(define (kc-quote . strs)
  (string-join (map kc-quote-in strs) " "))

; Also replace some html characters we  need to
(define (kc-html-quote arg)
  (kc-replace
    (kc-replace
      (kc-replace arg "&" "&amp;")
      "<"
      "&lt;")
    ">"
    "&gt;"))

; Display message with notify-send and execute the command
(define old_E_use_Xbindkey
  (lambda (text cmd)
    (string-append
      "if hash notify-send 2>/dev/null >&2; then"
      "   notify-send -u low -t 2000 -i forward xbindkeys "
      (kc-shell-quote
        (if (string-null? text)
          ""
          (string-append
            "<big><b>\t"
            (kc-html-quote text)
            "</b></big>\n"))
        "<small>Running: <tt>"
        (kc-html-quote cmd)
        "</tt></small>")
      " ;"
      "fi;"
      cmd)))

; Get path into kamilscripts repository
(define (kc-dir . args)
  (string-append
    (getenv "HOME")
    "/.config/kamilscripts/kamilscripts/"
    (string-join args "")))
(define (kc-dir-has arg) (access? (kc-dir arg)))
(define (kc-icon-arg name)
  (let ((d (kc-dir "/icons/" name ".png")))
    (if (access? d R_OK) (string-append "-i" d))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; The hostname
(define host (string->symbol (gethostname)))

; Simpler version of notify what is executing
; Use (Xbindkey '(Mod4 F1) "Some message" "Some command)
; or use (Xbindkey '(Mod4 F1) "Some command)
(define (Xbindkey_in bind text cmd)
  (xbindkey bind (E text cmd)))
(define (Xbindkey bind . args)
  (xbindkey
    bind
    (apply kc-quote
           (append '(",xbindkeys-helper.sh") args))))

; xbindkey multiple keys to one command.
; Use like the following:
;     (XbindkeyMultiple
;        '((Mod4 d) (Mod4 s))
;        "echo something")
(define (XbindkeyMultiple bindarr . args)
  (map (lambda (bind)
         (apply Xbindkey (append (list bind) args)))
       bindarr))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(define (movewindow arg)
  (if (equal? (get-environment-variable "XDG_CURRENT_DESKTOP") "KDE")
	(string-append
	  "qdbus org.kde.kglobalaccel /component/kwin invokeShortcut Window\\ to\\ Desktop\\ "
	  (number->string arg)
	)
	(string-append
	  "xdotool getactivewindow set_desktop_for_window "
	  (number->string (- arg 1))
	)
  )
)
(xbindkey '(Mod4 F1) (movewindow 1))
(xbindkey '(Mod4 F2) (movewindow 2))
(xbindkey '(Mod4 F3) (movewindow 3))
(xbindkey '(Mod4 F4) (movewindow 4))
(xbindkey '(Mod4 F5) (movewindow 5))
(xbindkey '(Mod4 F6) (movewindow 6))
(xbindkey '(Mod4 F7) (movewindow 7))

;(Xbindkey '(Mod4 a) "geany")
(Xbindkey
  '(Mod4 shift A)
  ",todoist_dodaj_nowe_zadanie.sh")
(Xbindkey
  '(Mod4 t)
  (kc-icon-arg "todoist")
  "todoist"
  "firefox --new-window 'https://todoist.com/app/'")
;(Xbindkey '(Mod4 s) "subl")
(Xbindkey '(Mod4 f) "soffice --calc")
(Xbindkey '(Mod4 c) (case host
  ((leonidas) "-iutilities-terminal" "konsole")
  (else "-iorg.xfce.terminal" "terminal"
    (string-append
      "xfce4-terminal "
      (case host
        ((leonidas) "--geometry 157x40")
        ((ardalus) "--geometry 126x34")
        ((gorgo) "--geometry 94x22")
        (else ""))))))

(case host
  ((leonidas)
   (xbindkey
     '(Mod4 equal)
     "soffice --calc /home/kamil/mnt/share/archive/moje_dokumenty/zestawienie.ods")
   (xbindkey
     '(Mod4 "3")
     ",leonidas toggle_hdmi_mute")
   (xbindkey
     '(Mod4 "4")
     ",xrandr_change_brightness.sh -0.1")
   (xbindkey
     '(Mod4 "5")
     ",xrandr_change_brightness.sh +0.1")
   (xbindkey
     '(Mod4 F9)
     "pactl set-sink-mute   @DEFAULT_SINK@ toggle")
   (xbindkey
     '(Mod4 F10)
     "pactl set-sink-volume @DEFAULT_SINK@ -2%")
   (xbindkey
     '(Mod4 F11)
     "pactl set-sink-volume @DEFAULT_SINK@ +2%")
   (xbindkey
     '(Mod4 F12)
     ",leonidas toggle_hdmi_mute"))
  (else
   (xbindkey
     '(Mod4 "4")
     "xdotool keyup 4 keyup Super_L key XF86MonBrightnessDown keydown Super_L")
   (xbindkey
     '(Mod4 "5")
     "xdotool keyup 5 keyup Super_L key XF86MonBrightnessUp   keydown Super_L")))

(xbindkey
  '(Mod4 grave)
  "pactl set-sink-mute   @DEFAULT_SINK@ toggle")
(xbindkey
  '(Mod4 "1")
  "pactl set-sink-volume @DEFAULT_SINK@ -2%")
(xbindkey
  '(Mod4 "2")
  "pactl set-sink-volume @DEFAULT_SINK@ +2%")

(case host
  ((leonidas) "")
  (else
	(xbindkey
	  '(Mod4 Right)
	  ",magic_position_window.sh right")
	(xbindkey
	  '(Mod4 Up)
	  ",magic_position_window.sh up")
	(xbindkey
	  '(Mod4 Down)
	  ",magic_position_window.sh down")
	(xbindkey
	  '(Mod4 Left)
	  ",magic_position_window.sh left")
))

(Xbindkey
  '(XF86Search)
  "-iorg.xfce.appfinder"
  "xfce4-appfinder")
(Xbindkey
  '(XF86HomePage)
  "-ifirefox"
  "browser"
  "firefox")
(Xbindkey
  '(XF86ScreenSaver)
  "-ixfsm-lock"
  "xflock4")
(Xbindkey
  '(XF86Calculator)
  "-iorg.xfce.terminal"
  "xfce4-terminal -e \"bash -c \\\"echo Running bc calculator; bc\\\"\"")
(Xbindkey
  '(XF86Tools)
  "-ifirefox"
  "firefox https://open.fm/stacja/alt-pl https://open.spotify.com/search")
;(Xbindkey
  ;'(Print)
  ;"-iorg.xfce.screenshooter"
  ;"printscreen"
  ;"xfce4-screenshooter --fullscreen")
(Xbindkey
  '(Mod4 n)
  "-ifirefox"
  "browser"
  "firefox")
(Xbindkey
  '(Mod4 e)
  "-ifolder_open"
  "File Explorer"
  "xdg-open ~")
(XbindkeyMultiple
  '((Mod4 w) (Mod4 m) (XF86Mail))
  "-iemblem-mail"
  "email"
  "nohup birdtray -t >/dev/null </dev/null 2>&1")

(XbindkeyMultiple
  '((Mod4 d) (Mod4 s))
  "-islack"
  "wmctrl -c 'Slack |' || slack")

(Xbindkey '(Alt F3) "xfce4-appfinder")
(Xbindkey
  '(Alt F2)
  "-iorg.xfce.appfinder"
  "xfce4-appfinder --collapsed")

(XbindkeyMultiple
  '((Control Shift  Alt Mod4 Mod5 Control_R)
    (Control Shift Mod2 Mod4 Mod5 Control_R))
  "-ixfsm-suspend"
  "Suspend"
  "systemctl suspend")

(Xbindkey
  '(Control Escape)
  "-ixfce4-whiskermenu"
  "xfce4-popup-whiskermenu")

(xbindkey
  '(Mod4 r)
  "xdotool click --repeat 4 1")
  ;"xdotool click --repeat 10 --delay 10 1")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; End of xbindkeys guile configuration ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
