(in-package #:bones.wam)
(named-readtables:in-readtable :fare-quasiquote)

;;;; ,,--.     .                    .
;;;; |`, | ,-. |- . ,-,-. . ,_, ,-. |- . ,-. ,-.
;;;; |   | | | |  | | | | |  /  ,-| |  | | | | |
;;;; `---' |-' `' ' ' ' ' ' '"' `-^ `' ' `-' ' '
;;;;       |
;;;;       '

;;; Optimization of the WAM instructions happens between the precompilation
;;; phase and the rendering phase.  We perform a number of passes over the
;;; circle of instructions, doing one optimization each time.


(defun* optimize-get-constant ((node circle)
                               (constant fname)
                               (register register))
  ;; 1. get_structure c/0, Ai -> get_constant c, Ai
  (circle-replace node `(:get-constant ,constant ,register)))

(defun* optimize-put-constant ((node circle)
                               (constant fname)
                               (register register))
  ;; 2. put_structure c/0, Ai -> put_constant c, Ai
  (circle-replace node `(:put-constant ,constant ,register)))

(defun* optimize-subterm-constant-query ((node circle)
                                         (constant fname)
                                         (register register))
  ;; 3. put_structure c/0, Xi                     *** WE ARE HERE
  ;;    ...
  ;;    subterm_value Xi          -> subterm_constant c
  (loop
    :with previous = (circle-prev node)
    ;; Search for the corresponding set-value instruction
    :for n = (circle-forward-remove node) :then (circle-forward n)
    :while n
    :for (opcode . arguments) = (circle-value n)
    :when (and (eql opcode :subterm-value-local)
               (register= register (first arguments)))
    :do
    (circle-replace n `(:subterm-constant ,constant))
    (return previous)))

(defun* optimize-subterm-constant-program ((node circle)
                                           (constant fname)
                                           (register register))
  ;; 4. subterm_variable Xi       -> subterm_constant c
  ;;    ...
  ;;    get_structure c/0, Xi                     *** WE ARE HERE
  (loop
    ;; Search backward for the corresponding subterm-variable instruction
    :for n = (circle-backward node) :then (circle-backward n)
    :while n
    :for (opcode . arguments) = (circle-value n)
    :when (and (eql opcode :subterm-variable-local)
               (register= register (first arguments)))
    :do
    (circle-replace n `(:subterm-constant ,constant))
    (return (circle-backward-remove node))))

(defun* optimize-constants ((instructions circle))
  (:returns circle)
  ;; From the book and the erratum, there are four optimizations we can do for
  ;; constants (0-arity structures).

  (loop :for node = (circle-forward instructions) :then (circle-forward node)
        :while node
        :for (opcode . arguments) = (circle-value node)
        :do
        (match (circle-value node)

          (`(:put-structure ,functor 0 ,register)
           (setf node
                 (if (register-argument-p register)
                   (optimize-put-constant node functor register)
                   (optimize-subterm-constant-query node functor register))))

          (`(:get-structure ,functor 0 ,register)
           (setf node
                 (if (register-argument-p register)
                   (optimize-get-constant node functor register)
                   (optimize-subterm-constant-program node functor register))))))
  instructions)


(defun* optimize-void-runs ((instructions circle))
  (:returns circle)
  ;; We can optimize runs of N (:[unify/set]-void 1) instructions into a single
  ;; one that does all N at once.
  (loop
    :for node = (circle-forward instructions) :then (circle-forward node)
    :while node
    :for opcode = (car (circle-value node))
    :when (or (eq opcode :set-void)
              (eq opcode :subterm-void))
    :do
    (loop
      :with beginning = (circle-backward node)
      :for run-node = node :then (circle-forward run-node)
      :for run-opcode = (car (circle-value run-node))
      :while (eq opcode run-opcode)
      :do (circle-remove run-node)
      :sum 1 :into run-length fixnum ; lol
      :finally
      (progn
        (setf node (circle-forward beginning))
        (circle-insert-after beginning
                             `(,opcode ,run-length)))))
  instructions)


(defun* optimize-instructions ((instructions circle))
  (->> instructions
    (optimize-constants)
    (optimize-void-runs)))



