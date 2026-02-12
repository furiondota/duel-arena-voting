(define-data-var red-score uint u0)
(define-data-var blue-score uint u0)

(define-public (vote-red)
  (begin
    (var-set red-score (+ (var-get red-score) u1))
    (ok "Red fighter +1")
  )
)

(define-public (vote-blue)
  (begin
    (var-set blue-score (+ (var-get blue-score) u1))
    (ok "Blue fighter +1")
  )
)

(define-read-only (scoreboard)
  {
    red: (var-get red-score),
    blue: (var-get blue-score)
  }
)
