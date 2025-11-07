(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-PROJECT-NOT-FOUND (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-USER-NOT-FOUND (err u104))
(define-constant ERR-ALREADY-VERIFIED (err u105))
(define-constant ERR-INVALID-DATA (err u106))
(define-constant ERR-PROJECT-COMPLETED (err u107))
(define-constant ERR-INVALID-LOCATION (err u108))
(define-constant ERR-MEASUREMENT-NOT-FOUND (err u109))

(define-data-var contract-owner principal tx-sender)
(define-data-var total-ocean-cleaned uint u0)
(define-data-var total-projects uint u0)
(define-data-var conservation-fund uint u0)
(define-data-var platform-fee-rate uint u300)

(define-map users principal {
    ocean-tokens: uint,
    projects-created: uint,
    total-impact-score: uint,
    verification-level: uint,
    joined-at: uint,
    reputation: uint
})

(define-map conservation-projects uint {
    creator: principal,
    name: (string-ascii 100),
    project-type: (string-ascii 50),
    location: (string-ascii 100),
    description: (string-ascii 500),
    target-cleanup: uint,
    current-cleanup: uint,
    funding-goal: uint,
    funds-raised: uint,
    verified: bool,
    created-at: uint,
    status: (string-ascii 20)
})

(define-map project-verifications { project-id: uint, verifier: principal } {
    verified-at: uint,
    cleanup-confirmed: uint,
    verification-notes: (string-ascii 200)
})

(define-map cleanup-measurements uint {
    project-id: uint,
    measurer: principal,
    waste-type: (string-ascii 50),
    amount-collected: uint,
    measurement-date: uint,
    location-data: (string-ascii 100),
    verified: bool
})

(define-map marine-species uint {
    species-name: (string-ascii 100),
    population-count: uint,
    conservation-status: (string-ascii 50),
    habitat-location: (string-ascii 100),
    last-updated: uint,
    reporter: principal
})

(define-map ocean-transactions uint {
    from: principal,
    to: principal,
    amount: uint,
    transaction-type: (string-ascii 30),
    project-id: uint,
    timestamp: uint
})

(define-map project-funding { project-id: uint, funder: principal } {
    amount-funded: uint,
    funding-date: uint,
    reward-tokens: uint
})

(define-data-var next-project-id uint u1)
(define-data-var next-measurement-id uint u1)
(define-data-var next-species-id uint u1)
(define-data-var next-transaction-id uint u1)

(define-public (register-user (verification-level uint))
    (let ((caller tx-sender))
        (if (is-some (map-get? users caller))
            (err u100)
            (begin
                (map-set users caller {
                    ocean-tokens: u0,
                    projects-created: u0,
                    total-impact-score: u0,
                    verification-level: verification-level,
                    joined-at: stacks-block-height,
                    reputation: u100
                })
                (ok true)))))

(define-public (create-conservation-project (name (string-ascii 100)) (project-type (string-ascii 50)) (location (string-ascii 100)) (description (string-ascii 500)) (target-cleanup uint) (funding-goal uint))
    (let ((project-id (var-get next-project-id))
          (caller tx-sender)
          (user-data (unwrap! (map-get? users caller) ERR-USER-NOT-FOUND)))
        (if (or (< target-cleanup u1) (< funding-goal u1))
            ERR-INVALID-AMOUNT
            (begin
                (map-set conservation-projects project-id {
                    creator: caller,
                    name: name,
                    project-type: project-type,
                    location: location,
                    description: description,
                    target-cleanup: target-cleanup,
                    current-cleanup: u0,
                    funding-goal: funding-goal,
                    funds-raised: u0,
                    verified: false,
                    created-at: stacks-block-height,
                    status: "active"
                })
                (map-set users caller {
                    ocean-tokens: (get ocean-tokens user-data),
                    projects-created: (+ (get projects-created user-data) u1),
                    total-impact-score: (get total-impact-score user-data),
                    verification-level: (get verification-level user-data),
                    joined-at: (get joined-at user-data),
                    reputation: (+ (get reputation user-data) u10)
                })
                (var-set total-projects (+ (var-get total-projects) u1))
                (var-set next-project-id (+ project-id u1))
                (ok project-id)))))

(define-public (record-cleanup-measurement (project-id uint) (waste-type (string-ascii 50)) (amount-collected uint) (location-data (string-ascii 100)))
    (let ((measurement-id (var-get next-measurement-id))
          (caller tx-sender)
          (project-data (unwrap! (map-get? conservation-projects project-id) ERR-PROJECT-NOT-FOUND)))
        (if (not (is-eq caller (get creator project-data)))
            ERR-NOT-AUTHORIZED
            (if (< amount-collected u1)
                ERR-INVALID-AMOUNT
                (begin
                    (map-set cleanup-measurements measurement-id {
                        project-id: project-id,
                        measurer: caller,
                        waste-type: waste-type,
                        amount-collected: amount-collected,
                        measurement-date: stacks-block-height,
                        location-data: location-data,
                        verified: false
                    })
                    (var-set next-measurement-id (+ measurement-id u1))
                    (ok measurement-id))))))

(define-public (verify-project (project-id uint) (cleanup-confirmed uint) (verification-notes (string-ascii 200)))
    (let ((caller tx-sender)
          (project-data (unwrap! (map-get? conservation-projects project-id) ERR-PROJECT-NOT-FOUND))
          (user-data (unwrap! (map-get? users caller) ERR-USER-NOT-FOUND)))
        (if (< (get verification-level user-data) u1)
            ERR-NOT-AUTHORIZED
            (if (is-some (map-get? project-verifications { project-id: project-id, verifier: caller }))
                ERR-ALREADY-VERIFIED
                (begin
                    (map-set project-verifications { project-id: project-id, verifier: caller } {
                        verified-at: stacks-block-height,
                        cleanup-confirmed: cleanup-confirmed,
                        verification-notes: verification-notes
                    })
                    (map-set conservation-projects project-id {
                        creator: (get creator project-data),
                        name: (get name project-data),
                        project-type: (get project-type project-data),
                        location: (get location project-data),
                        description: (get description project-data),
                        target-cleanup: (get target-cleanup project-data),
                        current-cleanup: (+ (get current-cleanup project-data) cleanup-confirmed),
                        funding-goal: (get funding-goal project-data),
                        funds-raised: (get funds-raised project-data),
                        verified: true,
                        created-at: (get created-at project-data),
                        status: (get status project-data)
                    })
                    (map-set users caller {
                        ocean-tokens: (get ocean-tokens user-data),
                        projects-created: (get projects-created user-data),
                        total-impact-score: (get total-impact-score user-data),
                        verification-level: (get verification-level user-data),
                        joined-at: (get joined-at user-data),
                        reputation: (+ (get reputation user-data) u5)
                    })
                    (var-set total-ocean-cleaned (+ (var-get total-ocean-cleaned) cleanup-confirmed))
                    (ok true))))))

(define-public (fund-project (project-id uint) (amount uint))
    (let ((caller tx-sender)
          (project-data (unwrap! (map-get? conservation-projects project-id) ERR-PROJECT-NOT-FOUND))
          (funder-data (unwrap! (map-get? users caller) ERR-USER-NOT-FOUND))
          (creator-data (unwrap! (map-get? users (get creator project-data)) ERR-USER-NOT-FOUND)))
        (if (< amount u1)
            ERR-INVALID-AMOUNT
            (let ((platform-fee (/ (* amount (var-get platform-fee-rate)) u10000))
                  (project-amount (- amount platform-fee))
                  (reward-tokens (/ (* amount u150) u100)))
                (map-set project-funding { project-id: project-id, funder: caller } {
                    amount-funded: amount,
                    funding-date: stacks-block-height,
                    reward-tokens: reward-tokens
                })
                (map-set conservation-projects project-id {
                    creator: (get creator project-data),
                    name: (get name project-data),
                    project-type: (get project-type project-data),
                    location: (get location project-data),
                    description: (get description project-data),
                    target-cleanup: (get target-cleanup project-data),
                    current-cleanup: (get current-cleanup project-data),
                    funding-goal: (get funding-goal project-data),
                    funds-raised: (+ (get funds-raised project-data) project-amount),
                    verified: (get verified project-data),
                    created-at: (get created-at project-data),
                    status: (get status project-data)
                })
                (map-set users caller {
                    ocean-tokens: (+ (get ocean-tokens funder-data) reward-tokens),
                    projects-created: (get projects-created funder-data),
                    total-impact-score: (+ (get total-impact-score funder-data) (/ amount u100)),
                    verification-level: (get verification-level funder-data),
                    joined-at: (get joined-at funder-data),
                    reputation: (+ (get reputation funder-data) u3)
                })
                (map-set users (get creator project-data) {
                    ocean-tokens: (+ (get ocean-tokens creator-data) (/ project-amount u10)),
                    projects-created: (get projects-created creator-data),
                    total-impact-score: (+ (get total-impact-score creator-data) (/ project-amount u50)),
                    verification-level: (get verification-level creator-data),
                    joined-at: (get joined-at creator-data),
                    reputation: (+ (get reputation creator-data) u5)
                })
                (var-set conservation-fund (+ (var-get conservation-fund) platform-fee))
                (ok reward-tokens)))))

(define-public (register-marine-species (species-name (string-ascii 100)) (population-count uint) (conservation-status (string-ascii 50)) (habitat-location (string-ascii 100)))
    (let ((species-id (var-get next-species-id))
          (caller tx-sender)
          (user-data (unwrap! (map-get? users caller) ERR-USER-NOT-FOUND)))
        (if (< population-count u0)
            ERR-INVALID-DATA
            (begin
                (map-set marine-species species-id {
                    species-name: species-name,
                    population-count: population-count,
                    conservation-status: conservation-status,
                    habitat-location: habitat-location,
                    last-updated: stacks-block-height,
                    reporter: caller
                })
                (map-set users caller {
                    ocean-tokens: (+ (get ocean-tokens user-data) u50),
                    projects-created: (get projects-created user-data),
                    total-impact-score: (+ (get total-impact-score user-data) u25),
                    verification-level: (get verification-level user-data),
                    joined-at: (get joined-at user-data),
                    reputation: (+ (get reputation user-data) u3)
                })
                (var-set next-species-id (+ species-id u1))
                (ok species-id)))))

(define-public (transfer-ocean-tokens (recipient principal) (amount uint))
    (let ((caller tx-sender)
          (sender-data (unwrap! (map-get? users caller) ERR-USER-NOT-FOUND))
          (recipient-data (unwrap! (map-get? users recipient) ERR-USER-NOT-FOUND))
          (transaction-id (var-get next-transaction-id)))
        (if (< amount u1)
            ERR-INVALID-AMOUNT
            (if (< (get ocean-tokens sender-data) amount)
                ERR-INSUFFICIENT-FUNDS
                (begin
                    (map-set users caller {
                        ocean-tokens: (- (get ocean-tokens sender-data) amount),
                        projects-created: (get projects-created sender-data),
                        total-impact-score: (get total-impact-score sender-data),
                        verification-level: (get verification-level sender-data),
                        joined-at: (get joined-at sender-data),
                        reputation: (get reputation sender-data)
                    })
                    (map-set users recipient {
                        ocean-tokens: (+ (get ocean-tokens recipient-data) amount),
                        projects-created: (get projects-created recipient-data),
                        total-impact-score: (get total-impact-score recipient-data),
                        verification-level: (get verification-level recipient-data),
                        joined-at: (get joined-at recipient-data),
                        reputation: (+ (get reputation recipient-data) u1)
                    })
                    (map-set ocean-transactions transaction-id {
                        from: caller,
                        to: recipient,
                        amount: amount,
                        transaction-type: "transfer",
                        project-id: u0,
                        timestamp: stacks-block-height
                    })
                    (var-set next-transaction-id (+ transaction-id u1))
                    (ok transaction-id))))))

(define-public (complete-project (project-id uint))
    (let ((caller tx-sender)
          (project-data (unwrap! (map-get? conservation-projects project-id) ERR-PROJECT-NOT-FOUND))
          (creator-data (unwrap! (map-get? users (get creator project-data)) ERR-USER-NOT-FOUND)))
        (if (not (is-eq caller (get creator project-data)))
            ERR-NOT-AUTHORIZED
            (if (>= (get current-cleanup project-data) (get target-cleanup project-data))
                (let ((completion-bonus (/ (get target-cleanup project-data) u10)))
                    (map-set conservation-projects project-id {
                        creator: (get creator project-data),
                        name: (get name project-data),
                        project-type: (get project-type project-data),
                        location: (get location project-data),
                        description: (get description project-data),
                        target-cleanup: (get target-cleanup project-data),
                        current-cleanup: (get current-cleanup project-data),
                        funding-goal: (get funding-goal project-data),
                        funds-raised: (get funds-raised project-data),
                        verified: (get verified project-data),
                        created-at: (get created-at project-data),
                        status: "completed"
                    })
                    (map-set users (get creator project-data) {
                        ocean-tokens: (+ (get ocean-tokens creator-data) completion-bonus),
                        projects-created: (get projects-created creator-data),
                        total-impact-score: (+ (get total-impact-score creator-data) (* completion-bonus u2)),
                        verification-level: (get verification-level creator-data),
                        joined-at: (get joined-at creator-data),
                        reputation: (+ (get reputation creator-data) u20)
                    })
                    (ok completion-bonus))
                (err u106)))))

(define-public (update-species-population (species-id uint) (new-population uint))
    (let ((caller tx-sender)
          (species-data (unwrap! (map-get? marine-species species-id) ERR-MEASUREMENT-NOT-FOUND))
          (user-data (unwrap! (map-get? users caller) ERR-USER-NOT-FOUND)))
        (if (< (get verification-level user-data) u1)
            ERR-NOT-AUTHORIZED
            (begin
                (map-set marine-species species-id {
                    species-name: (get species-name species-data),
                    population-count: new-population,
                    conservation-status: (get conservation-status species-data),
                    habitat-location: (get habitat-location species-data),
                    last-updated: stacks-block-height,
                    reporter: caller
                })
                (map-set users caller {
                    ocean-tokens: (+ (get ocean-tokens user-data) u25),
                    projects-created: (get projects-created user-data),
                    total-impact-score: (+ (get total-impact-score user-data) u10),
                    verification-level: (get verification-level user-data),
                    joined-at: (get joined-at user-data),
                    reputation: (+ (get reputation user-data) u2)
                })
                (ok true)))))

(define-read-only (get-user-data (user principal))
    (map-get? users user))

(define-read-only (get-project-data (project-id uint))
    (map-get? conservation-projects project-id))

(define-read-only (get-measurement-data (measurement-id uint))
    (map-get? cleanup-measurements measurement-id))

(define-read-only (get-species-data (species-id uint))
    (map-get? marine-species species-id))

(define-read-only (get-transaction-data (transaction-id uint))
    (map-get? ocean-transactions transaction-id))

(define-read-only (get-project-verification (project-id uint) (verifier principal))
    (map-get? project-verifications { project-id: project-id, verifier: verifier }))

(define-read-only (get-project-funding (project-id uint) (funder principal))
    (map-get? project-funding { project-id: project-id, funder: funder }))

(define-read-only (get-platform-stats)
    {
        total-ocean-cleaned: (var-get total-ocean-cleaned),
        total-projects: (var-get total-projects),
        conservation-fund: (var-get conservation-fund),
        platform-fee-rate: (var-get platform-fee-rate),
        next-project-id: (var-get next-project-id),
        next-measurement-id: (var-get next-measurement-id),
        next-species-id: (var-get next-species-id)
    })

(define-read-only (calculate-project-progress (project-id uint))
    (let ((project-data (unwrap! (map-get? conservation-projects project-id) (err u0))))
        (if (> (get target-cleanup project-data) u0)
            (ok (/ (* (get current-cleanup project-data) u100) (get target-cleanup project-data)))
            (ok u0))))

(define-read-only (get-user-token-balance (user principal))
    (match (map-get? users user)
        user-data (ok (get ocean-tokens user-data))
        ERR-USER-NOT-FOUND))

(define-public (update-platform-fee (new-rate uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (asserts! (<= new-rate u1000) ERR-INVALID-AMOUNT)
        (var-set platform-fee-rate new-rate)
        (ok true)))

(define-public (withdraw-conservation-fund (amount uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (asserts! (<= amount (var-get conservation-fund)) ERR-INSUFFICIENT-FUNDS)
        (var-set conservation-fund (- (var-get conservation-fund) amount))
        (ok true)))