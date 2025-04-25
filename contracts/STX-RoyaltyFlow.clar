;; Music Royalty Distribution Smart Contract
;; This contract manages music royalty distributions among artists, producers, and rights holders

;; Error codes
(define-constant ERR-UNAUTHORIZED-ACCESS (err u100))
(define-constant ERR-INVALID-ROYALTY-PERCENTAGE (err u101))
(define-constant ERR-DUPLICATE-SONG-ENTRY (err u102))
(define-constant ERR-SONG-DOES-NOT-EXIST (err u103))
(define-constant ERR-INSUFFICIENT-PAYMENT-FUNDS (err u104))
(define-constant ERR-INVALID-ROYALTY-RECIPIENT (err u105))
(define-constant ERR-PAYMENT-FAILED (err u106))
(define-constant ERR-INVALID-STRING-LENGTH (err u107))
(define-constant ERR-INVALID-SONG-TITLE (err u108))
(define-constant ERR-INVALID-PARTICIPANT-ROLE (err u109))
(define-constant ERR-INVALID-PRIMARY-ARTIST (err u110))
(define-constant ERR-INVALID-ADMINISTRATOR (err u111))

;; Data structures
(define-map RegisteredSongs
    { song-identifier: uint }
    {
        song-title: (string-ascii 50),
        primary-artist: principal,
        accumulated-revenue: uint,
        publication-date: uint,
        song-status-active: bool
    }
)

(define-map RoyaltyDistribution
    { song-identifier: uint, royalty-recipient: principal }
    {
        royalty-percentage: uint,
        participant-role: (string-ascii 20),
        accumulated-earnings: uint
    }
)

;; Track total registered songs
(define-data-var registered-song-count uint u0)

;; Track contract administrator
(define-data-var contract-administrator principal tx-sender)

;; Read-only functions
(define-read-only (get-song-information (song-identifier uint))
    (map-get? RegisteredSongs { song-identifier: song-identifier })
)

(define-read-only (get-royalty-distribution (song-identifier uint) (royalty-recipient principal))
    (map-get? RoyaltyDistribution { song-identifier: song-identifier, royalty-recipient: royalty-recipient })
)

(define-read-only (get-total-registered-songs)
    (var-get registered-song-count)
)

;; Get royalty shares for a song
(define-read-only (get-royalty-shares-by-song (song-identifier uint))
    (let (
        (song-info (get-song-information song-identifier))
        (primary-artist (match song-info record (get primary-artist record) tx-sender))
    )
    (let ((distribution (get-royalty-distribution song-identifier primary-artist)))
        (match distribution share
            (list {
                royalty-recipient: primary-artist,
                royalty-percentage: (get royalty-percentage share)
            })
            (list))))
)

;; Helper functions for input validation
(define-private (is-valid-royalty-share (share {
    royalty-percentage: uint,
    participant-role: (string-ascii 20),
    accumulated-earnings: uint
}))
    (> (get royalty-percentage share) u0)
)

(define-private (verify-contract-administrator)
    (is-eq tx-sender (var-get contract-administrator))
)

(define-private (validate-royalty-percentage (royalty-percentage uint))
    (and (>= royalty-percentage u0) (<= royalty-percentage u100))
)

(define-private (validate-string-ascii (input (string-ascii 50)))
    (let ((length (len input)))
        (and (> length u0) (<= length u50))))

(define-private (validate-participant-role (role (string-ascii 20)))
    (let ((length (len role)))
        (and (> length u0) (<= length u20))))

(define-private (validate-principal (principal-to-check principal))
    (and 
        (not (is-eq principal-to-check tx-sender))  ;; Can't be the sender
        (not (is-eq principal-to-check (var-get contract-administrator)))  ;; Can't be the admin
    ))

;; Fixed process-royalty-share function
(define-private (process-royalty-share
    (share {royalty-recipient: principal, royalty-percentage: uint}) 
    (payment-amount uint))
    (let (
        (recipient-payment-amount (/ (* payment-amount (get royalty-percentage share)) u100))
    )
    (if (> recipient-payment-amount u0)
        (match (stx-transfer? recipient-payment-amount tx-sender (get royalty-recipient share))
            success payment-amount
            error u0)
        u0))
)
