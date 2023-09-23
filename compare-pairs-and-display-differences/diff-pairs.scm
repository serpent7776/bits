(use-modules (ice-9 popen))
(use-modules (ice-9 rdelim))

(define args (cadr (command-line)))

(define command (format #f "ls ~a | xargs -n 2" args))

(define process (open-input-pipe command))

(let loop ((line (read-line process)))
  (if (eof-object? line)
    (close-pipe process)
    (begin
      (let
	((status (system (format #f "zcmp -s ~a" line))))
	(if (not (= status 0))
	  (begin
	    (display (format #f "~a differ" line))
	    (system (format #f "vim -d ~a" line)))))
      (loop (read-line process)))))
