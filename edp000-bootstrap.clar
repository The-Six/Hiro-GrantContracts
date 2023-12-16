;; Challenge 1 : Initialize Your Grants Program
(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		;; Enable genesis extensions.
		(try! (contract-call? .core set-extensions
			(list
                {extension: .membership-token, enabled: true}
                 {extension: .proposal-voting, enabled: true}
                 {extension: .proposal-submission, enabled: true}
			)
		))

		;; Mint initial token supply.
		(try! (contract-call? .membership-token mint-many 
			(list
				{amount: u1000, recipient: sender}
				{amount: u1000, recipient: 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5}
				{amount: u1000, recipient: 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG}
				{amount: u1000, recipient: 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC}
				{amount: u1000, recipient: 'ST2NEB84ASENDXKYGJPQW86YXQCEFEX2ZQPG87ND}
				{amount: u1000, recipient: 'ST2REHHS5J3CERCRBEPMGH7921Q6PYKAADT7JP2VB}
				{amount: u1000, recipient: 'ST3AM1A56AK2C1XAFJ4115ZSV26EB49BVQ10MGCS0}
				{amount: u1000, recipient: 'ST3NBRSFKX28FQ2ZJ1MAKX58HKHSDGNV5N7R21XCP}
				{amount: u1000, recipient: 'ST3PF13W7Z0RRM42A8VZRVFQ75SV1K26RXEP8YGKJ}
				{amount: u1000, recipient: 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6}
			)
		))

		(print "Core GrantsProgram activated.")
		(ok true)
	)
)
;; Challenge 1 : Initialize Your Grants Program End
