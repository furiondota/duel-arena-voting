;; ==============================
;; SIMPLE FIGHT VOTING CONTRACT
;; ==============================

;; Error Codes
(define-constant ERR-ALREADY-VOTED (err u100))
(define-constant ERR-VOTING-CLOSED (err u101))
(define-constant ERR-NOT-AUTHORIZED (err u102))
(define-constant ERR-INVALID-DURATION (err u103))

;; Owner
(define-constant CONTRACT-OWNER tx-sender)

;; Config
(define-constant VOTE-FEE u1000) ;; 0.001 STX per vote

;; Data Variables
(define-data-var red-score uint u0)
(define-data-var blue-score uint u0)
(define-data-var voting-end uint u0)

;; Track voters
(define-map has-voted principal bool)

;; ==============================
;; Admin: Start Voting
;; ==============================

(define-public (start-voting (duration uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> duration u0) ERR-INVALID-DURATION)

    (var-set voting-end (+ block-height duration))
    (ok true)
  )
)

;; ==============================
;; Vote Red
;; ==============================

(define-public (vote-red)
  (begin
    (asserts! (< block-height (var-get voting-end)) ERR-VOTING-CLOSED)
    (asserts! (is-none (map-get? has-voted tx-sender)) ERR-ALREADY-VOTED)

    ;; Charge voting fee
    (try! (stx-transfer? VOTE-FEE tx-sender (as-contract tx-sender)))

    ;; Record vote
    (map-set has-voted tx-sender true)
    (var-set red-score (+ (var-get red-score) u1))

    ;; Emit event
    (print {
      event: "vote",
      side: "red",
      voter: tx-sender,
      new-score: (var-get red-score),
      block: block-height
    })

    (ok "Red fighter +1")
  )
)

;; ==============================
;; Vote Blue
;; ==============================

(define-public (vote-blue)
  (begin
    (asserts! (< block-height (var-get voting-end)) ERR-VOTING-CLOSED)
    (asserts! (is-none (map-get? has-voted tx-sender)) ERR-ALREADY-VOTED)

    ;; Charge voting fee
    (try! (stx-transfer? VOTE-FEE tx-sender (as-contract tx-sender)))

    ;; Record vote
    (map-set has-voted tx-sender true)
    (var-set blue-score (+ (var-get blue-score) u1))

    ;; Emit event
    (print {
      event: "vote",
      side: "blue",
      voter: tx-sender,
      new-score: (var-get blue-score),
      block: block-height
    })

    (ok "Blue fighter +1")
  )
)

;; ==============================
;; Reset Voting (Owner Only)
;; ==============================

(define-public (reset)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (var-set red-score u0)
    (var-set blue-score u0)
    (var-set voting-end u0)

    (ok true)
  )
)

;; ==============================
;; Read-only: Scoreboard
;; ==============================

(define-read-only (scoreboard)
  {
    red: (var-get red-score),
    blue: (var-get blue-score),
    voting-end: (var-get voting-end)
  }
)

;; ==============================
;; Read-only: Winner
;; ==============================

(define-read-only (winner)
  (let (
    (red (var-get red-score))
    (blue (var-get blue-score))
  )
    (if (> red blue)
        "Red"
        (if (> blue red)
            "Blue"
            "Tie"
        )
    )
  )
)
