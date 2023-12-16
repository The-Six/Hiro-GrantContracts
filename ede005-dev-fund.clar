;; Challenge 3 : Implement Milestone-Based funding
(impl-trait .extension-trait.extension-trait)

(define-constant one-month-time u4380) ;; 43,800 minutes / 10 minute average block time.

(define-constant err-unauthorised (err u3000))
(define-constant err-no-allowance (err u3001))
(define-constant err-already-claimed (err u3002))

(define-map monthly-developer-allowances principal {start-height: uint, allowance: uint})
(define-map claim-counts principal uint)

;; --- Authorisation check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .core) (contract-call? .core is-extension contract-caller)) err-unauthorised))
)

;; --- Internal DAO functions

(define-public (set-developer-allowance (start-height uint) (allowance uint) (who principal))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set monthly-developer-allowances who {start-height: start-height, allowance: allowance}))
	)
)

(define-private (set-developer-allowances-iter (item {start-height: uint, allowance: uint, who: principal}) (previous bool))
	(map-set monthly-developer-allowances (get who item) {start-height: (get start-height item), allowance: (get allowance item)})
)

(define-public (set-developer-allowances (developers (list 200 {start-height: uint, allowance: uint, who: principal})))
	(begin
		(try! (is-dao-or-extension))
		(ok (fold set-developer-allowances-iter developers true))
	)
)

(define-public (transfer (amount uint) (recipient principal) (memo (optional (buff 34))))
	(begin
		(try! (is-dao-or-extension))
		(as-contract (contract-call? .membership-token transfer amount tx-sender recipient memo))
	)
)

;; --- Public functions

(define-read-only (get-developer-allowance (who principal))
	(map-get? monthly-developer-allowances who)
)

(define-read-only (get-developer-claim-count (who principal))
	(default-to u0 (map-get? claim-counts who))
)

(define-public (claim (memo (optional (buff 34))))
	(let
		(
			(entry (unwrap! (get-developer-allowance tx-sender) err-no-allowance))
			(claim-count (get-developer-claim-count tx-sender))
			(start-height (get start-height entry))
			(max-claims (/ (- block-height start-height) one-month-time))
			(developer tx-sender)
		)
		(asserts! (< claim-count max-claims) err-already-claimed)
		(map-set claim-counts tx-sender max-claims)
		(as-contract (contract-call? .membership-token transfer (* (- max-claims claim-count) (get allowance entry)) tx-sender developer memo))
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)
;; Challenge 3 : Implement Milestone-Based funding End