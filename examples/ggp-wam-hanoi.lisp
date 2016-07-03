(in-package #:bones.wam)

(declaim (optimize (speed 3) (debug 0) (safety 0)))

(defparameter *d* (make-database))

(with-database *d*
  (rules ((member :thing (list* :thing :rest)))
         ((member :thing (list* :other :rest))
          (member :thing :rest)))

  (rule (true :state :thing)
    (member :thing :state))

  (rule (does :performed :role :move)
    (member (does :role :move) :performed))

  (rules ((not :x) (call :x) ! fail)
         ((not :x)))

  (fact (role player))

  (facts (init (on disc7 pillar1))
         (init (on disc6 disc7))
         (init (on disc5 disc6))
         (init (on disc4 disc5))
         (init (on disc3 disc4))
         (init (on disc2 disc3))
         (init (on disc1 disc2))
         (init (clear disc1))
         (init (clear pillar2))
         (init (clear pillar3))
         (init (step s0)))

  (rule (legal :state player (puton :x :y))
    (true :state (clear :x))
    (true :state (clear :y))
    (smallerdisc :x :y))

  (rules ((next :state :performed (step :y))
          (true :state (step :x))
          (successor :x :y))
         ((next :state :performed (on :x :y))
          (does :performed player (puton :x :y)))
         ((next :state :performed (on :x :y))
          (true :state (on :x :y))
          (not (put_on_any :performed :x)))
         ((next :state :performed (clear :y))
          (true :state (on :x :y))
          (put_on_any :performed :x))
         ((next :state :performed (clear :y))
          (true :state (clear :y))
          (not (put_any_on :performed :y))))

  (rule (put_on_any :performed :x)
    (does :performed player (puton :x :y)))

  (rule (put_any_on :performed :y)
    (does :performed player (puton :x :y)))

  (rules ((goal :state player num100)
          (tower :state pillar3 s7))
         ((goal :state player num80)
          (tower :state pillar3 s6))
         ((goal :state player num60)
          (tower :state pillar3 s5))
         ((goal :state player num40)
          (tower :state pillar3 s4))
         ((goal :state player num0)
          (tower :state pillar3 :height)
          (smaller :height s4)))

  (rule (terminal :state)
    (true :state (step s127)))

  (rules ((tower :state :x s0)
          (true :state (clear :x)))
         ((tower :state :x :height)
          (true :state (on :y :x))
          (disc_or_pillar :y)
          (tower :state :y :height1)
          (successor :height1 :height)))

  (facts (pillar pillar1)
         (pillar pillar2)
         (pillar pillar3))

  (rules ((nextsize disc1 disc2))
         ((nextsize disc2 disc3))
         ((nextsize disc3 disc4))
         ((nextsize disc4 disc5))
         ((nextsize disc5 disc6))
         ((nextsize disc6 disc7))
         ((nextsize disc7 :pillar)
          (pillar :pillar)))

  (rules ((disc_or_pillar :p) (pillar :p))
         ((disc_or_pillar disc1))
         ((disc_or_pillar disc2))
         ((disc_or_pillar disc3))
         ((disc_or_pillar disc4))
         ((disc_or_pillar disc5))
         ((disc_or_pillar disc6))
         ((disc_or_pillar disc7)))

  (rules ((smallerdisc :a :b)
          (nextsize :a :b))
         ((smallerdisc :a :b)
          (nextsize :a :c)
          (smallerdisc :c :b)))

  (facts (successor s0 s1) (successor s1 s2) (successor s2 s3)
         (successor s3 s4) (successor s4 s5) (successor s5 s6)
         (successor s6 s7) (successor s7 s8) (successor s8 s9)
         (successor s9 s10) (successor s10 s11) (successor s11 s12)
         (successor s12 s13) (successor s13 s14) (successor s14 s15)
         (successor s15 s16) (successor s16 s17) (successor s17 s18)
         (successor s18 s19) (successor s19 s20) (successor s20 s21)
         (successor s21 s22) (successor s22 s23) (successor s23 s24)
         (successor s24 s25) (successor s25 s26) (successor s26 s27)
         (successor s27 s28) (successor s28 s29) (successor s29 s30)
         (successor s30 s31) (successor s31 s32) (successor s32 s33)
         (successor s33 s34) (successor s34 s35) (successor s35 s36)
         (successor s36 s37) (successor s37 s38) (successor s38 s39)
         (successor s39 s40) (successor s40 s41) (successor s41 s42)
         (successor s42 s43) (successor s43 s44) (successor s44 s45)
         (successor s45 s46) (successor s46 s47) (successor s47 s48)
         (successor s48 s49) (successor s49 s50) (successor s50 s51)
         (successor s51 s52) (successor s52 s53) (successor s53 s54)
         (successor s54 s55) (successor s55 s56) (successor s56 s57)
         (successor s57 s58) (successor s58 s59) (successor s59 s60)
         (successor s60 s61) (successor s61 s62) (successor s62 s63)
         (successor s63 s64) (successor s64 s65) (successor s65 s66)
         (successor s66 s67) (successor s67 s68) (successor s68 s69)
         (successor s69 s70) (successor s70 s71) (successor s71 s72)
         (successor s72 s73) (successor s73 s74) (successor s74 s75)
         (successor s75 s76) (successor s76 s77) (successor s77 s78)
         (successor s78 s79) (successor s79 s80) (successor s80 s81)
         (successor s81 s82) (successor s82 s83) (successor s83 s84)
         (successor s84 s85) (successor s85 s86) (successor s86 s87)
         (successor s87 s88) (successor s88 s89) (successor s89 s90)
         (successor s90 s91) (successor s91 s92) (successor s92 s93)
         (successor s93 s94) (successor s94 s95) (successor s95 s96)
         (successor s96 s97) (successor s97 s98) (successor s98 s99)
         (successor s99 s100) (successor s100 s101) (successor s101 s102)
         (successor s102 s103) (successor s103 s104) (successor s104 s105)
         (successor s105 s106) (successor s106 s107) (successor s107 s108)
         (successor s108 s109) (successor s109 s110) (successor s110 s111)
         (successor s111 s112) (successor s112 s113) (successor s113 s114)
         (successor s114 s115) (successor s115 s116) (successor s116 s117)
         (successor s117 s118) (successor s118 s119) (successor s119 s120)
         (successor s120 s121) (successor s121 s122) (successor s122 s123)
         (successor s123 s124) (successor s124 s125) (successor s125 s126)
         (successor s126 s127))

  (rules ((smaller :x :y)
          (successor :x :y))
         ((smaller :x :y)
          (successor :x :z)
          (smaller :z :y))))


(defun extract (key results)
  (mapcar (lambda (result) (getf result key)) results))

(defun to-prolog-list (l)
  (if (null l)
    nil
    (list* 'list l)))

(defun initial-state ()
  (to-prolog-list
    (with-database *d*
      (extract :what (return-all (init :what))))))

(defun terminalp (state)
  (with-database *d*
    (perform-prove `((terminal ,state)))))

(defun legal-moves (state)
  (with-database *d*
    (perform-return `((legal ,state :role :move)) :all)))

(defun roles ()
  (with-database *d*
    (extract :role (return-all (role :role)))))

(defun goal-value (state role)
  (with-database *d*
    (getf (perform-return `((goal ,state ,role :goal)) :one) :goal)))

(defun goal-values (state)
  (with-database *d*
    (perform-return `((goal ,state :role :goal)) :all)))

(defun next-state (current-state move)
  (let ((does `(list (does
                       ,(getf move :role)
                       ,(getf move :move)))))
    (with-database *d*
      (to-prolog-list
        (extract :what
                 (perform-return `((next ,current-state ,does :what)) :all))))))



(defvar *count* 0)

(defstruct search-path state (path nil) (previous nil))

(defun tree-search (states goal-p children combine)
  (labels
      ((recur (states)
         (if (null states)
           nil
           (destructuring-bind (state . remaining) states
             (incf *count*)
             (when (zerop (rem *count* 1000))
               (format t "~D...~%" *count*))
             ; (format t "Searching: ~S (~D remaining)~%"
             ;         state
             ;         (length remaining))
             (if (funcall goal-p state)
               state
               (recur (funcall combine
                               (funcall children state)
                               remaining)))))))
    (let ((result (recur states)))
      (when result
        (reverse (search-path-path result))))))


(defun game-goal-p (search-path)
  (let ((state (search-path-state search-path)))
    (and (terminalp state)
         (eql (goal-value state 'player) 'num100))))

(defun game-children (search-path)
  (let ((state (search-path-state search-path))
        (path (search-path-path search-path)))
    (when (not (terminalp state))
      (loop :for move :in (legal-moves state)
            :collect (make-search-path :state (next-state state move)
                                       :path (cons move path)
                                       :previous search-path)))))

(defun never (&rest args)
  (declare (ignore args))
  nil)

(defun dfs ()
  (let ((*count* 0))
    (tree-search (list (make-search-path :state (initial-state)))
               #'game-goal-p
               #'game-children
               #'append)))

(defun dfs-exhaust ()
  (let ((*count* 0))
    (prog1
        (tree-search (list (make-search-path :state (initial-state)))
                     #'never
                     #'game-children
                     #'append)
      (format t "Searched ~D nodes.~%" *count*))))

(defun bfs ()
  (tree-search (list (make-search-path :state (initial-state)))
               #'game-goal-p
               #'game-children
               (lambda (x y)
                 (append y x))))