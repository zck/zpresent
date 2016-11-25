;;; tests.el -- tests for zpresent.el

;;; Commentary:

;;; Code:


;; (ert-deftest format-block-helper-single-block ()
;;   (should (org-structure/hash-tables-equal #s(hash-table data (title "a title" body ("one" "two")))
;;                                            (car (zpresent-format-block-helper (make-hash-table)
;;                                                                               (make-hash-table 'title "a title"
;;                                                                                                'body nil)
;;                                                                               nil)))))

(ert-deftest make-slide/title-only/check-title ()
  (should (equal "I'm the title!"
                 (gethash 'title (zpresent/make-slide "I'm the title!")))))

(ert-deftest make-slide/title-only/no-body ()
  (should-not (gethash 'body (zpresent/make-slide "I'm the title!"))))

(ert-deftest make-slide/title-only/proper-things-added ()
  (should (equal 2
                 (hash-table-count (zpresent/make-slide "I'm the title!")))))

(ert-deftest make-slide/body/no-body ()
  (should (equal "I'm a body"
                 (gethash 'body (zpresent/make-slide "I'm the title!" "I'm a body")))))

(ert-deftest make-slide/body/no-body ()
  (should (equal 2
                 (hash-table-count (zpresent/make-slide "I'm the title!" "I'm a body")))))


(ert-deftest extend-slide/original-slide-not-updated ()
  (let* ((original-slide (zpresent/make-slide "I'm the title!"))
         (new-slide (zpresent/extend-slide original-slide (car (org-structure "* New body text.")) 1)))
    (should (equal 2 (hash-table-count original-slide)))
    (should-not (gethash 'body original-slide))))

(ert-deftest extend-slide/check-title ()
  (let* ((original-slide (zpresent/make-slide "I'm the title!"))
         (new-slide (zpresent/extend-slide original-slide (car (org-structure "* New body text.")) 1)))
    (should (equal "I'm the title!"
                   (gethash 'title new-slide)))))

(ert-deftest extend-slide/check-new-body ()
  (let* ((original-slide (zpresent/make-slide "I'm the title!"))
         (new-slide (zpresent/extend-slide original-slide (car (org-structure "* New body text.")) 1)))
    (should (equal (list " ▸ New body text.")
                   (gethash 'body new-slide)))))

(ert-deftest extend-slide/check-added-body ()
  (let* ((original-slide (zpresent/make-slide "I'm the title!" "Initial body."))
         (new-slide (zpresent/extend-slide original-slide (car (org-structure "* New body text.")) 1)))
    (should (equal (list "Initial body." " ▸ New body text.")
                   (gethash 'body new-slide)))))


(ert-deftest extract-current-text/simple-headline ()
  (should (equal "simple headline"
                 (zpresent/extract-current-text (car (org-structure "* simple headline"))))))

(ert-deftest extract-current-text/nested-headline ()
  (should (equal "nested headline"
                 (zpresent/extract-current-text (car (org-structure "** nested headline"))))))

(ert-deftest extract-current-text/simple-headline-with-multiple-line-body ()
  (should (equal (list "nested headline" "with body" "over multiple lines")
                 (zpresent/extract-current-text (car (org-structure "** nested headline\nwith body\nover multiple lines"))))))

(ert-deftest extract-current-text/simple-plain-list ()
  (should (equal "simple plain list"
                 (zpresent/extract-current-text (car (org-structure "- simple plain list"))))))

(ert-deftest extract-current-text/nested-plain-list ()
  (should (equal "nested plain list"
                 (zpresent/extract-current-text (car (org-structure "  - nested plain list"))))))

(ert-deftest extract-current-text/simple-plain-list-with-multiple-line-body ()
  (should (equal (list "nested plain list" "with body" "over multiple lines")
                 (zpresent/extract-current-text (car (org-structure "  - nested plain list\nwith body\nover multiple lines"))))))


(ert-deftest make-body-text/simple-headline ()
  (should (equal (list " ▸ headline")
                 (zpresent/make-body-text (car (org-structure "* headline")) 1))))

(ert-deftest make-body-text/indented-headline ()
  (should (equal (list "   ▸ my headline")
                 (zpresent/make-body-text (car (org-structure "** my headline")) 2))))

(ert-deftest make-body-text/plain-list ()
  (should (equal (list "  a plain list")
                 (zpresent/make-body-text (car (org-structure "- a plain list")) 1))))

(ert-deftest make-body-text/indented-plain-list ()
  (should (equal (list "    in too deep")
                 (zpresent/make-body-text (car (org-structure "  - in too deep")) 2))))

(ert-deftest make-body-text/two-line-headline-not-at-top ()
  (should (equal (list "   ▸ headline" "     on two lines")
                 (zpresent/make-body-text (car (gethash :children (car (org-structure "* top\n** headline\non two lines")))) 2))))


(ert-deftest format-title/basic-title ()
  (should (equal "  title\n"
                 (zpresent/format-title "title" 9))))

(ert-deftest format-title/too-long-title ()
  (should (equal "  long\n  title\n"
                 (zpresent/format-title "long title" 9 t))))

(ert-deftest format-title/face-is-applied ()
  (should (equal 'zpresent-h1
                 (get-text-property 0 'face (zpresent/format-title "here for the face" 10 t)))))

(ert-deftest format-title/break-long-title-arg-obeyed ()
  (should (equal "this title is way too long\n"
                 (zpresent/format-title "this title is way too long" 5))))



(ert-deftest format-title-single-line/too-long-title ()
  (should (equal "this is a long long title\n"
                 (zpresent/format-title-single-line "this is a long long title" 10))))

(ert-deftest format-title-single-line/padding-just-one-character ()
  (should (equal " single\n"
                 (zpresent/format-title-single-line "single" 8))))

(ert-deftest format-title-single-line/several-padding-chars ()
  (should (equal "   three here\n"
                 (zpresent/format-title-single-line "three here" 16))))

(ert-deftest format-title-single-line/ ()
  (should (equal 'zpresent-h1
                 (get-text-property 0 'face (zpresent/format-title-single-line "here for the face" 10)))))



(ert-deftest title-should-be-split/short-title ()
  (should-not (zpresent/title-should-be-split "abc" 9 t)))

(ert-deftest title-should-be-split/long-title ()
  (should (zpresent/title-should-be-split (make-string 14 ?z) 5 t)))

(ert-deftest title-should-be-split/break-long-title-argument-is-obeyed ()
  (should-not (zpresent/title-should-be-split (make-string 14 ?z) 5 nil)))



;;; tests.el ends here
