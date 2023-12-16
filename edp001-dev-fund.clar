;; Challenge 2 : Create Grant Proposals Start

(impl-trait .proposal-trait.proposal-trait)

(define-constant dev-fund-percentage u30)

(define-public (execute (sender principal))
	(let
		(
			(total-supply (unwrap-panic (contract-call? .membership-token get-total-supply)))
			(dev-fund-amount (/ (* total-supply dev-fund-percentage) u100))
		)
		(try! (contract-call? .core set-extension .ede005-dev-fund true))
		(try! (contract-call? .ede005-dev-fund set-developer-allowances (list
			{who: 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG, start-height: block-height, allowance: u100}
			{who: 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC, start-height: block-height, allowance: u20}
		)))
		(contract-call? .membership-token mint dev-fund-amount .ede005-dev-fund)
	)
)

;; Challenge 2 : Create Grant Proposals End
