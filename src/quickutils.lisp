;;;; This file was automatically generated by Quickutil.
;;;; See http://quickutil.org for details.

;;;; To regenerate:
;;;; (qtlc:save-utils-as "quickutils.lisp" :utilities '(:DEFINE-CONSTANT :SET-EQUAL :CURRY :SWITCH :ENSURE-BOOLEAN :WHILE :UNTIL :TREE-MEMBER-P :TREE-COLLECT :WITH-GENSYMS :ONCE-ONLY :ZIP :ALIST-TO-HASH-TABLE :MAP-TREE :WEAVE :RANGE :ALIST-PLIST :EQUIVALENCE-CLASSES :MAP-PRODUCT) :ensure-package T :package "BONES.QUICKUTILS")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "BONES.QUICKUTILS")
    (defpackage "BONES.QUICKUTILS"
      (:documentation "Package that contains Quickutil utility functions.")
      (:use #:cl))))

(in-package "BONES.QUICKUTILS")

(when (boundp '*utilities*)
  (setf *utilities* (union *utilities* '(:DEFINE-CONSTANT :SET-EQUAL
                                         :MAKE-GENSYM-LIST :ENSURE-FUNCTION
                                         :CURRY :STRING-DESIGNATOR
                                         :WITH-GENSYMS :EXTRACT-FUNCTION-NAME
                                         :SWITCH :ENSURE-BOOLEAN :UNTIL :WHILE
                                         :TREE-MEMBER-P :TREE-COLLECT
                                         :ONCE-ONLY :TRANSPOSE :ZIP
                                         :ALIST-TO-HASH-TABLE :MAP-TREE :WEAVE
                                         :RANGE :SAFE-ENDP :ALIST-PLIST
                                         :EQUIVALENCE-CLASSES :MAPPEND
                                         :MAP-PRODUCT))))

  (defun %reevaluate-constant (name value test)
    (if (not (boundp name))
        value
        (let ((old (symbol-value name))
              (new value))
          (if (not (constantp name))
              (prog1 new
                (cerror "Try to redefine the variable as a constant."
                        "~@<~S is an already bound non-constant variable ~
                       whose value is ~S.~:@>" name old))
              (if (funcall test old new)
                  old
                  (restart-case
                      (error "~@<~S is an already defined constant whose value ~
                              ~S is not equal to the provided initial value ~S ~
                              under ~S.~:@>" name old new test)
                    (ignore ()
                      :report "Retain the current value."
                      old)
                    (continue ()
                      :report "Try to redefine the constant."
                      new)))))))

  (defmacro define-constant (name initial-value &key (test ''eql) documentation)
    "Ensures that the global variable named by `name` is a constant with a value
that is equal under `test` to the result of evaluating `initial-value`. `test` is a
function designator that defaults to `eql`. If `documentation` is given, it
becomes the documentation string of the constant.

Signals an error if `name` is already a bound non-constant variable.

Signals an error if `name` is already a constant variable whose value is not
equal under `test` to result of evaluating `initial-value`."
    `(defconstant ,name (%reevaluate-constant ',name ,initial-value ,test)
       ,@(when documentation `(,documentation))))
  

  (defun set-equal (list1 list2 &key (test #'eql) (key nil keyp))
    "Returns true if every element of `list1` matches some element of `list2` and
every element of `list2` matches some element of `list1`. Otherwise returns false."
    (let ((keylist1 (if keyp (mapcar key list1) list1))
          (keylist2 (if keyp (mapcar key list2) list2)))
      (and (dolist (elt keylist1 t)
             (or (member elt keylist2 :test test)
                 (return nil)))
           (dolist (elt keylist2 t)
             (or (member elt keylist1 :test test)
                 (return nil))))))
  
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun make-gensym-list (length &optional (x "G"))
    "Returns a list of `length` gensyms, each generated as if with a call to `make-gensym`,
using the second (optional, defaulting to `\"G\"`) argument."
    (let ((g (if (typep x '(integer 0)) x (string x))))
      (loop repeat length
            collect (gensym g))))
  )                                        ; eval-when
(eval-when (:compile-toplevel :load-toplevel :execute)
  ;;; To propagate return type and allow the compiler to eliminate the IF when
  ;;; it is known if the argument is function or not.
  (declaim (inline ensure-function))

  (declaim (ftype (function (t) (values function &optional))
                  ensure-function))
  (defun ensure-function (function-designator)
    "Returns the function designated by `function-designator`:
if `function-designator` is a function, it is returned, otherwise
it must be a function name and its `fdefinition` is returned."
    (if (functionp function-designator)
        function-designator
        (fdefinition function-designator)))
  )                                        ; eval-when

  (defun curry (function &rest arguments)
    "Returns a function that applies `arguments` and the arguments
it is called with to `function`."
    (declare (optimize (speed 3) (safety 1) (debug 1)))
    (let ((fn (ensure-function function)))
      (lambda (&rest more)
        (declare (dynamic-extent more))
        ;; Using M-V-C we don't need to append the arguments.
        (multiple-value-call fn (values-list arguments) (values-list more)))))

  (define-compiler-macro curry (function &rest arguments)
    (let ((curries (make-gensym-list (length arguments) "CURRY"))
          (fun (gensym "FUN")))
      `(let ((,fun (ensure-function ,function))
             ,@(mapcar #'list curries arguments))
         (declare (optimize (speed 3) (safety 1) (debug 1)))
         (lambda (&rest more)
           (apply ,fun ,@curries more)))))
  

  (deftype string-designator ()
    "A string designator type. A string designator is either a string, a symbol,
or a character."
    `(or symbol string character))
  
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro with-gensyms (names &body forms)
    "Binds each variable named by a symbol in `names` to a unique symbol around
`forms`. Each of `names` must either be either a symbol, or of the form:

    (symbol string-designator)

Bare symbols appearing in `names` are equivalent to:

    (symbol symbol)

The string-designator is used as the argument to `gensym` when constructing the
unique symbol the named variable will be bound to."
    `(let ,(mapcar (lambda (name)
                     (multiple-value-bind (symbol string)
                         (etypecase name
                           (symbol
                            (values name (symbol-name name)))
                           ((cons symbol (cons string-designator null))
                            (values (first name) (string (second name)))))
                       `(,symbol (gensym ,string))))
            names)
       ,@forms))

  (defmacro with-unique-names (names &body forms)
    "Binds each variable named by a symbol in `names` to a unique symbol around
`forms`. Each of `names` must either be either a symbol, or of the form:

    (symbol string-designator)

Bare symbols appearing in `names` are equivalent to:

    (symbol symbol)

The string-designator is used as the argument to `gensym` when constructing the
unique symbol the named variable will be bound to."
    `(with-gensyms ,names ,@forms))
  )                                        ; eval-when
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun extract-function-name (spec)
    "Useful for macros that want to mimic the functional interface for functions
like `#'eq` and `'eq`."
    (if (and (consp spec)
             (member (first spec) '(quote function)))
        (second spec)
        spec))
  )                                        ; eval-when

  (eval-when (:compile-toplevel :load-toplevel :execute)
    (defun generate-switch-body (whole object clauses test key &optional default)
      (with-gensyms (value)
        (setf test (extract-function-name test))
        (setf key (extract-function-name key))
        (when (and (consp default)
                   (member (first default) '(error cerror)))
          (setf default `(,@default "No keys match in SWITCH. Testing against ~S with ~S."
                                    ,value ',test)))
        `(let ((,value (,key ,object)))
           (cond ,@(mapcar (lambda (clause)
                             (if (member (first clause) '(t otherwise))
                                 (progn
                                   (when default
                                     (error "Multiple default clauses or illegal use of a default clause in ~S."
                                            whole))
                                   (setf default `(progn ,@(rest clause)))
                                   '(()))
                                 (destructuring-bind (key-form &body forms) clause
                                   `((,test ,value ,key-form)
                                     ,@forms))))
                           clauses)
                 (t ,default))))))

  (defmacro switch (&whole whole (object &key (test 'eql) (key 'identity))
                    &body clauses)
    "Evaluates first matching clause, returning its values, or evaluates and
returns the values of `default` if no keys match."
    (generate-switch-body whole object clauses test key))

  (defmacro eswitch (&whole whole (object &key (test 'eql) (key 'identity))
                     &body clauses)
    "Like `switch`, but signals an error if no key matches."
    (generate-switch-body whole object clauses test key '(error)))

  (defmacro cswitch (&whole whole (object &key (test 'eql) (key 'identity))
                     &body clauses)
    "Like `switch`, but signals a continuable error if no key matches."
    (generate-switch-body whole object clauses test key '(cerror "Return NIL from CSWITCH.")))
  

  (defun ensure-boolean (x)
    "Convert `x` into a Boolean value."
    (and x t))
  

  (defmacro until (expression &body body)
    "Executes `body` until `expression` is true."
    `(do ()
         (,expression)
       ,@body))
  

  (defmacro while (expression &body body)
    "Executes `body` while `expression` is true."
    `(until (not ,expression)
       ,@body))
  

  (defun tree-member-p (item tree &key (test #'eql))
    "Returns `t` if `item` is in `tree`, `nil` otherwise."
    (labels ((rec (tree)
               (cond ((null tree) nil)
                     ((atom tree) (funcall test item tree))
                     (t (or (rec (car tree))
                            (rec (cdr tree)))))))
      (rec tree)))
  

  (defun tree-collect (predicate tree)
    "Returns a list of every node in the `tree` that satisfies the `predicate`. If there are any improper lists in the tree, the `predicate` is also applied to their dotted elements."
    (let ((sentinel (gensym)))
      (flet ((my-cdr (obj)
               (cond ((consp obj)
                      (let ((result (cdr obj)))
                        (if (listp result)
                            result
                            (list result sentinel))))
                     (t
                      (list sentinel)))))
        (loop :for (item . rest) :on tree :by #'my-cdr
              :until (eq item sentinel)
              :if (funcall predicate item) collect item
                :else
                  :if (listp item)
                    :append (tree-collect predicate item)))))
  

  (defmacro once-only (specs &body forms)
    "Evaluates `forms` with symbols specified in `specs` rebound to temporary
variables, ensuring that each initform is evaluated only once.

Each of `specs` must either be a symbol naming the variable to be rebound, or of
the form:

    (symbol initform)

Bare symbols in `specs` are equivalent to

    (symbol symbol)

Example:

    (defmacro cons1 (x) (once-only (x) `(cons ,x ,x)))
      (let ((y 0)) (cons1 (incf y))) => (1 . 1)"
    (let ((gensyms (make-gensym-list (length specs) "ONCE-ONLY"))
          (names-and-forms (mapcar (lambda (spec)
                                     (etypecase spec
                                       (list
                                        (destructuring-bind (name form) spec
                                          (cons name form)))
                                       (symbol
                                        (cons spec spec))))
                                   specs)))
      ;; bind in user-macro
      `(let ,(mapcar (lambda (g n) (list g `(gensym ,(string (car n)))))
              gensyms names-and-forms)
         ;; bind in final expansion
         `(let (,,@(mapcar (lambda (g n)
                             ``(,,g ,,(cdr n)))
                           gensyms names-and-forms))
            ;; bind in user-macro
            ,(let ,(mapcar (lambda (n g) (list (car n) g))
                    names-and-forms gensyms)
               ,@forms)))))
  

  (defun transpose (lists)
    "Analog to matrix transpose for a list of lists given by `lists`."
    (apply #'mapcar #'list lists))
  

  (defun zip (&rest lists)
    "Take a tuple of lists and turn them into a list of
tuples. Equivalent to `unzip`."
    (transpose lists))
  

  (defun alist-to-hash-table (kv-pairs)
    "Create a hash table populated with `kv-pairs`."
    (let ((hashtab (make-hash-table :test #'equal)))
      (loop 
        :for (i j) :in kv-pairs
        :do (setf (gethash i hashtab) j)
        :finally (return hashtab))))
  

  (defun map-tree (function tree)
    "Map `function` to each of the leave of `tree`."
    (check-type tree cons)
    (labels ((rec (tree)
               (cond
                 ((null tree) nil)
                 ((atom tree) (funcall function tree))
                 ((consp tree)
                  (cons (rec (car tree))
                        (rec (cdr tree)))))))
      (rec tree)))
  

  (defun weave (&rest lists)
    "Return a list whose elements alternate between each of the lists
`lists`. Weaving stops when any of the lists has been exhausted."
    (apply #'mapcan #'list lists))
  

  (defun range (start end &key (step 1) (key 'identity))
    "Return the list of numbers `n` such that `start <= n < end` and
`n = start + k*step` for suitable integers `k`. If a function `key` is
provided, then apply it to each number."
    (assert (<= start end))
    (loop :for i :from start :below end :by step :collecting (funcall key i)))
  

  (declaim (inline safe-endp))
  (defun safe-endp (x)
    (declare (optimize safety))
    (endp x))
  

  (defun alist-plist (alist)
    "Returns a property list containing the same keys and values as the
association list ALIST in the same order."
    (let (plist)
      (dolist (pair alist)
        (push (car pair) plist)
        (push (cdr pair) plist))
      (nreverse plist)))

  (defun plist-alist (plist)
    "Returns an association list containing the same keys and values as the
property list PLIST in the same order."
    (let (alist)
      (do ((tail plist (cddr tail)))
          ((safe-endp tail) (nreverse alist))
        (push (cons (car tail) (cadr tail)) alist))))
  

  (defun equivalence-classes (equiv seq)
    "Partition the sequence `seq` into a list of equivalence classes
defined by the equivalence relation `equiv`."
    (let ((classes nil))
      (labels ((find-equivalence-class (x)
                 (member-if (lambda (class)
                              (funcall equiv x (car class)))
                            classes))
               
               (add-to-class (x)
                 (let ((class (find-equivalence-class x)))
                   (if class
                       (push x (car class))
                       (push (list x) classes)))))
        (declare (dynamic-extent (function find-equivalence-class)
                                 (function add-to-class))
                 (inline find-equivalence-class
                         add-to-class))
        
        ;; Partition into equivalence classes.
        (map nil #'add-to-class seq)
        
        ;; Return the classes.
        classes)))
  

  (defun mappend (function &rest lists)
    "Applies `function` to respective element(s) of each `list`, appending all the
all the result list to a single list. `function` must return a list."
    (loop for results in (apply #'mapcar function lists)
          append results))
  

  (defun map-product (function list &rest more-lists)
    "Returns a list containing the results of calling `function` with one argument
from `list`, and one from each of `more-lists` for each combination of arguments.
In other words, returns the product of `list` and `more-lists` using `function`.

Example:

    (map-product 'list '(1 2) '(3 4) '(5 6))
     => ((1 3 5) (1 3 6) (1 4 5) (1 4 6)
         (2 3 5) (2 3 6) (2 4 5) (2 4 6))"
    (labels ((%map-product (f lists)
               (let ((more (cdr lists))
                     (one (car lists)))
                 (if (not more)
                     (mapcar f one)
                     (mappend (lambda (x)
                                (%map-product (curry f x) more))
                              one)))))
      (%map-product (ensure-function function) (cons list more-lists))))
  
(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(define-constant set-equal curry switch eswitch cswitch
            ensure-boolean while until tree-member-p tree-collect with-gensyms
            with-unique-names once-only zip alist-to-hash-table map-tree weave
            range alist-plist plist-alist equivalence-classes map-product)))

;;;; END OF quickutils.lisp ;;;;
