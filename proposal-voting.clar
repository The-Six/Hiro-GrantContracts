;;Traits and Constants
(impl-trait .extension-trait.extension-trait)
;; (use-trait extension-trait .extension-trait.extension-trait)
(use-trait proposal-trait .proposal-trait.proposal-trait)

(define-constant ERR_UNAUTHORIZED (err u3000))
(define-constant ERR_PROPOSAL_ALREADY_EXECUTED (err u3002))
(define-constant ERR_PROPOSAL_ALREADY_EXISTS (err u3003))
(define-constant ERR_UNKNOWN_PROPOSAL (err u3004))
(define-constant ERR_PROPOSAL_ALREADY_CONCLUDED (err u3005))
(define-constant ERR_PROPOSAL_INACTIVE (err u3006))
(define-constant ERR_PROPOSAL_NOT_CONCLUDED (err u3007))
(define-constant ERR_NO_VOTES_TO_RETURN (err u3008))
(define-constant ERR_END_BLOCK_HEIGHT_NOT_REACHED (err u3009))
(define-constant ERR_DISABLED (err u3010))
;;Traits and Constants End.

;;Variables
(define-map proposals
  principal
  {
    votes-for: uint,
    votes-against: uint,
    start-block-height: uint,
    end-block-height: uint,
    concluded: bool,
    passed: bool,
    proposer: principal,
    title: (string-ascii 50),
    description: (string-ascii 500)
  }
)

(define-map member-total-votes {proposal: principal, voter: principal} uint)
;;Variables End.

;;Authorization Check
(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .core) (contract-call? .core is-extension contract-caller)) ERR_UNAUTHORIZED))
)
;;Authorization Check End.

;;Proposals
(define-public (add-proposal (proposal <proposal-trait>) (data {start-block-height: uint, end-block-height: uint, proposer: principal, title: (string-ascii 50), description: (string-ascii 500)}))
  (begin
    (try! (is-dao-or-extension))
    ;; change .executor-dao to .core
    (asserts! (is-none (contract-call? .core executed-at proposal)) ERR_PROPOSAL_ALREADY_EXECUTED)
    (print {event: "propose", proposal: proposal, proposer: tx-sender})
    (ok (asserts! (map-insert proposals (contract-of proposal) (merge {votes-for: u0, votes-against: u0, concluded: false, passed: false} data)) ERR_PROPOSAL_ALREADY_EXISTS))
  )
)
;;Proposals End.

;;Voting
(define-public (vote (amount uint) (for bool) (proposal principal))
  (let
    (
      (proposal-data (unwrap! (map-get? proposals proposal) ERR_UNKNOWN_PROPOSAL))
    )
    (asserts! (>= (unwrap-panic (contract-call? .membership-token get-balance tx-sender)) u1) ERR_UNAUTHORIZED)
    (map-set member-total-votes {proposal: proposal, voter: tx-sender}
      (+ (get-current-total-votes proposal tx-sender) amount)
    )
    (map-set proposals proposal
      (if for
        (merge proposal-data {votes-for: (+ (get votes-for proposal-data) amount)})
        (merge proposal-data {votes-against: (+ (get votes-against proposal-data) amount)})
      )
    )
    (ok (print {event: "vote", proposal: proposal, voter: tx-sender, for: for, amount: amount}))
  )
)

;; Challenge 4 start

(define-read-only (get-proposal-data (proposal principal))
	(map-get? proposals proposal)
)

;; Challenge 4 end

(define-read-only (get-current-total-votes (proposal principal) (voter principal))
  (default-to u0 (map-get? member-total-votes {proposal: proposal, voter: voter}))
)
;;Voting End.

;;Conclusion
(define-public (conclude (proposal <proposal-trait>))
  (let
    (
      (proposal-data (unwrap! (map-get? proposals (contract-of proposal)) ERR_UNKNOWN_PROPOSAL))
      (passed (> (get votes-for proposal-data) (get votes-against proposal-data)))
    )
    (asserts! (not (get concluded proposal-data)) ERR_PROPOSAL_ALREADY_CONCLUDED)
    (asserts! (>= block-height (get end-block-height proposal-data)) ERR_END_BLOCK_HEIGHT_NOT_REACHED)
    (map-set proposals (contract-of proposal) (merge proposal-data {concluded: true, passed: passed}))
    (print {event: "conclude", proposal: proposal, passed: passed})
    ;; change .executor-dao to .core
    (and passed (try! (contract-call? .core execute proposal tx-sender)))
    (ok passed)
  )
)
;;Conclusion End.

;; ;; Challenge 4 start

;; (define-public (reclaim-votes (proposal <proposal-trait>))
;; 	(let
;; 		(
;; 			(proposal-principal (contract-of proposal))
;; 			(proposal-data (unwrap! (map-get? proposals proposal-principal) err-unknown-proposal))
;; 			(votes (unwrap! (map-get? member-total-votes {proposal: proposal-principal, voter: tx-sender}) err-no-votes-to-return))
;; 		)
;; 		(asserts! (get concluded proposal-data) err-proposal-not-concluded)
;; 		(map-delete member-total-votes {proposal: proposal-principal, voter: tx-sender})
;; 		(contract-call? .membership-token edg-unlock votes tx-sender)
;; 	)
;; )

;; (define-public (reclaim-and-vote (amount uint) (for bool) (proposal principal) (reclaim-from <proposal-trait>))
;; 	(begin
;; 		(try! (reclaim-votes reclaim-from))
;; 		(vote amount for proposal)
;; 	)
;; )

;; ;; Challenge 4 end

;;Extension Callback
(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)
;;Extension Callback End.