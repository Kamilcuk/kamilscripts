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

(define host (cond
	((string=? (gethostname) "leonidas") 'leonidas)
	((string=? (gethostname) "ardalus")  'ardalus)
	(else 'unknown)
))

(xbindkey '(Mod4 F1) "qqoknonainnypulpit.sh 0")
(xbindkey '(Mod4 F2) "qqoknonainnypulpit.sh 1")
(xbindkey '(Mod4 F3) "qqoknonainnypulpit.sh 2")
(xbindkey '(Mod4 F4) "qqoknonainnypulpit.sh 3")
(xbindkey '(Mod4 F5) "qqoknonainnypulpit.sh 4")
(xbindkey '(Mod4 F6) "qqoknonainnypulpit.sh 5")
(xbindkey '(Mod4 F7) "qqoknonainnypulpit.sh 6")
(xbindkey '(Mod4 F8) "qqoknonainnypulpit.sh 7")
(xbindkey '(Mod4 F12) "qqoknonainnyscreen")

(xbindkey '(Mod4 a) "geany")
(xbindkey '(Mod4 s) "subl")
(xbindkey '(Mod4 f) "soffice --calc")
(xbindkey '(Mod4 c) 
	(string-append "xfce4-terminal "
		(case host 
			((leonidas) "--geometry 140x35")
			((ardalus)  "--geometry 126x34")
			(else "")
		)
	)
)

(case host ((leonidas)
	(xbindkey '(Mod4 equal) "soffice --calc /home/moje/zestawienie.ods")
	(xbindkey '(Mod4 "3") "/home/users/kamil/bin/leonidas_toggle_hdmi_mute.sh")
	(xbindkey '(Mod4 "4") "/home/users/kamil/bin/qq_setbrigthness.sh --dec")
	(xbindkey '(Mod4 "5") "/home/users/kamil/bin/qq_setbrigthness.sh --inc")
))

(xbindkey '(Mod4 grave) "pactl set-sink-mute @DEFAULT_SINK@ toggle")
(xbindkey '(Mod4 "1") "pactl set-sink-volume @DEFAULT_SINK@ -2%")
(xbindkey '(Mod4 "2") "pactl set-sink-volume @DEFAULT_SINK@ +2%")

(xbindkey '(Mod4 Right) ",magic_position_window.sh right")
(xbindkey '(Mod4 Up) ",magic_position_window.sh up")
(xbindkey '(Mod4 Down) ",magic_position_window.sh down")
(xbindkey '(Mod4 Left) ",magic_position_window.sh left")

(xbindkey '(XF86Search) "xfce4-appfinder")
(xbindkey '(XF86HomePage) "firefox")
(xbindkey '(Mod4 b)       "firefox")
(xbindkey '(XF86Mail) "nohup birdtray -t >/dev/null </dev/null 2>&1 &")
(xbindkey '(Mod4 m)   "nohup birdtray -t >/dev/null </dev/null 2>&1 &")

(xbindkey '(Mod4 d) "/home/users/kamil/bin/,slack_toggle.sh")

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; End of xbindkeys guile configuration ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;