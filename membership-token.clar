(define-constant ERR_UNAUTHORIZED (err u2000))
(define-constant ERR_NOT_TOKEN_OWNER (err u2001))
(define-constant ERR_MEMBERSHIP_LIMIT_REACHED (err u2002))

(define-fungible-token sGrant)

(define-data-var tokenName (string-ascii 32) "sGrant")
(define-data-var tokenSymbol (string-ascii 10) "SGT")
(define-data-var tokenUri (optional (string-utf8 256)) none)
(define-data-var tokenDecimals uint u6)

;;Authorization Check
(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .core) (contract-call? .core is-extension contract-caller)) ERR_UNAUTHORIZED))
)
;;Authorization Check End.

;; ;; Challenge 4

;; (define-public (edg-unlock (amount uint) (owner principal))
;; 	(begin
;; 		(try! (is-dao-or-extension))
;; 		(try! (ft-burn? edg-token-locked amount owner))
;; 		(ft-mint? sGrant amount owner)
;; 	)
;; )

;; ;; Challenge 4 End

;;Token Minting and Burning
(define-public (mint (amount uint) (recipient principal))
  (begin
    (try! (is-dao-or-extension))
    (ft-mint? sGrant amount recipient)
  )
)

(define-public (burn (amount uint) (owner principal))
  (begin
    (try! (is-dao-or-extension))
    (ft-burn? sGrant amount owner)
  )
)
;;Token Minting and Burning End.

;; Challenge 1
;; This can handle minting with a list of recipients and amounts

(define-private (mint-many-iter (item {amount: uint, recipient: principal}))
	(ft-mint? sGrant (get amount item) (get recipient item))
)

(define-public (mint-many (recipients (list 200 {amount: uint, recipient: principal})))
	(begin
		(try! (is-dao-or-extension))
		(ok (map mint-many-iter recipients))
	)
)
;; Challenge 1 End

;; Challenge 2 start

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) ERR_NOT_TOKEN_OWNER)
		(ft-transfer? sGrant amount sender recipient)
	)
)

;; Challenge 2 End

;;Token Information
(define-read-only (get-name)
  (ok (var-get tokenName))
)

(define-read-only (get-symbol)
  (ok (var-get tokenSymbol))
)

(define-read-only (get-decimals)
  (ok (var-get tokenDecimals))
)

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance sGrant who))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply sGrant))
)

(define-read-only (get-token-uri)
  (ok (var-get tokenUri))
)
;;Token Information End.