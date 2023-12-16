;;Traits and Constants
(impl-trait .extension-trait.extension-trait)
;;(use-trait extension-trait .extension-trait.extension-trait)
(use-trait proposal-trait .proposal-trait.proposal-trait)

(define-constant ERR_UNAUTHORIZED (err u3000))
(define-constant ERR_UNKNOWN_PARAMETER (err u3001))
;;Traits and Constants End.

;;Variables
(define-map parameters (string-ascii 34) uint)
(map-set parameters "proposal-duration" u1440) ;; ~10 days based on a ~10 minute block time.
;;Variables End.

;;Authorization Check
(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .core) (contract-call? .core is-extension contract-caller)) ERR_UNAUTHORIZED))
)
;;Authorization Check End.

;;Parameters
(define-read-only (get-parameter (parameter (string-ascii 34)))
  (ok (unwrap! (map-get? parameters parameter) ERR_UNKNOWN_PARAMETER))
)
;;Parameters End.

;;Proposals
(define-public (propose (proposal <proposal-trait>) (title (string-ascii 50)) (description (string-ascii 500)))
  (begin
    (contract-call? .proposal-voting add-proposal
      proposal
      {
        end-block-height: (+ block-height (try! (get-parameter "proposal-duration"))),
        proposer: tx-sender,
        title: title,
        description: description,
        ;; Add this to solve error and set start block height
        start-block-height: block-height,
      }
    )
  )
)
;;Proposals End.

;;Extension Callback
(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)
;;Extension Callback End.

